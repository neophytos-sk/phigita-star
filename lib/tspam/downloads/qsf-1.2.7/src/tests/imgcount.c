/*
 * Rules which add tokens depending on how many images are attached.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"


/*
 * Add a token if the message contains exactly one attached image.
 */
int spam_test_image_single(opts_t opts, msg_t msg, spam_t spam)
{
	if (msg->num_images == 1)
		return 2;
	return 0;
}


/*
 * Add a token if the message contains more than one attached image.
 */
int spam_test_image_multiple(opts_t opts, msg_t msg, spam_t spam)
{
	if (msg->num_images > 1)
		return 2;
	return 0;
}

/* EOF */
