/*
 * Parse command-line options.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "options.h"
#include "spam.h"
#include "log.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#ifdef HAVE_GETOPT_H
#include <getopt.h>
#endif

#include <unistd.h>

#ifndef HAVE_GETOPT

int minigetopt(int, char **, char *);
extern char *minioptarg;
extern int minioptind, miniopterr, minioptopt;

#define getopt minigetopt
#define optarg minioptarg
#define optind minioptind
#define opterr miniopterr
#define optopt minioptopt

#endif				/* !HAVE_GETOPT */


void display_help(void);
void display_version(void);


/*
 * Free an opts_t object.
 */
void opts_free(opts_t opts)
{
	if (!opts)
		return;
	if (opts->argv)
		free(opts->argv);
	if (opts->plaindata)
		spam_plaintext_free(opts);
	free(opts);
}


/*
 * Parse the given command-line arguments into an opts_t object, handling
 * "help" and "version" options internally.
 *
 * Returns an opts_t, or 0 on error.
 *
 * Note that the contents of *argv[] (i.e. the command line parameters)
 * aren't copied anywhere, just the pointers are copied, so make sure the
 * command line data isn't overwritten or argv[1] free()d or whatever.
 */
opts_t opts_parse(int argc, char **argv)
{
#ifdef HAVE_GETOPT_LONG
	struct option long_options[] = {
		{"help", 0, 0, 'h'},
		{"version", 0, 0, 'V'},
		{"subject", 0, 0, 's'},
		{"subject-marker", 1, 0, 'S'},
		{"header-marker", 1, 0, 'H'},
		{"no-header", 0, 0, 'n'},
		{"rate", 0, 0, 'r'},
		{"rating", 0, 0, 'r'},
		{"add-rating", 0, 0, 'r'},
		{"asterisk", 0, 0, 'A'},
		{"asterisks", 0, 0, 'A'},
		{"stars", 0, 0, 'A'},
		{"add-stars", 0, 0, 'A'},
		{"add-asterisk", 0, 0, 'A'},
		{"add-asterisks", 0, 0, 'A'},
		{"test", 0, 0, 't'},
		{"allowlist", 0, 0, 'a'},
		{"allow-list", 0, 0, 'a'},
		{"denylist", 0, 0, 'y'},
		{"deny-list", 0, 0, 'y'},
		{"plain", 1, 0, 'P'},
		{"plainmap", 1, 0, 'P'},
		{"plain-map", 1, 0, 'P'},
		{"plaintext", 1, 0, 'P'},
		{"plaintextmap", 1, 0, 'P'},
		{"plaintext-map", 1, 0, 'P'},
		{"level", 1, 0, 'L'},
		{"threshold", 1, 0, 'L'},
		{"min-tokens", 1, 0, 'Q'},
		{"mintokens", 1, 0, 'Q'},
		{"email", 1, 0, 'e'},
		{"email-only", 1, 0, 'e'},
		{"mark-spam", 0, 0, 'm'},
		{"mark-nonspam", 0, 0, 'M'},
		{"mark-non-spam", 0, 0, 'M'},
		{"database", 1, 0, 'd'},
		{"global", 1, 0, 'g'},
		{"weight", 1, 0, 'w'},
		{"train", 0, 0, 'T'},
		{"noprune", 0, 0, 'N'},
		{"no-prune", 0, 0, 'N'},
		{"no-autoprune", 0, 0, 'N'},
		{"noautoprune", 0, 0, 'N'},
		{"prune-max", 1, 0, 'X'},
		{"prunemax", 1, 0, 'X'},
		{"prune", 0, 0, 'p'},
		{"trim", 0, 0, 'p'},
		{"dump", 0, 0, 'D'},
		{"restore", 0, 0, 'R'},
		{"tokens", 0, 0, 'O'},
		{"benchmark", 0, 0, 'B'},
		{"merge", 1, 0, 'E'},
		{"verbose", 0, 0, 'v'},
		{0, 0, 0, 0}
	};
	int option_index = 0;
#endif
	char *short_options = "hVsS:H:nrAtoayL:Q:e:mMd:g:P:w:NTX:pDROBE:v";
	int c;
	opts_t opts;

	opts = calloc(1, sizeof(*opts));
	if (!opts) {
		fprintf(stderr,		    /* RATS: ignore (OK) */
			_("%s: option structure allocation failed (%s)"),
			argv[0], strerror(errno));
		fprintf(stderr, "\n");
		return 0;
	}

	opts->program_name = argv[0];

	opts->argc = 0;
	opts->argv = calloc(argc + 1, sizeof(char *));
	if (!opts->argv) {
		fprintf(stderr,		    /* RATS: ignore (OK) */
			_
			("%s: option structure argv allocation failed (%s)"),
			argv[0], strerror(errno));
		fprintf(stderr, "\n");
		opts_free(opts);
		return 0;
	}

	opts->threshold = 0.9;
	opts->min_token_count = 0;
	opts->prune_max = 100000;

	opts->db1weight = 1;
	opts->db2weight = 1;
	opts->db3weight = 1;

	opts->action = ACTION_TEST;
	opts->showprune = 0;

	do {
#ifdef HAVE_GETOPT_LONG
		c = getopt_long(argc, argv, /* RATS: ignore */
				short_options, long_options,
				&option_index);
#else
		c = getopt(argc, argv, short_options);	/* RATS: ignore */
#endif

		if (c < 0)
			continue;

		switch (c) {
		case 'h':
			display_help();
			opts->action = ACTION_NONE;
			return opts;
			break;
		case 'V':
			display_version();
			opts->action = ACTION_NONE;
			return opts;
			break;
		case 's':
			opts->modify_subject = 1;
			break;
		case 'S':
			opts->modify_subject = 1;
			opts->subject_marker = optarg;
			break;
		case 'H':
			opts->header_marker = optarg;
			break;
		case 'n':
			opts->no_header = 1;
			break;
		case 'r':
			opts->add_rating = 1;
			break;
		case 'A':
			opts->add_stars = 1;
			break;
		case 't':
			opts->no_filter = 1;
			break;
		case 'a':
			opts->allowlist = 1;
			break;
		case 'y':
			opts->denylist = 1;
			break;
		case 'L':
			opts->threshold = (double) (atoi(optarg)) / 100;
			break;
		case 'Q':
			opts->min_token_count = atoi(optarg);
			break;
		case 'e':
			opts->emailonly = optarg;
			opts->allowlist = 1;
			break;
		case 'm':
			opts->modifydenylist = 0;
			if (opts->action == ACTION_MARK_SPAM)
				opts->modifydenylist = 1;
			opts->action = ACTION_MARK_SPAM;
			break;
		case 'M':
			opts->modifydenylist = 0;
			if (opts->action == ACTION_MARK_NONSPAM)
				opts->modifydenylist = 1;
			opts->action = ACTION_MARK_NONSPAM;
			break;
		case 'd':
			opts->database = optarg;
			break;
		case 'g':
			if (opts->globaldb) {
				opts->globaldb2 = optarg;
			} else {
				opts->globaldb = optarg;
			}
			break;
		case 'P':
			opts->plainmap = optarg;
			break;
		case 'w':
			opts->weight = atoi(optarg);
			break;
		case 'T':
			opts->action = ACTION_TRAIN;
			opts->showprune = 1;
			break;
		case 'N':
			opts->noautoprune = 1;
			break;
		case 'X':
			opts->prune_max = atol(optarg);
			break;
		case 'p':
			opts->action = ACTION_PRUNE;
			opts->showprune = 1;
			break;
		case 'D':
			opts->action = ACTION_DUMP;
			break;
		case 'R':
			opts->action = ACTION_RESTORE;
			break;
		case 'O':
			opts->action = ACTION_TOKENS;
			break;
		case 'B':
			opts->action = ACTION_BENCHMARK;
			opts->showprune = 1;
			break;
		case 'E':
			opts->action = ACTION_MERGE;
			opts->mergefrom = optarg;
			break;
		case 'v':
			opts->loglevel++;
			break;
		default:
#ifdef HAVE_GETOPT_LONG
			fprintf(stderr,	    /* RATS: ignore (OK) */
				_("Try `%s --help' for more information."),
				argv[0]);
#else
			fprintf(stderr,	    /* RATS: ignore (OK) */
				_("Try `%s -h' for more information."),
				argv[0]);
#endif
			fprintf(stderr, "\n");
			opts_free(opts);
			return 0;
			break;
		}

	} while (c != -1);

	log_level(opts->loglevel);

	if (opts->weight < 1) {
		opts->weight = 1;
	} else if (opts->weight > 8) {
		opts->weight = 8;
	}

	if (opts->threshold < 0.01) {
		opts->threshold = 0.01;
	} else if (opts->threshold > 1.00) {
		opts->threshold = 1.00;
	}

	if (opts->prune_max < 10)
		opts->prune_max = 10;

	while (optind < argc) {
		opts->argv[opts->argc++] = argv[optind++];
	}

	if ((opts->action == ACTION_TRAIN)
	    && ((opts->argc < 2) || (opts->argc > 3))) {
		fprintf(stderr, "%s: %s\n", argv[0],
			_("train syntax: SPAM NONSPAM [MAXROUNDS]"));
		opts_free(opts);
		return 0;
	} else if ((opts->action == ACTION_BENCHMARK)
		   && ((opts->argc < 2) || (opts->argc > 3))) {
		fprintf(stderr, "%s: %s\n", argv[0],
			_("benchmark syntax: SPAM NONSPAM [MAXROUNDS]"));
		opts_free(opts);
		return 0;
	} else if ((opts->action == ACTION_DUMP) && (opts->argc > 1)) {
		fprintf(stderr, "%s: %s\n", argv[0],
			_
			("dump only requires one argument (file to dump to)"));
		opts_free(opts);
		return 0;
	} else if ((opts->action == ACTION_RESTORE) && (opts->argc > 1)) {
		fprintf(stderr, "%s: %s\n", argv[0],
			_
			("restore only requires one argument (file to restore from)"));
		opts_free(opts);
		return 0;
	} else if ((opts->action != ACTION_DUMP)
		   && (opts->action != ACTION_RESTORE)
		   && (opts->action != ACTION_TRAIN)
		   && (opts->action != ACTION_BENCHMARK)
		   && (opts->argc > 0)
	    ) {
		fprintf(stderr, "%s: %s\n", argv[0],
			_
			("spurious extra arguments given on command line"));
		opts_free(opts);
		return 0;
	}

	return opts;
}

/* EOF */
