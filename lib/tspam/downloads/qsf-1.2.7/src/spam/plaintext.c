/*
 * Plaintext database mapping functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "spami.h"
#include "log.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#ifdef HAVE_FCNTL
#include <fcntl.h>
#endif

struct spam_p_item_s {
	char *hash;
	char *token;
};

struct spam_p_s {
	FILE *fptr;
#ifdef HAVE_FCNTL
	int lockcount;
#endif
	struct spam_p_item_s *list;
	int list_size;
	int list_alloced;
};


#ifdef HAVE_FCNTL
/*
 * Obtain / release a read or write lock on the database. Returns nonzero on
 * error, and blocks until a lock can be obtained.
 */
static int spam_plaintext__lock(struct spam_p_s *data, int lock_type)
{
	struct flock lock;

	if ((lock_type == F_UNLCK) && (data->lockcount > 1)) {
		data->lockcount--;
		return 0;
	} else if ((lock_type != F_UNLCK) && (data->lockcount > 0)) {
		data->lockcount++;
		return 0;
	}

	lock.l_whence = SEEK_SET;
	lock.l_start = 0;
	lock.l_len = 0;

	lock.l_type = lock_type;

	if (fcntl(fileno(data->fptr), F_SETLKW, &lock)) {
		return 1;
	}

	if (lock_type == F_UNLCK) {
		data->lockcount--;
	} else {
		data->lockcount++;
	}

	return 0;
}
#endif				/* HAVE_FCNTL */


/*
 * Add the given hash / token pair to the in-memory list.
 */
static void spam_plaintext__append(struct spam_p_s *data, char *hash,
				   int hashlen, char *token, int tokenlen)
{
	struct spam_p_item_s *ptr;

	if (data->list_size >= data->list_alloced) {
		if (data->list) {
			ptr = realloc(data->list,	/* RATS: ignore */
				      (sizeof *ptr) * (data->list_alloced +
						       1000));
		} else {
			ptr =
			    malloc((sizeof *ptr) *
				   (data->list_alloced + 1000));
		}
		if (ptr == NULL) {
			log_add(1, "%s", strerror(errno));
			return;
		}
		data->list = ptr;
		data->list_alloced += 1000;
	}

	data->list[data->list_size].hash = calloc(1, hashlen + 1);
	data->list[data->list_size].token = calloc(1, tokenlen + 1);

	if (data->list[data->list_size].hash)
		strncpy(data->list[data->list_size].hash, hash, hashlen);
	if (data->list[data->list_size].token)
		strncpy(data->list[data->list_size].token, token,
			tokenlen);

	data->list_size++;
}


/*
 * Update the plaintext mapping with the given hash / token pair.
 */
void spam_plaintext_update(opts_t opts, char *hash, int hashlen,
			   char *token, int tokenlen)
{
	struct spam_p_s *data;
	int i;

	if (opts->plainmap == NULL)
		return;

	if (opts->plaindata == NULL) {
		opts->plaindata = calloc(1, sizeof(struct spam_p_s));
		if (opts->plaindata == NULL) {
			log_add(1, "%s: %s", opts->plainmap,
				strerror(errno));
			return;
		}
	}

	data = opts->plaindata;

	if (data->fptr == NULL) {
		char hashbuf[1024];	 /* RATS: ignore */
		char tokenbuf[1024];	 /* RATS: ignore */

		data->fptr = fopen(opts->plainmap, "a+");

		if (data->fptr == NULL) {
			log_add(1, "%s: %s", opts->plainmap,
				strerror(errno));
			return;
		}
#ifdef HAVE_FCNTL
		spam_plaintext__lock(data, F_WRLCK);
#endif

		fseek(data->fptr, 0, SEEK_SET);
		while (!feof(data->fptr)) {
			char linebuf[4096];	/* RATS: ignore */
			int n;

			linebuf[0] = 0;
			if (fgets(linebuf, sizeof(linebuf), data->fptr) ==
			    NULL)
				break;
			linebuf[sizeof(linebuf) - 1] = 0;
			hashbuf[0] = 0;
			tokenbuf[0] = 0;
			n = sscanf(linebuf, "%1023[^\t\n]\t%1023[^\n]",
				   hashbuf, tokenbuf);
			if (n < 2)
				continue;

			spam_plaintext__append(data, hashbuf,
					       strlen(hashbuf), tokenbuf,
					       strlen(tokenbuf));
		}
	}

	for (i = 0; i < data->list_size; i++) {
		if (data->list[i].hash == NULL)
			continue;
		if (strlen(data->list[i].hash) != hashlen)
			continue;
		if (strncmp(data->list[i].hash, hash, hashlen) != 0)
			continue;
		return;
	}

	spam_plaintext__append(data, hash, hashlen, token, tokenlen);

	if (hashlen > 1023)
		hashlen = 1023;
	if (tokenlen > 1023)
		tokenlen = 1023;
	for (i = 0; i < tokenlen; i++) {
		if (token[i] == '\n') {
			tokenlen = i;
			break;
		}
	}

	fseek(data->fptr, 0, SEEK_END);
	fprintf(data->fptr, "%.*s\t%.*s\n", hashlen, hash, tokenlen,
		token);
}


/*
 * Free the plaintext handling data area.
 */
void spam_plaintext_free(opts_t opts)
{
	struct spam_p_s *data;
	int i;

	if (opts == NULL)
		return;
	if (opts->plainmap == NULL)
		return;
	if (opts->plaindata == NULL)
		return;

	data = opts->plaindata;

	if (data->fptr) {
		fflush(data->fptr);
#ifdef HAVE_FCNTL
		spam_plaintext__lock(data, F_UNLCK);
#endif
		fclose(data->fptr);
	}

	for (i = 0; i < data->list_size; i++) {
		if (data->list[i].hash)
			free(data->list[i].hash);
		if (data->list[i].token)
			free(data->list[i].token);
	}

	if (data->list)
		free(data->list);

	free(opts->plaindata);

	opts->plaindata = NULL;
}

/* EOF */
