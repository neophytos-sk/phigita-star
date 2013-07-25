/*
 * Database fetch/store functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdlib.h>
#include <string.h>

/*
 * Fetch the given key from the database, trying all databases if
 * applicable; if both databases have a value for that key, they are added
 * together - except for the SINCEPRUNE counter, which is only ever read
 * from the writable database and is read as 0 if all databases are
 * read-only. If the third value is not present, it is 0; if present in more
 * than one database, the highest value is returned.
 */
void spam_fetch(spam_t spam, char *key, int len, long *val1, long *val2,
		long *val3)
{
	qdb_datum dkey, val;
	int needcksum = 0;

	dkey.data = (unsigned char *) key;
	dkey.size = len;

	if ((dkey.size == 11) && (strncmp(key, " SINCEPRUNE", 11) == 0)) {
		*val1 = 0;
		*val2 = 0;
		*val3 = 0;
		if (spam->dbw) {
			val = qdb_fetch(spam->dbw, dkey);
			if (val.data != NULL) {
				*val1 = ((long *) (val.data))[0];
				*val2 = ((long *) (val.data))[1];
				if (val.size > 2 * sizeof(long))
					*val3 = ((long *) (val.data))[2];
				free(val.data);
			}
			return;
		} else {
			return;
		}
	}

	if ((key[0] != ' ')
	    && (key[0] != '!')
	    && (key[0] != '?')
	    && (key[0] != '\\')
	    && (key[0] != '.')
	    ) {
		needcksum = 1;
		dkey.data = spam_checksum(key, len);
		dkey.size = strlen((char *) (dkey.data));
	}

	*val3 = 0;

	val = qdb_fetch(spam->db1, dkey);
	if (val.data != NULL) {
		*val1 += spam->db1weight * ((long *) (val.data))[0];
		*val2 += spam->db1weight * ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long)) {
			long n;
			n = ((long *) (val.data))[2];
			if (n > *val3)
				*val3 = n;
		}
		free(val.data);
	}

	val = qdb_fetch(spam->db2, dkey);
	if (val.data != NULL) {
		*val1 += spam->db2weight * ((long *) (val.data))[0];
		*val2 += spam->db2weight * ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long)) {
			long n;
			n = ((long *) (val.data))[2];
			if (n > *val3)
				*val3 = n;
		}
		free(val.data);
	}

	val = qdb_fetch(spam->db3, dkey);
	if (val.data != NULL) {
		*val1 += spam->db3weight * ((long *) (val.data))[0];
		*val2 += spam->db3weight * ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long)) {
			long n;
			n = ((long *) (val.data))[2];
			if (n > *val3)
				*val3 = n;
		}
		free(val.data);
	}

	if (needcksum)
		free(dkey.data);
}


/*
 * Store the given key into the database that is opened for write access.
 */
void spam_store(opts_t opts, char *key, int len, long val1, long val2,
		long val3)
{
	qdb_datum dkey, dval;
	int needcksum = 0;
	long dat[3];

	dkey.data = (unsigned char *) key;
	dkey.size = len;

	if ((key[0] != ' ')
	    && (key[0] != '!')
	    && (key[0] != '?')
	    && (key[0] != '\\')
	    && (key[0] != '.')
	    ) {
		needcksum = 1;
		dkey.data = spam_checksum(key, len);
		dkey.size = strlen((char *) (dkey.data));
	}

	dval.data = (unsigned char *) dat;
	dval.size = sizeof(dat);
	dat[0] = val1;
	dat[1] = val2;
	dat[2] = val3;
	qdb_store(opts->dbw, dkey, dval);

	if (needcksum) {
		if (opts->plainmap) {
			spam_plaintext_update(opts, (char *) (dkey.data),
					      dkey.size, key, len);
		}
		free(dkey.data);
	}
}


/*
 * Temporarily release the lock on the writable database, if any.
 */
void spam_dbunlock(opts_t opts)
{
	if (opts == NULL)
		return;
	if (opts->dbw == NULL)
		return;
	qdb_unlock(opts->dbw);
}


/*
 * Reassert the lock on the writable database, if any.
 */
void spam_dbrelock(opts_t opts)
{
	if (opts == NULL)
		return;
	if (opts->dbw == NULL)
		return;
	qdb_relock(opts->dbw);
}

/* EOF */
