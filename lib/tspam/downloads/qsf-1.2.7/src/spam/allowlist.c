/*
 * Functions dealing with the allow-list and the deny-list.
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


/*
 * Return a malloc()ed pointer to a null-terminated string which is the
 * database key for the given allow-list or deny-list email address.
 */
static char *spam_allowlist__token(char *address, int denylist)
{
	unsigned char *ptr;

	if (address == NULL)
		return NULL;

	ptr = spam_checksum(address, strlen(address));

	if (ptr != NULL) {
		if (denylist) {
			ptr[0] = '\\';
		} else {
			ptr[0] = '?';
		}
	}

	return (char *) ptr;
}


/*
 * The same as spam_allowlist__token, but converts a copy of the address to
 * lower case first.
 */
static char *spam_allowlist__lctoken(char *address, int denylist)
{
	char *addrcopy;
	char *key;
	int i;

	addrcopy = strdup(address);
	if (addrcopy == NULL)
		return NULL;

	for (i = 0; addrcopy[i] != 0; i++) {
		if (addrcopy[i] >= 'A' && addrcopy[i] <= 'Z')
			addrcopy[i] += 32;
	}

	key = spam_allowlist__token(addrcopy, denylist);

	free(addrcopy);

	return key;
}


/*
 * Look up the given email address in the allow-list or the deny-list,
 * returning 1 if it is present, 0 if not. First the address is checked in
 * lowercase, then as-is.
 */
static int spam_allowlist__domatch(spam_t spam, int denylist,
				   char *address)
{
	char *key;
	long a, b, c;

	if (spam == NULL)
		return 0;
	if (address == NULL)
		return 0;

	key = spam_allowlist__lctoken(address, denylist);
	if (key != NULL) {
		a = 0;
		b = 0;
		c = 0;
		spam_fetch(spam, key, strlen(key), &a, &b, &c);
		free(key);
		if (a > 0) {
			log_add(2,
				denylist ? _("deny-list match: %s") :
				_("allow-list match: %s"), address);
			return 1;
		}
	}

	key = spam_allowlist__token(address, denylist);
	if (key != NULL) {
		a = 0;
		b = 0;
		c = 0;
		spam_fetch(spam, key, strlen(key), &a, &b, &c);
		free(key);
		if (a > 0) {
			log_add(2,
				denylist ? _("deny-list match: %s") :
				_("allow-list match: %s"), address);
			return 1;
		}
	}

	return 0;
}


/*
 * Add the given email address to the allow-list or the deny-list. It is
 * converted to lower case before being stored.
 */
static void spam_allowlist__doadd(opts_t opts, int denylist, char *address)
{
	char *key;

	if (opts == NULL)
		return;
	if (address == NULL)
		return;

	key = spam_allowlist__lctoken(address, denylist);
	if (key == NULL)
		return;

	spam_store(opts, key, strlen(key), 1, 1, 0);

	if (opts->plainmap) {
		spam_plaintext_update(opts, key, strlen(key), address,
				      strlen(address));
	}

	free(key);
}


/*
 * Remove the given email address from the allow-list or the deny-list. Both
 * as-is and lower-case versions of the address will be removed.
 */
static void spam_allowlist__doremove(opts_t opts, int denylist,
				     char *address)
{
	char *key;
	qdb_datum qkey;

	if (opts == NULL)
		return;
	if (opts->dbw == NULL)
		return;
	if (address == NULL)
		return;

	key = spam_allowlist__token(address, denylist);
	if (key != NULL) {
		qkey.data = (unsigned char *) key;
		qkey.size = strlen(key);
		qdb_delete(opts->dbw, qkey);
		free(key);
	}

	key = spam_allowlist__lctoken(address, denylist);
	if (key != NULL) {
		qkey.data = (unsigned char *) key;
		qkey.size = strlen(key);
		qdb_delete(opts->dbw, qkey);
		free(key);
	}
}


/*
 * Look up the given email address in the allow-list, returning 1 if it is
 * present, 0 if not. First the address is checked in lowercase, then as-is.
 */
