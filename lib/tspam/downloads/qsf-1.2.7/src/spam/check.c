/*
 * Check whether a message is spam.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include "log.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


/*
 * Return a probability that the message is spam, where 0.9 and above means
 * "definitely spam", using the Robinson method.
 *
 * Robinson's method:
 *
 *   Set pN = "spam probability" of token N, where pN = f(p(w)), where p(w)
 *   is (bad / tb) / ((bad / tb) + (good / tg)) - bad is number of times
 *   token seen in bad messages, good is times token seen in good messages,
 *   tb and tg are total number of bad and good messages seen; f(w) is (robs
 *   * robx + gbtot * p(w)) / (robs + gbtot), where gbtot is is good + bad,
 *   robs is a constant, and robx is a fudge factor calculated from the
 *   average p(w) of all tokens that have been seen over 10 times.
 *
 *   Then:
 *
 *   P = 1 - ((1-p1)(1-p2)(1-p3)...(1-pN))^(1/n)
 *   Q = 1 - (p1p2p3...pN)^(1/n)
 *   S = (P - Q) / (P + Q)
 *
 * S is then a number from -1 to +1, so we scale it to 0-1 and then divide
 * by (0.54/0.9=0.6) and clip to 1, since the spam cutoff point for this
 * algorithm is 0.54 and we want it to be 0.9.
 */
double spam_check__robinson(opts_t opts, msg_t msg, spam_t spam)
{
	token_t token;
	long i, n;
	double r, ln2, p_log, q_log, p, q, s, robs, robx;
	struct {
		double mant;
		int exp;
	} P, Q;
	int e;

	P.mant = 1.0;
	P.exp = 0;
	Q.mant = 1.0;
	Q.exp = 0;

	robx = spam->robx;
	robs = 1.0;

	n = 0;

	if (spam->token_count < 1)
		return 0.5;

	for (i = 0; i < spam->token_count; i++) {
		double pw, fw, gbtot;

		token = spam->tarray[i];

		pw = token->prob_spam;
		gbtot = token->num_nonspam + token->num_spam;

		fw = (robs * robx + gbtot * pw) / (robs + gbtot);

		if (fabs(0.5 - pw) < 0.00001)
			continue;

		P.mant *= 1 - fw;
		if (P.mant < 1.0e-200) {
			P.mant = frexp(P.mant, &e);
			P.exp += e;
		}

		Q.mant *= fw;
		if (Q.mant < 1.0e-200) {
			Q.mant = frexp(Q.mant, &e);
			Q.exp += e;
		}

		n++;
	}

	if (n < 1)
		n = 1;

	r = 1.0 / (double) n;
	ln2 = 0.69314718055994530941;

	/*
	 * Avoid floating point exceptions.
	 */
	if (P.mant <= 0)
		P.mant = 0.00000000001;
	if (Q.mant <= 0)
		Q.mant = 0.00000000001;

	p_log = log(P.mant) + P.exp * ln2;
	q_log = log(Q.mant) + Q.exp * ln2;

	p = 1.0 - exp(p_log * r);
	q = 1.0 - exp(q_log * r);

	s = (1.0 + (p - q) / (p + q)) / 2.0;

	s = s / 0.6;
	if (s > 1.0)
		s = 1.0;

	return s;
}


/*
 * Return a score above zero if the given message is probably spam, zero or
 * less if not. If the score is < -9999, then the message should not be
 * processed at all (due to the "min-tokens" option).
 */
double spam_check(opts_t opts, msg_t msg)
{
	double prob;
	spam_t spam;

	spam =
	    spam_tokenise(opts, msg, opts->dbr1, opts->dbr2, opts->dbr3,
			  opts->db1weight, opts->db2weight,
			  opts->db3weight);

	/*
	 * If we're not in training or benchmarking mode and we know the
	 * email address of the message sender or the envelope address,
	 * check either against the deny-list and if a match is found,
	 * return a "definitely spam" score. Then check against the
	 * allow-list, and if a match is found, return a "definitely not
	 * spam" score. Then check both again for just the "@domain" part.
	 */
	if ((opts->action != ACTION_TRAIN)
	    && (opts->action != ACTION_BENCHMARK)
	    ) {
		char *senderdomain;
		char *envsenderdomain;

		/*
		 * First check the sender and envelope sender addresses
		 * against the deny and allow lists.
		 */
		if ((opts->denylist)
		    && ((spam_denylist_match(spam, msg->sender))
			|| (spam_denylist_match(spam, msg->envsender))
		    )
		    ) {
			spam_free(spam);
			return 0.1;
		} else if ((opts->allowlist)
			   && ((spam_allowlist_match(spam, msg->sender))
			       ||
			       (spam_allowlist_match(spam, msg->envsender))
			   )
		    ) {
			spam_free(spam);
			return 0.00 - (opts->threshold + 0.01);
		}

		/*
		 * Now check just the @domain part of each address.
		 */
		senderdomain = NULL;
		if (msg->sender)
			senderdomain = strchr(msg->sender, '@');
		envsenderdomain = NULL;
		if (msg->envsender)
			envsenderdomain = strchr(msg->envsender, '@');

		if ((opts->denylist)
		    && ((spam_denylist_match(spam, senderdomain))
			|| (spam_denylist_match(spam, envsenderdomain))
		    )
		    ) {
			spam_free(spam);
			return 0.1;
		} else if ((opts->allowlist)
			   && ((spam_allowlist_match(spam, senderdomain))
			       ||
			       (spam_allowlist_match
				(spam, envsenderdomain))
			   )
		    ) {
			spam_free(spam);
			return 0.00 - (opts->threshold + 0.01);
		}
	}


	/*
	 * If we've been told to do nothing if there are fewer than a
	 * particular number of tokens, then return -10000 if there aren't
	 * enough tokens.
	 */
	if ((opts->min_token_count > spam->token_count)
	    && (opts->action != ACTION_TRAIN)
	    && (opts->action != ACTION_BENCHMARK)
	    ) {
		spam_free(spam);
		return -10000.00;
	}

	if ((opts->action != ACTION_TRAIN)
	    && (opts->action != ACTION_BENCHMARK))
		log_add(2, _("token count: %d"), spam->token_count);


	/*
	 * If a spam test caused an override, return the appropriate score
	 * (definitely spam or non-spam) depending on whether the override
	 * flag is positive or negative respectively.
	 */
	if (spam->override != 0) {
		prob = 0.1;
		if (spam->override < 0)
			prob = 0.00 - (opts->threshold + 0.01);

		spam_free(spam);

		return prob;
	}

	prob = spam_check__robinson(opts, msg, spam);

	spam_free(spam);

	if (prob > opts->threshold)
		return prob - opts->threshold;

	return prob - (opts->threshold + 0.01);
}

/* EOF */
