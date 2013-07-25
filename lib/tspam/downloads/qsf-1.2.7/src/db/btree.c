/*
 * Binary tree database backend.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"
#include "log.h"

#ifdef USING_BTREE

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
#ifdef HAVE_MMAP
#include <sys/mman.h>
#endif
#ifdef HAVE_UTIME
#include <time.h>
#include <utime.h>
#endif

#define BT_RECORD_SIZE sizeof(struct bt_record)
#define BT_TOKEN_MAX   36

typedef unsigned long bt_ul;

struct bt_record {			 /* single binary tree record */
	bt_ul lower;			 /* offset of "lower" token */
	bt_ul higher;			 /* offset of "higher" token */
	unsigned char token[BT_TOKEN_MAX];	/* RATS: ignore - 0-term. token */
	long data[3];			 /* token data (i.e. the counts) */
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
#ifdef HAVE_MMAP
	unsigned char *data;		 /* mmap()ed database data */
	bt_ul filepos;			 /* current file pointer */
#endif
	char *filename;			 /* filename of database */
	int modified;			 /* flag, set if db modified at all */
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


static off_t dbbt_lseek(qdbint_t db, off_t offset, int whence)
{
#ifdef HAVE_MMAP
	if ((db->data == 0) || (db->filepos < 0) || (whence != SEEK_SET)) {
		db->filepos = lseek(db->fd, offset, whence);
	} else {
		db->filepos = offset;
	}
	return db->filepos;
#else
	return lseek(db->fd, offset, whence);
#endif
}


/*
 * Analogue of fread().
 */
static int dbbt_chunkread_raw(void *ptr, int size, int nmemb, int fd)
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
static int dbbt_chunkwrite_raw(void *ptr, int size, int nmemb, int fd)
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
 * Analogue of fread(), using memory mapped data if possible.
 */
static int dbbt_chunkread(void *ptr, int size, int nmemb, qdbint_t db)
{
#ifdef HAVE_MMAP
	long available, copyable, tocopy;

	if ((db->data == 0) || (db->filepos < 0)) {
		return dbbt_chunkread_raw(ptr, size, nmemb, db->fd);
	}

	if (size < 1)
		return 0;

	available = db->size - db->filepos;

	if (available <= 0)
		return 0;

	copyable = available / size;
	if (copyable < nmemb)
		nmemb = copyable;

	tocopy = nmemb * size;
	memcpy(ptr, db->data + db->filepos, tocopy);
	db->filepos += tocopy;

	return nmemb;
#else				/* !HAVE_MMAP */
	return dbbt_chunkread_raw(ptr, size, nmemb, db->fd);
#endif				/* HAVE_MMAP */
}


/*
 * Analogue of fwrite(), using memory mapped data if possible, remapping
 * after extending the file if not.
 */
static int dbbt_chunkwrite(void *ptr, int size, int nmemb, qdbint_t db)
{
#ifdef HAVE_MMAP
	long available, copyable, tocopy;

	db->modified = 1;

	if ((db->data == 0) || (db->filepos < 0))
		return dbbt_chunkwrite_raw(ptr, size, nmemb, db->fd);

	if (size < 1)
		return 0;

	available = db->size - db->filepos;
	copyable = available / size;
	if (copyable < nmemb) {
		int retval;

		munmap(db->data, db->size);
		db->data = 0;

		lseek(db->fd, db->filepos, SEEK_SET);
		retval = dbbt_chunkwrite_raw(ptr, size, nmemb, db->fd);

		db->size = lseek(db->fd, 0, SEEK_END);
		db->data =
		    mmap(NULL, db->size, PROT_READ | PROT_WRITE,
			 MAP_SHARED, db->fd, 0);
		if (db->data == MAP_FAILED)
			db->data = 0;
		db->filepos = db->size;

		return retval;
	} else {
		tocopy = nmemb * size;
		memcpy(db->data + db->filepos, ptr, tocopy);
		db->filepos += tocopy;

		return nmemb;
	}
#else				/* !HAVE_MMAP */
	return dbbt_chunkwrite_raw(ptr, size, nmemb, db->fd);
#endif				/* HAVE_MMAP */
}