int spam_allowlist_match(spam_t spam, char *address)
{
	return spam_allowlist__domatch(spam, 0, address);
}


/*
 * Add the given email address to the allow-list. It is converted to lower
 * case before being stored.
 */
void spam_allowlist_add(opts_t opts, char *address)
{
	spam_allowlist__doadd(opts, 0, address);
}


/*
 * Remove the given email address from the allow-list. Both as-is and
 * lower-case versions of the address will be removed.
 */
void spam_allowlist_remove(opts_t opts, char *address)
{
	spam_allowlist__doremove(opts, 0, address);
}


/*
 * Manage the allow-list manually (-e).
 */
int spam_allowlist_manage(opts_t opts)
{
	int inlist;
	spam_t spam;

	if (opts->action == ACTION_MARK_SPAM) {
		spam_allowlist_remove(opts, opts->emailonly);
		spam_allowlist_remove(opts, opts->emailonly2);
		return 0;
	} else if (opts->action == ACTION_MARK_NONSPAM) {
		spam_allowlist_add(opts, opts->emailonly);
		spam_allowlist_add(opts, opts->emailonly2);
		return 0;
	}

	spam = calloc(1, sizeof(*spam));
	if (spam == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return 1;
	}

	spam->db1 = opts->dbr1;
	spam->db2 = opts->dbr2;
	spam->db3 = opts->dbr3;
	spam->dbw = opts->dbw;

	spam->db1weight = 1;
	spam->db2weight = 1;
	spam->db3weight = 1;

	inlist = spam_allowlist_match(spam, opts->emailonly);
	if (!inlist)
		inlist = spam_allowlist_match(spam, opts->emailonly2);

	free(spam);

	if (inlist) {
		if (opts->no_filter)
			return 0;
		printf("YES\n");
	} else {
		if (opts->no_filter)
			return 1;
		printf("NO\n");
	}

	return 0;
}


/*
 * Look up the given email address in the deny-list, returning 1 if it is
 * present, 0 if not. First the address is checked in lowercase, then as-is.
 */
int spam_denylist_match(spam_t spam, char *address)
{
	return spam_allowlist__domatch(spam, 1, address);
}


/*
 * Add the given email address to the deny-list. It is converted to lower
 * case before being stored.
 */
void spam_denylist_add(opts_t opts, char *address)
{
	spam_allowlist__doadd(opts, 1, address);
}


/*
 * Remove the given email address from the deny-list. Both as-is and
 * lower-case versions of the address will be removed.
 */
void spam_denylist_remove(opts_t opts, char *address)
{
	spam_allowlist__doremove(opts, 1, address);
}


/*
 * Manage the deny-list manually (-e).
 */
int spam_denylist_manage(opts_t opts)
{
	int inlist;
	spam_t spam;

	if (opts->action == ACTION_MARK_NONSPAM) {
		spam_denylist_remove(opts, opts->emailonly);
		spam_denylist_remove(opts, opts->emailonly2);
		return 0;
	} else if (opts->action == ACTION_MARK_SPAM) {
		spam_denylist_add(opts, opts->emailonly);
		spam_denylist_add(opts, opts->emailonly2);
		return 0;
	}

	spam = calloc(1, sizeof(*spam));
	if (spam == NULL) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("calloc failed"), strerror(errno));
		return 1;
	}

	spam->db1 = opts->dbr1;
	spam->db2 = opts->dbr2;
	spam->db3 = opts->dbr3;
	spam->dbw = opts->dbw;

	spam->db1weight = 1;
	spam->db2weight = 1;
	spam->db3weight = 1;

	inlist = spam_denylist_match(spam, opts->emailonly);
	if (!inlist)
		inlist = spam_denylist_match(spam, opts->emailonly2);

	free(spam);

	if (inlist) {
		if (opts->no_filter)
			return 0;
		printf("YES\n");
	} else {
		if (opts->no_filter)
			return 1;
		printf("NO\n");
	}

	return 0;
}

/* EOF */
