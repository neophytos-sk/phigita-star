/*
 * In-memory flat list database backend.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include "log.h"

#ifdef USING_LIST

#include <stdio.h>
#include <stdlib.h>
#include <search.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif
#ifdef HAVE_UTIME
#include <time.h>
#include <utime.h>
#endif
#include <netinet/in.h>

#define ML_TOKEN_MAX	36		    /* maximum token length */
#define ML_INCSIZE	10000		    /* increments by which array size grows */
#define ML_ADDITIONBUF	1000		    /* size of addition buffer */

struct mh_record_s {
	char token[ML_TOKEN_MAX];	 /* RATS: ignore - 0-term. token */
	uint32_t data[3];		 /* token data (i.e. the counts) */
};

struct qdbint_s {
	int fd;
	long size;
#ifdef HAVE_FCNTL
	int lockcount;			 /* number of times lock asked for */
	int locktype;			 /* type of lock to use (read or write) */
#endif
	char *filename;			 /* filename of database */
	int modified;			 /* flag, set if db modified at all */
	int restoring;			 /* flag, set if no qsort on store */
	struct mh_record_s *array;	 /* array holding all list entries */
	long array_len;			 /* highest used index + 1 */
	long array_alloced;		 /* size of array */
	long walk_index;		 /* current index for ..._nextkey() */
	struct mh_record_s *addition;	 /* array holding all list entries */
	long addition_len;		 /* highest used index + 1 */
};


static char *mh_lasterror = "";


#ifdef HAVE_FCNTL
/*
 * Obtain / release a read or write lock on the database. Returns nonzero on
 * error, and blocks until a lock can be obtained.
 */
static int dbl_lock(qdbint_t db, int lock_type)
{
	int ret;
	ret = qdb_int__lock(db->fd, lock_type, &(db->lockcount));
	if (ret != 0) {
		mh_lasterror = strerror(errno);
		return 1;
	}
	return 0;
}
#endif				/* HAVE_FCNTL */


/*
 * Analogue of fread().
 */
static int dbl_chunkread(void *ptr, int size, int nmemb, int fd)
{
	int numread, togo, got;

	for (numread = 0; nmemb > 0; nmemb--, numread++) {
		for (togo = size; togo > 0;) {
			got = read(fd, ptr, togo);	/* RATS: ignore (OK) */
			if (got <= 0)
				return numread;
			togo -= got;
			ptr = (void *) (((char *) ptr) + got);
		}
	}

	return numread;
}


/*
 * Analogue of fwrite().
 */
static int dbl_chunkwrite(void *ptr, int size, int nmemb, int fd)
{
	int numwritten, togo, written;

	for (numwritten = 0; nmemb > 0; nmemb--, numwritten++) {
		for (togo = size; togo > 0;) {
			written = write(fd, ptr, togo);
			if (written <= 0)
				return numwritten;
			togo -= written;
			ptr = (void *) (((char *) ptr) + written);
		}
	}

	return numwritten;
}


/*
 * Read a single long integer from the database and return it, converting
 * from network byte order.
 */
static long dbl_longread(qdbint_t db)
{
	uint32_t val;

	val = 0;
	dbl_chunkread(&val, sizeof(val), 1, db->fd);

	return ntohl(val);
}


/*
 * Write a single long integer to the database, converting to network byte
 * order. Returns nonzero on error.
 */
static int dbl_longwrite(qdbint_t db, long val)
{
	uint32_t newval;

	newval = htonl(val);
	return dbl_chunkwrite(&newval, sizeof(newval), 1,
			      db->fd) == 1 ? 0 : -1;
}


/*
 * Comparison function to compare two database records' tokens.
 */
