/*
 * Spam handling prototypes, structures, and constants.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _SPAM_H
#define _SPAM_H 1

#ifndef _OPTIONS_H
#include "options.h"
#endif
#ifndef _MESSAGE_H
#include "message.h"
#endif

enum {
	SPAM,
	NONSPAM
};

#define TOKEN_CHARS "0123456789" \
                    "abcdefghijklmnopqrstuvwxyz" \
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
                    "_'.$£-!"

double spam_check(opts_t, msg_t);
int spam_update(opts_t, msg_t, int);
int spam_dumptokens(opts_t, msg_t);
int spam_db_dump(opts_t);
int spam_db_restore(opts_t);
int spam_db_prune(opts_t);
int spam_db_merge(opts_t);
int spam_train(opts_t);
int spam_benchmark(opts_t);
int spam_allowlist_manage(opts_t);
int spam_denylist_manage(opts_t);
void spam_plaintext_update(opts_t, char *, int, char *, int);
void spam_plaintext_free(opts_t);

#endif /* _SPAM_H */

/* EOF */
