/*
 * Functions for merging one spam database into another.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include "database.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


/*
 * Merge the contents of another spam database into the currently writable
 * one.  Returns nonzero on error.
 */
int spam_db_merge(opts_t opts)
{
	void *dbfrom;
	void *dbto;
	spam_t spam;
	qdb_datum key, nextkey;
	char **keylist = NULL;
	char **newkeylist;
	long keylistsize = 0;
	long numkeys = 0;
	long i, a, b, c;

	dbto = opts->dbw;

	if (opts->dbr1 == opts->dbw) {

		if (opts->dbr2)
			qdb_close(opts->dbr2);

		if (opts->dbr3)
			qdb_close(opts->dbr3);

		opts->dbr2 = qdb_open(opts->mergefrom, QDB_READONLY);

		if (opts->dbr2 == NULL) {
			fprintf(stderr, "%s: %s: %s: %s\n",
				opts->program_name,
				opts->mergefrom,
				_("failed to open database"), qdb_error());
			return 1;
		}

		dbfrom = opts->dbr2;

	} else {

		if (opts->dbr1)
			qdb_close(opts->dbr1);

		opts->dbr1 = qdb_open(opts->mergefrom, QDB_READONLY);

		if (opts->dbr1 == NULL) {
			fprintf(stderr, "%s: %s: %s: %s\n",
				opts->program_name,
				opts->mergefrom,
				_("failed to open database"), qdb_error());
			return 1;
		}

		dbfrom = opts->dbr1;

	}

	spam = calloc(1, sizeof(*spam));
	if (spam == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return 1;
	}

	spam->db1 = dbfrom;
	spam->db2 = dbto;
	spam->db3 = NULL;

	spam->db1weight = 1;
	spam->db2weight = 1;
	spam->db3weight = 1;

	/*
	 * Get list of all keys in the database we're merging from.
	 */
	key = qdb_firstkey(dbfrom);
	while (key.data != NULL) {
		if (keylistsize >= numkeys) {
			keylistsize += 10000;
			if (numkeys > 0) {
				newkeylist = realloc(keylist,	/* RATS: ignore */
						     sizeof(char *) *
						     keylistsize);
			} else {
				newkeylist =
				    malloc(sizeof(char *) * keylistsize);
			}
			if (newkeylist == NULL) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name,
					_("memory allocation failed"),
					strerror(errno));
				free(keylist);
				free(key.data);
				free(spam);
				return 1;
			}
			keylist = newkeylist;
		}

		keylist[numkeys] = calloc(1, key.size + 1);
		if (keylist[numkeys] == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				_("memory allocation failed"),
				strerror(errno));
			free(keylist);
			free(key.data);
			free(spam);
			return 1;
		}

		strncpy(keylist[numkeys], (char *) (key.data), key.size);
		numkeys++;

		nextkey = qdb_nextkey(dbfrom, key);
		free(key.data);
		key = nextkey;
	}

	/*
	 * For each key in the merge-from database, read the combined value
	 * for that key in both the merge-from and, if present, the merge-to
	 * database, then store this combined value into the merge-to
	 * database.
	 */
	for (i = 0; i < numkeys; i++) {
		a = 0;
		b = 0;
		spam_fetch(spam, keylist[i], strlen(keylist[i]), &a, &b,
			   &c);
		spam_store(opts, keylist[i], strlen(keylist[i]), a, b, c);
		free(keylist[i]);
	}

	free(keylist);
	free(spam);

	return 0;
}

/* EOF */