static int dbl_compare(const void *a, const void *b)
{
	if (a == NULL)
		return -1;
	if (b == NULL)
		return 1;
	if (((struct mh_record_s *) a)->token[0] == 0)
		return 1;
	if (((struct mh_record_s *) b)->token[0] == 0)
		return -1;
	return strncmp(((struct mh_record_s *) a)->token,
		       ((struct mh_record_s *) b)->token, ML_TOKEN_MAX);
}


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_list_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	return db->fd;
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_list_identify(const char *file)
{
	int fd;
	char buf[8];			 /* RATS: ignore (checked) */

	if (file == NULL)
		return 0;
	if (strncasecmp(file, "list:", 5) == 0)
		return 1;

	fd = open(file, O_RDONLY);
	if (fd < 0)
		return 0;
	if (dbl_chunkread(buf, 4, 1, fd) < 1) {
		close(fd);
		return 0;
	}

	close(fd);

	if (strncmp(buf, "QSF2", 4) == 0)
		return 1;

	return 0;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_list_open(const char *file, qdb_open_t method)
{
	qdbint_t db;
	int fd = -1;
#ifdef HAVE_FCNTL
	int locktype = F_RDLCK;
#endif

	if (strncasecmp(file, "list:", 5) == 0)
		file += 5;

	switch (method) {
	case QDB_NEW:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if (fd < 0)
			mh_lasterror = strerror(errno);
#ifdef HAVE_FCNTL
		locktype = F_WRLCK;
#endif
		break;
	case QDB_READONLY:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDONLY);
		if (fd < 0)
			mh_lasterror = strerror(errno);
		break;
	case QDB_READWRITE:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if (fd < 0)
			mh_lasterror = strerror(errno);
#ifdef HAVE_FCNTL
		locktype = F_WRLCK;
#endif
		break;
	default:
		break;
	}

	if (fd < 0)
		return NULL;

	db = calloc(1, sizeof(*db));
	if (db == NULL) {
		mh_lasterror = strerror(errno);
		close(fd);
		return NULL;
	}

	db->filename = strdup(file);
	db->fd = fd;
#ifdef HAVE_FCNTL
	db->locktype = locktype;
#endif
	db->modified = 0;

	db->array = NULL;
	db->array_len = 0;
	db->array_alloced = 0;

	db->addition_len = 0;
	db->addition = calloc(ML_ADDITIONBUF, sizeof(struct mh_record_s));

	if (db->addition == NULL) {
		mh_lasterror = strerror(errno);
		close(fd);
		free(db->filename);
		free(db);
		return NULL;
	}
#ifdef HAVE_FCNTL
	if (dbl_lock(db, db->locktype)) {
		close(db->fd);
		if (db->filename)
			free(db->filename);
		if (db->addition)
			free(db->addition);
		free(db);
		return NULL;
	}
#endif

	db->size = lseek(db->fd, 0, SEEK_END);
	if (db->size == (off_t) - 1)
		db->size = 0;

	/*
	 * If this is a new database, and it's not readonly, write our
	 * header to it and return.
	 */
	if ((db->size <= 8) && (method != QDB_READONLY)) {
		lseek(db->fd, 0, SEEK_SET);
		dbl_chunkwrite("QSF2", 4, 1, db->fd);
		dbl_longwrite(db, 0);
		db->size = 8;
		db->modified = 1;
		return db;
	}

	lseek(db->fd, 4, SEEK_SET);

	db->array_len = dbl_longread(db);

	if ((db->array_len < 0) || (db->array_len > 10000000)) {
		mh_lasterror =
		    _("invalid database (array size out of range)");
#ifdef HAVE_FCNTL
		dbl_lock(db, F_UNLCK);
#endif
		close(db->fd);
		if (db->filename)
			free(db->filename);
		if (db->addition)
			free(db->addition);
		free(db);
		return NULL;
	}

	db->array_alloced = db->array_len + ML_INCSIZE;
	db->array = calloc(db->array_alloced, sizeof(struct mh_record_s));

	if (db->array == NULL) {
		mh_lasterror = strerror(errno);
#ifdef HAVE_FCNTL
		dbl_lock(db, F_UNLCK);
#endif
		close(db->fd);
		if (db->filename)
			free(db->filename);
		if (db->addition)
			free(db->addition);
		free(db);
		return NULL;
	}

	if (dbl_chunkread
	    (db->array, sizeof(struct mh_record_s), db->array_len,
	     db->fd) < db->array_len) {
		mh_lasterror = _("invalid database (file truncated)");
#ifdef HAVE_FCNTL
		dbl_lock(db, F_UNLCK);
#endif
		close(db->fd);
		if (db->filename)
			free(db->filename);
		free(db->array);
		if (db->addition)
			free(db->addition);
		free(db);
		return NULL;
	}

	qsort(db->array, db->array_len, sizeof(struct mh_record_s),
	      dbl_compare);

	return db;
}


/*
 * Extend the array by "amount" items. Returns nonzero on error.
 */
