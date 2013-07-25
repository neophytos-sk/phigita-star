/*
 * Decode RFC2047-encoded strings.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "message.h"
#include <stdlib.h>
#include <string.h>


/*
 * Table for decoding hex digits
 */
static char index_hex[256] = {
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1,
	-1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
};

#define CHARHEX(c)  (index_hex[(unsigned char)(c)])


/*
 * Take the given single RFC2047 encoded word and store it, decoded, into
 * the given buffer with the given maximum length.
 *
 * It it assumed that "str" contains a valid RFC2047 encoded word, as found
 * by the findencoded function below.
 */
static void decode_rfc2047_word(char *str, char *buf, long bufsize)
{
	int seenq, encoding;
	char *charset;
	char *rpos;
	char *nextq;

	seenq = 0;
	charset = NULL;
	encoding = 0;

	buf[0] = 0;

	for (rpos = str; (nextq = strchr(rpos, '?')); rpos = nextq + 1) {
		char *ptr;
		int n;

		seenq++;

		switch (seenq) {
		case 2:		    /* CHARSET part */
			n = nextq - rpos;

			/*
			 * Since RFC2231 says CHARSET can be of the form
			 * CHARSET*LANGUAGE, we need to throw away the
			 * LANGUAGE part if an asterisk is present.
			 */
			ptr = memchr(rpos, '*', n);
			if (ptr)
				n = ptr - rpos;

			charset = malloc(n + 1);
			if (charset != NULL) {
				memcpy(charset, rpos, n);
				charset[n] = 0;
			}

			break;

		case 3:		    /* ENC part */
			switch (rpos[0]) {
			case 'Q':
			case 'q':
				encoding = 'Q';
				break;
			case 'B':
			case 'b':
				encoding = 'B';
				break;
			default:
				if (charset)
					free(charset);
				return;
			}
			break;

		case 4:		    /* DATA part */

			if (encoding == 'Q') {

				/* Quoted-Printable decoding */

				while ((rpos < nextq) && (bufsize > 0)) {
					if (rpos[0] == '_') {
						buf[0] = ' ';
						buf++;
						bufsize--;
					} else if (rpos[0] == '=') {
						if (rpos[1] == 0)
							break;
						if (rpos[2] == 0)
							break;
						buf[0] =
						    (CHARHEX(rpos[1]) << 4)
						    | CHARHEX(rpos[2]);
						buf++;
						bufsize--;
						rpos += 2;
					} else {
						buf[0] = rpos[0];
						buf++;
						bufsize--;
					}
					rpos++;
				}

				buf[0] = 0;

			} else if (encoding == 'B') {

				/* Base64 decoding */

				char *decbuf;
				long size;

				size = nextq - rpos;
				decbuf = msg_from_base64(rpos, &size);

				if (decbuf == NULL) {
					if (charset)
						free(charset);
					return;
				}

				if (size > bufsize)
					size = bufsize;

				memcpy(buf, decbuf, size);
				free(decbuf);

				buf += size;
				bufsize -= size;
				buf[0] = 0;

			}
			break;
		}
	}

	if (charset) {
		/*
		 * We don't do anything with the charset information, as
		 * converting between character sets would make this project
		 * a lot more complicated than it really needs to be.
		 */
		free(charset);
	}
}


/*
 * Find the next RFC2047 encoded word in the given string, assuming that the
 * encoding must be B or Q (case insensitive, as per the RFC).
 *
 * An RFC2047 encoded word looks like this: =?CHARSET?ENC?DATA?=
 *
 * CHARSET is a character set specifier, ENC is the encoding (Q for
 * quoted-printable, B for base64), and DATA is the encoded data.
 *
 * Returns a pointer to the start of the encoded word and fills in *endptr
 * with a pointer to the end of the encoded word, or returns NULL if nothing
 * was found.
 */
static char *decode_rfc2047_findencoded(char *str, char **endptr)
{
	char *start;
	char *end;

	for (end = str; (start = strstr(end, "=?"));) {

		/*
		 * Look for the next ? at the end of the CHARSET specifier;
		 * CHARSET cannot contain "forbidden" characters.
		 */
		for (end = start + 2; (end[0] > 32)
		     && (end[0] < 127)
		     && (strchr("()<>@,;:\"/[].=?", end[0]) == NULL);
		     end++) {
		}

		/*
		 * Check we've found the ?ENC? part, where ENC is B or Q
		 * (not case sensitive).
		 */
		if (end[0] != '?')
			continue;
		if (strchr("BQbq", end[1]) == NULL)
			continue;
		if (end[2] != '?')
			continue;

		/*
		 * Skip the DATA part.
		 */
		for (end = end + 3; (end[0] > 32)
		     && (end[0] < 127)
		     && (end[0] != '?'); end++) {
		}

		/*
		 * Check that the encoded word ends with ?= as it should.
		 */
		if ((end[0] != '?') || (end[1] != '=')) {
			end--;
			continue;
		}

		end += 2;
		*endptr = end;
		return start;
	}

	return NULL;
}


/*
 * Return a malloc()ed string containing the input string with any RFC2047
 * encoded content decoded.  The content of "len" is updated to contain the
 * size of the output string, and on entry should contain the size of the
 * input string.
 *
 * Returns NULL on error.
 */
char *msg_decode_rfc2047(char *str, long *len)
{
	char *in;
	char *out;
	char *inptr;
	char *outptr;
	long bytesleft;
	int enccount;

	if (str == NULL)
		return NULL;
	if (len == NULL)
		return NULL;
	if (*len < 1)
		return NULL;
	if (str[0] == 0)
		return NULL;

	bytesleft = *len;

	in = malloc(bytesleft + 1);
	if (in == NULL)
		return NULL;

	out = malloc(bytesleft + 1);
	if (out == NULL) {
		free(in);
		return NULL;
	}

	memcpy(in, str, bytesleft);
	in[bytesleft] = 0;

	inptr = in;
	outptr = out;
	enccount = 0;

	while ((inptr[0] != 0) && (bytesleft > 0)) {
		char *start;
		char *end;
		int n;

		/*
		 * Find the next RFC2047 encoded word.
		 */
		start = decode_rfc2047_findencoded(inptr, &end);

		/*
		 * No encoded word found - copy the remainder of the string
		 * to the output and exit the loop.
		 */
		if (start == NULL) {
			strncpy(outptr, inptr, bytesleft);
			outptr += bytesleft;
			break;
		}

		/*
		 * Copy across parts of the string before the encoded word
		 * to the output. However, we ignore whitespace between
		 * encoded words if they are all that's there (i.e. we treat
		 * "ENCWORD ENCWORD" as "ENCWORDENCWORD", but treat "ENCWORD
		 * foo ENCWORD" as "ENCWORD foo ENCWORD".
		 */
		if (start != inptr) {
			n = start - inptr;
			if ((enccount == 0)
			    || (strspn(inptr, " \t\r\n") != n)
			    ) {
				if (n > bytesleft)
					n = bytesleft;
				memcpy(outptr, inptr, n);
				outptr += n;
				bytesleft -= n;
			}
		}

		decode_rfc2047_word(start, outptr, bytesleft);

		enccount++;
		bytesleft -= (1 + end - start);
		inptr = end;
		n = strlen(outptr);
		outptr += n;
	}

	outptr[0] = 0;
	*len = strlen(out);

	free(in);

	return out;
}

/* EOF */
