/*
 * Functions for recognising mail as spam and updating the database.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdio.h>

/*
 * Update the database, marking the contents of the given message as either
 * spam or non-spam depending on whether "type" is SPAM or NONSPAM. Returns
 * nonzero on error.
 */
int spam_update(opts_t opts, msg_t msg, int type)
{
	spam_t spam;
	token_t token;
	long i;

	if (opts->dbw == NULL) {
		fprintf(stderr, "%s: %s\n", opts->program_name,
			_("no database to write to"));
		return 1;
	}

	if (opts->denylist && opts->modifydenylist) {
		if (type == SPAM) {
			spam_denylist_add(opts, msg->sender);
			spam_denylist_add(opts, msg->envsender);
		} else {
			spam_denylist_remove(opts, msg->sender);
			spam_denylist_remove(opts, msg->envsender);
		}
	} else if (opts->allowlist) {
		if (type == SPAM) {
			spam_allowlist_remove(opts, msg->sender);
			spam_allowlist_remove(opts, msg->envsender);
		} else {
			spam_allowlist_add(opts, msg->sender);
			spam_allowlist_add(opts, msg->envsender);
		}
	}

	spam = spam_tokenise(opts, msg, opts->dbw, NULL, NULL, 1, 1, 1);

	if (type == SPAM) {
		spam->total_spam += opts->weight;
	} else {
		spam->total_nonspam += opts->weight;
	}

	spam->update_count++;

	spam_store(opts, " COUNTS", 7,
		   spam->total_spam, spam->total_nonspam,
		   spam->update_count);

	spam->since_prune++;

	spam_store(opts, " SINCEPRUNE", 11, spam->since_prune, 0, 0);

	for (i = 0; i < spam->token_count; i++) {
		token = spam->tarray[i];
		if (type == SPAM) {
			token->num_spam += token->count * opts->weight;
		} else {
			token->num_nonspam += token->count * opts->weight;
		}

		token->last_updated = spam->update_count;

		spam_store(opts, token->token, token->length,
			   token->num_spam, token->num_nonspam,
			   token->last_updated);
	}

	if (spam->update_count > 1) {
		int oldshowprune;

		oldshowprune = opts->showprune;

		opts->showprune = 0;

		spam_db_prune(opts);

		opts->showprune = oldshowprune;

	} else if ((opts->action != ACTION_TRAIN)
		   && (opts->action != ACTION_BENCHMARK)
		   && (!opts->noautoprune)
		   && (spam->since_prune > 500)) {
		spam_db_prune(opts);
	}

	spam_free(spam);

	return 0;
}

/* EOF */
