/*
 * Functions for reading messages from a mailbox.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _MAILBOX_H
#define _MAILBOX_H 1

#ifndef _OPTIONS_H
#include "options.h"
#endif
#ifndef _STDIO_H
#include <stdio.h>
#endif

struct mbox_s;
typedef struct mbox_s *mbox_t;

mbox_t mbox_scan(opts_t, FILE *);
void mbox_free(mbox_t mbox);
size_t mbox_count(mbox_t mbox);
int mbox_select(opts_t, mbox_t, FILE *, size_t);

#endif /* _MAILBOX_H */

/* EOF */
