/*
 * Output command-line help to stdout.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

struct optdesc_s {
	char *optshort;
	char *optlong;
	char *param;
	char *description;
};


/*
 * Display command-line help.
 */
void display_help(void)
{
	struct optdesc_s optlist[] = {
		{"-d", "--database", _("FILE"),
		 _("use FILE as a database")},
		{"-g", "--global", _("FILE"),
		 _("use FILE as a global (readonly) database")},
		{"-P", "--plain-map", _("FILE"),
		 _("store plaintext token map in FILE")},
		{"-s", "--subject", 0,
		 _("add \"[SPAM]\" to Subject: of spam")},
		{"-S", "--subject-marker", _("MARK"),
		 _("add \"MARK\" instead of \"[SPAM]\"")},
		{"-H", "--header-marker", _("MARK"),
		 _("set X-Spam header to \"MARK\" instead of \"YES\"")},
		{"-n", "--no-header", 0,
		 _("do not add X-Spam header to spam")},
		{"-r", "--add-rating", 0,
		 _("add an X-Spam-Rating header (0-100, 90+ = spam)")},
		{"-A", "--asterisk", 0,
		 _("add an X-Spam-Level header (0-20 *s)")},
		{"-t", "--test", 0,
		 _("do not filter, just test for spam")},
		{"-a", "--allowlist", 0,
		 _("enable the allow-list")},
		{"-y", "--denylist", 0,
		 _("enable the deny-list")},
		{"-L", "--level", _("LEVEL"),
		 _("set spam threshold level to LEVEL, not 90")},
		{"-Q", "--min-tokens", _("NUM"),
		 _("only give a score if more than NUM tokens found")},
		{"-e", "--email", _("EMAIL"),
		 _
		 ("update/query allow-list for given EMAIL (set to \"MSG\" to use sender address)")},
		{"-v", "--verbose", 0,
		 _("add informational headers to email")},
		{"", 0, 0, 0},
		{"-T", "--train", _("SPAM NON"),
		 _("train database using SPAM and NON mbox folders")},
		{"-m", "--mark-spam", 0,
		 _("mark incoming message as spam in the database")},
		{"-M", "--mark-nonspam", 0,
		 _("mark incoming message as non-spam in the database")},
		{"-w", "--weight", _("WEIGHT"),
		 _("mark message with weight of WEIGHT instead of 1")},
/*
 * Deprecated options - don't list in the help.
		{"-N", "--no-autoprune", 0,
		 _("do not automatically prune after every 500th entry")},
		{"-p", "--prune", 0,
		 _("remove redundant entries from the database")},
		{"-X", "--prune-max", _("NUM"),
		 _("prune at most NUM tokens, rather than 100000")},
*/
		{"", 0, 0, 0},
		{"-D", "--dump", _("[FILE]"),
		 _("dump database as text to FILE or stdout")},
		{"-R", "--restore", _("[FILE]"),
		 _("restore database from text FILE or stdin")},
		{"-O", "--tokens", 0,
		 _("list tokens found in a message")},
		{"-E", "--merge", _("OTHERDB"),
		 _("merge OTHERDB into current database")},
		{"", 0, 0, 0},
		{"-h", "--help", 0,
		 _("show this help and exit")},
		{"-V", "--version", 0,
		 _("show version information and exit")},
		{0, 0, 0, 0}
	};
	int i, col1max = 0, tw = 77;
	char *optbuf;
	int sz;

	printf(_("Usage: %s [OPTION]..."),  /* RATS: ignore */
	       PROGRAM_NAME);
	printf("\n%s\n\n",
	       _
	       ("Read the message on standard input and output it with an X-Spam header\n"
		"if it is spam."));

	for (i = 0; optlist[i].optshort; i++) {
		int width = 0;

		width = 2 + strlen(optlist[i].optshort);	/* RATS: ignore */
#ifdef HAVE_GETOPT_LONG
		if (optlist[i].optlong)
			width += 2 + strlen(optlist[i].optlong);	/* RATS: ignore */
#endif
		if (optlist[i].param)
			width += 1 + strlen(optlist[i].param);	/* RATS: ignore */

		if (width > col1max)
			col1max = width;
	}

	col1max++;

	sz = col1max + 16;
	optbuf = malloc(sz);
	if (optbuf == NULL) {
		fprintf(stderr, "%s: %s\n", PROGRAM_NAME, strerror(errno));
		exit(1);
	}

	for (i = 0; optlist[i].optshort; i++) {
		char *start;
		char *end;

		if (optlist[i].optshort[0] == 0) {
			printf("\n");
			continue;
		}
#ifdef HAVE_SNPRINTF
		snprintf(optbuf, sz, "%s%s%s%s%s",	/* RATS: ignore (checked) */
#else
		sprintf(optbuf, "%s%s%s%s%s",	/* RATS: ignore (checked) */
#endif
			optlist[i].optshort,
#ifdef HAVE_GETOPT_LONG
			optlist[i].optlong ? ", " : "",
			optlist[i].optlong ? optlist[i].optlong : "",
#else
			"", "",
#endif
			optlist[i].param ? " " : "",
			optlist[i].param ? optlist[i].param : "");

		printf("  %-*s ", col1max - 2, optbuf);

		if (optlist[i].description == NULL) {
			printf("\n");
			continue;
		}

		start = optlist[i].description;

		while (strlen(start) /* RATS: ignore */ >tw - col1max) {
			end = start + tw - col1max;
			while ((end > start) && (end[0] != ' '))
				end--;
			if (end == start) {
				end = start + tw - col1max;
			} else {
				end++;
			}
			printf("%.*s\n%*s ", (int) (end - start), start,
			       col1max, "");
			if (end == start)
				end++;
			start = end;
		}

		printf("%s\n", start);
	}

	printf("\n");
	printf(_("Please report any bugs to %s."),	/* RATS: ignore */
	       BUG_REPORTS_TO);
	printf("\n");
}

/* EOF */
