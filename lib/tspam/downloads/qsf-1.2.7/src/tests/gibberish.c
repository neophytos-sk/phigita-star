/*
 * Rules which look for gibberish - words containing too many consonants or
 * vowels in a row.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include <string.h>

#define CONSONANTS "BCDFGHJKLMNPQRSTVWXZbcdfghjklmnpqrstvwxz" \
		   "ÇÐÑÞßçðñþ"
#define VOWELS "AEIOUYaeiouy" \
	       "ÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝ" \
	       "àáâãäåæèéêëìíîïòóôõöøùúûüý\0377"

/*
 * Return nonzero if a sequence of "count" or more characters from the
 * string "accept" are found in the given word, so long as the word is
 * shorter than 60 characters (so we don't trip up on base64 encoded stuff).
 */
static int spam_test_gibberish__runon(char *word, int len, char *accept,
				      int count)
{
	int pos = 0;
	int n;

	if (len >= 60)
		return 0;

	while (pos < len) {
		/*
		 * Skip any characters not in the accept string.
		 */
		while (pos < len) {
			if (strchr(accept, word[pos]) != NULL)
				break;
			pos++;
		}

		if (pos >= len)
			return 0;

		/*
		 * Count the number of allowable characters in a row.
		 */
		n = 0;
		while (pos < len) {
			if (strchr(accept, word[pos]) == NULL)
				break;
			pos++;
			n++;
		}

		if (n >= count)
			return 1;
	}

	return 0;
}


/*
 * Add a token for every word found that contains more than 5 consonants
 * (not including "y") in a row.
 */
int spam_test_gibberish_consonants(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long n;
	char *word;
	int len;

	for (n = 0; n < msg->num_words; n++) {
		word = msg->textcontent + msg->wordpos[n];
		len = msg->wordlength[n];

		if (spam_test_gibberish__runon(word, len, CONSONANTS, 5))
			nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for every word found that contains more than 4 vowels
 * (including "y") in a row.
 */
int spam_test_gibberish_vowels(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long n;
	char *word;
	int len;

	for (n = 0; n < msg->num_words; n++) {
		word = msg->textcontent + msg->wordpos[n];
		len = msg->wordlength[n];

		if (spam_test_gibberish__runon(word, len, VOWELS, 4))
			nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for if the "From:" or "Return-Path:" addresses contain more
 * than 5 consonants (not including "y") in a row.
 */
int spam_test_gibberish_from_consonants(opts_t opts, msg_t msg,
					spam_t spam)
{
	if ((msg->sender)
	    &&
	    (spam_test_gibberish__runon
	     (msg->sender, strlen(msg->sender), CONSONANTS, 5)))
		return 2;
	if ((msg->envsender)
	    &&
	    (spam_test_gibberish__runon
	     (msg->envsender, strlen(msg->envsender), CONSONANTS, 5)))
		return 2;

	return 0;
}


/*
 * Add a token if the "From:" address contains more than 4 vowels (including
 * "y") in a row.
 */
int spam_test_gibberish_from_vowels(opts_t opts, msg_t msg, spam_t spam)
{
	if ((msg->sender)
	    &&
	    (spam_test_gibberish__runon
	     (msg->sender, strlen(msg->sender), VOWELS, 4)))
		return 2;
	if ((msg->envsender)
	    &&
	    (spam_test_gibberish__runon
	     (msg->envsender, strlen(msg->envsender), VOWELS, 4)))
		return 2;

	return 0;
}


/*
 * Add a token for every word found that starts with non-alphanumeric
 * characters other than <>"'*_/.
 */
int spam_test_gibberish_badstart(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long n;
	char *word;
	int len;

	for (n = 0; n < msg->num_words; n++) {
		word = msg->textcontent + msg->wordpos[n];
		len = msg->wordlength[n];

		if (strchr(CONSONANTS, word[0]))
			continue;

		if (strchr(VOWELS, word[0]))
			continue;

		if (strchr("<>\"'*_/", word[0]))
			continue;

		nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for every word found that contains more than 3 hyphens or
 * underscores.
 */
int spam_test_gibberish_hyphens(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long n;
	char *word;
	int len;

	for (n = 0; n < msg->num_words; n++) {
		int hyphens = 0;

		word = msg->textcontent + msg->wordpos[n];
		len = msg->wordlength[n];

		while (len > 0) {
			int c = word[0];

			word++;
			len--;

			if ((c == '-') || (c == '_')) {
				hyphens++;
				if (hyphens > 3)
					break;
			}
		}

		if (hyphens > 3)
			nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}


/*
 * Add a token for every word found that is ridiculously long (over 30
 * characters), not counting 60+ character words because they may be part of
 * a Base64-encoded chunk.
 */
int spam_test_gibberish_longwords(opts_t opts, msg_t msg, spam_t spam)
{
	int nfound = 0;
	long n;
	int len;
	char *word;

	for (n = 0; n < msg->num_words; n++) {
		len = msg->wordlength[n];
		word = msg->textcontent + msg->wordpos[n];

		if (len <= 30)
			continue;
		if (len >= 60)
			continue;

		if (strchr(CONSONANTS, word[0]))
			continue;

		if (strchr(VOWELS, word[0]))
			continue;

		nfound++;
	}

	if (nfound > 0)
		return nfound + 1;

	return 0;
}

/* EOF */
