/*
 * Message handling prototypes and structures.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _MESSAGE_H
#define _MESSAGE_H 1

#ifndef _OPTIONS_H
#include "options.h"
#endif

#define MAX_MESSAGE_SIZE 512*1024

struct msg_s;
typedef struct msg_s *msg_t;

struct msg_s {           /* structure describing an email message */
	char *original;     /* the original message, in full */
	long original_size; /* the length of the full original message */
	char *sender;       /* email address from "From:" header */
	char *envsender;    /* email address of envelope sender */
	int num_headers;    /* number of header lines */
	char **header;      /* the header lines */
	char *body;         /* the original message body */
	long body_size;     /* the size of the original message body */
	char *content;      /* decoded content of message */
	long content_size;  /* the size of the decoded content */
	long content_alloced; /* size of block allocated */
	char *textcontent;  /* decoded content of message, no HTML */
	long text_size;     /* the size of the decoded non-HTML content */
	long *wordpos;      /* positions of words in decoded non-HTML */
	int *wordlength;    /* the length of each word */
	long num_words;     /* size of the above array (no. of words) */
	int num_images;     /* the number of image attachments found */
	char *_bound[8];    /* content boundaries */
	int _bdepth;        /* current boundary nesting depth */
	char _in_header;    /* in message header */
	char _encoding;     /* current content encoding type */
	char _nottext;      /* set if current content is not text */
	long _pos;          /* decoding position */
};

msg_t msg_parse(opts_t);
void msg_spamsubject(msg_t, char *);
void msg_spamheader(msg_t, char *, double);
void msg_spamratingheader(msg_t, double, double);
void msg_spamlevelheader(msg_t, double, double);
void msg_dump(msg_t);
void msg_free(msg_t);

char *msg_from_base64(char *, long *);
char *msg_from_qp(char *, long *);
char *msg_decode_rfc2047(char *, long *);

int msg_addcontent(opts_t, msg_t, char *, long);
msg_t msg_alloc(opts_t);
int msg_read(opts_t, msg_t);
int msg_headers_store(opts_t, msg_t);

#endif /* _MESSAGE_H */

/* EOF */
