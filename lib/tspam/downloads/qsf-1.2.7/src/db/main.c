/*
 * Main entry point for database functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif

#ifdef USING_OBTREE
int qdb_obtree_identify(const char *);
qdbint_t qdb_obtree_open(const char *, qdb_open_t);
int qdb_obtree_fd(qdbint_t);
void qdb_obtree_close(qdbint_t);
qdb_datum qdb_obtree_fetch(qdbint_t, qdb_datum);
int qdb_obtree_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_obtree_delete(qdbint_t, qdb_datum);
qdb_datum qdb_obtree_firstkey(qdbint_t);
qdb_datum qdb_obtree_nextkey(qdbint_t, qdb_datum);
char *qdb_obtree_error(void);
void qdb_obtree_unlock(qdbint_t);
void qdb_obtree_relock(qdbint_t);
#endif				/* USING_OBTREE */
#ifdef USING_BTREE
int qdb_btree_identify(const char *);
qdbint_t qdb_btree_open(const char *, qdb_open_t);
int qdb_btree_fd(qdbint_t);
void qdb_btree_close(qdbint_t);
qdb_datum qdb_btree_fetch(qdbint_t, qdb_datum);
int qdb_btree_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_btree_delete(qdbint_t, qdb_datum);
qdb_datum qdb_btree_firstkey(qdbint_t);
qdb_datum qdb_btree_nextkey(qdbint_t, qdb_datum);
void qdb_btree_optimise(qdbint_t);
char *qdb_btree_error(void);
void qdb_btree_unlock(qdbint_t);
void qdb_btree_relock(qdbint_t);
#endif				/* USING_BTREE */
#ifdef USING_LIST
int qdb_list_identify(const char *);
qdbint_t qdb_list_open(const char *, qdb_open_t);
int qdb_list_fd(qdbint_t);
void qdb_list_close(qdbint_t);
qdb_datum qdb_list_fetch(qdbint_t, qdb_datum);
int qdb_list_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_list_delete(qdbint_t, qdb_datum);
qdb_datum qdb_list_firstkey(qdbint_t);
qdb_datum qdb_list_nextkey(qdbint_t, qdb_datum);
char *qdb_list_error(void);
void qdb_list_restore_start(qdbint_t);
void qdb_list_restore_end(qdbint_t);
#endif				/* USING_LIST */
#ifdef USING_GDBM
int qdb_gdbm_identify(const char *);
qdbint_t qdb_gdbm_open(const char *, qdb_open_t);
int qdb_gdbm_fd(qdbint_t);
void qdb_gdbm_close(qdbint_t);
qdb_datum qdb_gdbm_fetch(qdbint_t, qdb_datum);
int qdb_gdbm_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_gdbm_delete(qdbint_t, qdb_datum);
qdb_datum qdb_gdbm_firstkey(qdbint_t);
qdb_datum qdb_gdbm_nextkey(qdbint_t, qdb_datum);
void qdb_gdbm_optimise(qdbint_t);
char *qdb_gdbm_error(void);
#endif				/* USING_GDBM */
#ifdef USING_MYSQL
int qdb_mysql_identify(const char *);
qdbint_t qdb_mysql_open(const char *, qdb_open_t);
int qdb_mysql_fd(qdbint_t);
void qdb_mysql_close(qdbint_t);
qdb_datum qdb_mysql_fetch(qdbint_t, qdb_datum);
int qdb_mysql_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_mysql_delete(qdbint_t, qdb_datum);
qdb_datum qdb_mysql_firstkey(qdbint_t);
qdb_datum qdb_mysql_nextkey(qdbint_t, qdb_datum);
char *qdb_mysql_error(void);
#endif				/* USING_MYSQL */
#ifdef USING_SQLITE
int qdb_sqlite_identify(const char *);
qdbint_t qdb_sqlite_open(const char *, qdb_open_t);
int qdb_sqlite_fd(qdbint_t);
void qdb_sqlite_close(qdbint_t);
qdb_datum qdb_sqlite_fetch(qdbint_t, qdb_datum);
int qdb_sqlite_store(qdbint_t, qdb_datum, qdb_datum);
int qdb_sqlite_delete(qdbint_t, qdb_datum);
qdb_datum qdb_sqlite_firstkey(qdbint_t);
qdb_datum qdb_sqlite_nextkey(qdbint_t, qdb_datum);
char *qdb_sqlite_error(void);
void qdb_sqlite_unlock(qdbint_t);
void qdb_sqlite_relock(qdbint_t);
#endif				/* USING_SQLITE */

