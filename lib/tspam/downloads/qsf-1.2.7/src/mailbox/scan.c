/*
 * Functions to scan a mailbox for messages.
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

void tick(void);


/*
 * Scan the mailbox on the given file handle, returning an mbox_t describing
 * where each message in the mailbox can be found, or NULL on error.
 */
mbox_t mbox_scan(opts_t opts, FILE * fptr)
{
	char linebuf[1024];		 /* RATS: ignore (size OK) */
	mbox_t mbox;
	int prevnewline = 0;
	size_t pos, filepos;
	size_t *newptr;

	mbox = calloc(1, sizeof(*mbox));
	if (mbox == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return NULL;
	}

	mbox->start = calloc(1, sizeof(pos));
	if (mbox->start == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		free(mbox);
		return NULL;
	}
	mbox->length = calloc(1, sizeof(pos));
	if (mbox->length == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		free(mbox->start);
		free(mbox);
		return NULL;
	}

	mbox->count = 0;
	mbox->alloced = 1;

	filepos = 0;
	while (fgets(linebuf, sizeof(linebuf) - 1, fptr) != NULL) {
		linebuf[sizeof(linebuf) - 1] = 0;
		filepos = ftell(fptr);
		tick();
		if (strrchr(linebuf, '\n') == NULL) {
			prevnewline = 0;
			continue;
		}
		if (prevnewline && (strncmp(linebuf, "From ", 5) == 0)) {
			pos = filepos - strlen(linebuf);
			mbox->length[mbox->count] =
			    pos - mbox->start[mbox->count];
			if (mbox->count >= (mbox->alloced - 1)) {
				mbox->alloced += 4096;
				newptr = realloc(	/* RATS: ignore (OK) */
							mbox->start,
							sizeof(pos) *
							(mbox->alloced));
				if (newptr == NULL) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						_("realloc failed"),
						strerror(errno));
					free(mbox->start);
					free(mbox->length);
					free(mbox);
					return NULL;
				}
				mbox->start = newptr;
				newptr = realloc(	/* RATS: ignore (OK) */
							mbox->length,
							sizeof(pos) *
							(mbox->alloced));
				if (newptr == NULL) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						_("realloc failed"),
						strerror(errno));
					free(mbox->start);
					free(mbox->length);
					free(mbox);
					return NULL;
				}
				mbox->length = newptr;
			}
			mbox->count++;
			mbox->start[mbox->count] = pos;
			mbox->length[mbox->count] = 0;
		}
		prevnewline = 1;
	}

	mbox->length[mbox->count] = filepos - mbox->start[mbox->count];

	if (mbox->length[mbox->count] != 0)
		mbox->count++;

	return mbox;
}

/* EOF */
