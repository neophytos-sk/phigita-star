/*
 * Functions for dumping and restoring the spam database, and for dumping
 * tokens from a message.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


/*
 * Dump the tokens from the given message on stdout, returning nonzero on
 * error.
 */
int spam_dumptokens(opts_t opts, msg_t msg)
{
	spam_t spam;
	long i;

	spam = spam_tokenise(opts, msg, NULL, NULL, NULL, 1, 1, 1);
	if (spam == NULL)
		return 1;

	for (i = 0; i < spam->token_count; i++) {
		printf("%ld\t%.*s\n",
		       spam->tarray[i]->count,
		       spam->tarray[i]->length, spam->tarray[i]->token);
	}

	spam_free(spam);

	return 0;
}


/*
 * Dump the database on stdout in text form, returning nonzero on error.
 */
int spam_db_dump(opts_t opts)
{
	FILE *fptr;
	qdb_t db;
	qdb_datum key, val, nextkey;
	long a, b, c;
	time_t t;

	if ((opts->argc == 1) && (opts->argv[0])
	    && (strcmp(opts->argv[0], "-") != 0)) {
		struct stat outsb, sb;

		/*
		 * Before trying to write to the file, check it's not the
		 * same file as any of the databases. We don't care if
		 * someone moves it in the middle of us trying something.
		 */
		if (stat(opts->argv[0], &outsb)) {	/* RATS: ignore */
			if (errno != ENOENT) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name, opts->argv[0],
					strerror(errno));
				return 1;
			}
		} else {
			/*
			 * File exists; check against databases.
			 */
			if ((opts->dbw)
			    && (fstat(qdb_fd(opts->dbw), &sb) == 0)
			    ) {
				if ((sb.st_dev == outsb.st_dev)
				    && (sb.st_ino == outsb.st_ino)
				    ) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						opts->argv[0],
						_
						("attempted to dump to an existing database"));
					return 1;
				}
			}

			if ((opts->dbr1)
			    && (fstat(qdb_fd(opts->dbr1), &sb) == 0)
			    ) {
				if ((sb.st_dev == outsb.st_dev)
				    && (sb.st_ino == outsb.st_ino)
				    ) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						opts->argv[0],
						_
						("attempted to dump to an existing database"));
					return 1;
				}
			}

			if ((opts->dbr2)
			    && (fstat(qdb_fd(opts->dbr2), &sb) == 0)
			    ) {
				if ((sb.st_dev == outsb.st_dev)
				    && (sb.st_ino == outsb.st_ino)
				    ) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						opts->argv[0],
						_
						("attempted to dump to an existing database"));
					return 1;
				}
			}

			if ((opts->dbr3)
			    && (fstat(qdb_fd(opts->dbr3), &sb) == 0)
			    ) {
				if ((sb.st_dev == outsb.st_dev)
				    && (sb.st_ino == outsb.st_ino)
				    ) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						opts->argv[0],
						_
						("attempted to dump to an existing database"));
					return 1;
				}
			}

		}

		/*
		 * Now we've done the checks, so try and open the file for
		 * writing.
		 */

		fptr = fopen(opts->argv[0], "w");
		if (fptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				opts->argv[0], strerror(errno));
			return 1;
		}
	} else {
		fptr = stdout;
	}

	time(&t);

	db = opts->dbw;
	if (db == NULL)
		db = opts->dbr1;
	if (db == NULL)
		db = opts->dbr2;
	if (db == NULL)
		db = opts->dbr3;

	if (db == NULL) {
		fprintf(stderr, "%s: %s\n", opts->program_name,
			_("cannot find a database to dump"));
		return 1;
	}

	a = 0;
	b = 0;
	c = 0;

	key.data = (unsigned char *) " COUNTS";
	key.size = 7;
	val = qdb_fetch(db, key);
	if (val.data != NULL) {
		a = ((long *) (val.data))[0];
		b = ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long))
			c = ((long *) (val.data))[2];
		free(val.data);
		val.data = NULL;
	}

	fprintf(fptr, "# %s %s %s\n", PROGRAM_NAME, _("database dump"),
		VERSION);
	fprintf(fptr, "# %s: %s\n", _("Date of dump"), ctime(&t));
	fprintf(fptr, "COUNT-SPAM %ld\n", a);
	fprintf(fptr, "COUNT-NONSPAM %ld\n", b);
	fprintf(fptr, "COUNT-UPDATES %ld\n\n", c);

	a = 0;
	key.data = (unsigned char *) " SINCEPRUNE";
	key.size = 11;
	val = qdb_fetch(db, key);
	if (val.data != NULL) {
		a = ((long *) (val.data))[0];
		b = ((long *) (val.data))[1];
		free(val.data);
		val.data = NULL;
	}
	fprintf(fptr, "SINCEPRUNE %ld\n\n", a);

	fprintf(fptr, "# %s\t%s\t%s\t%s\n\n", _("Token"), _("Spam"),
		_("Non-Spam"), _("Last Updated"));

	key = qdb_firstkey(db);
	while (key.data != NULL) {
		val.data = NULL;
		if (((key.size == 7)
		     && (strncmp((char *) (key.data), " COUNTS", 7) == 0)
		    ) || ((key.size == 11)
			  &&
			  (strncmp((char *) (key.data), " SINCEPRUNE", 11)
			   == 0)
		    )
		    ) {
			val.data = NULL;
		} else {
			val = qdb_fetch(db, key);
		}
		if (val.data != NULL) {
			a = ((long *) (val.data))[0];
			b = ((long *) (val.data))[1];
			c = 0;
			if (val.size > 2 * sizeof(long))
				c = ((long *) (val.data))[2];
			fprintf(fptr, "%.*s\t%ld\t%ld\t%ld\n", key.size,
				key.data, a, b, c);
			free(val.data);
		}
		nextkey = qdb_nextkey(db, key);
		free(key.data);
		key = nextkey;
	}

	if ((opts->argc == 1) && (opts->argv[0])
	    && (strcmp(opts->argv[0], "-") != 0))
		fclose(fptr);

	return 0;
}


