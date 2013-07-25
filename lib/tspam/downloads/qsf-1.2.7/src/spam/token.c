/*
 * Functions for breaking a message up into tokens.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


/*
 * Add a new token to the token tree.
 */
void spam_token_add(opts_t opts, spam_t spam, char *str, int len)
{
	token_t *parentptr;
	token_t token;
	int c;

	/*
	 * Refuse to add a token that's too small.
	 */
	if (len < 2)
		return;

	token = spam->tokens;
	parentptr = &(spam->tokens);

	while (token != NULL) {

		if (len > token->length) {
			parentptr = &(token->longer);
		} else {
			c = strncmp(str, token->token, len);
			if (len == token->length && c == 0) {
				break;
			} else if (c < 0) {
				parentptr = &(token->lower);
			} else {
				parentptr = &(token->higher);
			}
		}
		token = *parentptr;
	}

	if (token == NULL) {
		token = calloc(1, sizeof(*token));
		if (token == NULL) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				_("calloc failed"), strerror(errno));
			return;
		}

		*parentptr = token;
		spam->token_count++;
		token->token = str;
		token->length = len;
	}

	if (token->count < 1)
		spam_fetch(spam, str, len, &(token->num_spam),
			   &(token->num_nonspam), &(token->last_updated));

	token->count++;
}


/*
 * Add a token and (recursively) all its leaf nodes to the array.
 */
static void spam_token_arrayadd(spam_t spam, token_t token, int depth)
{
	if (token == NULL)
		return;
	if (depth > 10000)
		return;
	if (spam->_idx >= spam->token_count)
		return;

	spam->tarray[spam->_idx++] = token;

	spam_token_arrayadd(spam, token->lower, depth + 1);
	spam_token_arrayadd(spam, token->longer, depth + 1);
	spam_token_arrayadd(spam, token->higher, depth + 1);
}


/*
 * Return the length of the initial segment of "buf" (length "buflen") that
 * consists entirely of characters in "accept".
 */
static int spam_tokenise__span(char *buf, int buflen, char *accept)
{
	int len;

	for (len = 0; (len < buflen) && strchr(accept, buf[len]); len++) {
	}

	return len;
}


/*
 * Return the length of the initial segment of "buf" (length "buflen") that
 * consists entirely of characters not in "reject".
 */
static int spam_tokenise__cspan(char *buf, int buflen, char *reject)
{
	int len;

	for (len = 0; (len < buflen) && !strchr(reject, buf[len]); len++) {
	}

	return len;
}


/*
 * Tokenise the given message and return a spam structure containing the
 * tokens in the message and their spam ratings. Returns NULL on error.  The
 * following special token names are used:
 *
 * " COUNTS"     - total number of spam and non-spam email messages seen,
 *                 plus the total number of updates we have ever applied
 * " SINCEPRUNE" - number of updates since the last prune (first val only)
 *
 * Note that these special token names all start with a space, so as to not
 * clash with any "real" tokens.
 */
spam_t spam_tokenise(opts_t opts, msg_t msg, qdb_t db1, qdb_t db2,
		     qdb_t db3, int db1weight, int db2weight,
		     int db3weight)
{
	spam_t spam;
	long pos, start, len, i, n, dummy;
	char *content;
	long content_size;
	long prevstart;

	spam = calloc(1, sizeof(*spam));
	if (spam == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return NULL;
	}

	spam->db1 = db1;
	spam->db2 = db2;
	spam->db3 = db3;
	spam->dbw = opts->dbw;

	spam->db1weight = db1weight;
	spam->db2weight = db2weight;
	spam->db3weight = db3weight;

	spam_fetch(spam, " COUNTS", 7, &(spam->total_spam),
		   &(spam->total_nonspam), &(spam->update_count));

	spam_fetch(spam, " SINCEPRUNE", 11, &(spam->since_prune), &pos,
		   &dummy);

	if (spam->total_spam < 1)
		spam->total_spam = 1;
	if (spam->total_nonspam < 1)
		spam->total_nonspam = 1;

	content = msg->textcontent;
	content_size = msg->text_size;
	if (content == NULL) {
		content = msg->content;
		content_size = msg->content_size;
	}

	prevstart = 0;

	for (pos = 0; pos < content_size;) {

		len =
		    spam_tokenise__span(content + pos, content_size - pos,
					TOKEN_CHARS);

		if (len <= 0) {

			len = spam_tokenise__cspan(content + pos,
						   content_size - pos,
						   TOKEN_CHARS);
			pos += len;
			if (len < 1)
				pos++;

			continue;
		}

		start = pos;
		pos += len;

		/*
		 * Don't allow a token to start with 0-9, -, ', !, or .
		 */

		if ((content[start] >= '0' && content[start] <= '9')
		    || content[start] == '-'
		    || content[start] == '\''
		    || content[start] == '!'
		    || content[start] == '?' || content[start] == '.')
			continue;

		/*
		 * Skip tokens that are too short or too long
		 */
		if ((len < 3) || (len > 34))
			continue;

		/*
		 * Make all tokens lower case (tests indicate that case
		 * sensitive tokens lead to a higher false positive rate, as
		 * well as making the token database bigger)
		 */
		for (i = 0; i < len; i++) {
			if (content[start + i] >= 'A'
			    && content[start + i] <= 'Z')
				content[start + i] += 32;
		}

		/*
		 * Strip -, ', . from end of token
		 */
		for (i = len - 1; i > 0; i--) {
			if (content[start + i] == '-'
			    || content[start + i] == '\''
			    || content[start + i] == '.') {
				len--;
			} else {
				break;
			}
		}

		/*
		 * Check length again, eg in case token was "a--"
		 */
		if (len < 2)
			continue;

		spam_token_add(opts, spam, content + start, len);

		/*
		 * If this isn't the first token, add a second pseudo-token
		 * consisting of all the text from the start of the previous
		 * token to the end of the current one.
		 */
		if ((prevstart != 0) && (prevstart < start)) {
			spam_token_add(opts, spam,
				       content + prevstart,
				       (start - prevstart) + len);
		}

		prevstart = start;

	}

	spam->override = spam_test(opts, spam, msg);

	if (spam->token_count < 1)
		return spam;

	spam->tarray = calloc(spam->token_count, sizeof(token_t));
	if (spam->tarray == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return spam;
	}

	spam_token_arrayadd(spam, spam->tokens, 0);
	spam->token_count = spam->_idx;

	n = 0;
	spam->robx = 0.0;

	/*
	 * Calculate the spam probabilities for each token.
	 *
	 * Formerly we did (bad / tb) / ((bad / tb) + (good / tg)) where
	 * tb/tg are total bad/good messages seen. This appears to be
	 * slightly redundant, so we now just use the token counts directly,
	 * i.e. we do pw = bad / (bad+good) instead. This approximation
	 * allows us to not worry about how to modify message total counts
	 * when the database is pruned.
	 */
	for (i = 0; i < spam->token_count; i++) {
		double good, bad, gbtot, pw;
		token_t token;

		token = spam->tarray[i];

		good = token->num_nonspam;
		bad = token->num_spam;
		gbtot = good + bad;

		pw = 0.0;
		if (gbtot > 0) {
			pw = bad / (bad + good);
			if (gbtot > 10.0) {
				spam->robx += pw;
				n++;
			}
		}

		token->prob_spam = pw;
	}

	if (n > 0) {
		spam->robx = spam->robx / (double) n;
	} else {
		spam->robx = 0.5;
	}

	return spam;
}

/* EOF */
