/*
 * Functions for pruning a spam database.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <math.h>

#undef DEBUG_THRESHOLD
#undef DEBUG_DISCARD

void tick(void);


/*
 * Scan through the database and return the average spam (or non-spam) token
 * count, and fill in the maximum count found.
 */
static double spam_db_prune_old__maxcount(opts_t opts, long *maxcount,
					  int spam)
{
	long num_tokens, num_spam, num_nonspam;
	qdb_datum key, val, nextkey;
	double avg;

	num_tokens = 0;
	avg = 0;
	*maxcount = 0;

	key = qdb_firstkey(opts->dbw);
	while (key.data != NULL) {
		if (opts->showprune) {
			tick();
		}
		val.data = NULL;
		if (((key.size == 7)
		     && (strncmp((char *) (key.data), " COUNTS", 7) == 0)
		    ) || ((key.size == 11)
			  &&
			  (strncmp((char *) (key.data), " SINCEPRUNE", 11)
			   == 0)
		    ) || (key.data[0] == '?')
		    ) {
			val.data = NULL;
		} else {
			val = qdb_fetch(opts->dbw, key);
		}

		if (val.data != NULL) {
			num_tokens++;
			free(val.data);
		}

		nextkey = qdb_nextkey(opts->dbw, key);
		free(key.data);
		key = nextkey;
	}

	key = qdb_firstkey(opts->dbw);
	while (key.data != NULL) {

		if (opts->showprune) {
			tick();
		}

		val.data = NULL;

		if (((key.size == 7)
		     && (strncmp((char *) (key.data), " COUNTS", 7) == 0)
		    ) || ((key.size == 11)
			  &&
			  (strncmp((char *) (key.data), " SINCEPRUNE", 11)
			   == 0)
		    ) || (key.data[0] == '?')
		    ) {
			val.data = NULL;
		} else {
			val = qdb_fetch(opts->dbw, key);
		}

		if (val.data == NULL) {
			nextkey = qdb_nextkey(opts->dbw, key);
			free(key.data);
			key = nextkey;
			continue;
		}

		num_spam = ((long *) (val.data))[0];
		num_nonspam = ((long *) (val.data))[1];
		free(val.data);

		if (spam == SPAM) {
			avg += ((double) num_spam) / ((double) num_tokens);
			if (num_spam > *maxcount)
				*maxcount = num_spam;
		} else {
			avg +=
			    ((double) num_nonspam) / ((double) num_tokens);
			if (num_nonspam > *maxcount)
				*maxcount = num_nonspam;
		}

		nextkey = qdb_nextkey(opts->dbw, key);
		free(key.data);
		key = nextkey;
	}

	return avg;
}


/*
 * Scan through the database looking for tokens to strip, and strip them. We
 * also cap token counts to stop them getting too high relative to the total
 * message counts.  Returns nonzero on error.
 */
