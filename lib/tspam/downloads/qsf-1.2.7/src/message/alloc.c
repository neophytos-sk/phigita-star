/*
 * Functions for allocating and freeing memory.
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
 * Add the content of the given length to the "content" field of the message.
 *
 * Returns nonzero on error.
 */
int msg_addcontent(opts_t opts, msg_t msg, char *data, long size)
{
	char *newptr;

	if ((msg->content_size + size + 16) > msg->content_alloced) {
		newptr = realloc(msg->content,	/* RATS: ignore */
				 msg->content_alloced + size + 8192);
		if (newptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n",
				opts->program_name,
				_("realloc failed"), strerror(errno));
			return 1;
		}
		msg->content = newptr;
		msg->content_alloced += size + 8192;
	}

	memcpy(msg->content + msg->content_size, data, size);
	msg->content[msg->content_size + size] = 0;
	msg->content_size += size;

	return 0;
}


/*
 * Allocate a new msg_t and return it, or NULL on error.
 */
msg_t msg_alloc(opts_t opts)
{
	msg_t msg;

	msg = calloc(1, sizeof(*msg));
	if (msg == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return NULL;
	}

	return msg;
}


/*
 * Free the memory a message takes up.
 */
void msg_free(msg_t msg)
{
	int i;

	if (msg == NULL)
		return;

	if (msg->original != NULL)
		free(msg->original);

	if (msg->content != NULL)
		free(msg->content);

	if (msg->textcontent != NULL)
		free(msg->textcontent);

	if (msg->sender != NULL)
		free(msg->sender);

	if (msg->envsender != NULL)
		free(msg->envsender);

	if (msg->wordpos != NULL)
		free(msg->wordpos);

	if (msg->wordlength != NULL)
		free(msg->wordlength);

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] != NULL)
			free(msg->header[i]);
	}

	for (i = 0; i < 8; i++) {
		if (msg->_bound[i] != NULL)
			free(msg->_bound[i]);
	}

	if (msg->header != NULL)
		free(msg->header);

	free(msg);
}

/* EOF */
