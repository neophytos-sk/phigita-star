/*
 * Decode a block of Quoted-Printable encoded data.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include <stdlib.h>


#define XX 127
/*
 * Table for decoding hexadecimal in quoted-printable
 */
static char index_hex[256] = {		    /* RATS: ignore (OK) */
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, XX, XX, XX, XX, XX, XX,
	XX, 10, 11, 12, 13, 14, 15, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, 10, 11, 12, 13, 14, 15, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
};

#define HEXCHAR(c) (index_hex[(unsigned char)(c)])


/*
 * Decode a block of Quoted-Printable-encoded data and return a pointer to
 * the decoded data, which will have been malloc()ed, or NULL on error.  The
 * content of "size" is updated to contain the size of the output buffer,
 * and on entry should contain the size of the input block.
 */
char *msg_from_qp(char *data, long *size)
{
	char *out;
	long inpos, outpos;
	int byte, c, c1 = 0, c2 = 0;

	out = malloc(64 + *size);
	if (out == NULL)
		return NULL;

	for (inpos = 0, outpos = 0, byte = 0; inpos < *size; inpos++) {

		c = data[inpos];

		switch (byte) {
		case 0:
			if (c == '=') {
				byte++;
			} else {
				out[outpos++] = c;
			}
			break;
		case 1:
			c1 = HEXCHAR(c);
			if (c1 == XX) {
				byte = 0;
			} else {
				byte++;
			}
			break;
		case 2:
			c2 = HEXCHAR(c);
			if (c2 != XX) {
				out[outpos++] = c1 << 4 | c2;
			}
			byte = 0;
			break;
		default:
			break;
		}
	}

	out[outpos] = 0;
	*size = outpos;

	return out;
}

/* EOF */