static int spam_db_prune_old__strip(opts_t opts)
{
	qdb_datum key, val, nextkey;
	long total_spam, total_nonspam, total_updates;
	long num_spam, num_nonspam, last_updated;
	double good, bad, prob_spam;
	qdb_datum *to_remove = NULL;
	qdb_datum *ptr;
	long num_to_remove = 0;
	long to_remove_alloced = 0;
	long total_tokens;
	long a, b, c, i;
	int clip;

	a = 0;
	b = 0;
	c = 0;
	key.data = (unsigned char *) " COUNTS";
	key.size = 7;
	val = qdb_fetch(opts->dbw, key);
	if (val.data != NULL) {
		a = ((long *) (val.data))[0];
		b = ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long))
			c = ((long *) (val.data))[2];
	}

	total_spam = a;
	total_nonspam = b;
	total_updates = c;
	if (total_spam < 1)
		total_spam = 1;
	if (total_nonspam < 1)
		total_nonspam = 1;

	total_tokens = 0;

	key = qdb_firstkey(opts->dbw);
	while (key.data != NULL) {

		if (opts->showprune) {
			tick();
		}

		val.data = NULL;

		if (((key.size == 7)
		     && (strncmp((char *) (key.data), " COUNTS", 7) == 0)
		    ) || ((key.size == 11)
			  &&
			  (strncmp((char *) (key.data), " SINCEPRUNE", 11)
			   == 0)
		    ) || (key.data[0] == '?')
		    ) {
			val.data = NULL;
		} else {
			val = qdb_fetch(opts->dbw, key);
		}

		if (val.data == NULL) {
			nextkey = qdb_nextkey(opts->dbw, key);
			free(key.data);
			key = nextkey;
			continue;
		}

		num_spam = ((long *) (val.data))[0];
		num_nonspam = ((long *) (val.data))[1];
		last_updated = 0;
		if (val.size > 2 * sizeof(long))
			last_updated = ((long *) (val.data))[2];
		free(val.data);

		clip = 0;
		if (num_spam > 3 * total_spam) {
			num_spam = 3 * total_spam;
			clip = 1;
		}
		if (num_nonspam > 3 * total_nonspam) {
			num_nonspam = 3 * total_nonspam;
			clip = 1;
		}
		if (clip) {
			spam_store(opts, (char *) (key.data), key.size,
				   num_spam, num_nonspam, last_updated);
		}

		total_tokens++;

		good = 2 * num_nonspam;
		bad = num_spam;

		good = good / total_nonspam;
		if (good > 1.0)
			good = 1.0;

		bad = bad / total_spam;
		if (bad > 1.0)
			bad = 1.0;

		if (num_nonspam + num_spam < 4) {
			prob_spam = 0.5;
		} else if ((good < 0.00001) && (bad < 0.00001)) {
			prob_spam = 0.5;
		} else if (2 * num_nonspam + num_spam > 5) {
			prob_spam = bad / (good + bad);
			if (prob_spam > 0.9999) {
				prob_spam = 0.9999;
			} else if (prob_spam < 0.0001) {
				prob_spam = 0.0001;
			}
		} else {
			prob_spam = 1.5;
		}

		if ((prob_spam >= 0.48 && prob_spam <= 0.52)
		    && (num_to_remove < opts->prune_max)
		    ) {
			/*
			 * Add this token to the list to delete afterwards
			 */
			num_to_remove++;
			if (num_to_remove > to_remove_alloced) {
				to_remove_alloced = num_to_remove + 10000;
				ptr = realloc(to_remove,	/* RATS: ignore */
					      to_remove_alloced
					      * sizeof(qdb_datum));
				if (ptr == NULL) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						_
						("memory allocation failed"),
						strerror(errno));
					return 1;
				}
				to_remove = ptr;
			}
			to_remove[num_to_remove - 1].size = key.size;
			to_remove[num_to_remove - 1].data =
			    malloc(key.size);
			if (to_remove[num_to_remove - 1].data == NULL) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name,
					_("memory allocation failed"),
					strerror(errno));
				return 1;
			}
			memcpy(to_remove[num_to_remove - 1].data, key.data,
			       key.size);
		}

		nextkey = qdb_nextkey(opts->dbw, key);
		free(key.data);
		key = nextkey;
	}

	if (opts->showprune) {
		printf(" %ld/%ld [%3.2f%%]",
		       num_to_remove, total_tokens,
		       total_tokens > 0
		       ? 100.0 * (double) num_to_remove
		       / (double) total_tokens : 0);
	}

	/*
	 * Now we remove any keys in the remove list.
	 */

	if (num_to_remove > 0) {
		for (i = 0; i < num_to_remove; i++) {
			if (opts->showprune) {
				tick();
			}
			qdb_delete(opts->dbw, to_remove[i]);
			free(to_remove[i].data);
		}
		if (to_remove != NULL)
			free(to_remove);
	}

	if (opts->showprune) {
		printf(" %s\n", _("removed"));
	}

	return 0;
}


/*
 * Prune the currently writable database, removing redundant entries and
 * scaling down token and message counts if they get too large. Returns
 * nonzero on error.
 *
 * This is the version for old-style databases that don't use token aging.
 */
