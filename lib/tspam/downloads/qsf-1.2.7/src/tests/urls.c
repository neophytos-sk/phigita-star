/*
 * Rules to look for URLs in messages.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include "spam.h"
#include <string.h>


extern char *minimemmem(char *, long, char *, long);


/*
 * Add a token for every URL found containing an IP address, and also add
 * all URLs found and their hostnames as tokens in their own right.
 */
int spam_test_html_urls(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound, ldr, ldrl, isip, dots, isint, isurlenc;
	long pos, len, i, hoststart, hostend;
	char *leaders[] = {
		"http:",
		"Http:",
		"HTTP:",
		"ftp:",
		"Ftp:",
		"FTP:",
		"mailto:",
		"Mailto:",
		"MAILTO:",
		NULL
	};
	char *ptr;

	for (nfound = 0, ldr = 0; leaders[ldr]; ldr++) {

		ldrl = strlen(leaders[ldr]);	/* RATS: ignore (OK) */

		for (pos = 0; pos < msg->content_size;) {
			ptr =
			    minimemmem(msg->content + pos,
				       msg->content_size - pos,
				       leaders[ldr], ldrl);
			if (!ptr)
				break;

			pos = ptr - msg->content;
			if (pos < 0)
				break;

			/*
			 * Find the length of the URL (i.e. where it ends),
			 * counting ? as an end-of-URL character
			 */
			for (len = 0; (len < msg->content_size - pos)
			     && !strchr("?>\"' \n\t\r",
					msg->content[pos + len]); len++) {
			}

			/*
			 * Find the start of the hostname (after the // part)
			 */
			hoststart = 5;
			while ((hoststart < len)
			       && (msg->content[pos + hoststart] == '/')) {
				hoststart++;
			}

			/*
			 * If the URL has a @ in it, the hostname comes
			 * after that
			 */
			for (i = 0; i < len; i++) {
				if (msg->content[pos + i] == '@')
					hoststart = i + 1;
			}

			/*
			 * Don't go past the end of the URL
			 */
			if (hoststart >= len)
				hoststart = 0;

			/*
			 * Find the first / after the hostname, if any
			 */
			hostend = 0;
			for (i = hoststart; i < len; i++) {
				if (msg->content[pos + i] == '/') {
					hostend = i;
					break;
				}
			}

			/*
			 * Add the URL as a token
			 */
			spam_token_add(opts, spam, msg->content + pos,
				       len);

			/*
			 * Add the part of the URL that starts with the
			 * hostname (i.e. after http://, and any @) as a
			 * token
			 */
			if (hoststart > 0) {
				spam_token_add(opts, spam, msg->content +
					       pos + hoststart,
					       len - hoststart);
				/*
				 * Add the hostname on its own as a token
				 */
				if (hostend > hoststart) {
					spam_token_add(opts, spam,
						       msg->content + pos +
						       hoststart,
						       hostend -
						       hoststart);
				}
			}

			/*
			 * See whether the URL's hostname is an IP address,
			 * just an integer, or might be URL-encoded
			 */
			isint = 1;
			isip = 1;
			isurlenc = 0;
			dots = 0;
			for (i = hoststart; i < len; i++) {
				if ((msg->content[pos + i] >= '0')
				    && (msg->content[pos + i] <= '9'))
					continue;
				if (msg->content[pos + i] == '.') {
					dots++;
				} else if (msg->content[pos + i] == '/') {
					if (dots < 3)
						isip = 0;
					break;
				} else {
					isip = 0;
					isint = 0;
					if (msg->content[pos + i] == '%')
						isurlenc = 1;
				}
			}

			if (dots < 3)
				isip = 0;
			if (dots > 0)
				isint = 0;

			if (isip) {
				nfound++;
			} else if (isint) {
				spam_token_add(opts, spam,
					       ".HTML-INT-IN-URL.", 18);
			} else if (isurlenc) {
				spam_token_add(opts, spam,
					       ".HTML-URLENCODED-URL.",
					       21);
			}

			pos++;
		}
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}

/* EOF */