static int qdb_list__extendarray(qdbint_t db, long amount)
{
	long origlen, origalloced;
	void *ptr;

	origlen = db->array_len;

	db->array_len += amount;
	if (db->array_len < db->array_alloced)
		return 0;

	origalloced = db->array_alloced;

	while (db->array_alloced < db->array_len) {
		db->array_alloced += ML_INCSIZE;
	}

	if (db->array == NULL) {
		ptr =
		    calloc(db->array_alloced, sizeof(struct mh_record_s));
	} else {
		ptr = realloc(db->array,    /* RATS: ignore (OK) */
			      db->array_alloced *
			      sizeof(struct mh_record_s));
	}

	if (ptr == NULL) {
		mh_lasterror = strerror(errno);
		db->array_len = origlen;
		db->array_alloced = origalloced;
		return 1;
	}

	db->array = ptr;

	return 0;
}


/*
 * Dump the addition list on to the end of the array, and re-sort the array.
 * Returns nonzero on error.
 */
static int qdb_list__dumpaddition(qdbint_t db)
{
	if (db->addition_len == 0)
		return 0;

	if (qdb_list__extendarray(db, db->addition_len))
		return 1;

	memcpy(&(db->array[db->array_len - db->addition_len]),
	       db->addition,
	       db->addition_len * sizeof(struct mh_record_s));

	db->addition_len = 0;

	if (!db->restoring) {
		qsort(db->array, db->array_len, sizeof(struct mh_record_s),
		      dbl_compare);
	}

	return 0;
}


/*
 * Save any changes that were made to the database. This function only
 * stores the data, it doesn't free memory or update timestamps. Returns
 * nonzero on error.
 */
static int qdb_list__savedb(qdbint_t db)
{
	unsigned long newsize;

	/*
	 * Append the addition list to the array.
	 */
	if (qdb_list__dumpaddition(db))
		return 1;

	/*
	 * Write the contents of the array first.
	 */

	lseek(db->fd, 8, SEEK_SET);

	if (dbl_chunkwrite
	    (db->array, sizeof(struct mh_record_s), db->array_len,
	     db->fd) < db->array_len) {
		return 1;
	}

	newsize = lseek(db->fd, 0, SEEK_CUR);

	/*
	 * Now store the new size of the array.
	 */
	lseek(db->fd, 4, SEEK_SET);

	if (dbl_longwrite(db, db->array_len))
		return 1;

	/*
	 * Finally, truncate the database (if it's got smaller).
	 */
	if (ftruncate(db->fd, newsize) != 0) {
		log_add(0, "%s: failed to truncate database: %s",
			db->filename, strerror(errno));
	}

	return 0;
}


/*
 * Close the given database.
 */
void qdb_list_close(qdbint_t db)
{
	if (db == NULL)
		return;

	if (db->modified) {
		qdb_int__sig_block();
		qdb_list__savedb(db);
		qdb_int__sig_unblock();
	}

	if (db->array)
		free(db->array);
	if (db->addition)
		free(db->addition);

#ifdef HAVE_FCNTL
	while (db->lockcount > 0)
		dbl_lock(db, F_UNLCK);
#endif
	close(db->fd);

	if (db->modified && db->filename) {
#ifdef HAVE_UTIME
		struct utimbuf utb;

		utb.actime = time(NULL);
		utb.modtime = time(NULL);
		utime(db->filename, &utb);
#endif
	}

	if (db->filename)
		free(db->filename);

	free(db);
}


/*
 * Search the array for the given token. Returns a pointer to the array
 * entry or NULL on failure.
 */
static struct mh_record_s *dbl_search(qdbint_t db, qdb_datum key)
{
	struct mh_record_s search;
	struct mh_record_s *val;

	if (db == NULL)
		return NULL;

	if (key.data == NULL)
		return NULL;

	memset(search.token, 0, ML_TOKEN_MAX);

	strncpy(search.token, (char *) (key.data),
		(key.size > ML_TOKEN_MAX) ? ML_TOKEN_MAX : key.size);

	if (db->addition_len > 0) {
		val = bsearch((void *) (&search), (void *) db->addition,
			      db->addition_len, sizeof(struct mh_record_s),
			      dbl_compare);
		if (val != NULL)
			return val;
	}

	if (db->array == NULL)
		return NULL;

	return bsearch((void *) (&search), (void *) db->array,
		       db->array_len, sizeof(struct mh_record_s),
		       dbl_compare);
}


