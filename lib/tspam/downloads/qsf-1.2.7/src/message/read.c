/*
 * Functions for parsing and handling mail messages.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "message.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


/*
 * Read a message into memory (msg->original) from either stdin or an
 * existing buffer (opts->inbuf), aborting if it gets too big.  Returns
 * nonzero on abort, zero on success.
 */
int msg_read(opts_t opts, msg_t msg)
{
	char buffer[1024];		 /* RATS: ignore (checked all) */
	char *newptr;
	long got;

	/*
	 * Just copy inbuf if it's set
	 */
	if (opts->inbuf != NULL) {
		msg->original = malloc(opts->inbufsize);
		if (msg->original == NULL) {
			fprintf(stderr, "%s: %s: %s\n",
				opts->program_name,
				_("malloc failed"), strerror(errno));
			return 1;
		}
		memcpy(msg->original, opts->inbuf, opts->inbufsize);
		msg->original_size = opts->inbufsize;
		return 0;
	}

	/*
	 * Read the entire message into memory from stdin, aborting if it
	 * gets too big
	 */
	while (!feof(stdin)) {
		got = fread(buffer, 1, sizeof(buffer), stdin);

		if (got < 0) {
			fprintf(stderr, "%s: %s: %s\n",
				opts->program_name,
				_("error reading message"),
				strerror(errno));
			return 1;
		}

		if (got == 0)
			break;

		if (got > sizeof(buffer))
			got = sizeof(buffer);

		newptr = realloc(	    /* RATS: ignore (not sensitive) */
					msg->original,
					msg->original_size + got + 64);

		if (newptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n",
				opts->program_name,
				_("realloc failed"), strerror(errno));
			return 1;
		}

		memcpy(newptr + msg->original_size, buffer, got);
		newptr[msg->original_size + got] = 0;
		msg->original = newptr;
		msg->original_size += got;
		if (msg->original_size >= MAX_MESSAGE_SIZE)
			return 1;
	}

	return 0;
}

/* EOF */
