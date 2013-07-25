/*
 * Functions for benchmarking the training process.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "mailbox.h"
#include "spami.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/time.h>
#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif
#include <unistd.h>

void tick(void);

#ifdef HAVE_SYS_RESOURCE_H
/*
 * Fill in "t" with the difference in time between "t1" and "t2".
 */
static void diff_timeval(struct timeval *t, struct timeval *t1,
			 struct timeval *t2)
{
	t->tv_sec = t2->tv_sec - t1->tv_sec;
	t->tv_usec = t2->tv_usec - t1->tv_usec;
	if (t->tv_usec < 0) {
		t->tv_sec--;
		t->tv_usec += 1000000;
	}
}


/*
 * Fill in "t" with the sum of "t1" and "t2".
 */
static void add_timeval(struct timeval *t, struct timeval *t1,
			struct timeval *t2)
{
	t->tv_sec = t1->tv_sec + t2->tv_sec;
	t->tv_usec = t1->tv_usec + t2->tv_usec;
	if (t->tv_usec >= 1000000) {
		t->tv_sec++;
		t->tv_usec -= 1000000;
	}
}


/*
 * Fill in "usage" with the difference between "usage1" and "usage2", to get
 * the amount of user and system time elapsed between the two,
 */
static void diff_usage(struct rusage *usage, struct rusage *usage1,
		       struct rusage *usage2)
{
	diff_timeval(&(usage->ru_utime), &(usage1->ru_utime),
		     &(usage2->ru_utime));
	diff_timeval(&(usage->ru_stime), &(usage1->ru_stime),
		     &(usage2->ru_stime));
}
#endif				/* HAVE_SYS_RESOURCE_H */


/*
 * Benchmark the training process by training on the first 75% of messages
 * in each folder, and then looking at the classification of the remaining
 * 25% (looking for false positive/false negative results).
 *
 * Also outputs some information about how long (in CPU time) the training
 * process took.
 *
 * Returns nonzero on error.
 */
int spam_benchmark(opts_t opts)
{
#ifdef HAVE_SYS_RESOURCE_H
	struct rusage usage1, usage2, usage;
	struct timeval total;
#endif
	FILE *fptr_spam;
	FILE *fptr_nonspam;
	mbox_t mbox_spam, mbox_nonspam;
	long numspam, numnonspam, msgnum;
	long false_positive, false_negative;
	long spam_checked, nonspam_checked;
	double score;
	msg_t msg;

#ifdef HAVE_SYS_RESOURCE_H
	if (getrusage(RUSAGE_SELF, &usage1)) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("failed to read resource usage"),
			strerror(errno));
		return 1;
	}
#endif

	fflush(stdout);

	if (spam_train(opts))
		return 1;

#ifdef HAVE_SYS_RESOURCE_H
	if (getrusage(RUSAGE_SELF, &usage2)) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("failed to read resource usage"),
			strerror(errno));
		return 1;
	}

	diff_usage(&usage, &usage1, &usage2);
	add_timeval(&total, &(usage.ru_utime), &(usage.ru_stime));
#endif

	printf("%s", _("Optimising database..."));
	qdb_optimise(opts->dbw);
	printf(" %s\n", _("done"));

	printf("\n");

#ifdef HAVE_SYS_RESOURCE_H
	printf("%s\n  %s %5ld.%06ld\n  %s %5ld.%06ld\n  %s %5ld.%06ld\n",
	       _("Resource usage during training and optimising:"),
	       _("  User time (sec):"),
	       (long) (usage.ru_utime.tv_sec),
	       (long) (usage.ru_utime.tv_usec),
	       _("System time (sec):"),
	       (long) (usage.ru_stime.tv_sec),
	       (long) (usage.ru_stime.tv_usec),
	       _(" Total time (sec):"),
	       (long) (total.tv_sec), (long) (total.tv_usec));
	printf("\n");
#endif

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

	numspam = -1;
	numnonspam = -1;

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

#ifdef HAVE_SYS_RESOURCE_H
	if (getrusage(RUSAGE_SELF, &usage1)) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("failed to read resource usage"),
			strerror(errno));
		return 1;
	}
#endif

	printf("Counting incorrect classifications...");

	false_positive = 0;
	false_negative = 0;
	spam_checked = 0;
	nonspam_checked = 0;

	for (msgnum = 0; msgnum < numspam; msgnum++) {
		tick();
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
		score = spam_check(opts, msg);
		if (score <= 0) {
			false_negative++;
		}
		msg_free(msg);
		spam_checked++;
	}

	for (msgnum = 0; msgnum < numnonspam; msgnum++) {
		tick();
		mbox_select(opts, mbox_nonspam, fptr_nonspam, msgnum);
		msg = msg_parse(opts);
		if (msg == NULL) {
			mbox_select(opts, NULL, NULL, 0);
			mbox_free(mbox_spam);
			mbox_free(mbox_nonspam);
			fclose(fptr_spam);
			fclose(fptr_nonspam);
			return 1;
		}
		score = spam_check(opts, msg);
		if (score > 0) {
			false_positive++;
		}
		msg_free(msg);
		nonspam_checked++;
	}

#ifdef HAVE_SYS_RESOURCE_H
	if (getrusage(RUSAGE_SELF, &usage2)) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("failed to read resource usage"),
			strerror(errno));
		return 1;
	}

	diff_usage(&usage, &usage1, &usage2);
	add_timeval(&total, &(usage.ru_utime), &(usage.ru_stime));
#endif

	/*
	 * Prevent division by zero
	 */
	if (spam_checked < 1)
		spam_checked = 1;
	if (nonspam_checked < 1)
		nonspam_checked = 1;

	printf(" \n\n");

#ifdef HAVE_SYS_RESOURCE_H
	printf
	    ("%s\n  %s %5ld.%06ld\n  %s %5ld.%06ld\n  %s %5ld.%06ld\n  %s %ld\n",
	     _("Resource usage during classification:"),
	     _("    User time (sec):"), (long) (usage.ru_utime.tv_sec),
	     (long) (usage.ru_utime.tv_usec), _("  System time (sec):"),
	     (long) (usage.ru_stime.tv_sec),
	     (long) (usage.ru_stime.tv_usec), _("   Total time (sec):"),
	     (long) (total.tv_sec), (long) (total.tv_usec),
	     _("Messages classified:"), spam_checked + nonspam_checked);
	printf("\n");
#endif

	printf("%s %5.2f%% [%ld/%ld] \t%s\n%s %5.2f%% [%ld/%ld] \t%s\n",
	       _("False negatives:"),
	       (100.0 * (double) false_negative) / (double) spam_checked,
	       false_negative, spam_checked,
	       _("(failing to mark spam as being spam)"),
	       _("False positives:"),
	       (100.0 * (double) false_positive) /
	       (double) nonspam_checked, false_positive, nonspam_checked,
	       _("(wrongly marking a real email as spam)"));

	printf("\n%s %5.4f%% [%ld/%ld]\n", _("Accuracy:"),
	       (100.0 *
		(double) (spam_checked + nonspam_checked - false_negative -
			  false_positive) / (double) (spam_checked +
						      nonspam_checked)),
	       (long) (spam_checked + nonspam_checked - false_negative -
		       false_positive),
	       (long) (spam_checked + nonspam_checked)
	    );

	mbox_select(opts, NULL, NULL, 0);
	mbox_free(mbox_spam);
	mbox_free(mbox_nonspam);
	fclose(fptr_spam);
	fclose(fptr_nonspam);

	return 0;
}

/* EOF */
