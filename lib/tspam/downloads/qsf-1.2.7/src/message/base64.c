/*
 * Decode Base64-encoded data.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include <stdlib.h>


/*
 * Table for decoding base64
 */
static char index_64[256] = {		    /* RATS: ignore (OK) */
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
	-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
	-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
};

#define CHAR64(c)  (index_64[(unsigned char)(c)])


/*
 * Decode a block of Base64-encoded data and return a pointer to the decoded
 * data, which will have been malloc()ed, or NULL on error.  The content of
 * "size" is updated to contain the size of the output buffer, and on entry
 * should contain the size of the input block.
 */
char *msg_from_base64(char *data, long *size)
{
	char *out;
	long inpos, outpos;
	int byte, c, c1 = 0, c2 = 0, c3 = 0, c4 = 0;
	char buf[3];			 /* RATS: ignore (checked all) */

	out = malloc(64 + *size);
	if (out == NULL)
		return NULL;

	for (inpos = 0, outpos = 0, byte = 0; inpos < *size; inpos++) {

		c = data[inpos];

		switch (byte) {
		case 0:
			if (c != '=' && CHAR64(c) == -1)
				continue;
			c1 = c;
			byte++;
			break;
		case 1:
			if (c != '=' && CHAR64(c) == -1)
				continue;
			c2 = c;
			byte++;
			break;
		case 2:
			if (c != '=' && CHAR64(c) == -1)
				continue;
			c3 = c;
			byte++;
			break;
		case 3:
			if (c != '=' && CHAR64(c) == -1)
				continue;
			c4 = c;
			byte++;
			break;
		default:
			break;
		}

		if (byte < 4)
			continue;

		byte = 0;

		if (c1 == '=' || c2 == '=')
			break;

		c1 = CHAR64(c1);
		c2 = CHAR64(c2);
		buf[0] = ((c1 << 2) | ((c2 & 0x30) >> 4));

		out[outpos++] = buf[0];

		if (c3 == '=')
			break;

		c3 = CHAR64(c3);
		buf[1] = (((c2 & 0x0F) << 4) | ((c3 & 0x3C) >> 2));
		out[outpos++] = buf[1];

		if (c4 == '=')
			break;
		c4 = CHAR64(c4);
		buf[2] = (((c3 & 0x03) << 6) | c4);
		out[outpos++] = buf[2];
	}

	out[outpos] = 0;
	*size = outpos;

	return out;
}

/* EOF */