/*
 * Restore the database from stdin in text form, returning nonzero on error.
 */
int spam_db_restore(opts_t opts)
{
	FILE *fptr;
	char linebuf[1024];		 /* RATS: ignore (checked all) */
	char tokenbuf[64];		 /* RATS: ignore (checked all) */
	qdb_t db = NULL;
	qdb_datum key, val;
	long a, b, c;
	long dat[3];
	int got_count = 0;

	if ((opts->argc == 1) && (opts->argv[0])
	    && (strcmp(opts->argv[0], "-") != 0)) {
		fptr = fopen(opts->argv[0], "r");
		if (fptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				opts->argv[0], strerror(errno));
			return 1;
		}
	} else {
		fptr = stdin;
	}

	a = 0;
	b = 0;
	c = 0;

	db = opts->dbw;
	if (db == NULL) {
		fprintf(stderr, "%s: %s\n", opts->program_name,
			_("cannot write to a database"));
		if ((opts->argc == 1) && (opts->argv[0])
		    && (strcmp(opts->argv[0], "-") != 0)) {
			fclose(fptr);
		}
		return 1;
	}

	while (fgets(linebuf, sizeof(linebuf) - 1, fptr) != NULL) {
		linebuf[sizeof(linebuf) - 1] = 0;
		if (linebuf[0] == '#'
		    || linebuf[0] == ' '
		    || linebuf[0] == '\t'
		    || linebuf[0] == '\r' || linebuf[0] == '\n')
			continue;
		switch (got_count) {
		case 0:
			if (sscanf(linebuf, "COUNT-SPAM %ld", &a) == 1)
				got_count++;
			break;
		case 1:
			if (sscanf(linebuf, "COUNT-NONSPAM %ld", &b) == 1)
				got_count++;
			break;
		case 2:
			if (sscanf(linebuf, "COUNT-UPDATES %ld", &c) == 1)
				break;
			qdb_restore_start(db);
			key.data = (unsigned char *) " COUNTS";
			key.size = 7;
			val.data = (unsigned char *) dat;
			val.size = sizeof(dat);
			dat[0] = a;
			dat[1] = b;
			dat[2] = c;
			qdb_store(db, key, val);
			got_count++;
		default:
			c = 0;
			if (sscanf(linebuf, "SINCEPRUNE %ld", &a) == 1) {
				key.data = (unsigned char *) " SINCEPRUNE";
				key.size = 11;
				val.data = (unsigned char *) dat;
				val.size = sizeof(dat);
				dat[0] = a;
				dat[1] = 0;
				dat[2] = 0;
				qdb_store(db, key, val);
			} else if (sscanf(linebuf,	/* RATS: ignore (const fmt) */
					  "%40[\\!?" TOKEN_CHARS "] "	/*s" */
					  "%ld %ld %ld",
					  tokenbuf, &a, &b, &c) >= 3) {
				tokenbuf[sizeof(tokenbuf) - 1] = 0;
				key.data = (unsigned char *) tokenbuf;
				key.size = strlen(tokenbuf);
				val.data = (unsigned char *) dat;
				val.size = sizeof(dat);
				dat[0] = a;
				dat[1] = b;
				dat[2] = c;
				qdb_store(db, key, val);
			}
			break;
		}
	}

	if (got_count > 2) {
		qdb_restore_end(db);
	}

	if ((opts->argc == 1) && (opts->argv[0])
	    && (strcmp(opts->argv[0], "-") != 0)) {
		fclose(fptr);
	}

	return 0;
}

/* EOF */
