/* $Id: str.h,v 1.1.1.1 2002/09/30 21:08:29 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _STR_H
#define _STR_H

/* a couple of generic string functions... */
void strlwr( char* s );
void strcpylwr( char* d, const char* s );
void strncpylwr( char* d, const char* s, int n );

typedef struct _str
{
    char*       p;
    uint        len;
} str_t;

void    str_create ( str_t* pthis );
void    str_destroy( str_t* pthis );

int     str_cmp    ( const str_t* pthis, const str_t* pother );
int     str_casecmp( const str_t* pthis, const str_t* pother );

#endif /* ndef _STR_H */
