/* $Id: config.h,v 1.8 2002/10/20 07:16:57 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _CONFIG_H
#define _CONFIG_H

/**************************************
 * Standard headers
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include <ctype.h>
#include <assert.h>

/**************************************
 * System headers
 */
#include <sys/types.h>
#include <limits.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/file.h>
#include <time.h>

/**************************************
 * For convenience
 */
typedef unsigned char byte;
typedef const char* cpchar;
typedef const byte* cpbyte;
typedef const void* cpvoid;
typedef enum { false, true } bool_t;

#define min(a,b)        ( (a)<(b) ? (a) : (b) )
#define max(a,b)        ( (a)<(b) ? (b) : (a) )
#define minmax(v,a,b)   ( (v)<(a)?(a) : (v)>(b)?(b) : (v) )

/* XXX: need to figure out MH and any others (MMDF?) */
typedef enum { detect, mbox, maildir } mbox_t;

/**************************************
 * Tweakables
 */

/* If you have the mysql client libs installed and wish to use them... */
/* #define HAVE_MYSQL */

#define MSGCOUNT_KEY        ".MSGCOUNT"
#define MSGCOUNT_KEY_LEN    (sizeof(MSGCOUNT_KEY)-1)

#define DB_USER         "username"
#define DB_PASS         "password"

#define IOBUFSIZE       4096    /* chunk size for file buffers */
#define MAXWORDLEN      20      /* max word length, inclusive */
#define MAXFREQ         4       /* max times to count word per email */
#define GOOD_BIAS       2.0     /* give good words more weight */
#define DEF_KEEPERS     15      /* how many extrema to keep by default */
#define MINIMUM_FREQ    5       /* min word count for consideration in filter */
#define UNKNOWN_WORD    0.4     /* odds that unknown word is spammish */
#define SPAM_CUTOFF     0.9     /* if it's spammier than this... */

/*
 * If NON_EQUIPROBABLE is defined, use ratio of spamcount/goodcount instead
 * of UNKNOWN_WORDS, and as a factor in the known word calculation.  This is
 * merely copied from bogofilter.  I didn't write it and I cannot explain the
 * relative merits of using it or not.  Please don't ask.  :-)
 */

#endif /* ndef _CONFIG_H */
