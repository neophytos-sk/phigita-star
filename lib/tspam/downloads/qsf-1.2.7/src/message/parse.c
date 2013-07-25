/*
 * Functions for parsing and handling mail messages.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "message.h"
#include "md5.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

extern char *minimemmem(char *, long, char *, long);


/*
 * Replace the existing msg->sender, if there is one, with a malloc()ed
 * string containing the email address part of the given "From:" header
 * line.
 *
 * Note that we don't follow the RFC here, we just look for the last @ and
 * work backwards and forwards from there, since that will catch the vast
 * majority of cases and is simplest.
 */
static void msg_parse__fromhdr(opts_t opts, msg_t msg, char *line,
			       long size)
{
	long i, a, b;
	char *ptr;

	for (i = size - 1; i > 0 && line[i] != '@'; i--) {
	}

	if (line[i] != '@')
		return;

	for (a = i; a > 0 && line[a] != '<' && line[a] > 32; a--) {
	}
	if ((line[a] == '<') || (line[a] <= 32))
		a++;

	for (b = i; b < size && line[b] != '>' && line[b] > 32; b++) {
	}
	if ((line[b] == '>') || (line[b] <= 32))
		b--;

	if (b < (a + 2))
		return;

	ptr = calloc(1, 2 + b - a);
	if (ptr == NULL)
		return;
	strncpy(ptr, line + a, 1 + b - a);

	if (msg->sender)
		free(msg->sender);

	msg->sender = ptr;
}


/*
 * Replace the existing msg->envsender, if there is one, with a malloc()ed
 * string containing the email address part of the given "Return-Path:"
 * header line. This works the same way as msg_parse__fromhdr() above.
 */
static void msg_parse__returnpathhdr(opts_t opts, msg_t msg, char *line,
				     long size)
{
	long i, a, b;
	char *ptr;

	for (i = size - 1; i > 0 && line[i] != '@'; i--) {
	}

	if (line[i] != '@')
		return;

	for (a = i; a > 0 && line[a] != '<' && line[a] > 32; a--) {
	}
	if ((line[a] == '<') || (line[a] <= 32))
		a++;

	for (b = i; b < size && line[b] != '>' && line[b] > 32; b++) {
	}
	if ((line[b] == '>') || (line[b] <= 32))
		b--;

	if (b < (a + 2))
		return;

	ptr = calloc(1, 2 + b - a);
	if (ptr == NULL)
		return;
	strncpy(ptr, line + a, 1 + b - a);

	if (msg->envsender)
		free(msg->envsender);

	msg->envsender = ptr;
}


/*
 * Parse a single message header, updating internal state as appropriate.
 * Returns nonzero on error.
 */
