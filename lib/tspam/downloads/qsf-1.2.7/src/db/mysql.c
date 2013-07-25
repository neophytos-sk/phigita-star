/*
 * Make our db functions a wrapper for MySQL.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include "log.h"

#ifdef USING_MYSQL

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif
#include <unistd.h>
#include <mysql.h>

struct qdbint_s {
	int fd;
	MYSQL *db;
	int readonly;
	int have_value3;
	char table[64];			 /* RATS: ignore (checked all) */
	char key1[256];			 /* RATS: ignore (checked all) */
	char key2[256];			 /* RATS: ignore (checked all) */
	MYSQL_RES *results;
};

static char qdb_mysql__errstr[4096] = { 0, };	/* RATS: ignore (bounded OK) */




/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_mysql_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	return db->fd;
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_mysql_identify(const char *file)
{
	FILE *fptr;
	char string[4096] = { 0, };	    /* RATS: ignore (checked all) */
	char host[256];			 /* RATS: ignore (checked all) */
	char user[64];			 /* RATS: ignore (checked all) */
	char pass[64];			 /* RATS: ignore (checked all) */
	char database[64];		 /* RATS: ignore (checked all) */
	char table[64];			 /* RATS: ignore (checked all) */
	char key1[256];			 /* RATS: ignore (checked all) */
	char key2[256];			 /* RATS: ignore (checked all) */
	unsigned int port;

	if (file == NULL)
		return 0;
	if (strncasecmp(file, "mysql:", 6) == 0)
		return 1;

	fptr = fopen(file, "r");
	if (!fptr) {
		sprintf(string, "%.*s", (int) (sizeof(string) - 1), file);
	} else {
		if (fread(string, 1, sizeof(string) - 1, fptr) < 1) {
			log_add(0, "%s: read failed: %s", file,
				strerror(errno));
		}
		fclose(fptr);
	}

	string[sizeof(string) - 1] = 0;

	if (sscanf(string, "database=%63[^;];"
		   "host=%255[^;];"
		   "port=%u;"
		   "user=%63[^;];"
		   "pass=%63[^;];"
		   "table=%63[^;];"
		   "key1=%255[^;];"
		   "key2=%255[^;]",
		   database,
		   host, &port, user, pass, table, key1, key2) == 8)
		return 1;

	if (sscanf(string, "database=%63[^;];"
		   "host=%255[^;];"
		   "port=%u;"
		   "user=%63[^;];"
		   "pass=;"
		   "table=%63[^;];"
		   "key1=%255[^;];"
		   "key2=%255[^;]",
		   database, host, &port, user, table, key1, key2) == 7)
		return 1;

	return 0;
}


/*
 * Initiate a database query, replacing any ? characters with an escaped
 * quoted (') copy of the next string in the argument list, and replacing
 * any ! characters with a similarly escaped string but quoted with
 * backquotes (`). Each string should be given as a (long) length, not
 * including any terminating \0, and the char * pointer to the string.
 *
 * Returns nonzero on error.
 */
