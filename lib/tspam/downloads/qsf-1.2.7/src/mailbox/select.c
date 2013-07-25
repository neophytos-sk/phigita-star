/*
 * Select a particular message from a mailbox.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "mailbox.h"
#include "mailboxi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/*
 * Select the given message in the given mailbox by loading it into memory
 * and setting the stdin-replacement stream to be an in-memory file handle.
 *
 * Returns non-zero on error.
 */
int mbox_select(opts_t opts, mbox_t mbox, FILE * fptr, size_t num)
{
	static char *buf = NULL;

	if (buf != NULL) {
		free(buf);
		buf = NULL;
	}

	if (fptr == NULL)
		return 0;

	if (mbox->length[num] < 1) {
		fprintf(stderr, "%s: %s %d: %s\n", opts->program_name,
			_("message"), (int) num + 1,
			_("invalid message size"));
		opts->inbuf = "";
		opts->inbufsize = 1;
		return 1;
	}

	fseek(fptr, mbox->start[num], SEEK_SET);
	buf = calloc(1, mbox->length[num]);
	if (buf == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		opts->inbuf = "";
		opts->inbufsize = 1;
		return 1;
	}

	if (fread(buf, mbox->length[num], 1, fptr) < 1) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("failed to read mailbox"), strerror(errno));
		opts->inbuf = "";
		opts->inbufsize = 1;
		return 1;
	}
	opts->inbuf = buf;
	opts->inbufsize = mbox->length[num];

	return 0;
}

/* EOF */