static int msg_parse__header(opts_t opts, msg_t msg)
{
	long start, end, boundstart;
	char *newptr;

	/*
	 * Find end of this header line (even if split over
	 * two lines)
	 */
	start = msg->_pos;
	end = msg->_pos;
	while ((end < msg->original_size)
	       && (msg->original[end] != '\n')) {
		end++;
		if (msg->original[end] == '\n'
		    && (msg->original[end + 1] == ' '
			|| msg->original[end + 1] == '\t')) {
			end++;
		}
	}

	if ((start == end)
	    || (end == (1 + start) && msg->original[start] == '\r')
	    ) {

		/*
		 * Empty line - end of headers
		 */

		msg->_in_header--;

	} else if (strncasecmp(msg->original + msg->_pos,
			       "Content-Type:", 13) == 0) {

		/*
		 * Content-Type header - look for type, and
		 * find boundary= and add a known boundary
		 * if we find one
		 */

		msg->_pos += 13;
		while ((msg->original[msg->_pos] == ' '
			|| msg->original[msg->_pos] == '\t'
			|| msg->original[msg->_pos] == '\r'
			|| msg->original[msg->_pos] == '\n')
		       && msg->_pos < end) {
			msg->_pos++;
		}
		msg->_nottext = 1;
		if (strncasecmp(msg->original + msg->_pos, "text/", 5) ==
		    0) {
			msg->_nottext = 0;
		} else
		    if (strncasecmp(msg->original + msg->_pos, "image/", 6)
			== 0) {
			msg->num_images++;
		} else
		    if (strncasecmp
			(msg->original + msg->_pos, "message/", 8) == 0) {
			/*
			 * Handle message/ types by allowing a blank line
			 * and then continuing to parse header lines, so
			 * that attached messages with inline parts can be
			 * processed properly.
			 */
			msg->_in_header = 2;
			msg->_nottext = 0;
		}
		while (((msg->original[msg->_pos] & 0x60) != 'B')
		       && (msg->_pos < end)
		       && (strncasecmp(msg->original + msg->_pos,
				       "boundary=", 9) != 0)) {
			msg->_pos++;
		}

		if ((strncasecmp(msg->original + msg->_pos,
				 "boundary=", 9) == 0)
		    && (msg->_bdepth < 8)) {
			msg->_pos += 9;
			if (msg->original[msg->_pos] == '"') {
				msg->_pos++;
				boundstart = msg->_pos;
				while ((msg->original[msg->_pos] != '"')
				       && (msg->_pos < end))
					msg->_pos++;
			} else {
				boundstart = msg->_pos;
				while ((msg->original[msg->_pos] != ';')
				       && msg->original[msg->_pos] != ' '
				       && msg->original[msg->_pos] != '\t'
				       && msg->original[msg->_pos] != '\r'
				       && (msg->_pos < end))
					msg->_pos++;
			}

			newptr = malloc(4 + msg->_pos - boundstart);
			if (newptr == NULL) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name,
					_("malloc failed"),
					strerror(errno));
				return 1;
			}
			memcpy(newptr, "\n--", 3);
			strncpy(newptr + 3,
				msg->original + boundstart,
				msg->_pos - boundstart);
			newptr[3 + msg->_pos - boundstart] = 0;

			if (msg->_bound[msg->_bdepth] != NULL)
				free(msg->_bound[msg->_bdepth]);
			msg->_bound[msg->_bdepth] = newptr;
			msg->_bdepth++;
		}

	} else if (strncasecmp(msg->original + msg->_pos,
			       "Content-Transfer-Encoding:", 26) == 0) {

		/*
		 * Content-Transfer-Encoding header - change
		 * encoding method to expect
		 */

		msg->_pos += 26;
		while (msg->_pos < end
		       && (msg->original[msg->_pos] == ' '
			   || msg->original[msg->_pos] == '\t'
			   || msg->original[msg->_pos] == '\r'
			   || msg->original[msg->_pos] == '\n'))
			msg->_pos++;

		if (strncasecmp(msg->original + msg->_pos,
				"Base64", 6) == 0) {
			msg->_encoding = 2;
		} else if (strncasecmp(msg->original + msg->_pos,
				       "Quoted-Printable", 16) == 0) {
			msg->_encoding = 1;
		} else {
			msg->_encoding = 0;
		}

	} else if ((strncasecmp(msg->original + msg->_pos,
				"Subject:", 8) == 0)
		   || (strncasecmp(msg->original + msg->_pos,
				   "From:", 5) == 0)
		   || (strncasecmp(msg->original + msg->_pos,
				   "Return-Path:", 12) == 0)
		   || (strncasecmp(msg->original + msg->_pos,
				   "Sender:", 7) == 0)
		   || (strncasecmp(msg->original + msg->_pos,
				   "To:", 3) == 0)
		   || (strncasecmp(msg->original + msg->_pos,
				   "Reply-To:", 9) == 0)) {
		char *decoded;
		long decodedlen;

		/*
		 * Add various headers to the message
		 * content
		 */

		if (strncasecmp(msg->original + msg->_pos,
				"Subject: [SPAM]", 15) == 0) {
			msg->_pos += 15;
		} else
		    if (strncasecmp(msg->original + msg->_pos, "From:", 5)
			== 0) {
			/*
			 * If it's a From: header, look for an email address
			 * and put it in msg->sender for later possible use
			 */
			msg_parse__fromhdr(opts, msg,
					   msg->original + msg->_pos,
					   end + 1 - msg->_pos);
		} else
		    if (strncasecmp
			(msg->original + msg->_pos, "Return-Path:", 12)
			== 0) {
			/*
			 * Also store email address of envelope sender
			 */
			msg_parse__returnpathhdr(opts, msg,
						 msg->original + msg->_pos,
						 end + 1 - msg->_pos);
		}

		/*
		 * Decode RFC2047-encoded headers.
		 */
		decodedlen = end + 1 - msg->_pos;
		decoded =
		    msg_decode_rfc2047(msg->original + msg->_pos,
				       &decodedlen);

		if (msg_addcontent(opts, msg, decoded, decodedlen))
			return 1;
		free(decoded);
	}

	msg->_pos = end + 1;

	return 0;
}