int qdb_mysql__query(qdbint_t db, char *format, ...)
{
	char *buf;
	long len, offs;
	va_list ap;
	int i, ret;
	long paramlen;
	char *param;

	va_start(ap, format);

	len = 0;

	for (i = 0; format[i] != 0; i++) {
		if (format[i] == '?') {
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			len += (paramlen * 3) + 2;
		} else if (format[i] == '!') {
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			len += (paramlen * 3) + 2;
		} else {
			len++;
		}
	}

	va_end(ap);

	len++;

	buf = malloc(len);
	if (buf == NULL) {
		return 1;
	}

	offs = 0;

	va_start(ap, format);

	for (i = 0; format[i] != 0; i++) {
		if (format[i] == '?') {
			buf[offs++] = '\'';
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			offs +=
			    mysql_real_escape_string(db->db,
						     buf + offs, param,
						     paramlen);
			buf[offs++] = '\'';
		} else if (format[i] == '!') {
			buf[offs++] = '`';
			paramlen = va_arg(ap, long);
			param = va_arg(ap, char *);
			offs +=
			    mysql_real_escape_string(db->db,
						     buf + offs, param,
						     paramlen);
			buf[offs++] = '`';
		} else {
			buf[offs++] = format[i];
		}
	}

	va_end(ap);

	ret = mysql_real_query(db->db, buf, offs);

	free(buf);

	return ret;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_mysql_open(const char *file, qdb_open_t method)
{
	char host[256];			 /* RATS: ignore (checked all) */
	char user[64];			 /* RATS: ignore (checked all) */
	char pass[64];			 /* RATS: ignore (checked all) */
	char database[64];		 /* RATS: ignore (checked all) */
	char table[64];			 /* RATS: ignore (checked all) */
	char key1[256];			 /* RATS: ignore (checked all) */
	char key2[256];			 /* RATS: ignore (checked all) */
	char string[4096] = { 0, };	    /* RATS: ignore (checked all) */
	unsigned int port;
	FILE *fptr;
	MYSQL *mdb;
	qdbint_t db;

	if (strncasecmp(file, "mysql:", 6) == 0)
		file += 6;

	mdb = mysql_init(NULL);
	if (mdb == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s",
			(int) (sizeof(qdb_mysql__errstr) - 1),
			_("mysql_init failed"));
		return NULL;
	}

	fptr = fopen(file, "r");	    /* RATS: ignore (no race) */
	if (!fptr) {
		sprintf(string, "%.*s", (int) (sizeof(string) - 1), file);
	} else {
		if (fread(string, 1, sizeof(string) - 1, fptr) < 1) {
			log_add(0, "%s: read failed: %s", file,
				strerror(errno));
		}
		fclose(fptr);
	}

	string[sizeof(string) - 1] = 0;

	pass[0] = 0;
	if (sscanf(string, "database=%63[^;];"
		   "host=%255[^;];"
		   "port=%u;"
		   "user=%63[^;];"
		   "pass=;"
		   "table=%63[^;];"
		   "key1=%255[^;];"
		   "key2=%255[^;]",
		   database, host, &port, user, table, key1, key2) < 7) {
		if (sscanf(string, "database=%63[^;];"
			   "host=%255[^;];"
			   "port=%u;"
			   "user=%63[^;];"
			   "pass=%63[^;];"
			   "table=%63[^;];"
			   "key1=%255[^;];"
			   "key2=%255[^;]",
			   database,
			   host, &port, user, pass, table, key1,
			   key2) < 8) {
			sprintf(qdb_mysql__errstr, "%.*s: %.100s",
				(int) (sizeof(qdb_mysql__errstr) - 110),
				_("invalid DB spec"), string);
			mysql_close(mdb);
			return NULL;
		}
	}

	/*
	 * Make sure all the strings we have just read are zero-terminated.
	 */
	database[sizeof(database) - 1] = 0;
	host[sizeof(host) - 1] = 0;
	user[sizeof(user) - 1] = 0;
	pass[sizeof(pass) - 1] = 0;
	table[sizeof(table) - 1] = 0;
	key1[sizeof(key1) - 1] = 0;
	key2[sizeof(key2) - 1] = 0;

	if (mysql_real_connect
	    (mdb, host, user, pass, database, port, NULL, 0) == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("mysql connect failed"), mysql_error(mdb));
		mysql_close(mdb);
		return NULL;
	}

	db = calloc(1, sizeof(*db));
	if (db == NULL) {
		sprintf(qdb_mysql__errstr, "%.999s", strerror(errno));
		mysql_close(mdb);
		return NULL;
	}

	db->fd = open(file, O_RDONLY);
	db->db = mdb;

	strncpy(db->table, table, sizeof(table) - 1);
	strncpy(db->key1, key1, sizeof(key1) - 1);
	strncpy(db->key2, key2, sizeof(key2) - 1);

	/*
	 * Make sure db->{table,key1,key2} are zero-terminated.
	 */
	db->table[sizeof(db->table) - 1] = 0;
	db->key1[sizeof(db->key1) - 1] = 0;
	db->key2[sizeof(db->key2) - 1] = 0;

	db->readonly = (method == QDB_READONLY ? 1 : 0);

	/*
	 * See whether the given table exists; if not, and we're not
	 * supposed to be in readonly mode, try to create it.
	 */
	if (!db->readonly) {
		if (qdb_mysql__query(db, "SELECT value1 FROM ! LIMIT 0,1",
				     (long) (strlen(db->table)),
				     db->table)) {
			if (qdb_mysql__query(db, "CREATE TABLE ! ("
					     "key1      BIGINT UNSIGNED NOT NULL, "
					     "key2      BIGINT UNSIGNED NOT NULL, "
					     "token     VARCHAR(64) DEFAULT '' NOT NULL, "
					     "value1    INT UNSIGNED NOT NULL, "
					     "value2    INT UNSIGNED NOT NULL, "
					     "value3    INT UNSIGNED NOT NULL, "
					     "PRIMARY KEY (key1,key2,token), "
					     "KEY (key1), "
					     "KEY (key2), "
					     "KEY (token) "
					     ")",
					     (long) (strlen(db->table)),
					     db->table) == 0) {
				MYSQL_RES *results;

				results = mysql_store_result(db->db);
				if (results)
					mysql_free_result(results);
				log_add(1, "%s: %s", db->table,
					_("table autocreated"));
			} else {
				log_add(1, "%s: %s", db->table,
					_("invalid table specified"));
			}
		} else {
			MYSQL_RES *results;

			results = mysql_store_result(db->db);
			if (results)
				mysql_free_result(results);
		}
	}

	db->have_value3 = 1;
	if (qdb_mysql__query(db, "SELECT value3 FROM ! LIMIT 0,1",
			     (long) (strlen(db->table)), db->table)) {
		db->have_value3 = 0;
		log_add(1, "%s",
			_("warning: old-style 2-value MySQL table"));
	} else {
		MYSQL_RES *results;

		results = mysql_store_result(db->db);
		if (results)
			mysql_free_result(results);
	}

	switch (method) {
	case QDB_NEW:
		/* fall-through */
	case QDB_READWRITE:
		break;
	case QDB_READONLY:
		break;
	default:
		break;
	}

