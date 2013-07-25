/*
 * Count the number of messages in the given mailbox.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "mailbox.h"
#include "mailboxi.h"

/*
 * Return the number of messages in the given mailbox.
 */
size_t mbox_count(mbox_t mbox)
{
	if (mbox == NULL)
		return 0;
	return mbox->count;
}

/* EOF */