/*
 * Decode the message up to the next boundary and, if it is textual, add its
 * contents to msg->content. Returns nonzero on error.
 */
static int msg_parse__content(opts_t opts, msg_t msg)
{
	struct MD5Context md5c;
	unsigned char digest[16];	 /* RATS: ignore (checked all) */
	char digeststr[64];		 /* RATS: ignore (large enough) */
	char *newptr;
	char *data;
	char *content;
	long boundstart;		 /* start of message part being decoded */
	long partsize;			 /* size of message part being decoded */
	int i, n;

	boundstart = msg->_pos;
	partsize = msg->original_size - boundstart;

	msg->_pos = msg->original_size;

	/*
	 * Look for the next boundary
	 */
	for (i = msg->_bdepth - 1; i >= 0; i--) {

		if (msg->_bound[i] == NULL)
			continue;

		newptr = minimemmem(msg->original + boundstart - 1,
				    partsize,
				    msg->_bound[i],
				    strlen(msg->_bound[i]));

		if (newptr == NULL)
			continue;

		msg->_pos = newptr - msg->original;
		partsize = msg->_pos - boundstart;

		/*
		 * Move new position to after the boundary marker
		 */
		msg->_pos += strlen(msg->_bound[i]);
		while ((msg->_pos < msg->original_size)
		       && (msg->original[msg->_pos] == '\r'
			   || msg->original[msg->_pos] == '\n')
		    )
			msg->_pos++;

		/*
		 * Set nesting depth, and we now scan headers
		 */
		msg->_bdepth = i + 1;
		msg->_in_header = 1;
		i = -1;
	}

	if (partsize < 1 || partsize > 409600) {
		if (msg->_in_header) {
			msg->_nottext = 0;
			msg->_encoding = 0;
		}
		return 0;
	}

	switch (msg->_encoding) {
	case 1:
		data = msg_from_qp(msg->original + boundstart, &partsize);
		break;
	case 2:
		data =
		    msg_from_base64(msg->original + boundstart, &partsize);
		break;
	default:
		data = NULL;
		break;
	}

	content = data;
	if (content == NULL)
		content = msg->original + boundstart;

	if (msg->_nottext) {
		MD5Init(&md5c);
		MD5Update(&md5c, (unsigned char *) content, partsize);
		MD5Final(digest, &md5c);
		memcpy(digeststr, " z", 2);
		for (n = 0; n < 16; n++) {
#ifdef HAVE_SNPRINTF
			snprintf(digeststr + 2 + 2 * n,
				 sizeof(digeststr) - 2 - 2 * n,
#else
			sprintf(digeststr + 2 + 2 * n,	/* RATS: ignore */
#endif
				"%02X", digest[n]);
		}
		memcpy(digeststr + strlen(digeststr), "z \000", 3);
		if (msg_addcontent
		    (opts, msg, digeststr, strlen(digeststr)))
			return 1;
	} else {
		if (msg_addcontent(opts, msg, content, partsize))
			return 1;
	}

	if (data)
		free(data);

	if (msg->_in_header) {
		msg->_nottext = 0;
		msg->_encoding = 0;
	}

	return 0;
}


/*
 * Make a copy of the message content in msg->textcontent and strip all HTML
 * tags from it. Only HTML tags that start with an alphabetic character or /
 * are stripped, but only if the part within the <> is under 500 characters,
 * and all HTML comments are stripped from the <!-- to the --> inclusive.
 *
 * Returns nonzero on error.
 */
static int msg_parse__striphtml(opts_t opts, msg_t msg)
{
	long rpos, wpos, i;
	int in_tag, in_comment, ch;
	char *ptr;
	static struct {
		char *string;
		int ch;
	} entities[] = {
		{
		"&amp;", '&'}, {
		"&gt;", '>'}, {
		"&lt;", '<'}, {
		"&quot;", '"'}, {
		"&nbsp;", ' '}, {
		"&iexcl;", '!'}, {
		"&cent;", 'c'}, {
		"&pound;", '£'}, {
		"&curren;", '#'}, {
		"&yen;", 'Y'}, {
		"&brvbar;", '|'}, {
		"&sect;", ' '}, {
		"&uml;", ':'}, {
		"&copy;", 'C'}, {
		"&ordf;", ' '}, {
		"&laquo;", '"'}, {
		"&not;", '!'}, {
		"&shy;", '-'}, {
		"&reg;", 'R'}, {
		"&macr;", ' '}, {
		"&deg;", ' '}, {
		"&plusmn;", ' '}, {
		"&sup2;", '2'}, {
		"&sup3;", '3'}, {
		"&acute;", '\''}, {
		"&micro;", 'u'}, {
		"&para;", 'P'}, {
		"&middot;", '.'}, {
		"&cedil;", ' '}, {
		"&sup1;", '1'}, {
		"&ordm;", ' '}, {
		"&raquo;", '"'}, {
		"&frac14;", ' '}, {
		"&frac12;", ' '}, {
		"&frac34;", ' '}, {
		"&iquest;", '?'}, {
		"&Agrave;", 'A'}, {
		"&Aacute;", 'A'}, {
		"&Acirc;", 'A'}, {
		"&Atilde;", 'A'}, {
		"&Auml;", 'A'}, {
		"&Aring;", 'A'}, {
		"&AElig;", 'A'}, {
		"&Ccedil;", 'C'}, {
		"&Egrave;", 'E'}, {
		"&Eacute;", 'E'}, {
		"&Ecirc;", 'E'}, {
		"&Euml;", 'E'}, {
		"&Igrave;", 'I'}, {
		"&Iacute;", 'I'}, {
		"&Icirc;", 'I'}, {
		"&Iuml;", 'I'}, {
		"&ETH;", 'E'}, {
		"&Ntilde;", 'N'}, {
		"&Ograve;", 'O'}, {
		"&Oacute;", 'O'}, {
		"&Ocirc;", 'O'}, {
		"&Otilde;", 'O'}, {
		"&Ouml;", 'O'}, {
		"&times;", 'x'}, {
		"&Oslash;", 'O'}, {
		"&Ugrave;", 'U'}, {
		"&Uacute;", 'U'}, {
		"&Ucirc;", 'U'}, {
		"&Uuml;", 'U'}, {
		"&Yacute;", 'Y'}, {
		"&THORN;", 'T'}, {
		"&szlig;", 's'}, {
		"&agrave;", 'a'}, {
		"&aacute;", 'a'}, {
		"&acirc;", 'a'}, {
		"&atilde;", 'a'}, {
		"&auml;", 'a'}, {
		"&aring;", 'a'}, {
		"&aelig;", 'a'}, {
		"&ccedil;", 'c'}, {
		"&egrave;", 'e'}, {
		"&eacute;", 'e'}, {
		"&ecirc;", 'e'}, {
		"&euml;", 'e'}, {
		"&igrave;", 'i'}, {
		"&iacute;", 'i'}, {
		"&icirc;", 'i'}, {
		"&iuml;", 'i'}, {
		"&eth;", 'e'}, {
		"&ntilde;", 'n'}, {
		"&ograve;", 'o'}, {
		"&oacute;", 'o'}, {
		"&ocirc;", 'o'}, {
		"&otilde;", 'o'}, {
		"&ouml;", 'o'}, {
		"&divide;", '/'}, {
		"&oslash;", 'o'}, {
		"&ugrave;", 'u'}, {
		"&uacute;", 'u'}, {
		"&ucirc;", 'u'}, {
		"&uuml;", 'u'}, {
		"&yacute;", 'y'}, {
		"&thorn;", 't'}, {
		"&yuml;", 'y'}, {
		0, 0}
	};

	if (msg->content_size < 1)
		return 0;

	msg->textcontent = malloc(msg->content_size);
	if (msg->textcontent == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return 1;
	}

	msg->text_size = 0;

	for (rpos = 0, wpos = 0, in_tag = 0, in_comment = 0;
	     rpos < msg->content_size; rpos++) {
		if ((in_tag)
		    && (msg->content[rpos] == '>')
		    ) {
			in_tag = 0;
			continue;
		}

		if ((in_comment)
		    && (rpos < (msg->content_size - 3))
		    && (strncmp(msg->content + rpos, "-->", 3) == 0)
		    ) {
			in_comment = 0;
			rpos += 2;
			continue;
		}

		if (in_tag || in_comment)
			continue;

		if ((rpos < (msg->content_size - 8))
		    && (msg->content[rpos] == '&')
		    && (msg->content[rpos + 1] != '#')
		    ) {
			for (i = 0; entities[i].string; i++) {
				if (strncmp
				    (msg->content + rpos,
				     entities[i].string,
				     strlen(entities[i].string)) == 0) {
					msg->textcontent[wpos] =
					    entities[i].ch;
					rpos +=
					    strlen(entities[i].string) - 1;
					wpos++;
					msg->text_size = wpos;
					break;
				}
			}
			if (entities[i].string)
				continue;
		}

		if ((msg->content[rpos] == '&')
		    && (rpos < (msg->content_size - 6))
		    && (msg->content[rpos + 1] == '#')
		    ) {
			ch = 0;
			for (i = 2; (rpos + i < msg->content_size)
			     && (msg->content[rpos + i] >= '0')
			     && (msg->content[rpos + i] <= '9'); i++) {
				ch = ch * 10;
				ch += (msg->content[rpos + i] - '0');
			}
			if ((rpos + i < msg->content_size)
			    && (msg->content[rpos + i] == ';')
			    && (ch > 0)
			    ) {
				msg->textcontent[wpos] = ch;
				wpos++;
				rpos += i + 1;
				msg->text_size = wpos;
				continue;
			}
		}

		if ((msg->content[rpos] == '<')
		    && (rpos < (msg->content_size - 1))
		    && (strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			       "abcdefghijklmnopqrstuvwxyz"
			       "/", msg->content[rpos + 1]))
		    && (memchr(msg->content + rpos,
			       '>', msg->content_size - rpos))
		    && ((char *) memchr(msg->content + rpos,
					'>', msg->content_size - rpos)
			- (msg->content + rpos)
			< 500)
		    ) {
			in_tag = 1;
			continue;
		}

		if ((msg->content[rpos] == '<')
		    && (rpos < (msg->content_size - 5))
		    && (msg->content[rpos + 1] == '!')
		    && (msg->content[rpos + 2] == '-')
		    && (msg->content[rpos + 3] == '-')
		    ) {
			in_comment = 1;
			continue;
		}

		msg->textcontent[wpos] = msg->content[rpos];

		wpos++;
		msg->text_size = wpos;
	}

	ptr = realloc(msg->textcontent,	    /* RATS: ignore (not sensitive) */
		      msg->text_size);
	if (ptr != NULL)
		msg->textcontent = ptr;

	return 0;
}


