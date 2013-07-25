/*
 * Small program to generate a fake email given a wordlist to choose words
 * from.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include "config.h"


/*
 * Return a random word from the given word list.
 */
char *random_word(char **wordlist, int wordcount)
{
	return wordlist[rand() % wordcount];
}


/*
 * Output between "min" and "max" (inclusive) random words to stdout.
 */
void random_words(char **wordlist, int wordcount, int wmin, int wmax)
{
	int numtodo, i;

	numtodo = wmin + (rand() % (wmax - wmin));

	for (i = 0; i < numtodo; i++) {
		if (i > 0) printf(" ");
		printf("%s", random_word(wordlist, wordcount));
	}
}


/*
 * Main program.
 */
int main(int argc, char **argv) {
	char **wordlist = NULL;
	char **newptr;
	char *strptr;
	int wordcount = 0;
	char buf[1024];		/* RATS: ignore (checked) */
	char *suffix[] = {
	  ".co.uk",
	  ".com",
	  ".net",
	  ".org",
	  ".org.uk"
	};
	int mailnum;
	time_t t;
	FILE *fptr;

	if (argc != 3) {
		fprintf(stderr, "Usage: fakemail WORDFILE NUMMESSAGES\n");
		return(1);
	}

	fptr = fopen(argv[1], "r");
	if (!fptr) {
		fprintf(stderr, "fakemail: %s: %s\n", argv[1], strerror(errno));
		return(1);
	}

	while (fgets(buf, sizeof(buf) - 1, fptr)) {
		wordcount++;
		if (wordlist) {
			newptr = realloc(wordlist, wordcount * sizeof(char *));	/* RATS: ignore */
		} else {
			newptr = malloc(wordcount * sizeof(char *));
		}
		if (!newptr) {
			fprintf(stderr, "fakemail: %s\n", strerror(errno));
			fclose(fptr);
			return (1);
		}

		strptr = strchr(buf, '\n');
		if (strptr) *strptr = 0;

		wordlist = newptr;
		wordlist[wordcount-1] = strdup(buf);
	}
	fclose(fptr);

	srand(time(NULL));	/* RATS: ignore (randomness not important) */

	for (mailnum = 0; mailnum < atoi(argv[2]); mailnum++) {
#ifdef HAVE_SNPRINTF
		snprintf(buf, sizeof(buf),
#else
		sprintf(buf,	/* RATS: ignore */
#endif
			"%s.%s@%s%s",
			random_word(wordlist, wordcount),
			random_word(wordlist, wordcount),
			random_word(wordlist, wordcount),
			suffix[rand()%5]);
		t = time(NULL);
		printf("From %s  %s", buf, ctime(&t));
		printf("Return-Path: <%s>\n", buf);
		printf("From: <%s>\n", buf);
		printf("To: you@your.com\n");
		printf("Date: %s", ctime(&t));
		printf("Subject: ");
		random_words(wordlist, wordcount, 2, 10);
		printf("\n\n");
		random_words(wordlist, wordcount, 20, 400);
		printf("\n\n");
	}

	return(0);
}

/* EOF */
