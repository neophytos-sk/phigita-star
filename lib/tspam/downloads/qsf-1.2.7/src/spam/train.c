/*
 * Functions for training the database to recognise spam.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "mailbox.h"
#include "spami.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>

void tick(void);


/*
 * Train the database by repeatedly classifying the contents of two mail
 * folders as spam or non-spam, then updating the database for those
 * messages that get incorrectly classified.
 *
 * If opts->benchmark is set, only the first 75% of messages in each mailbox
 * will be considered, and the database will not be optimised after
 * training.
 *
 * Returns nonzero on error.
 */
int spam_train(opts_t opts)
{
	FILE *fptr_spam;
	FILE *fptr_nonspam;
	mbox_t mbox_spam, mbox_nonspam;
	long numspam, numnonspam, msgnum;
	int round, nobetterspam, nobetternonspam;
	long wrongspam, wrongnonspam, prevwrongspam, prevwrongnonspam;
	double pctwrongspam, pctwrongnonspam;
	int maxrounds;
	time_t last_unlock;
	msg_t msg;

	setvbuf(stdin, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	fptr_spam = fopen(opts->argv[0], "r");
	if (fptr_spam == NULL) {
		fprintf(stderr, "%s: %s: %s: %s\n", opts->program_name,
			opts->argv[0], _("failed to open spam mailbox"),
			strerror(errno));
		return 1;
	}

	fptr_nonspam = fopen(opts->argv[1], "r");
	if (fptr_nonspam == NULL) {
		fprintf(stderr, "%s: %s: %s: %s\n", opts->program_name,
			opts->argv[1],
			_("failed to open non-spam mailbox"),
			strerror(errno));
		fclose(fptr_spam);
		return 1;
	}

	maxrounds = 200;

	if ((opts->argc > 2) && (opts->argv[2])) {
		maxrounds = atoi(opts->argv[2]);
		if (maxrounds < 1)
			maxrounds = 1;
		if (maxrounds > 1000)
			maxrounds = 1000;
	}

	numspam = -1;
	numnonspam = -1;

	/*
	 * Release the database lock while we're counting messages.
	 */
	spam_dbunlock(opts);

	printf("%s ", _("Counting messages in folders..."));

	mbox_spam = mbox_scan(opts, fptr_spam);
	if (mbox_spam == NULL) {
		fclose(fptr_nonspam);
		fclose(fptr_spam);
		return 1;
	}
	numspam = mbox_count(mbox_spam);

	printf("%ld ", numspam);

	mbox_nonspam = mbox_scan(opts, fptr_nonspam);
	if (mbox_nonspam == NULL) {
		fclose(fptr_nonspam);
		fclose(fptr_spam);
		mbox_free(mbox_spam);
		return 1;
	}
	numnonspam = mbox_count(mbox_nonspam);
	printf("%ld\n", numnonspam);

	if (opts->action == ACTION_BENCHMARK) {
		numspam = (numspam * 3) / 4;
		numnonspam = (numnonspam * 3) / 4;
	}

	nobetterspam = 0;
	nobetternonspam = 0;

	prevwrongspam = 0;
	prevwrongnonspam = 0;

	opts->weight = 1;

	/*
	 * Re-lock the database.
	 */
	spam_dbrelock(opts);

	last_unlock = time(NULL);

	for (round = 1; round <= maxrounds; round++) {

		/*
		 * Prune the database after every 15 rounds.
		 */
		if (round > 1 && round % 15 == 1)
			spam_db_prune(opts);

		printf("%s %d: %s", _("round"), round,
		       _("checking spam..."));

		for (msgnum = 0, wrongspam = 0; msgnum < numspam; msgnum++) {
			tick();

			/*
			 * Briefly unlock the database every couple of
			 * seconds, so that any other processes waiting to
			 * read from the database can do so.
			 */
			if (time(NULL) - last_unlock > 1) {
				spam_dbunlock(opts);
				spam_dbrelock(opts);
				last_unlock = time(NULL);
			}

			mbox_select(opts, mbox_spam, fptr_spam, msgnum);
			msg = msg_parse(opts);
			if (msg == NULL) {
				mbox_select(opts, NULL, NULL, 0);
				mbox_free(mbox_spam);
				mbox_free(mbox_nonspam);
				fclose(fptr_spam);
				fclose(fptr_nonspam);
				return 1;
			}
			if (round == 1 && opts->allowlist) {
				spam_allowlist_remove(opts, msg->sender);
				spam_allowlist_remove(opts,
						      msg->envsender);
			}
			if (spam_check(opts, msg) < 0.0) {
				wrongspam++;
				spam_update(opts, msg, SPAM);
			}
			msg_free(msg);
		}

		pctwrongspam = 100.0 * ((double) wrongspam)
		    / (numspam > 0 ? (double) numspam : 1.0);

		printf(			    /* RATS: ignore */
			      _("     reclassified [%3.2f%%] %ld/%ld\n"),
			      pctwrongspam, wrongspam, numspam);

		if (wrongspam >= prevwrongspam) {
			nobetterspam++;
		} else {
			nobetterspam = 0;
		}

		prevwrongspam = wrongspam;

		printf("%s %d: %s", _("round"), round,
		       _("checking non-spam..."));

		for (msgnum = 0, wrongnonspam = 0; msgnum < numnonspam;
		     msgnum++) {
			tick();

			if (time(NULL) - last_unlock > 1) {
				spam_dbunlock(opts);
				spam_dbrelock(opts);
				last_unlock = time(NULL);
			}

			mbox_select(opts, mbox_nonspam, fptr_nonspam,
				    msgnum);
			msg = msg_parse(opts);
			if (msg == NULL) {
				mbox_select(opts, NULL, NULL, 0);
				mbox_free(mbox_spam);
				mbox_free(mbox_nonspam);
				fclose(fptr_spam);
				fclose(fptr_nonspam);
				return 1;
			}
			if (round == 1 && opts->allowlist) {
				spam_allowlist_add(opts, msg->sender);
				spam_allowlist_add(opts, msg->envsender);
			}
			if (spam_check(opts, msg) > -0.01) {
				wrongnonspam++;
				spam_update(opts, msg, NONSPAM);
			}
			msg_free(msg);
		}

		pctwrongnonspam = 100.0 * ((double) wrongnonspam)
		    / (numnonspam > 0 ? (double) numnonspam : 1.0);

		printf(			    /* RATS: ignore */
			      _(" reclassified [%3.2f%%] %ld/%ld\n"),
			      pctwrongnonspam, wrongnonspam, numnonspam);

		if (wrongnonspam >= prevwrongnonspam) {
			nobetternonspam++;
		} else {
			nobetternonspam = 0;
		}

		prevwrongnonspam = wrongnonspam;

		if (wrongnonspam == 0 && pctwrongspam < 0.5 && round > 5) {
			printf("%s\n",
			       _("Good results, ending training."));
			round = 999999;
		}

		if (nobetterspam > 10 && nobetternonspam > 10) {
			printf("%s\n",
			       _("Several rounds with no improvement, "
				 "ending training."));
			round = 999999;
		}
	}

	mbox_select(opts, NULL, NULL, 0);
	mbox_free(mbox_spam);
	mbox_free(mbox_nonspam);
	fclose(fptr_spam);
	fclose(fptr_nonspam);

	if (opts->action == ACTION_BENCHMARK)
		return 0;

	printf("%s", _("Optimising database..."));
	qdb_optimise(opts->dbw);
	printf(" %s\n", _("done"));

	return 0;
}

/* EOF */
