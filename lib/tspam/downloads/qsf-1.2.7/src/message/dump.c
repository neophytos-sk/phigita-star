/*
 * Dump a mail message to stdout.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "message.h"
#include "log.h"
#include <stdio.h>
#include <string.h>


/*
 * Dump the given message on standard output. If the "content" field is
 * null, the "original" field is just dumped; otherwise, the message is
 * reconstructed from the "header" array and the "body" field.
 */
void msg_dump(msg_t msg)
{
	long pos, sent;
	int i;

	if (msg == NULL)
		return;

	if (msg->content == NULL) {
		pos = 0;
		while (pos < msg->original_size) {
			sent = fwrite(msg->original + pos,
				      1, msg->original_size - pos, stdout);
			if (sent <= 0)
				break;
			pos += sent;
		}
		return;
	}

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] == NULL)
			continue;
		sent =
		    fwrite(msg->header[i], strlen(msg->header[i]), 1,
			   stdout);
		if (sent <= 0)
			break;
		sent = fwrite("\n", 1, 1, stdout);
		if (sent <= 0)
			break;
	}

	log_dump("X-QSF-Info: ");

	if (fwrite("\n", 1, 1, stdout) <= 0)
		return;

	pos = 0;
	while (pos < msg->body_size) {
		sent =
		    fwrite(msg->body + pos, 1, msg->body_size - pos,
			   stdout);
		if (sent <= 0)
			break;
		pos += sent;
	}
}

/* EOF */
