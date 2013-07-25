/*
 * A ticker to let the user know we've not crashed.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include <stdio.h>
#include <time.h>

/*
 * Output a ticker.
 */
void tick(void)
{
	static char *ticker = "-\\|/";
	static int tickpos = 0;
	static time_t last_tick = 0;

	if (time(NULL) <= last_tick)
		return;
	last_tick = time(NULL);

	printf("%c%c", ticker[tickpos++], 8);
	if (ticker[tickpos] == 0)
		tickpos = 0;
}

/* EOF */