/*
 * Trim the whitespace from msg->textcontent, such that long runs of \r,
 * space, tab, \n, etc get truncated to a single space.
 *
 * Also fill in the wordpos[] and wordlength[] arrays, and count the number
 * of words.
 */
static void msg_parse__trimwhitespace(opts_t opts, msg_t msg)
{
	long rpos, wpos, words_alloced;
	int prevws;
	char *ptr;

	msg->num_words = 0;
	words_alloced = 10000;

	msg->wordpos = calloc(words_alloced, sizeof(long));
	msg->wordlength = calloc(words_alloced, sizeof(int));

	for (rpos = 0, wpos = 0, prevws = 0; rpos < msg->text_size; rpos++) {
		if ((msg->textcontent[rpos] == ' ')
		    || (msg->textcontent[rpos] == '\r')
		    || (msg->textcontent[rpos] == '\n')
		    || (msg->textcontent[rpos] == '\t')
		    ) {
			if (prevws)
				continue;
			prevws = 1;
			msg->textcontent[wpos++] = ' ';
			if (msg->num_words > 0) {
				msg->wordlength[msg->num_words - 1] =
				    (wpos - 1) -
				    msg->wordpos[msg->num_words - 1];
			}
			continue;
		}

		/*
		 * Non-whitespace. If it follows whitespace, or is the first
		 * character, add it to the word list.
		 */
		if ((wpos == 0) || (prevws)) {

			/*
			 * First, make sure there's room in the array; if
			 * not, extend the array.
			 */
			if (msg->num_words >= words_alloced - 1) {
				long *newwordpos;
				int *newwordlength;

				words_alloced += 10000;

				newwordpos = realloc(msg->wordpos,	/* RATS: ignore */
						     words_alloced *
						     sizeof(long));
				if (newwordpos != NULL) {
					msg->wordpos = newwordpos;
					newwordlength = realloc(msg->wordlength,	/* RATS: ignore */
								words_alloced
								*
								sizeof
								(int));
					if (newwordlength != NULL) {
						msg->wordlength =
						    newwordlength;
					} else {
						words_alloced -= 10000;
					}
				} else {
					words_alloced -= 10000;
				}
			}

			/*
			 * Next, assuming the array can hold another entry
			 * (the above extension could have failed), add the
			 * word to the list. The word's default length is
			 * set to the size of the remaining buffer.
			 */

			if (msg->num_words < words_alloced - 1) {
				msg->wordpos[msg->num_words] = wpos;
				msg->wordlength[msg->num_words] =
				    msg->text_size - rpos;
				msg->num_words++;
			}
		}

		prevws = 0;
		msg->textcontent[wpos++] = msg->textcontent[rpos];
	}

	msg->text_size = wpos;

	ptr = realloc(msg->textcontent,	    /* RATS: ignore (not sensitive) */
		      msg->text_size);
	if (ptr != NULL)
		msg->textcontent = ptr;

	return;
}


