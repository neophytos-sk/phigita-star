/*
 * Memory allocation/deallocation functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdlib.h>

/*
 * Free the given spam structure.
 */
void spam_free(spam_t spam)
{
	long i;

	if (spam == NULL)
		return;

	if (spam->tarray != NULL) {
		for (i = 0; i < spam->token_count; i++) {
			free(spam->tarray[i]);
		}
		free(spam->tarray);
		spam->tarray = NULL;
	}

	free(spam);
}

/* EOF */