/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_list_fetch(qdbint_t db, qdb_datum key)
{
	struct mh_record_s *result;
	qdb_datum val;

	val.data = NULL;
	val.size = 0;

	result = dbl_search(db, key);

	if (result == NULL)
		return val;

	val.size = 3 * sizeof(long);
	val.data = calloc(1, val.size);
	if (val.data == NULL) {
		val.size = 0;
		return val;
	}

	((long *) val.data)[0] = ntohl(result->data[0]);
	((long *) val.data)[1] = ntohl(result->data[1]);
	((long *) val.data)[2] = ntohl(result->data[2]);

	return val;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_list_store(qdbint_t db, qdb_datum key, qdb_datum val)
{
	struct mh_record_s *result;

	if (db == NULL)
		return 1;

	if ((key.data == NULL) || (val.data == NULL))
		return 1;

	db->modified = 1;

	if (db->restoring) {
		result = NULL;
	} else {
		result = dbl_search(db, key);
	}

	if (result != NULL) {
		result->data[0] = htonl(((long *) val.data)[0]);
		result->data[1] = htonl(((long *) val.data)[1]);
		result->data[2] = htonl(((long *) val.data)[2]);
	} else {
		db->addition_len++;
		result = &(db->addition[db->addition_len - 1]);

		memset(result, 0, sizeof(struct mh_record_s));
		strncpy(result->token, (char *) (key.data),
			(key.size >
			 ML_TOKEN_MAX) ? ML_TOKEN_MAX : key.size);
		result->data[0] = htonl(((long *) val.data)[0]);
		result->data[1] = htonl(((long *) val.data)[1]);
		result->data[2] = htonl(((long *) val.data)[2]);

		if (db->addition_len >= ML_ADDITIONBUF) {
			if (qdb_list__dumpaddition(db))
				return 1;
		} else if (!db->restoring) {
			qsort(db->addition, db->addition_len,
			      sizeof(struct mh_record_s), dbl_compare);
		}
	}

	return 0;
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_list_delete(qdbint_t db, qdb_datum key)
{
	struct mh_record_s *result;
	long src, dst;

	if (db == NULL)
		return 1;

	if (key.data == NULL)
		return 1;

	if (qdb_list__dumpaddition(db))
		return 1;

	result = dbl_search(db, key);

	if (result == NULL)
		return 0;

	db->modified = 1;

	result->token[0] = 0;

	for (src = 0, dst = 0; src < db->array_len; src++) {
		if (db->array[src].token[0] == 0)
			continue;
		if (src != dst)
			memcpy(&(db->array[dst]), &(db->array[src]),
			       sizeof(struct mh_record_s));
		dst++;
	}

	db->array_len = dst;

	return 0;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_list_nextkey(qdbint_t db, qdb_datum key)
{
	qdb_datum newkey;
	char keystr[ML_TOKEN_MAX + 1];	 /* RATS: ignore */

	newkey.data = NULL;
	newkey.size = 0;

	db->walk_index++;

	while ((db->walk_index < db->array_len)
	       && (db->array[db->walk_index].token[0] == 0)
	    ) {
		db->walk_index++;
	}

	if (db->walk_index >= db->array_len)
		return newkey;

	if (db->array[db->walk_index].token[0] == 0)
		return newkey;

	memset(keystr, 0, sizeof(keystr));
	strncpy(keystr, db->array[db->walk_index].token, ML_TOKEN_MAX);

	newkey.data = (unsigned char *) strdup((char *) keystr);
	newkey.size = strlen((char *) keystr);

	return newkey;
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_list_firstkey(qdbint_t db)
{
	qdb_datum key;

	qdb_list__dumpaddition(db);

	db->walk_index = -1;
	key.data = NULL;
	key.size = 0;

	return qdb_list_nextkey(db, key);
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_list_error(void)
{
	return mh_lasterror;
}


/*
 * Tell the database that a restore operation is starting.
 */
void qdb_list_restore_start(qdbint_t db)
{
	db->restoring = 1;
}


/*
 * Tell the database that a restore operation is ending.
 */
void qdb_list_restore_end(qdbint_t db)
{
	qdb_list__dumpaddition(db);
	qsort(db->array, db->array_len, sizeof(struct mh_record_s),
	      dbl_compare);
	db->restoring = 0;
}


#endif				/* USING_LIST */

/* EOF */
