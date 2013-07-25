/*
 * Rules to look for oddities in the HTML of messages.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include "spam.h"
#include <string.h>


extern char *minimemmem(char *, long, char *, long);


/*
 * Add a token for every HTML comment found in the middle of a word (i.e.
 * with a valid token character either side of it).
 */
int spam_test_html_comments_in_words(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long pos = 0;
	char *ptr;

	while (pos < msg->content_size) {
		ptr =
		    minimemmem(msg->content + pos, msg->content_size - pos,
			       "<!", 2);
		if (!ptr)
			break;
		pos = ptr - msg->content;
		if ((pos < 1)
		    || (strchr(TOKEN_CHARS, msg->content[pos - 1]) == 0)
		    ) {
			pos++;
			continue;
		}

		pos++;
		ptr =
		    minimemmem(msg->content + pos, msg->content_size - pos,
			       ">", 1);
		if (!ptr)
			break;
		pos = ptr - msg->content;
		pos++;
		if (pos >= msg->content_size)
			break;
		if (strchr(TOKEN_CHARS, msg->content[pos]) != 0)
			nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for every IMG tag found referring to an external URL
 * (containing ://).
 */
int spam_test_html_external_img(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long pos = 0;
	char *ptr;

	while (pos < msg->content_size) {
		ptr =
		    memchr(msg->content + pos, '<',
			   msg->content_size - pos);
		if (!ptr)
			break;
		pos = ptr - msg->content;

		if (pos > msg->content_size - 4)
			break;

		pos++;

		if (strncasecmp(msg->content + pos, "img", 3) == 0) {
			ptr =
			    memchr(msg->content + pos, '>',
				   msg->content_size - pos);

			if (!ptr)
				break;

			if (minimemmem
			    (msg->content + pos,
			     (ptr - msg->content) - pos, "://", 3))
				nfound++;

			pos = ptr - msg->content;

			pos++;
			if (pos >= msg->content_size)
				break;
		}
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for every FONT tag found.
 */
int spam_test_html_font(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long pos = 0;
	char *ptr;

	while (pos < msg->content_size) {
		ptr =
		    memchr(msg->content + pos, '<',
			   msg->content_size - pos);
		if (!ptr)
			break;
		pos = ptr - msg->content;

		if (pos > msg->content_size - 5)
			break;

		pos++;

		if (strncasecmp(msg->content + pos, "font", 4) != 0)
			continue;

		nfound++;

		ptr =
		    memchr(msg->content + pos, '>',
			   msg->content_size - pos);

		if (!ptr)
			break;

		pos = ptr - msg->content;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}

/* EOF */