#ifdef HAVE_MYSQL_AUTOCOMMIT
	mysql_autocommit(db->db, 0);
#endif

	db->results = NULL;

	return db;
}


/*
 * Close the given database.
 */
void qdb_mysql_close(qdbint_t db)
{
	if (db == NULL)
		return;
#ifdef HAVE_MYSQL_AUTOCOMMIT
	mysql_commit(db->db);
#endif
	if (db->fd >= 0)
		close(db->fd);
	mysql_close(db->db);
	free(db);
}


/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_mysql_fetch(qdbint_t db, qdb_datum key)
{
	qdb_datum val;
	char *sql;
	MYSQL_RES *results;
	MYSQL_ROW row;
	unsigned long *lengths;
	long *data;
	char buf[256];			 /* RATS: ignore (checked all) */

	val.data = NULL;
	val.size = 0;

	if (db == NULL)
		return val;

	if (key.data == NULL)
		return val;

	if (db->have_value3) {
		sql = "SELECT value1,value2,value3 FROM ! "
		    "WHERE key1 = ? " "AND key2 = ? " "AND token = ?";
	} else {
		sql = "SELECT value1,value2 FROM ! "
		    "WHERE key1 = ? " "AND key2 = ? " "AND token = ?";
	}

	if (qdb_mysql__query(db, sql,
			     (long) (strlen(db->table)), db->table,
			     (long) (strlen(db->key1)), db->key1,
			     (long) (strlen(db->key2)), db->key2,
			     (long) (key.size), (char *) (key.data))) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("query failed"), mysql_error(db->db));
		return val;
	}

	results = mysql_store_result(db->db);
	if (results == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("query failed on results store"),
			mysql_error(db->db));
		return val;
	}

	row = mysql_fetch_row(results);
	if (row == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("query failed on row fetch"),
			mysql_error(db->db));
		mysql_free_result(results);
		return val;
	}

	lengths = mysql_fetch_lengths(results);
	if (lengths == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("query failed on lengths fetch"),
			mysql_error(db->db));
		mysql_free_result(results);
		return val;
	}

	data = malloc(3 * sizeof(long));
	if (data == NULL) {
		sprintf(qdb_mysql__errstr, "%.999s", strerror(errno));
		mysql_free_result(results);
		return val;
	}

	sprintf(buf, "%.*s",
		(int) ((lengths[0] <
			sizeof(buf) - 1) ? lengths[0] : sizeof(buf) - 1),
		row[0]);
	data[0] = strtol(buf, NULL, 10);
	sprintf(buf, "%.*s",
		(int) ((lengths[1] <
			sizeof(buf) - 1) ? lengths[1] : sizeof(buf) - 1),
		row[1]);
	data[1] = strtol(buf, NULL, 10);

	if (db->have_value3) {
		sprintf(buf, "%.*s",
			(int) ((lengths[2] <
				sizeof(buf) -
				1) ? lengths[2] : sizeof(buf) - 1),
			row[2]);
		data[2] = strtol(buf, NULL, 10);
	} else {
		data[2] = 0;
	}

	mysql_free_result(results);

	val.data = (unsigned char *) data;
	val.size = 3 * sizeof(long);

	return val;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_mysql_store(qdbint_t db, qdb_datum key, qdb_datum val)
{
	long *data;
	char val1[128];			 /* RATS: ignore (checked) */
	char val2[128];			 /* RATS: ignore (checked) */
	char val3[128];			 /* RATS: ignore (checked) */

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
		if (qdb_mysql__query(db, "REPLACE INTO ! "
				     "(key1,key2,token,value1,value2,value3) "
				     "VALUES (?,?,?,?,?,?)",
				     (long) (strlen(db->table)), db->table,
				     (long) (strlen(db->key1)), db->key1,
				     (long) (strlen(db->key2)), db->key2,
				     (long) (key.size),
				     (char *) (key.data),
				     (long) (strlen(val1)), val1,
				     (long) (strlen(val2)), val2,
				     (long) (strlen(val3)), val3)) {
			sprintf(qdb_mysql__errstr, "%.*s: %.900s",
				(int) (sizeof(qdb_mysql__errstr) - 910),
				_("store failed"), mysql_error(db->db));
			return 1;
		}
	} else {
		if (qdb_mysql__query(db, "REPLACE INTO ! "
				     "(key1,key2,token,value1,value2) "
				     "VALUES (?,?,?,?,?)",
				     (long) (strlen(db->table)), db->table,
				     (long) (strlen(db->key1)), db->key1,
				     (long) (strlen(db->key2)), db->key2,
				     (long) (key.size),
				     (char *) (key.data),
				     (long) (strlen(val1)), val1,
				     (long) (strlen(val2)), val2)) {
			sprintf(qdb_mysql__errstr, "%.*s: %.900s",
				(int) (sizeof(qdb_mysql__errstr) - 910),
				_("store failed"), mysql_error(db->db));
			return 1;
		}
	}

	return 0;
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_mysql_delete(qdbint_t db, qdb_datum key)
{
	if (db == NULL)
		return 1;

	if (key.data == NULL)
		return 1;

	if (db->readonly)
		return 1;

	if (qdb_mysql__query(db, "DELETE FROM ! "
			     "WHERE key1=? "
			     "AND key2=? "
			     "AND token=?",
			     (long) (strlen(db->table)), db->table,
			     (long) (strlen(db->key1)), db->key1,
			     (long) (strlen(db->key2)), db->key2,
			     (long) (key.size), (char *) (key.data))) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("delete failed"), mysql_error(db->db));
		return 1;
	}

	return 0;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_mysql_nextkey(qdbint_t db, qdb_datum key)
{
	MYSQL_ROW row;
	unsigned long *lengths;
	qdb_datum newkey;

	newkey.data = NULL;
	newkey.size = 0;

	row = mysql_fetch_row(db->results);
	if (row == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("row fetch failed"), mysql_error(db->db));
		mysql_free_result(db->results);
		db->results = NULL;
		return newkey;
	}

	lengths = mysql_fetch_lengths(db->results);
	if (lengths == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("row lengths fetch failed"),
			mysql_error(db->db));
		mysql_free_result(db->results);
		db->results = NULL;
		return newkey;
	}

	newkey.data = (unsigned char *) calloc(1, lengths[0] + 1);
	if (newkey.data == NULL) {
		sprintf(qdb_mysql__errstr, "%.999s", strerror(errno));
		return newkey;
	}

	newkey.size = lengths[0];
	strncpy((char *) (newkey.data), row[0], lengths[0]);

	return newkey;
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_mysql_firstkey(qdbint_t db)
{
	qdb_datum blankkey;

	blankkey.data = NULL;
	blankkey.size = 0;

	if (db->results)
		mysql_free_result(db->results);

	db->results = NULL;

	if (qdb_mysql__query(db, "SELECT token FROM ! "
			     "WHERE key1 = ? "
			     "AND key2 = ? "
			     "ORDER BY token",
			     (long) (strlen(db->table)), db->table,
			     (long) (strlen(db->key1)), db->key1,
			     (long) (strlen(db->key2)), db->key2)) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("select failed"), mysql_error(db->db));
		return blankkey;
	}

	db->results = mysql_store_result(db->db);
	if (db->results == NULL) {
		sprintf(qdb_mysql__errstr, "%.*s: %.900s",
			(int) (sizeof(qdb_mysql__errstr) - 910),
			_("result store failed"), mysql_error(db->db));
		return blankkey;
	}

	return qdb_mysql_nextkey(db, blankkey);
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_mysql_error(void)
{
	return qdb_mysql__errstr;
}


#endif				/* USING_MYSQL */

/* EOF */
