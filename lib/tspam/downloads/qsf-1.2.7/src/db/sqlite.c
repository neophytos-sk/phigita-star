/*
 * Make our db functions a wrapper for SQLite.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include "log.h"

#ifdef USING_SQLITE

#undef DEBUG_SQLITE

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <sqlite.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif
#include <unistd.h>

struct qdbint_s {
	int fd;
	sqlite *db;			 /* SQLite database object */
	int have_value3;		 /* flag, set if value3 column exists */
	int locked;			 /* flag, set if database locked */
	int compiled;			 /* flag, set if a zSQL VM has been compiled */
	const char *ztail;		 /* current compiled zSQL tail */
	sqlite_vm *vm;			 /* current VM for zSQL execution */
	int readonly;			 /* flag, set if this database is readonly */
};

static char qdb_sqlite__errstr[4096] = { 0, };
static char *qdb_sqlite__errptr = 0;



#if DEBUG_SQLITE
/*
 * Debugging function to output every SQL statement passed to SQLite.
 */
static void qdb_sqlite__debug(void *ptr, const char *str)
{
	printf("[%s]\n", str);
}
#endif


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_sqlite_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	return db->fd;
}


/*
 * Temporarily release the lock on the database.
 */
void qdb_sqlite_unlock(qdbint_t db)
{
	if (db == NULL)
		return;

	if (!db->locked)
		return;

	/*
	 * We "unlock" by ending the current transaction.
	 */

	sqlite_exec(db->db, "COMMIT", NULL, NULL, &qdb_sqlite__errptr);
	if (qdb_sqlite__errptr) {
		sqlite_freemem(qdb_sqlite__errptr);
		qdb_sqlite__errptr = 0;
	}

	db->locked = 0;
}


/*
 * Reassert the lock on the database.
 */