/*
 * Parse a message on standard input, and return an allocated msg_t, or NULL
 * on error. If the message cannot be parsed, eg if it is too big, the
 * "content" field will remain NULL but "original" will be allocated and
 * will contain the entirety of the message read so far.
 */
msg_t msg_parse(opts_t opts)
{
	msg_t msg;

	msg = msg_alloc(opts);
	if (msg == NULL)
		return NULL;

	/*
	 * Read message into memory
	 */
	if (msg_read(opts, msg))
		return msg;

	/*
	 * Store original message headers
	 */
	if (msg_headers_store(opts, msg))
		return msg;

	msg->_in_header = 1;
	msg->_pos = 0;

	/*
	 * Scan through the message, finding Content-Type and
	 * Content-Transfer-Encoding headers to get message boundaries, and
	 * split the body in these boundaries (and then scan each part's
	 * headers, if any, for more boundaries and content types and so
	 * on); selected headers are added to msg->content, as are all
	 * textual parts of the message body (after decoding).
	 */
	while (msg->_pos < msg->original_size) {

		if (msg->_in_header > 0) {
			if (msg_parse__header(opts, msg))
				return msg;
		} else {
			if (msg_parse__content(opts, msg))
				return msg;
		}
	}

	msg_parse__striphtml(opts, msg);
	msg_parse__trimwhitespace(opts, msg);

	return msg;
}

/* EOF */
