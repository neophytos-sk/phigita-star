/*
 * Make our db functions a wrapper for GDBM.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "database.h"

#ifdef USING_GDBM

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif
#include <unistd.h>
#include <gdbm.h>

struct qdbint_s {
	GDBM_FILE dbf;
#ifndef HAVE_GDBM_FDESC
	int fd;
#endif					 /* !HAVE_GDBM_FDESC */
};


/*
 * Return a file descriptor for the given database, or -1 on error.
 */
int qdb_gdbm_fd(qdbint_t db)
{
	if (db == NULL)
		return -1;
	if (db->dbf == NULL)
		return -1;
#ifdef HAVE_GDBM_FDESC
	return gdbm_fdesc(db->dbf);
#else				/* !HAVE_GDBM_FDESC */
	return db->fd;
#endif				/* HAVE_GDBM_FDESC */
}


/*
 * Return nonzero if the given file is of this database type.
 */
int qdb_gdbm_identify(const char *file)
{
	FILE *fptr;
	unsigned char buf[8];		 /* RATS: ignore (checked) */

	if (file == NULL)
		return 0;
	if (strncasecmp(file, "gdbm:", 5) == 0)
		return 1;

	fptr = fopen(file, "rb");
	if (fptr == NULL)
		return 0;
	if (fread(buf, 4, 1, fptr) < 1) {
		fclose(fptr);
		return 0;
	}

	fclose(fptr);

	buf[4] = 0;

	if ((buf[0] == 0x13)
	    && (buf[1] == 0x57)
	    && (buf[2] == 0x9a)
	    && (buf[3] == 0xce)
	    )
		return 1;

	if ((buf[3] == 0x13)
	    && (buf[2] == 0x57)
	    && (buf[1] == 0x9a)
	    && (buf[0] == 0xce)
	    )
		return 1;

	if (strncmp((char *) buf, "GDBM", 4) == 0)
		return 1;

	return 0;
}


/*
 * Open the given database in the given way (new database, read-only, or
 * read-write); return a qdbint_t or NULL on error.
 */
qdbint_t qdb_gdbm_open(const char *file, qdb_open_t method)
{
	GDBM_FILE dbf = NULL;
	qdbint_t db;
	int tries;

	if (strncasecmp(file, "gdbm:", 5) == 0)
		file += 5;

	for (tries = 0; tries < 60 && dbf == NULL; tries++) {
		switch (method) {
		case QDB_NEW:
			dbf =
			    gdbm_open((char *) file, 512, GDBM_NEWDB,
				      S_IRUSR | S_IWUSR, NULL);
			break;
		case QDB_READONLY:
			dbf =
			    gdbm_open((char *) file, 512, GDBM_READER,
				      S_IRUSR, NULL);
			break;
		case QDB_READWRITE:
			dbf =
			    gdbm_open((char *) file, 512, GDBM_WRCREAT,
				      S_IRUSR | S_IWUSR, NULL);
			break;
		default:
			break;
		}

		if (dbf != NULL)
			break;

		switch (gdbm_errno) {
		case GDBM_CANT_BE_READER:
		case GDBM_CANT_BE_WRITER:
			sleep(1);
			break;
		default:
			return NULL;
		}
	}

	if (dbf == NULL)
		return NULL;

	db = calloc(1, sizeof(*db));
	if (db == NULL) {
		gdbm_close(dbf);
		return NULL;
	}
#ifndef HAVE_GDBM_FDESC
	db->fd = open(file, O_RDONLY);
#endif				/* !HAVE_GDBM_FDESC */

	db->dbf = dbf;
	return db;
}


/*
 * Close the given database.
 */
void qdb_gdbm_close(qdbint_t db)
{
	if (db == NULL)
		return;
#ifndef HAVE_GDBM_FDESC
	if (db->fd >= 0)
		close(db->fd);
#endif				/* !HAVE_GDBM_FDESC */
	gdbm_close(db->dbf);
	free(db);
}


/*
 * Fetch a value from the database. The datum returned needs its val.data
 * free()ing after use. If val.data is NULL, no value was found for the
 * given key.
 */
qdb_datum qdb_gdbm_fetch(qdbint_t db, qdb_datum key)
{
	datum gkey, gval;
	qdb_datum val;

	if (db == NULL) {
		val.data = NULL;
		val.size = 0;
		return val;
	}

	if (key.data == NULL) {
		val.data = NULL;
		val.size = 0;
		return val;
	}

	gkey.dptr = (char *) (key.data);
	gkey.dsize = key.size;

	gval = gdbm_fetch(db->dbf, gkey);

	val.data = (unsigned char *) (gval.dptr);
	val.size = gval.dsize;

	return val;
}


/*
 * Store the given key with the given value into the database, replacing any
 * existing value for that key. Returns nonzero on error.
 */
int qdb_gdbm_store(qdbint_t db, qdb_datum key, qdb_datum val)
{
	datum gkey, gval;

	if (db == NULL)
		return 1;

	if ((key.data == NULL) || (val.data == NULL))
		return 1;

	gkey.dptr = (char *) (key.data);
	gkey.dsize = key.size;
	gval.dptr = (char *) (val.data);
	gval.dsize = val.size;

	return gdbm_store(db->dbf, gkey, gval, GDBM_REPLACE);
}


/*
 * Delete the given key from the database. Returns nonzero on error.
 */
int qdb_gdbm_delete(qdbint_t db, qdb_datum key)
{
	datum gkey;

	if (db == NULL)
		return 1;

	if (key.data == NULL)
		return 1;

	gkey.dptr = (char *) (key.data);
	gkey.dsize = key.size;

	return gdbm_delete(db->dbf, gkey);
}


/*
 * Return the "first" key in the database, suitable for using with repeated
 * calls to qdb_nextkey() to walk through every key in the database.
 */
qdb_datum qdb_gdbm_firstkey(qdbint_t db)
{
	datum gkey;
	qdb_datum key;

	gkey = gdbm_firstkey(db->dbf);

	key.data = (unsigned char *) (gkey.dptr);
	key.size = gkey.dsize;

	return key;
}


/*
 * Return the "next" key in the database, or key.data=NULL when all keys
 * have been returned.
 */
qdb_datum qdb_gdbm_nextkey(qdbint_t db, qdb_datum key)
{
	datum gkey, newgkey;
	qdb_datum newkey;

	gkey.dptr = (char *) (key.data);
	gkey.dsize = key.size;

	newgkey = gdbm_nextkey(db->dbf, gkey);

	newkey.data = (unsigned char *) (newgkey.dptr);
	newkey.size = newgkey.dsize;

	return newkey;
}


/*
 * Reorganise the database for better efficiency.
 */
void qdb_gdbm_optimise(qdbint_t db)
{
	gdbm_reorganize(db->dbf);
}


/*
 * Return a string describing the last database error to occur.
 */
char *qdb_gdbm_error(void)
{
	return (char *) gdbm_strerror(gdbm_errno);
}


#endif				/* USING_GDBM */

/* EOF */
