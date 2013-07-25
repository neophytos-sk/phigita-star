/*
 * Old binary tree database backend.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include "log.h"

#ifdef USING_OBTREE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif

#define BT_RECORD_SIZE sizeof(struct bt_record)
#define BT_TOKEN_MAX   36

typedef unsigned long bt_ul;

struct bt_record {			 /* single binary tree record */
	bt_ul lower;			 /* offset of "lower" token */
	bt_ul higher;			 /* offset of "higher" token */
	unsigned char token[BT_TOKEN_MAX];	/* RATS: ignore - 0-term. token */
	long data[2];			 /* token data (i.e. the counts) */
};

typedef struct bt_record *bt_record_t;

struct qdbint_s {			 /* database state */
	int fd;				 /* file descriptor of database file */
	bt_ul size;			 /* total size of database */
#ifdef HAVE_FCNTL
	int lockcount;			 /* number of times lock asked for */
	int locktype;			 /* type of lock to use (read or write) */
#endif
	int gotheadoffs;		 /* flag, set once head offset read */
	bt_ul head_offset;		 /* offset of head record of tree */
};

static char *bt_lasterror = "";


#ifdef HAVE_FCNTL
/*
 * Obtain / release a read or write lock on the database. Returns nonzero on
 * error, and blocks until a lock can be obtained.
 */
static int dbbt_lock(qdbint_t db, int lock_type)
{
	int ret;
	ret = qdb_int__lock(db->fd, lock_type, &(db->lockcount));
	if (ret != 0) {
		bt_lasterror = strerror(errno);
		return 1;
	}
	return 0;
}
#endif				/* HAVE_FCNTL */


/*
 * Analogue of fread().
 */
static int dbbt_chunkread(void *ptr, int size, int nmemb, int fd)
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
static int dbbt_chunkwrite(void *ptr, int size, int nmemb, int fd)
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
 * Read a record from the database at the given offset into the given record
 * structure, returning nonzero on failure.
 */