void qdb_sqlite_relock(qdbint_t db)
{
	int tries, ret;

	if (db == NULL)
		return;

	if (db->locked)
		return;

	/*
	 * We "lock" by starting a new transaction.
	 */

	for (tries = 0; tries < 60 && !db->locked; tries++) {
		ret =
		    sqlite_exec(db->db, "BEGIN", NULL, NULL,
				&qdb_sqlite__errptr);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		switch (ret) {
		case SQLITE_OK:
			db->locked = 1;
			break;
		case SQLITE_BUSY:
			sleep(1);
			break;
		default:
			break;
		}
	}
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_sqlite_identify(const char *file)
{
	FILE *fptr;
	unsigned char buf[64];		 /* RATS: ignore (checked) */

	if (file == NULL)
		return 0;
	if (strncasecmp(file, "sqlite:", 7) == 0)
		return 1;
	if (strncasecmp(file, "sqlite2:", 8) == 0)
		return 1;

	fptr = fopen(file, "rb");
	if (fptr == NULL)
		return 0;
	if (fread(buf, 33, 1, fptr) < 1) {
		fclose(fptr);
		return 0;
	}

	fclose(fptr);

	if (strncmp((char *) buf, "** This file contains an SQLite 2", 33)
	    == 0)
		return 1;

	return 0;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_sqlite_open(const char *file, qdb_open_t method)
{
	qdbint_t db;
	char **results;
	int rows, cols;

	if (strncasecmp(file, "sqlite:", 7) == 0)
		file += 7;
	if (strncasecmp(file, "sqlite2:", 8) == 0)
		file += 8;

	db = calloc(1, sizeof(*db));
	if (db == NULL) {
		sprintf(qdb_sqlite__errstr, "%.999s", strerror(errno));
		return NULL;
	}

	db->fd = -1;
	db->readonly = (method == QDB_READONLY ? 1 : 0);
	db->have_value3 = 1;

	/*
	 * If we need write access, and the file exists, check we can
	 * physically write to the file first, since sqlite_open() seems not
	 * to care.
	 */
	if (!db->readonly) {
		db->fd = open(file, O_RDWR);
		if (db->fd < 0) {
			if (errno != ENOENT) {
				sprintf(qdb_sqlite__errstr, "%.999s",
					strerror(errno));
				free(db);
				return NULL;
			}
		}
	}

	db->db = sqlite_open(file, 0, &qdb_sqlite__errptr);
	if (db->db == NULL) {
		sprintf(qdb_sqlite__errstr, "%.999s",
			qdb_sqlite__errptr ? qdb_sqlite__errptr : "");
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		free(db);
		return NULL;
	}

	if (method != QDB_READONLY) {
		/*
		 * We deliberately ignore errors at this point, in case the
		 * database table has already been created.
		 */
		sqlite_exec(db->db, "CREATE TABLE qsf ("
			    " token CHAR(64) NOT NULL PRIMARY KEY,"
			    " value1 INT UNSIGNED NOT NULL,"
			    " value2 INT UNSIGNED NOT NULL,"
			    " value3 INT UNSIGNED NOT NULL"
			    " )", NULL, NULL, &qdb_sqlite__errptr);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}

		qdb_sqlite_relock(db);
	}
#if DEBUG_SQLITE
	sqlite_trace(db->db, qdb_sqlite__debug, NULL);
#endif

	if (sqlite_get_table
	    (db->db, "SELECT value3 FROM qsf LIMIT 0,1", &results, &rows,
	     &cols, &qdb_sqlite__errptr) != 0) {
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		db->have_value3 = 0;
		log_add(1, "%s",
			_("warning: old-style 2-value SQLite table"));
	} else {
		sqlite_free_table(results);
	}

	db->fd = open(file, O_RDONLY);

	return db;
}


/*
 * Close the given database.
 */
void qdb_sqlite_close(qdbint_t db)
{
	if (db == NULL)
		return;
	if (db->compiled) {
		sqlite_finalize(db->vm, &qdb_sqlite__errptr);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
	}
	qdb_sqlite_unlock(db);
	if (db->fd >= 0)
		close(db->fd);
	sqlite_close(db->db);
	free(db);
}


/*
 * Construct a database query string, replacing any ? characters with an
 * escaped quoted (') copy of the next string in the argument list. Each
 * string should be given as a (long) length, not including any terminating
 * \0, and the char * pointer to the string.
 *
 * Returns a null-terminated string that needs free()ing after use, or NULL
 * on error.
 */
char *qdb_sqlite__query(char *format, ...)
{
	char *buf;
	long len, offs;
	va_list ap;
	int i;
	long paramlen;
	char *param;

	va_start(ap, format);

	len = 0;

	for (i = 0; format[i] != 0; i++) {
		if (format[i] == '?') {
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			len += (paramlen * 3) + 2;
		} else {
			len++;
		}
	}

	va_end(ap);

	len += 2;

	buf = malloc(len);
	if (buf == NULL) {
		return NULL;
	}

	offs = 0;

	va_start(ap, format);

	for (i = 0; format[i] != 0; i++) {
		if (format[i] == '?') {
			int j;
			buf[offs++] = '\'';
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			for (j = 0; j < paramlen; j++) {
				int c;
				c = param[j];
				if (c == '\'') {
					buf[offs++] = '\'';
				}
				buf[offs++] = c;
			}
			buf[offs++] = '\'';
		} else {
			buf[offs++] = format[i];
		}
	}
	buf[offs++] = 0;

	va_end(ap);

	return buf;
}


/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_sqlite_fetch(qdbint_t db, qdb_datum key)
{
	qdb_datum val;
	char *sql;
	char **results;
	int rows, cols;
	long val1, val2, val3;
	long *data;

	val.data = NULL;
	val.size = 0;

	if (db == NULL)
		return val;

	if (key.data == NULL)
		return val;

	if (db->have_value3) {
		sql =
		    qdb_sqlite__query
		    ("SELECT value1,value2,value3 FROM qsf "
		     "WHERE token=?", (long) (key.size),
		     (char *) (key.data));
	} else {
		sql = qdb_sqlite__query("SELECT value1,value2 FROM qsf "
					"WHERE token=?",
					(long) (key.size),
					(char *) (key.data));
	}

	if (sql == NULL)
		return val;

	if (sqlite_get_table
	    (db->db, sql, &results, &rows, &cols,
	     &qdb_sqlite__errptr) != 0) {
		sprintf(qdb_sqlite__errstr, "%.999s",
			qdb_sqlite__errptr ? qdb_sqlite__errptr : "");
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		free(sql);
		return val;
	}

	free(sql);

	if ((cols < 2) || (rows != 1)) {
		sqlite_free_table(results);
		return val;
	}

	if (db->have_value3) {
		val1 = strtol(results[3], NULL, 10);
		val2 = strtol(results[4], NULL, 10);
		val3 = strtol(results[5], NULL, 10);
	} else {
		val1 = strtol(results[2], NULL, 10);
		val2 = strtol(results[3], NULL, 10);
		val3 = 0;
	}

	sqlite_free_table(results);

	data = malloc(3 * sizeof(long));
	if (data == NULL) {
		sprintf(qdb_sqlite__errstr, "%.999s", strerror(errno));
		return val;
	}

	data[0] = val1;
	data[1] = val2;
	data[2] = val3;
	val.data = (unsigned char *) data;
	val.size = 3 * sizeof(long);

	return val;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_sqlite_store(qdbint_t db, qdb_datum key, qdb_datum val)
{
	long *data;
	char val1[128];			 /* RATS: ignore (checked) */
	char val2[128];			 /* RATS: ignore (checked) */
	char val3[128];			 /* RATS: ignore (checked) */
	char *sql;

	if (db == NULL)
		return 1;

	if ((key.data == NULL) || (val.data == NULL))
		return 1;

	if (db->readonly)
		return 1;

	data = (long *) (val.data);

#ifdef HAVE_SNPRINTF
	snprintf(val1, sizeof(val1) - 1,    /* RATS: ignore (OK) */
		 "%ld", data[0]);
	snprintf(val2, sizeof(val2) - 1,    /* RATS: ignore (OK) */
		 "%ld", data[1]);
	snprintf(val3, sizeof(val3) - 1,    /* RATS: ignore (OK) */
		 "%ld", data[2]);
#else
	sprintf(val1, "%ld", data[0]);
	sprintf(val2, "%ld", data[1]);
	sprintf(val3, "%ld", data[2]);
#endif

	val1[sizeof(val1) - 1] = 0;
	val2[sizeof(val2) - 1] = 0;
	val3[sizeof(val3) - 1] = 0;

	if (db->have_value3) {
		sql =
		    qdb_sqlite__query
		    ("INSERT INTO qsf (token,value1,value2,value3) "
		     "VALUES (?,?,?,?)", (long) (key.size),
		     (char *) (key.data), (long) (strlen(val1)), val1,
		     (long) (strlen(val2)), val2, (long) (strlen(val3)),
		     val3);
	} else {
		sql =
		    qdb_sqlite__query
		    ("INSERT INTO qsf (token,value1,value2) "
		     "VALUES (?,?,?)", (long) (key.size),
		     (char *) (key.data), (long) (strlen(val1)), val1,
		     (long) (strlen(val2)), val2);
	}

	if (sql == NULL)
		return 1;

	if (sqlite_exec(db->db, sql, NULL, NULL, &qdb_sqlite__errptr) != 0) {
		free(sql);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		if (db->have_value3) {
			sql = qdb_sqlite__query("UPDATE qsf "
						"SET value1=?,value2=?,value3=? "
						"WHERE token=?",
						(long) (strlen(val1)),
						val1,
						(long) (strlen(val2)),
						val2,
						(long) (strlen(val3)),
						val3, (long) (key.size),
						(char *) (key.data));
		} else {
			sql = qdb_sqlite__query("UPDATE qsf "
						"SET value1=?,value2=? "
						"WHERE token=?",
						(long) (strlen(val1)),
						val1,
						(long) (strlen(val2)),
						val2, (long) (key.size),
						(char *) (key.data));
		}
		if (sql == NULL)
			return 1;
		if (sqlite_exec
		    (db->db, sql, NULL, NULL, &qdb_sqlite__errptr) != 0) {
			free(sql);
			sprintf(qdb_sqlite__errstr, "%.999s",
				qdb_sqlite__errptr ? qdb_sqlite__errptr :
				"");
			if (qdb_sqlite__errptr) {
				sqlite_freemem(qdb_sqlite__errptr);
				qdb_sqlite__errptr = 0;
			}
			return 1;
		}
	}

	free(sql);

	return 0;
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_sqlite_delete(qdbint_t db, qdb_datum key)
{
	char *sql;

	if (db == NULL)
		return 1;

	if (key.data == NULL)
		return 1;

	if (db->readonly)
		return 1;

	sql = qdb_sqlite__query("DELETE FROM qsf WHERE token=?",
				(long) (key.size), (char *) (key.data));
	if (sql == NULL)
		return 1;

	if (sqlite_exec(db->db, sql, NULL, NULL, &qdb_sqlite__errptr) != 0) {
		free(sql);
		sprintf(qdb_sqlite__errstr, "%.999s",
			qdb_sqlite__errptr ? qdb_sqlite__errptr : "");
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		return 1;
	}

	free(sql);

	return 0;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_sqlite_nextkey(qdbint_t db, qdb_datum key)
{
	qdb_datum newkey;
	char **values;
	char **colnames;
	char *token;
	int ret, n;

	newkey.data = NULL;
	newkey.size = 0;

	if (!db->compiled)
		return newkey;

	ret =
	    sqlite_step(db->vm, &n, (const char ***) (&values),
			(const char ***) (&colnames));
	if (ret != SQLITE_ROW) {
		sqlite_finalize(db->vm, &qdb_sqlite__errptr);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		db->compiled = 0;
		return newkey;
	}

	token = values[0];

	newkey.data = (unsigned char *) calloc(1, 1 + strlen(token));
	if (newkey.data == NULL) {
		sprintf(qdb_sqlite__errstr, "%.999s", strerror(errno));
		return newkey;
	}

	newkey.size = strlen(token);
	strncpy((char *) (newkey.data), token, newkey.size);

	return newkey;
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_sqlite_firstkey(qdbint_t db)
{
	qdb_datum blankkey;

	blankkey.data = NULL;
	blankkey.size = 0;

	if (db->compiled) {
		sqlite_finalize(db->vm, &qdb_sqlite__errptr);
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
	}

	db->compiled = 0;

	if (sqlite_compile
	    (db->db, "SELECT token FROM qsf ORDER BY token", &(db->ztail),
	     &(db->vm), &qdb_sqlite__errptr) != 0) {
		sprintf(qdb_sqlite__errstr, "%.999s",
			qdb_sqlite__errptr ? qdb_sqlite__errptr : "");
		if (qdb_sqlite__errptr) {
			sqlite_freemem(qdb_sqlite__errptr);
			qdb_sqlite__errptr = 0;
		}
		return blankkey;
	}

	db->compiled = 1;

	return qdb_sqlite_nextkey(db, blankkey);
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_sqlite_error(void)
{
	return qdb_sqlite__errstr;
}

#endif				/* USING_SQLITE */

/* EOF */