static int spam_db_prune_old(opts_t opts)
{
	qdb_datum key, val, nextkey;
	long total_spam, total_nonspam, total_updates, max_spam,
	    max_nonspam;
	long num_spam, num_nonspam, last_updated;
	double avg_spam, avg_nonspam, top_count, scale_by;

	if (opts->dbw == NULL) {
		if (opts->showprune) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("pruning requires write access to the database"));
		}
		return 1;
	}

	setvbuf(stdin, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	key.data = (unsigned char *) " SINCEPRUNE";
	key.size = 11;
	spam_store(opts, (char *) (key.data), key.size, 0, 0, 0);

	total_spam = 0;
	total_nonspam = 0;
	total_updates = 0;
	key.data = (unsigned char *) " COUNTS";
	key.size = 7;
	val = qdb_fetch(opts->dbw, key);
	if (val.data != NULL) {
		total_spam = ((long *) (val.data))[0];
		total_nonspam = ((long *) (val.data))[1];
		if (val.size > 2 * sizeof(long))
			total_updates = ((long *) (val.data))[2];
		free(val.data);
		val.data = NULL;
	}
	if (total_spam < 1)
		total_spam = 1;
	if (total_nonspam < 1)
		total_nonspam = 1;

	/*
	 * Scan through all tokens in the database and get the highest
	 * counts for spam and non-spam.
	 */
	if (opts->showprune) {
		printf("%s", _("Checking average token counts..."));
	}

	avg_spam = spam_db_prune_old__maxcount(opts, &max_spam, SPAM);
	avg_nonspam =
	    spam_db_prune_old__maxcount(opts, &max_nonspam, NONSPAM);
	if (avg_spam < 1)
		avg_spam = 1;
	if (avg_nonspam < 1)
		avg_nonspam = 1;

	if (opts->showprune) {
		printf(" %f %f\n", avg_spam, avg_nonspam);
	}

	/*
	 * Scan through all tokens in the database looking for those that
	 * have a spam probability of somewhere around the middle or whose
	 * counts are very tiny compared to the total spam and nonspam
	 * counts, and remove them.
	 */

	if (opts->showprune) {
		printf("%s", _("Scanning for removable tokens..."));
	}

	if (spam_db_prune_old__strip(opts))
		return 1;

	/*
	 * Next, we scan through the database and scale down all of the
	 * counts, and also scale down the total counts by the same amount. 
	 * This helps new additions to the database to actually make an
	 * impact later on.
	 */

	top_count = (avg_spam < avg_nonspam ? avg_spam : avg_nonspam);
	scale_by = top_count / 1000.0;
	if (scale_by < 1.9) {
		/* Not worth scaling - just return */
		return 0;
	}

	if (opts->showprune) {
		printf( /* RATS: ignore */ _
		       ("Scaling down token counts by a factor of %f (max: %f)..."),
		       scale_by, top_count);
	}

	key = qdb_firstkey(opts->dbw);
	while (key.data != NULL) {

		if (opts->showprune) {
			tick();
		}

		val.data = NULL;

		if (key.data[0] != '?') {
			val = qdb_fetch(opts->dbw, key);
		}

		if (val.data == NULL) {
			nextkey = qdb_nextkey(opts->dbw, key);
			free(key.data);
			key = nextkey;
			continue;
		}

		num_spam = ((long *) (val.data))[0];
		num_nonspam = ((long *) (val.data))[1];
		last_updated = 0;
		if (val.size > 2 * sizeof(long))
			last_updated = ((long *) (val.data))[2];
		free(val.data);

		spam_store(opts,
			   (char *) (key.data),
			   key.size,
			   (long) (((double) num_spam) / scale_by),
			   (long) (((double) num_nonspam) / scale_by),
			   last_updated);

		nextkey = qdb_nextkey(opts->dbw, key);
		free(key.data);
		key = nextkey;
	}

	if (opts->showprune) {
		printf(" %s\n", _("done"));
	}

	/*
	 * Now we go through the database again and strip out removable
	 * tokens a final time.
	 */

	if (opts->showprune) {
		printf("%s", _("Secondary scan for removable tokens..."));
	}

	return spam_db_prune_old__strip(opts);
}


/*
 * Prune the currently writable database, removing redundant and old
 * entries.  Returns nonzero on error.
 */
