/*
 * Internal spam test prototypes, structures, and constants.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _TESTI_H
#define _TESTI_H 1

#ifndef _OPTIONS_H
#include "options.h"
#endif
#ifndef _MESSAGE_H
#include "message.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct spam_s;
typedef struct spam_s *spam_t;

typedef int (*spamtestfunc_t)(opts_t, msg_t, spam_t);

void spam_token_add(opts_t, spam_t, char *, int);

#ifdef __cplusplus
}
#endif

#endif /* _TESTI_H */

/* EOF */