/*
 * Read a record from the database at the given offset into the given record
 * structure, returning nonzero on failure.
 */
static int dbbt_read_record(qdbint_t db, bt_ul offset, bt_record_t record)
{
	int got;

	if (dbbt_lseek(db, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	got = dbbt_chunkread(record, BT_RECORD_SIZE, 1, db);
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
	if (dbbt_lseek(db, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	if (dbbt_chunkwrite(record, BT_RECORD_SIZE, 1, db) < 1) {
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
		dbbt_lseek(db, 4, SEEK_SET);
		dbbt_chunkread(offset, sizeof(*offset), 1, db);
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
 * Mark the block at the given offset as free space by adding it to the head
 * of the free space list. Returns nonzero on error.
 */
static int dbbt_markfree(qdbint_t db, bt_ul offset)
{
	bt_ul nextfree, storeoffs;

	/*
	 * Read the "next free" offset from the free space head block
	 */
	if (dbbt_lseek(db, 4 + sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}
	nextfree = 0x80000000;
	if (dbbt_chunkread(&nextfree, sizeof(nextfree), 1, db) < 0) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	/*
	 * Write the given offset as the new "next free" offset
	 */
	if (dbbt_lseek(db, 4 + sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}
	storeoffs = offset;
	storeoffs |= 0x80000000;
	if (dbbt_chunkwrite(&storeoffs, sizeof(offset), 1, db) < 0) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	/*
	 * Write the old "next free" offset into the block being freed
	 */
	if (dbbt_lseek(db, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}
	if (dbbt_chunkwrite(&nextfree, sizeof(nextfree), 1, db) < 1) {
		bt_lasterror = strerror(errno);
		return 1;
	}

	return 0;
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_btree_identify(const char *file)
{
	FILE *fptr;
	unsigned char buf[8];		 /* RATS: ignore (checked) */

	if (file == NULL)
		return 0;
	if (strncasecmp(file, "btree:", 6) == 0)
		return 1;

	fptr = fopen(file, "rb");
	if (fptr == NULL)
		return 0;
	if (fread(buf, 4, 1, fptr) < 1) {
		fclose(fptr);
		return 0;
	}

	fclose(fptr);

	if (strncmp((char *) buf, "QSF1", 4) == 0)
		return 1;

	return 0;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_btree_open(const char *file, qdb_open_t method)
{
	qdbint_t db;
	int fd = -1;
#ifdef HAVE_FCNTL
	int locktype = F_RDLCK;
#endif

	if (strncasecmp(file, "btree:", 6) == 0)
		file += 6;

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

	db->filename = strdup(file);
	db->fd = fd;
	db->modified = 0;

#ifdef HAVE_FCNTL
	db->locktype = locktype;

	if (dbbt_lock(db, locktype)) {
		close(fd);
		if (db->filename)
			free(db->filename);
		free(db);
		return NULL;
	}
#endif

	db->size = dbbt_lseek(db, 0, SEEK_END);

	/*
	 * If this is a new database, and it's not readonly, write our
	 * header to it and return.
	 */
	if ((db->size < 5) && (method != QDB_READONLY)) {
		dbbt_lseek(db, 0, SEEK_SET);
		dbbt_chunkwrite_raw("QSF1", 4, 1, db->fd);
		db->size = 4;
		db->modified = 1;
#ifdef HAVE_MMAP
		db->filepos = 0;
		db->data =
		    mmap(NULL, db->size,
			 PROT_READ | (method ==
				      QDB_READONLY ? 0 : PROT_WRITE),
			 MAP_SHARED, db->fd, 0);
		if (db->data == MAP_FAILED)
			db->data = 0;
#endif
		return db;
	}

	/*
	 * We now do some simple checks to make sure that the file is a
	 * database of the format we're expecting.
	 */

	/*
	 * If it's shorter than 4 bytes plus 2 long ints, it's not a valid
	 * database.
	 */
	if (db->size < 4 + 2 * sizeof(long)) {
		bt_lasterror = _("invalid database (too small)");
		close(fd);
		if (db->filename)
			free(db->filename);
		free(db);
		return NULL;
	}

	/*
	 * If its size, discounting the two longs at the start, isn't a
	 * multiple of our record size, it's not a valid database.
	 */
	if (((db->size - (4 + 2 * sizeof(long))) % BT_RECORD_SIZE) != 0) {
		bt_lasterror = _("invalid database (irregular size)");
		close(fd);
		if (db->filename)
			free(db->filename);
		free(db);
		return NULL;
	}

	/*
	 * If the first long int (the "head offset") is larger than the size
	 * of the file, this isn't a valid database.
	 */
	{
		bt_ul offset = db->size + 1;
		dbbt_lseek(db, 4, SEEK_SET);
		dbbt_chunkread(&offset, sizeof(offset), 1, db);
		if (offset > db->size) {
			bt_lasterror =
			    _("invalid database (bad head offset)");
			close(fd);
			if (db->filename)
				free(db->filename);
			free(db);
			return NULL;
		}
		dbbt_lseek(db, 4, SEEK_SET);
	}

#ifdef HAVE_MMAP
	db->data =
	    mmap(NULL, db->size,
		 PROT_READ | (method == QDB_READONLY ? 0 : PROT_WRITE),
		 MAP_SHARED, db->fd, 0);
	if (db->data == MAP_FAILED)
		db->data = 0;
#endif

	return db;
}


/*
 * Close the given database.
 */
void qdb_btree_close(qdbint_t db)
{
	if (db == NULL)
		return;

#ifdef HAVE_MMAP
	if (db->data)
		munmap(db->data, db->size);
#endif

#ifdef HAVE_FCNTL
	while (db->lockcount > 0)
		dbbt_lock(db, F_UNLCK);
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
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_btree_fetch(qdbint_t db, qdb_datum key)
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

	val.size = 3 * sizeof(long);
	val.data = calloc(1, val.size);
	if (val.data == NULL) {
		val.size = 0;
		return val;
	}

	((long *) val.data)[0] = record.data[0];
	((long *) val.data)[1] = record.data[1];
	((long *) val.data)[2] = record.data[2];

	return val;
}


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_btree_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	return db->fd;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_btree_store(qdbint_t db, qdb_datum key, qdb_datum val)
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
	if (val.size > 2 * sizeof(long))
		record.data[2] = ((long *) val.data)[2];

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
	if (db->size <= 4 + sizeof(offset)) {

		if (dbbt_lseek(db, 4, SEEK_SET) == (off_t) - 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}
		offset = 4 + 2 * sizeof(offset);
		if (dbbt_chunkwrite(&offset, sizeof(offset), 1, db) < 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		db->gotheadoffs = 0;

		offset = 0;
		if (dbbt_chunkwrite(&offset, sizeof(offset), 1, db) < 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		head.lower = (4 + 2 * sizeof(offset)) + BT_RECORD_SIZE;
		if (dbbt_chunkwrite(&head, BT_RECORD_SIZE, 1, db) < 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		if (dbbt_chunkwrite(&record, BT_RECORD_SIZE, 1, db) < 1) {
			bt_lasterror = strerror(errno);
			qdb_int__sig_unblock();
			return 1;
		}

		db->size = dbbt_lseek(db, 0, SEEK_CUR);
		qdb_int__sig_unblock();
		return 0;
	}

	/*
	 * Get offset of next free space block.
	 */
	if (dbbt_lseek(db, 4 + sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if (dbbt_chunkread(&offset, sizeof(offset), 1, db) < 1) {
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
	if (dbbt_lseek(db, offset, SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if ((offset < 5)
	    || (dbbt_chunkread(&nextfree, sizeof(nextfree), 1, db) < 1)
	    ) {
		offset = dbbt_lseek(db, 0, SEEK_END);
		nextfree = 0x80000000;
	}
	if (dbbt_lseek(db, 4 + sizeof(offset), SEEK_SET) == (off_t) - 1) {
		bt_lasterror = strerror(errno);
		qdb_int__sig_unblock();
		return 1;
	}
	if (dbbt_chunkwrite(&nextfree, sizeof(nextfree), 1, db) < 0) {
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
qdb_datum qdb_btree_firstkey(qdbint_t db)
{
	struct bt_record record;
	qdb_datum newkey;

	newkey.data = NULL;
	newkey.size = 0;

	if (dbbt_lseek(db, 4 + 2 * sizeof(unsigned long) + BT_RECORD_SIZE,
		       SEEK_SET) == (off_t) - 1)
		return newkey;

	do {
		if (dbbt_chunkread(&record, BT_RECORD_SIZE, 1, db) < 1) {
			return newkey;
		}
	} while (record.lower & 0x80000000);

	record.token[BT_TOKEN_MAX - 1] = 0;

	newkey.data = (unsigned char *) strdup((char *) (record.token));
	newkey.size = strlen((char *) (record.token));

	return newkey;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_btree_nextkey(qdbint_t db, qdb_datum key)
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

	if (dbbt_lseek(db, offset + BT_RECORD_SIZE, SEEK_SET) ==
	    (off_t) - 1) {
		return newkey;
	}

	do {
		if (dbbt_chunkread(&record, BT_RECORD_SIZE, 1, db) < 1) {
			return newkey;
		}
	} while (record.lower & 0x80000000);

	record.token[BT_TOKEN_MAX - 1] = 0;

	newkey.data = (unsigned char *) strdup((char *) (record.token));
	newkey.size = strlen((char *) (record.token));

	return newkey;
}


/*
 * Put the given record back into the binary tree, by storing it over again. 
 * Returns nonzero on error.
 */
static int qdb_btree_delete__rewrite(qdbint_t db, bt_record_t record)
{
	qdb_datum key, val;
	struct bt_record newrec;
	unsigned long offset, parent;
	int x;

	key.data = record->token;
	key.size = strlen((char *) (record->token));
	val.data = (void *) (record->data);
	val.size = 3 * sizeof(long);

	if (qdb_btree_store(db, key, val))
		return 1;

	x = dbbt_find_token(db, key, &newrec, &offset, &parent);
	if (offset < 4)
		return 1;

	newrec.lower = record->lower;
	newrec.higher = record->higher;

	qdb_int__sig_block();
	if (dbbt_write_record(db, offset, &newrec)) {
		qdb_int__sig_unblock();
		return 1;
	}

	qdb_int__sig_unblock();

	return 0;
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_btree_delete(qdbint_t db, qdb_datum key)
{
	struct bt_record record, recparent, reclower, rechigher;
	unsigned long offset, parent;

	int x;

	if (db == NULL)
		return 1;

	if (key.size < 1)
		return 1;

	x = dbbt_find_token(db, key, &record, &offset, &parent);
	if (offset < 5)
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
	 * Now we add this record's offset to the head of the "free records"
	 * linked list.
	 */
	if (dbbt_markfree(db, offset)) {
		qdb_int__sig_unblock();
		return 1;
	}

	/*
	 * If there were any direct children, mark them as free as well.
	 */
	if (record.lower > 0) {
		if (dbbt_markfree(db, record.lower)) {
			qdb_int__sig_unblock();
			return 1;
		}
	}
	if (record.higher > 0) {
		if (dbbt_markfree(db, record.higher)) {
			qdb_int__sig_unblock();
			return 1;
		}
	}

	qdb_int__sig_unblock();

	/*
	 * Re-attach any children of this record to the database.
	 */
	if (record.lower > 0) {
		if (qdb_btree_delete__rewrite(db, &reclower)) {
			return 1;
		}
	}
	if (record.higher > 0) {
		if (qdb_btree_delete__rewrite(db, &rechigher)) {
			return 1;
		}
	}

	return 0;
}


/*
 * Temporarily release the lock on the database.
 */
void qdb_btree_unlock(qdbint_t db)
{
#ifdef HAVE_FCNTL
	dbbt_lock(db, F_UNLCK);
#endif
}


/*
 * Reassert the lock on the database.
 */
void qdb_btree_relock(qdbint_t db)
{
#ifdef HAVE_FCNTL
	dbbt_lock(db, db->locktype);
#endif
	db->gotheadoffs = 0;
}


/*
 * Reorganise the database for better efficiency.
 *
 * This is done by dumping all the tokens in this database into a temporary
 * new one, then copying this temporary database over the top of the current
 * database.
 */
void qdb_btree_optimise(qdbint_t db)
{
	char filename[1024];		 /* RATS: ignore (checked all) */
	qdbint_t newdb;
	qdb_datum key, val, nextkey;
	int newdbfd, got;

#ifdef P_tmpdir
#ifdef HAVE_SNPRINTF
	snprintf(filename, sizeof(filename),
#else
	sprintf(filename,		    /* RATS: ignore (checked) */
#endif
		"%.*s", (int) (sizeof(filename) - 1),
		P_tmpdir "/qsfXXXXXX");
#else
#ifdef HAVE_SNPRINTF
	snprintf(filename, sizeof(filename),
#else
	sprintf(filename,		    /* RATS: ignore (checked) */
#endif
		"%.*s", (int) (sizeof(filename) - 1), "/tmp/qsfXXXXXX");
#endif

#ifdef HAVE_MKSTEMP
	newdbfd = mkstemp(filename);
#else
	newdbfd = -1;
	if (tmpnam(filename) != NULL) {	    /* RATS: ignore (OK) */
		newdbfd = open(filename,    /* RATS: ignore (OK) */
			       O_RDWR | O_CREAT | O_EXCL,
			       S_IRUSR | S_IWUSR);
	}
#endif

	if (newdbfd < 0) {
		fprintf(stderr, "%s: %s: %s\n",
			filename,
			_("failed to create temporary file"),
			strerror(errno));
		return;
	}

	newdb = qdb_btree_open(filename, QDB_NEW);
	if (newdb == NULL) {
		close(newdbfd);
		return;
	}

	key = qdb_btree_firstkey(db);
	while (key.data != NULL) {
		val = qdb_btree_fetch(db, key);
		if (val.data != NULL) {
			qdb_btree_store(newdb, key, val);
			free(val.data);
		}
		nextkey = qdb_btree_nextkey(db, key);
		free(key.data);
		key = nextkey;
	}

	qdb_btree_close(newdb);

#ifdef HAVE_MMAP
	munmap(db->data, db->size);
	db->data = 0;
#endif

	qdb_int__sig_block();

	dbbt_lseek(db, 0, SEEK_SET);
	lseek(newdbfd, 0, SEEK_SET);

	do {
		unsigned char buf[4096]; /* RATS: ignore (checked) */

		got = dbbt_chunkread_raw(buf, 1, sizeof(buf), newdbfd);
		if (got > 0)
			dbbt_chunkwrite_raw(buf, 1, got, db->fd);

	} while (got > 0);

	if (ftruncate(db->fd, lseek(db->fd, 0, SEEK_CUR)) != 0) {
		log_add(0, "%s: failed to truncate database: %s",
			db->filename, strerror(errno));
	}

	close(newdbfd);
	remove(filename);

	qdb_int__sig_unblock();

	db->size = dbbt_lseek(db, 0, SEEK_END);
	db->gotheadoffs = 0;

#ifdef HAVE_MMAP
	db->data =
	    mmap(NULL, db->size, PROT_READ | PROT_WRITE, MAP_SHARED,
		 db->fd, 0);
	if (db->data == MAP_FAILED)
		db->data = 0;
	db->filepos = db->size;
#endif
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_btree_error(void)
{
	return bt_lasterror;
}

#endif				/* USING_BTREE */

/* EOF */
