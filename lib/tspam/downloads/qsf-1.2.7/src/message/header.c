/*
 * Functions for modifying mail message headers.
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
 * Store a copy of each header in the message, and store a pointer to the
 * start of the message body for later use by msg_dump(). Returns nonzero on
 * error.
 */
int msg_headers_store(opts_t opts, msg_t msg)
{
	long start, end;
	char *newptr;

	start = 0;
	end = 1;

	do {
		end = start;
		while ((end < msg->original_size)
		       && (msg->original[end] != '\n')) {
			end++;
		}

		if (start == end)
			break;

		newptr = realloc(msg->header,	/* RATS: ignore (OK) */
				 sizeof(char *) * (msg->num_headers + 1));
		if (newptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				_("realloc failed"), strerror(errno));
			return 1;
		}
		msg->header = (char **) newptr;

		newptr = malloc(1 + end - start);
		if (newptr == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				_("malloc failed"), strerror(errno));
			return 1;
		}

		msg->header[msg->num_headers] = newptr;
		memcpy(newptr, msg->original + start, end - start);
		newptr[end - start] = 0;

		msg->num_headers++;

		start = end + 1;

	} while ((start != end) && (start < msg->original_size));

	msg->body = msg->original + end + 1;
	msg->body_size = msg->original_size - (end + 1);

	return 0;
}


/*
 * Modify the message's Subject line to mark it as spam, using the given
 * string as a marker or "[SPAM]" if NULL is supplied.
 */
void msg_spamsubject(msg_t msg, char *marker)
{
	char *ptr;
	int gotsubject = 0;
	int i, sz;

	if (marker == NULL)
		marker = "[SPAM]";

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] == NULL)
			continue;
		if (strncasecmp(msg->header[i], "Subject:", 8) == 0) {
			gotsubject = 1;
			if ((msg->header[i][8] == ' ')
			    &&
			    (strncasecmp
			     (msg->header[i] + 9, marker,
			      strlen(marker)) == 0))
				continue;
			sz = strlen(msg->header[i]) + strlen(marker) + 4;
			ptr = malloc(sz);
			if (ptr == NULL)
				continue;
#ifdef HAVE_SNPRINTF
			snprintf(ptr, sz,
#else
			sprintf(ptr,	    /* RATS: ignore (checked) */
#endif
				"%.8s %s%s", msg->header[i], marker,
				msg->header[i] + 8);
			free(msg->header[i]);
			msg->header[i] = ptr;
		}
	}

	if (gotsubject == 1)
		return;

	/*
	 * Add a Subject header if there wasn't one
	 */

	ptr = realloc(msg->header,	    /* RATS: ignore (OK) */
		      sizeof(char *) * (msg->num_headers + 1));
	if (ptr == NULL)
		return;
	msg->header = (char **) ptr;

	sz = strlen(marker) + 12;
	ptr = malloc(sz);
	if (ptr == NULL)
		return;

#ifdef HAVE_SNPRINTF
	snprintf(ptr, sz,
#else
	sprintf(ptr,			    /* RATS: ignore (checked) */
#endif
		"Subject: %.*s", (int) (strlen(marker) + 1), marker);

	msg->header[msg->num_headers] = ptr;

	msg->num_headers++;
}


/*
 * Add an X-Spam: header to the message, YES (or header marker) if
 * "spamscore" >0, NO if 0.
 */
void msg_spamheader(msg_t msg, char *marker, double spamscore)
{
	char *ptr;
	int i, sz;

	if (marker == NULL)
		marker = "YES";

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] == NULL)
			continue;
		if (strncasecmp(msg->header[i], "X-Spam:", 7) == 0) {
			free(msg->header[i]);
			msg->header[i] = NULL;
		}
	}

	ptr = realloc(msg->header,	    /* RATS: ignore (OK) */
		      sizeof(char *) * (msg->num_headers + 1));
	if (ptr == NULL)
		return;
	msg->header = (char **) ptr;

	if (spamscore > 0) {
		sz = strlen(marker) + 9;
		ptr = malloc(sz);
		if (ptr == NULL)
			return;

#ifdef HAVE_SNPRINTF
		snprintf(ptr, sz,
#else
		sprintf(ptr,		    /* RATS: ignore (checked) */
#endif
			"X-Spam: %.*s", (int) (strlen(marker) + 1),
			marker);
	} else {
		ptr = strdup("X-Spam: NO");
		if (ptr == NULL)
			return;
	}

	msg->header[msg->num_headers] = ptr;

	msg->num_headers++;
}


/*
 * Add an X-Spam-Rating: header to the message, giving the spam score as a
 * decimal percentage from 0 to 100.
 */
void msg_spamratingheader(msg_t msg, double spamscore, double threshold)
{
	char buf[256];			 /* RATS: ignore (OK) */
	double scaledscore;
	char *ptr;
	int i;

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] == NULL)
			continue;
		if (strncasecmp(msg->header[i], "X-Spam-Rating:", 14) == 0) {
			free(msg->header[i]);
			msg->header[i] = NULL;
		}
	}

	ptr = realloc(msg->header,	    /* RATS: ignore (OK) */
		      sizeof(char *) * (msg->num_headers + 1));
	if (ptr == NULL)
		return;
	msg->header = (char **) ptr;

	if (spamscore < 0)
		spamscore += 0.01;
	spamscore += threshold;

	scaledscore = spamscore * 100.0;

#ifdef HAVE_SNPRINTF
	snprintf(buf, sizeof(buf) - 1,
		 "X-Spam-Rating: %d", (int) scaledscore);
#else
	sprintf(buf, /* RATS: ignore (OK) */ "X-Spam-Rating: %d",
		(int) scaledscore);
#endif

	ptr = strdup(buf);
	if (ptr == NULL)
		return;

	msg->header[msg->num_headers] = ptr;

	msg->num_headers++;
}


/*
 * Add an X-Spam-Level: header to the message, giving the spam score as a
 * number of stars from 0 to 20.
 */
void msg_spamlevelheader(msg_t msg, double spamscore, double threshold)
{
	char buf[256];			 /* RATS: ignore (OK) */
	double scaledscore;
	char *ptr;
	int i, x;

	for (i = 0; i < msg->num_headers; i++) {
		if (msg->header[i] == NULL)
			continue;
		if (strncasecmp(msg->header[i], "X-Spam-Level:", 13) == 0) {
			free(msg->header[i]);
			msg->header[i] = NULL;
		}
	}

	ptr = realloc(msg->header,	    /* RATS: ignore (OK) */
		      sizeof(char *) * (msg->num_headers + 1));
	if (ptr == NULL)
		return;
	msg->header = (char **) ptr;

	if (spamscore < 0)
		spamscore += 0.01;
	spamscore += threshold;

	scaledscore = spamscore * 100.0;

	memcpy(buf, "X-Spam-Level: ", 14);
	x = strlen(buf);
	for (i = 0; (i < (scaledscore * 0.2)) && (i < 20); i++) {
		buf[x] = '*';
		x++;
		buf[x] = 0;
	}

	ptr = strdup(buf);
	if (ptr == NULL)
		return;

	msg->header[msg->num_headers] = ptr;

	msg->num_headers++;
}

/* EOF */