static int dbbt_read_record(qdbint_t db, bt_ul offset, bt_record_t record)
{
	int got;

	if (lseek(db->fd, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	got = dbbt_chunkread(record, BT_RECORD_SIZE, 1, db->fd);
	if (got < 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	record->token[BT_TOKEN_MAX - 1] = 0;

	return 0;
}


/*
 * Write a record to the database at the given offset, returning nonzero on
 * failure.
 */
static int dbbt_write_record(qdbint_t db, bt_ul offset, bt_record_t record)
{
	if (lseek(db->fd, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	if (dbbt_chunkwrite(record, BT_RECORD_SIZE, 1, db->fd) < 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	return 0;
}


/*
 * Find the given token in the database and fill in the given record
 * structure if found, also filling in the offset of the record (or 0 if not
 * found) and the offset of the parent record (0 if none).
 *
 * Returns -1 if the token looked for was "lower" than its parent or +1 if
 * "higher", or 0 if there was no parent record (i.e. this is the first
 * record).
 */
static int dbbt_find_token(qdbint_t db, qdb_datum key, bt_record_t record,
			   bt_ul * offset, bt_ul * parent)
{
	int hilow = 0;
	int x;

	*offset = 0;
	*parent = 0;

	if (db == NULL)
		return 0;

	if (db->size < 2 * sizeof(long))
		return 0;

	if (!db->gotheadoffs) {
		lseek(db->fd, 0, SEEK_SET);
		dbbt_chunkread(offset, sizeof(*offset), 1, db->fd);
		db->head_offset = *offset;
		db->gotheadoffs = 1;
	} else {
		*offset = db->head_offset;
	}

	while (*offset > 0) {
		int len;

		if (dbbt_read_record(db, *offset, record)) {
			*offset = 0;
			break;
		}

		x = strncmp((char *) (record->token), (char *) (key.data),
			    key.size);
		len = strlen((char *) (record->token));
		if (len < key.size) {
			x = -1;
		} else if (len > key.size) {
			x = 1;
		}

		if (x == 0) {
			return hilow;
		} else if (x < 0) {
			*parent = *offset;
			hilow = -1;
			*offset = record->lower;
		} else {
			*parent = *offset;
			hilow = 1;
			*offset = record->higher;
		}
	}

	return hilow;
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_obtree_identify(const char *file)
{
	if (file == NULL)
		return 0;
	if (strncasecmp(file, "obtree:", 7) == 0)
		return 1;
	return 0;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_obtree_open(const char *file, qdb_open_t method)
{
	qdbint_t db;
	int fd = -1;
#ifdef HAVE_FCNTL
	int locktype = F_RDLCK;
#endif
	int forced_type = 0;

	if (strncasecmp(file, "obtree:", 7) == 0) {
		file += 7;
		forced_type = 1;
	}

	switch (method) {
	case QDB_NEW:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if (fd < 0)
			bt_lasterror = strerror(errno);
#ifdef HAVE_FCNTL
		locktype = F_WRLCK;
#endif
		break;
	case QDB_READONLY:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDONLY);
		if (fd < 0)
			bt_lasterror = strerror(errno);
		break;
	case QDB_READWRITE:
		fd = open(file,		    /* RATS: ignore (no race) */
			  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if (fd < 0)
			bt_lasterror = strerror(errno);
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
		bt_lasterror = strerror(errno);
		close(fd);
		return NULL;
	}

	db->size = lseek(fd, 0, SEEK_END);
	db->fd = fd;

#ifdef HAVE_FCNTL
	db->locktype = locktype;

	if (dbbt_lock(db, locktype)) {
		close(fd);
		free(db);
		return NULL;
	}
#endif

	/*
	 * Complain at the user to stop using this backend if it wasn't
	 * specifically chosen.
	 */
	if (!forced_type) {
		log_add(0, "%s",
			_("WARNING: Using deprecated obtree backend!"));
		log_add(0, "%s",
			_("WARNING: Dump, delete, and restore your"));
		log_add(0, "%s",
			_("WARNING: databases to upgrade them to the"));
		log_add(0, "%s",
			_("WARNING: new format and stop this warning."));
	} else {
		log_add(1, "%s",
			_("warning: obtree backend is deprecated"));
	}

	/*
	 * If the database has zero size and we're writing to it, assume
	 * it's new and don't complain.
	 */
	if ((db->size == 0) && (method != QDB_READONLY))
		return db;

	/*
	 * We now do some simple checks to make sure that the file is a
	 * database of the format we're expecting.
	 */

	/*
	 * If it's shorter than 2 long ints, it's not a valid database.
	 */
	if (db->size < 2 * sizeof(long)) {
		bt_lasterror = _("invalid database (too small)");
		close(fd);
		free(db);
		return NULL;
	}

	/*
	 * If its size, discounting the two longs at the start, isn't a
	 * multiple of our record size, it's not a valid database.
	 */
	if (((db->size - 2 * sizeof(long)) % BT_RECORD_SIZE) != 0) {
		bt_lasterror = _("invalid database (irregular size)");
		close(fd);
		free(db);
		return NULL;
	}

	/*
	 * If the first long int (the "head offset") is larger than the size
	 * of the file, this isn't a valid database.
	 */
	{
		bt_ul offset = db->size + 1;
		lseek(fd, 0, SEEK_SET);
		dbbt_chunkread(&offset, sizeof(offset), 1, fd);
		if (offset > db->size) {
			bt_lasterror =
			    _("invalid database (bad head offset)");
			close(fd);
			free(db);
			return NULL;
		}
		lseek(fd, 0, SEEK_SET);
	}

	return db;
}


/*
 * Close the given database.
 */
void qdb_obtree_close(qdbint_t db)
{
	if (db == NULL)
		return;

#ifdef HAVE_FCNTL
	while (db->lockcount > 0)
		dbbt_lock(db, F_UNLCK);
#endif

	close(db->fd);

	free(db);
}


/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_obtree_fetch(qdbint_t db, qdb_datum key)
{
	struct bt_record record;
	unsigned long offset, parent;
	qdb_datum val;

	val.data = NULL;
	val.size = 0;

	if (db == NULL)
		return val;

	if (key.size >= BT_TOKEN_MAX)
		key.size = BT_TOKEN_MAX - 1;

	dbbt_find_token(db, key, &record, &offset, &parent);

	if (offset == 0)
		return val;

	val.size = 2 * sizeof(long);
	val.data = calloc(1, val.size);
	if (val.data == NULL) {
		val.size = 0;
		return val;
	}

	((long *) val.data)[0] = record.data[0];
	((long *) val.data)[1] = record.data[1];

	return val;
}


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_obtree_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	return db->fd;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_obtree_store(qdbint_t db, qdb_datum key, qdb_datum val)
{
	struct bt_record record, head;
	unsigned long offset, parent, nextfree;
	int x;

	if (db == NULL)
		return 1;

	memset(&head, 0, BT_RECORD_SIZE);
	memset(&record, 0, BT_RECORD_SIZE);

	if (key.size >= BT_TOKEN_MAX)
		key.size = BT_TOKEN_MAX - 1;

	x = dbbt_find_token(db, key, &record, &offset, &parent);

	memcpy(record.token, key.data, key.size);
	record.token[key.size] = 0;
	record.data[0] = ((long *) val.data)[0];
	record.data[1] = ((long *) val.data)[1];

	qdb_int__sig_block();

	/*
	 * Record exists - overwrite it.
	 */
	if (offset > 0) {
		if (dbbt_write_record(db, offset, &record)) {
			qdb_int__sig_unblock();
			return 1;
		}
		qdb_int__sig_unblock();
		return 0;
	}

	record.lower = 0;
	record.higher = 0;

	/*
	 * Database has just been created, so fill in the header and write
	 * this record as the first one.
	 */
	if (db->size <= sizeof(offset)) {

		if (lseek(db->fd, 0, SEEK_SET) == (off_t) - 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}
		offset = 2 * sizeof(offset);
		if (dbbt_chunkwrite(&offset, sizeof(offset), 1, db->fd) <
		    1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		db->gotheadoffs = 0;

		offset = 0;
		if (dbbt_chunkwrite(&offset, sizeof(offset), 1, db->fd) <
		    1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		head.lower = (2 * sizeof(offset)) + BT_RECORD_SIZE;
		if (dbbt_chunkwrite(&head, BT_RECORD_SIZE, 1, db->fd) < 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		if (dbbt_chunkwrite(&record, BT_RECORD_SIZE, 1, db->fd) <
		    1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		db->size = lseek(db->fd, 0, SEEK_CUR);
		qdb_int__sig_unblock();
		return 0;
	}

	/*
	 * Get offset of next free space block.
	 */
	if (lseek(db->fd, sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if (dbbt_chunkread(&offset, sizeof(offset), 1, db->fd) < 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	offset &= 0x7FFFFFFF;

	/*
	 * If offset is 0 or we can't read from that offset, it's a new
	 * block at the end of the file, otherwise we take the next free
	 * offset from there and store it in the core free pointer, and then
	 * use that free offset.
	 */
	if (lseek(db->fd, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if ((offset == 0)
	    || (dbbt_chunkread(&nextfree, sizeof(nextfree), 1, db->fd) < 1)
	    ) {
		offset = lseek(db->fd, 0, SEEK_END);
		nextfree = 0x80000000;
	}
	if (lseek(db->fd, sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if (dbbt_chunkwrite(&nextfree, sizeof(nextfree), 1, db->fd) < 0) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	if (dbbt_write_record(db, offset, &record)) {
		qdb_int__sig_unblock();
		return 1;
	}

	/*
	 * Now attach the new record to its parent, if applicable.
	 */
	if (parent > 0) {
		if (dbbt_read_record(db, parent, &record)) {
			qdb_int__sig_unblock();
			return 1;
		}
		if (x < 0) {
			record.lower = offset;
		} else {
			record.higher = offset;
		}
		if (dbbt_write_record(db, parent, &record)) {
			qdb_int__sig_unblock();
			return 1;
		}
	}

	qdb_int__sig_unblock();

	return 0;
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_obtree_firstkey(qdbint_t db)
{
	struct bt_record record;
	qdb_datum key;

	key.data = NULL;
	key.size = 0;

	if (lseek(db->fd, 2 * sizeof(unsigned long), SEEK_SET) ==
	    (off_t) - 1)
		return key;

	if (dbbt_chunkread(&record, BT_RECORD_SIZE, 1, db->fd) < 1) {
		return key;
	}

	record.token[BT_TOKEN_MAX - 1] = 0;

	key.data = (unsigned char *) strdup((char *) (record.token));
	key.size = strlen((char *) (record.token));

	return key;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_obtree_nextkey(qdbint_t db, qdb_datum key)
{
	struct bt_record record;
	unsigned long offset, parent;
	qdb_datum newkey;

	newkey.data = NULL;
	newkey.size = 0;

	if (key.data == NULL) {
		return newkey;
	}

	dbbt_find_token(db, key, &record, &offset, &parent);

	if (offset < 1) {
		return newkey;
	}

	if (lseek(db->fd, offset + BT_RECORD_SIZE, SEEK_SET) ==
	    (off_t) - 1) {
		return newkey;
	}

	do {
		if (dbbt_chunkread(&record, BT_RECORD_SIZE, 1, db->fd) < 1) {
			return newkey;
		}
	} while (record.lower & 0x80000000);

	record.token[BT_TOKEN_MAX - 1] = 0;

	newkey.data = (unsigned char *) strdup((char *) (record.token));
	newkey.size = strlen((char *) (record.token));

	return newkey;
}


/*
 * Reposition the given record in the binary tree, by finding an existing
 * record to link it to. Returns nonzero on error.
 */
static int qdb_obtree_delete__reposition(qdbint_t db, unsigned long offset,
					 char *token)
{
	struct bt_record record;
	unsigned long offs, parent;
	qdb_datum key;
	int x;

	key.data = (unsigned char *) token;
	key.size = strlen(token);

	x = dbbt_find_token(db, key, &record, &offs, &parent);

	if (parent < 1)
		return 1;

	if (dbbt_read_record(db, parent, &record))
		return 1;

	if (x < 0) {
		record.lower = offset;
	} else {
		record.higher = offset;
	}

	if (dbbt_write_record(db, parent, &record))
		return 1;

	return 0;
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_obtree_delete(qdbint_t db, qdb_datum key)
{
	struct bt_record record, recparent, reclower, rechigher;
	unsigned long offset, parent, nextfree;

	int x;

	if (db == NULL)
		return 1;

	if (key.size < 1)
		return 1;

	x = dbbt_find_token(db, key, &record, &offset, &parent);
	if (offset < 1)
		return 1;

	/*
	 * Get a copy of the lower and higher records, if any.
	 */
	if (record.lower > 0) {
		if (dbbt_read_record(db, record.lower, &reclower))
			return 1;
	}

	if (record.higher > 0) {
		if (dbbt_read_record(db, record.higher, &rechigher))
			return 1;
	}

	qdb_int__sig_block();

	/*
	 * Remove the link to this record from its parent.
	 */
	if (parent > 0) {
		if (dbbt_read_record(db, parent, &recparent)) {
			qdb_int__sig_unblock();
			return 1;
		}
		if (x < 0) {
			recparent.lower = 0;
		} else {
			recparent.higher = 0;
		}
		if (dbbt_write_record(db, parent, &recparent)) {
			qdb_int__sig_unblock();
			return 1;
		}
	}


	/*
	 * Re-attach any children of this record to the database.
	 */
	if (record.lower > 0)
		qdb_obtree_delete__reposition(db, record.lower,
					      (char *) (reclower.token));
	if (record.higher > 0)
		qdb_obtree_delete__reposition(db, record.higher,
					      (char *) (rechigher.token));

	/*
	 * Now we add this record's offset to the head of the "free records"
	 * linked list.
	 */
	if (lseek(db->fd, sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	nextfree = 0x80000000;
	if (dbbt_chunkread(&nextfree, sizeof(nextfree), 1, db->fd) < 0) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	if (lseek(db->fd, sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	offset |= 0x80000000;
	if (dbbt_chunkwrite(&offset, sizeof(offset), 1, db->fd) < 0) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	offset &= 0x7FFFFFFF;

	if (lseek(db->fd, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	if (dbbt_chunkwrite(&nextfree, sizeof(nextfree), 1, db->fd) < 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}

	qdb_int__sig_unblock();

	return 0;
}


/*
 * Temporarily release the lock on the database.
 */
void qdb_obtree_unlock(qdbint_t db)
{
#ifdef HAVE_FCNTL
	dbbt_lock(db, F_UNLCK);
#endif
}


/*
 * Reassert the lock on the database.
 */
void qdb_obtree_relock(qdbint_t db)
{
#ifdef HAVE_FCNTL
	dbbt_lock(db, db->locktype);
#endif
	db->gotheadoffs = 0;
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_obtree_error(void)
{
	return bt_lasterror;
}

#endif				/* USING_OBTREE */

/* EOF */
