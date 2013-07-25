/*
 * Global program option structure and the parsing function prototype.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _OPTIONS_H
#define _OPTIONS_H 1

struct opts_s;
typedef struct opts_s *opts_t;

typedef enum {
	ACTION_NONE,
	ACTION_TEST,
	ACTION_MARK_SPAM,
	ACTION_MARK_NONSPAM,
	ACTION_TRAIN,
	ACTION_PRUNE,
	ACTION_DUMP,
	ACTION_RESTORE,
	ACTION_TOKENS,
	ACTION_BENCHMARK,
	ACTION_MERGE,
	ACTION__MAX
} action_t;

struct opts_s {           /* structure describing run-time options */
	char *program_name;            /* name the program is running as */
	char *database;                /* location of the database file */
	char *globaldb;                /* location of global database */
	char *globaldb2;               /* location of 2nd global database */
	char *plainmap;                /* location of plaintext map */
	void *dbr1;                    /* first db handle, if any */
	void *dbr2;                    /* second db handle, if any */
	void *dbr3;                    /* third db handle, if any */
	void *plaindata;               /* plaintext working data */
	int db1weight;                 /* weighting multiplier for db 1 */
	int db2weight;                 /* weighting multiplier for db 2 */
	int db3weight;                 /* weighting multiplier for db 3 */
	void *dbw;                     /* db handle to write to, if any */
	void *inbuf;                   /* stdin replacement, if any */
	long inbufsize;                /* size of stdin replacement */
	unsigned char modify_subject;  /* whether to modify subject line */
	unsigned char no_header;       /* set if not to add an X-Spam line */
	unsigned char add_rating;      /* set if adding X-Spam-Rating line */
	unsigned char add_stars;       /* set if adding X-Spam-Level line */
	unsigned char no_filter;       /* set if we're not filtering */
	double threshold;              /* spam threshold (default 0.9) */
	unsigned char allowlist;       /* set if allow-list is enabled */
	unsigned char denylist;        /* set if deny-list is enabled */
	unsigned char modifydenylist;  /* set if acting on the deny-list */
	unsigned int weight;           /* weighting to use when marking */
	unsigned char noautoprune;     /* set if we've not to auto-prune */
	unsigned char showprune;       /* show verbose prune indicator */
	unsigned int loglevel;         /* logging level (default 0) */
	unsigned int min_token_count;  /* min tokens before giving a score */
	unsigned long prune_max;       /* max tokens to prune at once */
	char *subject_marker;          /* string to add to subject if spam */
	char *header_marker;           /* string to set X-Spam header to if spam */
	char *mergefrom;               /* database to merge data from */
	char *emailonly;               /* email address to use in -e mode */
	char *emailonly2;              /* extra email address for -e */
	int argc;                      /* number of non-option arguments */
	action_t action;               /* what action we are to take */
	char **argv;                   /* array of non-option arguments */
};

extern opts_t opts_parse(int, char **);
extern void opts_free(opts_t);

#endif /* _OPTIONS_H */

/* EOF */