struct qdbtype_s {
	char *name;
	int (*_identify) (const char *);
	 qdbint_t(*_open) (const char *, qdb_open_t);
	int (*_fd) (qdbint_t);
	void (*_close) (qdbint_t);
	 qdb_datum(*_fetch) (qdbint_t, qdb_datum);
	int (*_store) (qdbint_t, qdb_datum, qdb_datum);
	int (*_delete) (qdbint_t, qdb_datum);
	 qdb_datum(*_firstkey) (qdbint_t);
	 qdb_datum(*_nextkey) (qdbint_t, qdb_datum);
	char *(*_error) (void);
	void (*_optimise) (qdbint_t);	 /* optional */
	void (*_unlock) (qdbint_t);	 /* optional */
	void (*_relock) (qdbint_t);	 /* optional */
	void (*_restore_start) (qdbint_t);	/* optional */
	void (*_restore_end) (qdbint_t); /* optional */
};

struct qdb_s {
	struct qdbtype_s *type;
	int typeindex;
	struct qdbint_s *data;
};

static struct qdbtype_s qdb__backends[] = {
#ifdef USING_LIST
	{
	 "list",
	 qdb_list_identify,
	 qdb_list_open,
	 qdb_list_fd,
	 qdb_list_close,
	 qdb_list_fetch,
	 qdb_list_store,
	 qdb_list_delete,
	 qdb_list_firstkey,
	 qdb_list_nextkey,
	 qdb_list_error,
	 NULL,				    /* optimise */
	 NULL,				    /* unlock */
	 NULL,				    /* relock */
	 qdb_list_restore_start,
	 qdb_list_restore_end},
#endif
#ifdef USING_BTREE
	{
	 "btree",
	 qdb_btree_identify,
	 qdb_btree_open,
	 qdb_btree_fd,
	 qdb_btree_close,
	 qdb_btree_fetch,
	 qdb_btree_store,
	 qdb_btree_delete,
	 qdb_btree_firstkey,
	 qdb_btree_nextkey,
	 qdb_btree_error,
	 qdb_btree_optimise,
	 qdb_btree_unlock,
	 qdb_btree_relock,
	 NULL,				    /* restore_start */
	 NULL},				    /* restore_end */
#endif
#ifdef USING_OBTREE
	{
	 "obtree",
	 qdb_obtree_identify,
	 qdb_obtree_open,
	 qdb_obtree_fd,
	 qdb_obtree_close,
	 qdb_obtree_fetch,
	 qdb_obtree_store,
	 qdb_obtree_delete,
	 qdb_obtree_firstkey,
	 qdb_obtree_nextkey,
	 qdb_obtree_error,
	 NULL,				    /* optimise */
	 qdb_obtree_unlock,
	 qdb_obtree_relock,
	 NULL,				    /* restore_start */
	 NULL},				    /* restore_end */
#endif
#ifdef USING_GDBM
	{
	 "GDBM",
	 qdb_gdbm_identify,
	 qdb_gdbm_open,
	 qdb_gdbm_fd,
	 qdb_gdbm_close,
	 qdb_gdbm_fetch,
	 qdb_gdbm_store,
	 qdb_gdbm_delete,
	 qdb_gdbm_firstkey,
	 qdb_gdbm_nextkey,
	 qdb_gdbm_error,
	 qdb_gdbm_optimise,
	 NULL,				    /* unlock */
	 NULL,				    /* relock */
	 NULL,				    /* restore_start */
	 NULL},				    /* restore_end */
#endif
#ifdef USING_MYSQL
	{
	 "MySQL",
	 qdb_mysql_identify,
	 qdb_mysql_open,
	 qdb_mysql_fd,
	 qdb_mysql_close,
	 qdb_mysql_fetch,
	 qdb_mysql_store,
	 qdb_mysql_delete,
	 qdb_mysql_firstkey,
	 qdb_mysql_nextkey,
	 qdb_mysql_error,
	 NULL,				    /* optimise */
	 NULL,				    /* unlock */
	 NULL,				    /* relock */
	 NULL,				    /* restore_start */
	 NULL},				    /* restore_end */
#endif
#ifdef USING_SQLITE
	{
	 "sqlite",
	 qdb_sqlite_identify,
	 qdb_sqlite_open,
	 qdb_sqlite_fd,
	 qdb_sqlite_close,
	 qdb_sqlite_fetch,
	 qdb_sqlite_store,
	 qdb_sqlite_delete,
	 qdb_sqlite_firstkey,
	 qdb_sqlite_nextkey,
	 qdb_sqlite_error,
	 NULL,				    /* optimise */
	 qdb_sqlite_unlock,
	 qdb_sqlite_relock,
	 NULL,				    /* restore_start */
	 NULL},				    /* restore_end */
#endif
	{NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

static int qdb__lastbackend = 0;


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_fd(qdb_t db)
{
	if (db == NULL)
		return -1;
	qdb__lastbackend = db->typeindex;
	return db->type->_fd(db->data);
}


/*
 * Return a string describing the type of the given database, or "(none)" on
 * error. The string should NOT be free()d.
 */
char *qdb_type(qdb_t db)
{
	if (db == NULL)
		return "(none)";
	return db->type->name;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdb_t or NULL on error.
 */
qdb_t qdb_open(const char *file, qdb_open_t method)
{
	int type, i;
	qdb_t db;

	type = -1;
	for (i = 0; type == -1 && qdb__backends[i].name != NULL; i++) {
		if (qdb__backends[i]._identify(file))
			type = i;
	}

	/*
	 * If no valid type was determined, fall back to obtree if the file
	 * already exists, list if not (providing they are both compiled
	 * in). If neither is compiled in, fall back to the first available
	 * backend in the list.
	 */
	if (type == -1) {
		char *usetype = NULL;
		FILE *fptr;

#ifdef USING_LIST
		usetype = "list";
#endif

#ifdef USING_OBTREE
		fptr = fopen(file, "rb");
		if (fptr) {
			fclose(fptr);
			usetype = "obtree";
		}
#endif

		if (usetype) {
			for (i = 0;
			     type == -1 && qdb__backends[i].name != NULL;
			     i++) {
				if (strcmp(qdb__backends[i].name, usetype)
				    == 0)
					type = i;
			}
		}

		if (type == -1)
			type = 0;
	}

	qdb__lastbackend = type;

	db = calloc(1, sizeof(*db));
	if (db == NULL) {
		return NULL;
	}

	db->type = &(qdb__backends[type]);
	db->typeindex = type;
	db->data = db->type->_open(file, method);
	if (db->data == NULL) {
		free(db);
		return NULL;
	}

	return db;
}


/*
 * Close the given database.
 */
void qdb_close(qdb_t db)
{
	if (db == NULL)
		return;
	qdb__lastbackend = db->typeindex;
	db->type->_close(db->data);
	free(db);
}


/*
 * NOTE: From here on down, we take copies of "key" and "val" qdb_datum
 * objects before sending them on to the backend. For some reason OpenBSD
 * corrupts the key and val if we just pass them on, but if we pass on
 * copies, it's OK.
 */

/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_fetch(qdb_t db, qdb_datum key)
{
	qdb_datum keycopy;

	if (db == NULL) {
		qdb_datum val;
		val.data = NULL;
		val.size = 0;
		return val;
	}

	if (key.data == NULL) {
		qdb_datum val;
		val.data = NULL;
		val.size = 0;
		return val;
	}

	keycopy = key;

	qdb__lastbackend = db->typeindex;
	return db->type->_fetch(db->data, keycopy);
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_store(qdb_t db, qdb_datum key, qdb_datum val)
{
	qdb_datum keycopy, valcopy;

	if (db == NULL)
		return 1;

	if ((key.data == NULL) || (val.data == NULL))
		return 1;

	keycopy = key;
	valcopy = val;

	qdb__lastbackend = db->typeindex;
	return db->type->_store(db->data, keycopy, valcopy);
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_delete(qdb_t db, qdb_datum key)
{
	qdb_datum keycopy;

	if (db == NULL)
		return 1;

	if (key.data == NULL)
		return 1;

	keycopy = key;

	qdb__lastbackend = db->typeindex;
	return db->type->_delete(db->data, keycopy);
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_firstkey(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	return db->type->_firstkey(db->data);
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_nextkey(qdb_t db, qdb_datum key)
{
	qdb_datum keycopy;

	keycopy = key;

	qdb__lastbackend = db->typeindex;
	return db->type->_nextkey(db->data, keycopy);
}


/*
 * Reorganise the database for better efficiency.
 */
void qdb_optimise(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	if (db->type->_optimise == NULL)
		return;
	db->type->_optimise(db->data);
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_error(void)
{
	return qdb__backends[qdb__lastbackend]._error();
}


/*
 * Temporarily release the lock on the database.
 */
void qdb_unlock(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	if (db->type->_unlock == NULL)
		return;
	db->type->_unlock(db->data);
}


/*
 * Reassert the lock on the database.
 */
void qdb_relock(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	if (db->type->_relock == NULL)
		return;
	db->type->_relock(db->data);
}


/*
 * Tell the database that a restore operation is starting.
 */
void qdb_restore_start(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	if (db->type->_restore_start == NULL)
		return;
	db->type->_restore_start(db->data);
}


/*
 * Tell the database that a restore operation is ending.
 */
void qdb_restore_end(qdb_t db)
{
	qdb__lastbackend = db->typeindex;
	if (db->type->_restore_end == NULL)
		return;
	db->type->_restore_end(db->data);
}


/*
 * Utility functions that can be used by the back-end follow.
 */


/*
 * Block common interrupt signals, so a user doesn't accidentally kill this
 * process while it's doing something critical to data integrity.
 */
void qdb_int__sig_block(void)
{
#ifdef SIGHUP
	signal(SIGHUP, SIG_IGN);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGINT
	signal(SIGINT, SIG_IGN);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGQUIT
	signal(SIGQUIT, SIG_IGN);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGTERM
	signal(SIGTERM, SIG_IGN);	    /* RATS: ignore (OK) */
#endif
}


/*
 * Unblock previously blocked signals.
 */
void qdb_int__sig_unblock(void)
{
#ifdef SIGHUP
	signal(SIGHUP, SIG_DFL);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGINT
	signal(SIGINT, SIG_DFL);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGQUIT
	signal(SIGQUIT, SIG_DFL);	    /* RATS: ignore (OK) */
#endif
#ifdef SIGTERM
	signal(SIGTERM, SIG_DFL);	    /* RATS: ignore (OK) */
#endif
}


/*
 * Obtain / release a read or write lock on the database. Returns zero on
 * success, 1 on error. Blocks until a lock can be obtained. Keeps track of
 * the number of times locked, so we don't accidentally try to lock a file
 * descriptor twice.
 */
int qdb_int__lock(int fd, int lock_type, int *lockcount)
{
#ifdef HAVE_FCNTL
	struct flock lock;
	int lockdummy = 0;

	if (lockcount == NULL)
		lockcount = &lockdummy;

	if ((lock_type == F_UNLCK) && (*lockcount > 1)) {
		*lockcount = (*lockcount) - 1;
		return 0;
	} else if ((lock_type != F_UNLCK) && (*lockcount > 0)) {
		*lockcount = (*lockcount) + 1;
		return 0;
	}

	lock.l_whence = SEEK_SET;
	lock.l_start = 0;
	lock.l_len = 0;

	lock.l_type = lock_type;

	if (fcntl(fd, F_SETLKW, &lock)) {
		return 1;
	}

	if (lock_type == F_UNLCK) {
		*lockcount = (*lockcount) - 1;
	} else {
		*lockcount = (*lockcount) + 1;
	}

#endif				/* HAVE_FCNTL */
	return 0;
}


/* EOF */
