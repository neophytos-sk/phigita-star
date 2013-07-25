/* $Id: lex.h,v 1.4 2002/10/12 17:36:41 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _TOK_H
#define _TOK_H

typedef enum { from, eof, word } toktype_t;

typedef struct _tok
{
    toktype_t   tt;         /* token type */
    char*       p;
    uint        len;
} tok_t;

typedef enum { envelope, hdrs, body, mime_part } msgsec_t;

typedef struct _lex
{
    mbox_t      mboxtype;
    msgsec_t    section;    /* current section (envelope, headers, body) */
    uint        pos;        /* current position */
    uint        bom;        /* beginning of message */
    uint        eom;        /* end of current message (start of next) */
    uint        lineend;    /* line end (actually, start of next line) */
    uint        buflen;     /* length of buffer */
    char*       pbuf;
} lex_t;

void    lex_create   ( lex_t* plex, mbox_t mboxtype );
void    lex_destroy  ( lex_t* plex );

bool_t  lex_load     ( lex_t* plex, int fd );
void    lex_nexttoken( lex_t* plex, tok_t* ptok );

void    lex_passthru ( lex_t* plex, bool_t is_spam, double hits );

#endif /* ndef TOK_H */
