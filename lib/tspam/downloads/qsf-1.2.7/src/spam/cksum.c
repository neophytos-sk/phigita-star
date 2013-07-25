/*
 * Token checksumming functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "md5.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*
 * Generate a checksum string of the given token and return a malloc()ed
 * pointer to it.
 */
unsigned char *spam_checksum(char *key, int len)
{
	struct MD5Context md5c;
	unsigned char digest[64];	 /* RATS: ignore (size OK) */
	char buf[16];			 /* RATS: ignore (size OK) */
	char resultstr[128];		 /* RATS: ignore (size OK) */
	unsigned char *ptr;
	int i;

	MD5Init(&md5c);
	MD5Update(&md5c, (unsigned char *) key, len);
	MD5Final(digest, &md5c);

	memcpy(resultstr, "!\000", 2);
	for (i = 0; i < 16; i++) {
#ifdef HAVE_SNPRINTF
		snprintf(buf, sizeof(buf), "%02x", digest[i]);
#else
		sprintf(buf, "%02x", digest[i]);
#endif
		buf[2] = 0;
		memcpy(resultstr + strlen(resultstr), buf, 3);
	}

	ptr = (unsigned char *) (strdup(resultstr));

	if (ptr == NULL)
		abort();

	return ptr;
}

/* EOF */
