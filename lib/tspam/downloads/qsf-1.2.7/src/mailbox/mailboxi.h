/*
 * Internal definitions for the mailbox functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _MAILBOXI_H
#define _MAILBOXI_H 1

#ifdef __cplusplus
extern "C" {
#endif

struct mbox_s {            /* structure describing a mailbox */
	size_t count;         /* number of messages */
	size_t alloced;       /* size of array */
	size_t *start;        /* array of message start offsets */
	size_t *length;       /* array of message sizes */
};

#ifdef __cplusplus
}
#endif

#endif /* _MAILBOXI_H */

/* EOF */
