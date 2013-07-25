/*
 * Small program to output the Nth message from an mbox file on stdin.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*
 * Main program.
 */
int main(int argc, char **argv)
{
	int dispmsg, prevnl, msgnum;
	char buf[1024];		/* RATS: ignore (checked) */

	if (argc != 2) {
		fprintf(stderr, "Usage: mboxsplit MESSAGENUM\n");
		return(1);
	}

	dispmsg = atoi(argv[1]);

	prevnl = 1;
	msgnum = 0;

	while (fgets(buf, sizeof(buf) - 1, stdin)) {
		if (prevnl && (strncmp(buf, "From ", 5) == 0)) {
			msgnum++;
			prevnl = 0;
		} else if (buf[0] == '\n') {
			prevnl = 1;
		} else if ((buf[0] == '\r') && (buf[1] == '\n')) {
			prevnl = 1;
		} else {
			prevnl = 0;
		}

		if (msgnum == dispmsg)
			printf("%s", buf);
	}

	return(0);
}

/* EOF */
