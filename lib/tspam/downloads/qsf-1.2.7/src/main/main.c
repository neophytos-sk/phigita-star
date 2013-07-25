/*
 * Main program entry point - read the command line options, then perform
 * the appropriate actions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "options.h"
#include "message.h"
#include "spam.h"
#include "database.h"
#include "log.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif
#ifdef HAVE_MCHECK_H
#include <mcheck.h>
#endif


/*
 * Process command-line arguments and set option flags, then call functions
 * to initialise, and finally enter the main loop.
 */
int main(int argc, char **argv)
{
	char buffer[1024];		 /* RATS: ignore (checked all) */
	char filename[1024];		 /* RATS: ignore (checked all) */
	opts_t opts;
	int retcode = 0;
	int needwrite;
	int got, sent, totsent;
	double score;
	qdb_t dbr1, dbr2, dbr3, dbw;
	char *home;
	msg_t msg = NULL;
	int fd = -1;

#ifdef HAVE_MCHECK_H
	if (getenv("MALLOC_TRACE"))	    /* RATS: ignore (value unused) */
		mtrace();
#endif

#ifdef ENABLE_NLS
	setlocale(LC_ALL, "");
	bindtextdomain(PACKAGE, LOCALEDIR);
	textdomain(PACKAGE);
#endif

	opts = opts_parse(argc, argv);
	if (!opts)
		return 1;

	if (opts->action == ACTION_NONE) {
		opts_free(opts);
		return 0;
	}

	atexit(log_free);

	log_add(2, _("version %s initialising"), VERSION);
	log_add(2, _("backends available:%s"), BACKENDS);

	/*
	 * If we're testing, marking, or tokenising, or allow-list or
	 * deny-list updating/querying (having not been given an email
	 * address), we need to read a message from standard input before
	 * proceeding.
	 */
	if (((opts->action == ACTION_TEST)
	     || (opts->action == ACTION_MARK_SPAM)
	     || (opts->action == ACTION_MARK_NONSPAM)
	    ) && ((opts->emailonly == NULL)
		  || (strcmp(opts->emailonly, "MSG") == 0)
	    )
	    ) {
		msg = msg_parse(opts);
		if (msg == NULL) {
			log_add(2, "%s", _("failed to parse message"));
			log_errdump(opts->program_name);
			opts_free(opts);
			return 1;
		} else if (msg->content == NULL) {
			if (opts->emailonly) {
				fprintf(stderr, "%s: %s\n",
					opts->program_name,
					_
					("message is too large or has no content"));
				log_add(2, "%s",
					_("failed to parse message"));
				log_errdump(opts->program_name);
			} else if ((opts->action != ACTION_MARK_SPAM)
				   && (opts->action != ACTION_MARK_NONSPAM)
				   && (!opts->no_filter)
			    ) {
				msg_dump(msg);
			} else {
				log_add(2, "%s",
					_("failed to parse message"));
				log_errdump(opts->program_name);
			}
			msg_free(msg);
			while (!feof(stdin)) {
				got =
				    fread(buffer, 1, sizeof(buffer),
					  stdin);
				if ((got > 0)
				    && ((unsigned int) got >
					sizeof(buffer)))
					got = sizeof(buffer);
				if (opts->emailonly
				    || opts->no_filter
				    || (opts->action == ACTION_MARK_SPAM)
				    || (opts->action ==
					ACTION_MARK_NONSPAM)
				    )
					continue;
				totsent = 0;
				if (got > 0) {
					sent = fwrite(buffer + totsent, 1,
						      got, stdout);
					if (sent <= 0)
						break;
					totsent += sent;
					got -= sent;
				} else {
					break;
				}
			}
			retcode = (opts->emailonly ? 1 : 0);
			opts_free(opts);
			return retcode;
		}
	}

	/*
	 * If we're just tokenising, just do that, then exit. If the message
	 * cannot be parsed, do not dump it on stdout.
	 */
	if (opts->action == ACTION_TOKENS) {
		msg = msg_parse(opts);
		if (msg == NULL) {
			opts_free(opts);
			return 1;
		}
		retcode = spam_dumptokens(opts, msg);
		msg_free(msg);
		opts_free(opts);
		return retcode;
	}

	/*
	 * From this point on, we're going to need databases; if none was
	 * specified on the command line, we open both /var/lib/qsfdb and
	 * ~/.qsfdb.
	 */

	dbr1 = NULL;			    /* first database to read from */
	dbr2 = NULL;			    /* second database to read from */
	dbr3 = NULL;			    /* third database to read from */
	dbw = NULL;			    /* database to write to (=dbr1 or dbr2 or NULL) */

	/*
	 * Work out whether we need write access.
	 */
	switch (opts->action) {
	case ACTION_DUMP:
	case ACTION_RESTORE:
	case ACTION_TRAIN:
	case ACTION_MARK_SPAM:
	case ACTION_MARK_NONSPAM:
	case ACTION_PRUNE:
	case ACTION_MERGE:
		needwrite = 1;
		break;
	default:
		needwrite = 0;
		break;
	}

	log_add(3, "%s: %s", _("need write access to a database"),
		needwrite ? _("yes") : _("no"));

	/*
	 * Now determine database locations, and open them.
	 */

	if ((opts->action == ACTION_BENCHMARK)
	    && (opts->database)
	    && (strncasecmp(opts->database, "mysql:", 6) == 0)
	    ) {

		/*
		 * Benchmarking mode, with a MySQL database. Open the
		 * database ready for use.
		 */

		filename[0] = 0;	    /* for remove() below */

		dbr1 = qdb_open(opts->database, QDB_READWRITE);
		dbw = dbr1;
		if (dbr1 == NULL) {
			log_add(1, "%s: %s: %s", opts->database,
				_("failed to open database"), qdb_error());
			fprintf(stderr, "%s: %s: %s: %s\n",
				opts->program_name,
				opts->database,
				_("failed to open database"), qdb_error());
			retcode = 1;
		} else {
			log_add(2, "%s: [%s] %s",
				_("using database (rw)"),
				qdb_type(dbr1), opts->database);
			printf("%s: %s\n", _("Backend type"),
			       qdb_type(dbr1));
		}

	} else if (opts->action == ACTION_BENCHMARK) {

		/*
		 * Benchmarking mode. Create a temporary file (which is
		 * deleted after opening) for the database.
		 */

#ifdef P_tmpdir
#ifdef HAVE_SNPRINTF
		snprintf(filename, sizeof(filename), "%.*s",
#else
		sprintf(filename, "%.*s",   /* RATS: ignore (OK) */
#endif
			(int) (sizeof(filename) - 1),
			P_tmpdir "/qsfXXXXXX");
#else
#ifdef HAVE_SNPRINTF
		snprintf(filename, sizeof(filename), "%.*s",
#else
		sprintf(filename, "%.*s",   /* RATS: ignore (OK) */
#endif
			(int) (sizeof(filename) - 1), "/tmp/qsfXXXXXX");
#endif

#ifdef HAVE_MKSTEMP
		fd = mkstemp(filename);
#else
		fd = -1;
		if (tmpnam(filename) != NULL) {	/* RATS: ignore (OK) */
			fd = open(filename, /* RATS: ignore (OK) */
				  O_RDWR | O_CREAT | O_EXCL,
				  S_IRUSR | S_IWUSR);
		}
#endif
		if (fd < 0) {
			fprintf(stderr, "%s: %s: %s: %s\n",
				opts->program_name,
				filename,
				_("failed to create temporary file"),
				strerror(errno));
			retcode = 1;
		} else {
			char newfilename[4096];	/* RATS: ignore (checked) */
			char newtype[64];	/* RATS: ignore (checked) */

			newtype[0] = 0;
			if (opts->database)
				sscanf(opts->database, "%32[0-9A-Za-z]",
				       newtype);

			if (newtype[0] != 0) {
#ifdef HAVE_SNPRINTF
				snprintf(newfilename, sizeof(newfilename),
					 "%.*s:%.*s", 32,
#else
				sprintf(newfilename, "%.*s:%.*s", 32,	/* RATS: ignore (OK) */
#endif
					newtype,
					(int) (sizeof(filename) - 1 -
					       strlen(newtype)), filename);
			}

			chmod(filename,	    /* RATS: ignore (not important) */
			      S_IRUSR | S_IWUSR);
			dbr1 =
			    qdb_open(newtype[0] ==
				     0 ? filename : newfilename,
				     QDB_READWRITE);
			dbw = dbr1;
			if (dbr1 == NULL) {
				log_add(1, "%s: %s: %s", filename,
					_("failed to open database"),
					qdb_error());

				fprintf(stderr, "%s: %s: %s: %s\n",
					opts->program_name,
					filename,
					_("failed to open database"),
					qdb_error());
				retcode = 1;
			} else {
				log_add(2, "%s: [%s] %s",
					_("using database (rw)"),
					qdb_type(dbr1), filename);
			}
			close(fd);
			remove(filename);   /* RATS: ignore (no race) */

			printf("%s: %s\n", _("Backend type"),
			       qdb_type(dbr1));
		}

	} else if (opts->database == NULL) {

		/*
		 * Non-benchmarking mode, and no database specified. Work
		 * out the best databases to use, and open them.
		 */

		if (opts->globaldb) {
#ifdef HAVE_SNPRINTF
			snprintf(buffer, sizeof(buffer), "%.*s",
#else
			sprintf(buffer, "%.*s",	/* RATS: ignore (OK) */
#endif
				(int) (sizeof(buffer) - 1),
				opts->globaldb);
		} else {
#ifdef HAVE_SNPRINTF
			snprintf(buffer, sizeof(buffer),
#else
			sprintf(buffer,	    /* RATS: ignore (OK) */
#endif
				"%.*s",
				(int) (sizeof(buffer) - 1),
				"/var/lib/" PACKAGE "db");
		}

		if (needwrite) {
			if (opts->action == ACTION_RESTORE) {
				dbr1 = qdb_open(buffer, QDB_NEW);
			} else {
				dbr1 = qdb_open(buffer, QDB_READWRITE);
			}
		}

		if (dbr1 == NULL) {
			dbr1 = qdb_open(buffer, QDB_READONLY);
			if (dbr1)
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr1), buffer);
		} else {
			dbw = dbr1;
			log_add(2, "%s: [%s] %s", _("using database (rw)"),
				qdb_type(dbr1), buffer);
		}

		home = getenv("HOME");	    /* RATS: ignore (sanitised) */
		if (home == NULL)
			home = "/";

		if (strlen(home) /* RATS: ignore */ >(sizeof(buffer) - 64))
			home = "/";

#ifdef HAVE_SNPRINTF
		snprintf(buffer, sizeof(buffer),	/* RATS: ignore (OK) */
			 "%s/.%sdb", home, PACKAGE);
#else
		sprintf(buffer,		    /* RATS: ignore (checked above) */
			"%s/.%.*sdb", home,
			(int) (sizeof(buffer) - 8 -
			       strlen(home) /* RATS: ignore */ ),
			PACKAGE);
#endif

		if (needwrite) {
			if (opts->action == ACTION_RESTORE) {
				dbr2 = qdb_open(buffer, QDB_NEW);
			} else {
				dbr2 = qdb_open(buffer, QDB_READWRITE);
			}
		}

		if (dbr2 == NULL) {
			dbr2 = qdb_open(buffer, QDB_READONLY);
			if (dbr2)
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr2), buffer);
		} else if (dbw == NULL) {
			dbw = dbr2;
			log_add(2, "%s: [%s] %s", _("using database (rw)"),
				qdb_type(dbr2), buffer);
		}

		/*
		 * Weight the per-user database at 10 times the
		 * weighting of the global database.
		 */
		if (dbr2)
			opts->db2weight = 10;

		if (opts->globaldb2) {
#ifdef HAVE_SNPRINTF
			snprintf(buffer, sizeof(buffer),
#else
			sprintf(buffer,	    /* RATS: ignore (OK) */
#endif
				"%.*s", (int) (sizeof(buffer) - 1),
				opts->globaldb2);
		} else {
#ifdef HAVE_SNPRINTF
			snprintf(buffer, sizeof(buffer), "%.*s",
#else
			sprintf(buffer, "%.*s",	/* RATS: ignore (OK) */
#endif
				(int) (sizeof(buffer) - 1),
				"/var/lib/" PACKAGE "db2");
		}

		if (dbr3 == NULL) {
			dbr3 = qdb_open(buffer, QDB_READONLY);
			if (dbr3)
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr3), buffer);
		}

		if (dbr3) {
			/*
			 * Weight the first global database as twice
			 * as "heavy" as this one.
			 */
			opts->db1weight = 2;
			opts->db3weight = 1;
		}

	} else {

		/*
		 * Non-benchmarking mode, and a database has been specified.
		 * Open all available databases.
		 */

		dbr1 = qdb_open(opts->database, QDB_READWRITE);

		if (dbr1 == NULL) {
			dbr1 = qdb_open(opts->database, QDB_READONLY);
			if (dbr1)
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr1), opts->database);
		} else {
			dbw = dbr1;
			log_add(2, "%s: [%s] %s", _("using database (rw)"),
				qdb_type(dbr1), opts->database);
		}

		if (dbr1 == NULL) {
			log_add(1, "%s: %s: %s", opts->database,
				_("failed to open database"), qdb_error());
			fprintf(stderr, "%s: %s: %s: %s\n",
				opts->program_name, opts->database,
				_("failed to open database"), qdb_error());
			retcode = 1;
		} else {
			/*
			 * Weight the per-user database at 10 times the
			 * weighting of the global database.
			 */
			opts->db1weight = 10;
		}

		if (opts->globaldb) {
			dbr2 = qdb_open(opts->globaldb, QDB_READONLY);
			if (dbr2 == NULL) {
				log_add(1, "%s: %s: %s", opts->globaldb,
					_("failed to open database"),
					qdb_error());
				fprintf(stderr, "%s: %s: %s: %s\n",
					opts->program_name, opts->globaldb,
					_("failed to open database"),
					qdb_error());
				retcode = 1;
			} else {
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr2), opts->globaldb);
			}
		}

		if (opts->globaldb2) {
			dbr3 = qdb_open(opts->globaldb2, QDB_READONLY);
			if (dbr3 == NULL) {
				log_add(1, "%s: %s: %s",
					opts->globaldb2,
					_("failed to open database"),
					qdb_error());
				fprintf(stderr, "%s: %s: %s: %s\n",
					opts->program_name,
					opts->globaldb2,
					_("failed to open database"),
					qdb_error());
				retcode = 1;
			} else {
				log_add(2, "%s: [%s] %s",
					_("using database (ro)"),
					qdb_type(dbr3), opts->globaldb2);
				/*
				 * Weight the first global database as twice
				 * as "heavy" as this one.
				 */
				opts->db2weight = 2;
				opts->db3weight = 1;
			}
		}
	}

	opts->dbr1 = dbr1;
	opts->dbr2 = dbr2;
	opts->dbr3 = dbr3;
	opts->dbw = dbw;

	if (opts->dbr1)
		log_add(3, "%s %d: %d", _("weight of database"), 1,
			opts->db1weight);
	if (opts->dbr2)
		log_add(3, "%s %d: %d", _("weight of database"), 2,
			opts->db2weight);
	if (opts->dbr3)
		log_add(3, "%s %d: %d", _("weight of database"), 3,
			opts->db3weight);

	if (retcode) {
		/*
		 * Error condition from earlier - clean up and exit.
		 */
		if ((opts->action != ACTION_MARK_SPAM)
		    && (opts->action != ACTION_MARK_NONSPAM)
		    && (!opts->no_filter)
		    ) {
			msg_dump(msg);
		} else {
			log_errdump(opts->program_name);
		}
		opts_free(opts);
		qdb_close(dbr1);
		qdb_close(dbr2);
		qdb_close(dbr3);
		return retcode;
	}

	if (opts->emailonly) {
		/*
		 * Allow-list and deny-list manipulation / querying mode.
		 */
		if (strcmp(opts->emailonly, "MSG") == 0) {
			if ((msg) && (msg->sender))
				opts->emailonly = msg->sender;
			if ((msg) && (msg->envsender))
				opts->emailonly2 = msg->envsender;
		}
		if (opts->denylist) {
			retcode = spam_denylist_manage(opts);
		} else {
			retcode = spam_allowlist_manage(opts);
		}
		log_errdump(opts->program_name);
		opts_free(opts);
		qdb_close(dbr1);
		qdb_close(dbr2);
		qdb_close(dbr3);
		if (msg)
			msg_free(msg);
		return retcode;
	}

	switch (opts->action) {
	case ACTION_DUMP:
		/*
		 * Database dump mode.
		 */
		retcode = spam_db_dump(opts);
		log_errdump(opts->program_name);
		break;
	case ACTION_RESTORE:
		/*
		 * Database restore mode.
		 */
		retcode = spam_db_restore(opts);
		log_errdump(opts->program_name);
		break;
	case ACTION_PRUNE:
		/*
		 * Database prune mode.
		 */
		retcode = spam_db_prune(opts);
		if (retcode == 0) {
			printf("%s", _("Optimising database..."));
			qdb_optimise(dbw);
			printf(" %s\n", _("done"));
		}
		log_errdump(opts->program_name);
		break;
	case ACTION_TRAIN:
		/*
		 * Training mode.
		 */
		retcode = spam_train(opts);
		log_errdump(opts->program_name);
		break;
	case ACTION_BENCHMARK:
		/*
		 * Benchmarking mode.
		 */
		retcode = spam_benchmark(opts);
		qdb_close(dbr1);
		remove(filename);	    /* RATS: ignore (no race) */
		dbr1 = NULL;
		/*
		 * We close the database here, instead of leaving it until
		 * later, so that we can remove the file as well.
		 */
		log_errdump(opts->program_name);
		break;
	case ACTION_MERGE:
		/*
		 * Database merge mode.
		 */
		retcode = spam_db_merge(opts);
		/*
		 * Note we are closing opts->dbr1 etc instead of our dbr1
		 * etc because spam_db_merge() shuffles them around.
		 */
		qdb_close(opts->dbr1);
		qdb_close(opts->dbr2);
		qdb_close(opts->dbr3);
		dbr1 = NULL;
		dbr2 = NULL;
		dbr3 = NULL;
		log_errdump(opts->program_name);
		break;
	case ACTION_MARK_SPAM:
		retcode = spam_update(opts, msg, SPAM);
		msg_free(msg);
		log_errdump(opts->program_name);
		break;
	case ACTION_MARK_NONSPAM:
		retcode = spam_update(opts, msg, NONSPAM);
		msg_free(msg);
		log_errdump(opts->program_name);
		break;
	case ACTION_TEST:
		score = spam_check(opts, msg);

		if (score < -9999.00) {
			if (!opts->no_filter) {
				msg_dump(msg);
			} else {
				log_errdump(opts->program_name);
			}
			if (msg)
				msg_free(msg);
			opts_free(opts);
			qdb_close(dbr1);
			qdb_close(dbr2);
			qdb_close(dbr3);
			return 0;
		}

		log_add(2, _("raw score: %g"), score);
		log_add(3, _("images found: %d"), msg->num_images);

		if (!opts->no_header)
			msg_spamheader(msg, opts->header_marker, score);
		if (opts->add_rating) {
			msg_spamratingheader(msg, score, opts->threshold);
			if (opts->no_filter) {
				double spamscore, scaledscore;

				spamscore = score;
				if (spamscore < 0)
					spamscore += 0.01;
				spamscore += opts->threshold;
				scaledscore = spamscore * 100.0;
				printf("%d\n", (int) scaledscore);
			}
		}
		if (opts->add_stars)
			msg_spamlevelheader(msg, score, opts->threshold);
		if (score > 0) {
			if (opts->modify_subject)
				msg_spamsubject(msg, opts->subject_marker);
			if (!opts->no_filter) {
				msg_dump(msg);
				retcode = 0;
			} else {
				log_errdump(opts->program_name);
				retcode = 1;
			}
		} else {
			if (!opts->no_filter) {
				msg_dump(msg);
			} else {
				log_errdump(opts->program_name);
			}
			retcode = 0;
		}
		msg_free(msg);
		break;
	default:
		/*
		 * This code should never be reached.
		 */
		log_errdump(opts->program_name);
		fprintf(stderr, "%s: %s\n", opts->program_name,
			_("unknown action, please report this as a bug!"));
		retcode = 1;
		break;
	}

	opts_free(opts);

	qdb_close(dbr1);
	qdb_close(dbr2);
	qdb_close(dbr3);

	return retcode;
}

/* EOF */