int spam_db_prune(opts_t opts)
{
	qdb_datum key, val, nextkey;
	long total_updates, num_spam, num_nonspam, last_updated;
	qdb_datum *to_remove = NULL;
	qdb_datum *ptr;
	long num_to_remove = 0;
	long to_remove_alloced = 0;
	long total_tokens = 0;

	if (opts->dbw == NULL) {
		if (opts->showprune) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("pruning requires write access to the database"));
		}
		return 1;
	}

	total_updates = -1;
	key.data = (unsigned char *) " COUNTS";
	key.size = 7;
	val = qdb_fetch(opts->dbw, key);
	if (val.data != NULL) {
		if (val.size > 2 * sizeof(long))
			total_updates = ((long *) (val.data))[2];
		free(val.data);
		val.data = NULL;
	}

	setvbuf(stdin, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	if (total_updates < 0)
		return spam_db_prune_old(opts);

	key.data = (unsigned char *) " SINCEPRUNE";
	key.size = 11;
	spam_store(opts, (char *) (key.data), key.size, 0, 0, 0);

	/*
	 * Scan through all tokens in the database and make a list of the
	 * ones we're going to delete. These will be ones which are too old
	 * or insignificant to be of use; "insignificant" means that the
	 * contribution to the overall spam score of a message will be too
	 * small, and the threshold for "too small" moves according to how
	 * long ago the token was last updated.
	 */

	if (opts->showprune) {
		printf("%s", _("Scanning for removable tokens..."));
	}

	key = qdb_firstkey(opts->dbw);
	while (key.data != NULL) {
		double good, bad, prob_spam, significance, threshold, age,
		    agescale;

		if (opts->showprune) {
			tick();
		}

		val.data = NULL;

		/*
		 * Ignore global counters and allow-list entries - they are
		 * never pruned.
		 */
		if ((key.data[0] != '?') && (key.data[0] != ' ')) {
			val = qdb_fetch(opts->dbw, key);
		}

		if (val.data == NULL) {
			nextkey = qdb_nextkey(opts->dbw, key);
			free(key.data);
			key = nextkey;
			continue;
		}

		total_tokens++;

		num_spam = ((long *) (val.data))[0];
		num_nonspam = ((long *) (val.data))[1];
		last_updated = 0;
		if (val.size > 2 * sizeof(long))
			last_updated = ((long *) (val.data))[2];
		free(val.data);

		good = num_nonspam;
		bad = num_spam;
		age = total_updates - last_updated;
		if (age < 1)
			age = 1;

		agescale = log(1.0 + (age / 10));

		if (((good + bad) / agescale) < 1.0) {
			/*
			 * Throw away tokens with very small counts - the
			 * older the token, the larger the counts must be
			 * for the token to be kept.
			 */
			prob_spam = 0.5;
		} else {
			prob_spam = bad / (good + bad);
		}

		significance = fabs(0.5 - prob_spam);

		/*
		 * The threshold of significance: if the probability of
		 * being spam is at or further than this from even (0.5),
		 * then the token is worth keeping.
		 */
		threshold = 0.019;

#ifdef DEBUG_THRESHOLD
		fprintf(stderr, "%s %ld %ld %ld %g %g\n",
			significance < threshold ? "***" : "   ",
			num_nonspam, num_spam, (long) age, significance,
			(good + bad) / agescale);
#endif

		if ((significance < threshold)
		    && (num_to_remove < opts->prune_max)) {
#ifdef DEBUG_DISCARD
			fprintf(stderr, "%ld %ld %ld %g %g\n", num_nonspam,
				num_spam, (long) age, significance,
				(good + bad) / agescale);
#endif

			/*
			 * Token is too insignificant to keep - mark it to
			 * be discarded.
			 */
			num_to_remove++;
			if (num_to_remove > to_remove_alloced) {
				to_remove_alloced = num_to_remove + 10000;
				ptr = realloc(to_remove,	/* RATS: ignore */
					      to_remove_alloced
					      * sizeof(qdb_datum));
				if (ptr == NULL) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name,
						_
						("memory allocation failed"),
						strerror(errno));
					return 1;
				}
				to_remove = ptr;
			}
			to_remove[num_to_remove - 1].size = key.size;
			to_remove[num_to_remove - 1].data =
			    malloc(key.size);
			if (to_remove[num_to_remove - 1].data == NULL) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name,
					_("memory allocation failed"),
					strerror(errno));
				return 1;
			}
			memcpy(to_remove[num_to_remove - 1].data, key.data,
			       key.size);
		}

		nextkey = qdb_nextkey(opts->dbw, key);
		free(key.data);
		key = nextkey;
	}

	if (opts->showprune) {
		printf(" %ld/%ld [%3.2f%%]",
		       num_to_remove, total_tokens,
		       total_tokens > 0
		       ? 100.0 * (double) num_to_remove
		       / (double) total_tokens : 0);
	}

	/*
	 * Now we remove any keys in the remove list.
	 */

	if (num_to_remove > 0) {
		long i;
		for (i = 0; i < num_to_remove; i++) {
			if (opts->showprune) {
				tick();
			}
			if (qdb_delete(opts->dbw, to_remove[i])) {
				fprintf(stderr, "%s: %s: %s\n",
					opts->program_name,
					_("token deletion failed"),
					qdb_error());
			}
			free(to_remove[i].data);
		}
		if (to_remove != NULL)
			free(to_remove);
	}

	if (opts->showprune) {
		printf(" %s\n", _("removed"));
	}

	return 0;
}

/* EOF */
