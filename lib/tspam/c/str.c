/* $Id: str.c,v 1.2 2002/10/14 07:09:51 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#include "config.h"
#include "dbg.h"
#include "str.h"

void strlwr( char* s )
{
    while( *s != '\0' )
    {
        *s = tolower(*s);
        s++;
    }
}

void strcpylwr( char* d, const char* s )
{
    while( *s != '\0' )
    {
        *d++ = tolower(*s++);
    }
}

void strncpylwr( char* d, const char* s, int n )
{
    while( n-- )
    {
        *d++ = tolower(*s++);
    }
}

void str_create( str_t* pstr )
{
    pstr->p = NULL;
    pstr->len = 0;
}

void str_destroy( str_t* pstr )
{
    /* empty */
}

int str_cmp( const str_t* pthis, const str_t* pother )
{
    uint minlen = min( pthis->len, pother->len );
    int cmp;
    assert( pthis->p != NULL && pother->p != NULL && minlen != 0 );

    cmp = strncmp( pthis->p, pother->p, minlen );

    if( cmp == 0 && pthis->len != pother->len )
    {
        cmp = (pthis->len < pother->len) ? -1 : 1;
    }
    return cmp;
}

int str_casecmp( const str_t* pthis, const str_t* pother )
{
    uint minlen = min( pthis->len, pother->len );
    int cmp;
    assert( pthis->p != NULL && pother->p != NULL && minlen != 0 );

    cmp = strncasecmp( pthis->p, pother->p, minlen );

    if( cmp == 0 && pthis->len != pother->len )
    {
        cmp = (pthis->len < pother->len) ? -1 : 1;
    }
    return cmp;
}
