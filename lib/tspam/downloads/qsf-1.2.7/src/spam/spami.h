/*
 * Internal spam handling prototypes, structures, and constants.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _SPAMI_H
#define _SPAMI_H 1

#ifndef _OPTIONS_H
#include "options.h"
#endif
#ifndef _MESSAGE_H
#include "message.h"
#endif
#ifndef _DATABASE_H
#include "database.h"
#endif
#ifndef _SPAM_H
#include "spam.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct token_s;
typedef struct token_s *token_t;

struct spam_s;
typedef struct spam_s *spam_t;

struct spam_s {            /* structure describing spam state */
	qdb_t db1;               /* first database to read from */
	qdb_t db2;               /* second database to read from */
	qdb_t db3;               /* third database to read from */
	qdb_t dbw;               /* writable database handle */
	int db1weight;           /* weighting for first database */
	int db2weight;           /* weighting for second database */
	int db3weight;           /* weighting for third database */
	int override;            /* if non-zero, override spam_check() */
	token_t tokens;          /* start of token tree */
	long token_count;        /* number of different tokens */
	token_t *tarray;         /* token tree arranged as an array */
	double robx;             /* Robinson "x" value */
	long total_spam;         /* total spam messages seen */
	long total_nonspam;      /* total non-spam messages seen */
	long since_prune;        /* number of updates since last db prune */
	long update_count;       /* counter, increases every update */
	long _idx;               /* index used when filling array */
};

struct token_s {           /* structure describing an email token */
	char *token;             /* pointer to token start */
	int length;              /* length of token */
	long count;              /* number of times token seen */
	long num_spam;           /* times token seen in spam */
	long num_nonspam;        /* times token seen in non-spam */
	long last_updated;       /* update_count at last update */
	double prob_spam;        /* probability this token is spammy */
	token_t higher;          /* pointer to token nearer "Z" */
	token_t lower;           /* pointer to token nearer "A" */
	token_t longer;          /* pointer to longer token */
};

void spam_token_add(opts_t, spam_t, char *, int);
spam_t spam_tokenise(opts_t, msg_t, qdb_t, qdb_t, qdb_t, int, int, int);
void spam_free(spam_t);
void spam_fetch(spam_t, char *, int, long *, long *, long *);
void spam_store(opts_t, char *, int, long, long, long);
void spam_dbunlock(opts_t);
void spam_dbrelock(opts_t);
unsigned char *spam_checksum(char *, int);
int spam_allowlist_match(spam_t, char *);
void spam_allowlist_add(opts_t, char *);
void spam_allowlist_remove(opts_t, char *);
int spam_denylist_match(spam_t, char *);
void spam_denylist_add(opts_t, char *);
void spam_denylist_remove(opts_t, char *);
int spam_test(opts_t, spam_t, msg_t);

#ifdef __cplusplus
}
#endif

#endif /* _SPAMI_H */

/* EOF */
