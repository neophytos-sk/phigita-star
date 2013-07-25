/*
 * Functions for memory allocation and deallocation.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "mailbox.h"
#include "mailboxi.h"
#include <stdlib.h>

/*
 * Free an mbox_t.
 */
void mbox_free(mbox_t mbox)
{
	if (mbox == NULL)
		return;
	free(mbox->start);
	free(mbox->length);
	free(mbox);
}

/* EOF */
