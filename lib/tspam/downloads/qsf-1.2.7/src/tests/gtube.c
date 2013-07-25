/*
 * Implement GTUBE, the Generic Test for Unsolicited Bulk Email.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include <string.h>

#define GTUBE "XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X"


extern char *minimemmem(char *, long, char *, long);


/*
 * Override the spam filter and always mark a message as spam if it contains
 * the GTUBE string. This can be used to check that the spam filter is
 * working.
 */
int spam_test_gtube(opts_t opts, msg_t msg, spam_t spam)
{
	if (minimemmem
	    (msg->content, msg->content_size, GTUBE, strlen(GTUBE)) == 0)
		return 0;

	return 1;
}

/* EOF */
