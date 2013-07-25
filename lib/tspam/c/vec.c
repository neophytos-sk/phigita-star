/* $Id: vec.c,v 1.4 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * vec.c: vector functions for bmf.
 *   Vectors are used to hold token lists for input data and flatfile database
 *   entries in standalone mode.  They dramatically reduce the number of small
 *   mallocs and, if used properly, have no performance penalty over fancier
 *   data structures.
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"

/*****************************************************************************
 * vector
 */

void vec_create( vec_t* pthis )
{
    pthis->nalloc = VEC_INITIAL_SIZE;
    pthis->nitems = 0;
    pthis->pitems = (str_t*)malloc( VEC_INITIAL_SIZE*sizeof(str_t) );
}

void vec_destroy( vec_t* pthis )
{
    free( pthis->pitems );
}

static void vec_setsize( vec_t* pthis, uint nsize )
{
    if( nsize > pthis->nalloc )
    {
        uint    nnewalloc;
        str_t*  pnewitems;
        uint    n;

        nnewalloc = pthis->nalloc * 2;
        if( nnewalloc < nsize ) nnewalloc = nsize;
        pnewitems = (str_t*)realloc( pthis->pitems, nnewalloc*sizeof(str_t) );
        if( pnewitems == NULL )
        {
            exit( 2 );
        }
        for( n = pthis->nitems; n < nsize; n++ )
        {
            str_create( &pnewitems[n] );
        }
        pthis->pitems = pnewitems;
        pthis->nalloc = nnewalloc;
    }
}

void vec_addhead( vec_t* pthis, str_t* pstr )
{
    assert( pstr->p != NULL && pstr->len > 0 );

    vec_setsize( pthis, pthis->nitems+1 );
    memmove( &pthis->pitems[1], &pthis->pitems[0], pthis->nitems*sizeof(str_t) );
    pthis->pitems[0] = *pstr;
    pthis->nitems++;
}

void vec_addtail( vec_t* pthis, str_t* pstr )
{
    assert( pstr->p != NULL && pstr->len > 0 );

    vec_setsize( pthis, pthis->nitems+1 );
    pthis->pitems[pthis->nitems] = *pstr;
    pthis->nitems++;
}

void vec_delhead( vec_t* pthis )
{
    assert( pthis->nitems > 0 );
    pthis->nitems--;
    memmove( &pthis->pitems[0], &pthis->pitems[1], pthis->nitems*sizeof(str_t) );
}

void vec_deltail( vec_t* pthis )
{
    assert( pthis->nitems > 0 );
    pthis->nitems--;
}

void vec_first( vec_t* pthis, veciter_t* piter )
{
    piter->plist = pthis;
    piter->index = 0;
}

void vec_last( vec_t* pthis, veciter_t* piter )
{
    piter->plist = pthis;
    piter->index = pthis->nitems;
}

/*****************************************************************************
 * sorted vector
 */

static int svec_compare( const void* p1, const void* p2 )
{
    return str_casecmp( (const str_t*)p1, (const str_t*)p2 );
}

void svec_add( vec_t* pthis, str_t* pstr )
{
    int         lo, hi, mid;
    veciter_t   iter;

    if( pthis->nitems == 0 )
    {
        vec_addtail( pthis, pstr );
        return;
    }

    if( str_casecmp( pstr, &pthis->pitems[0] ) < 0 )
    {
        vec_addhead( pthis, pstr );
        return;
    }

    hi = pthis->nitems - 1;
    lo = -1;
    while( hi-lo > 1 )
    {
        mid = (hi+lo)/2;
        if( str_casecmp( pstr, &pthis->pitems[mid] ) <= 0 )
            hi = mid;
        else
            lo = mid;
    }
    assert( hi < pthis->nitems );

    iter.plist = pthis;
    iter.index = hi;

    if( str_casecmp( pstr, &pthis->pitems[hi] ) < 0 )
    {
        veciter_addbefore( &iter, pstr );
    }
    else
    {
        veciter_addafter( &iter, pstr );
    }
}

str_t* svec_find( vec_t* pthis, str_t* pstr )
{
    int         lo, hi, mid;

    if( pthis->nitems == 0 )
    {
        return NULL;
    }

    hi = pthis->nitems - 1;
    lo = -1;
    while( hi-lo > 1 )
    {
        mid = (hi+lo)/2;
        if( str_casecmp( pstr, &pthis->pitems[mid] ) <= 0 )
            hi = mid;
        else
            lo = mid;
    }
    assert( hi >= 0 && hi < pthis->nitems );

    if( str_casecmp( pstr, &pthis->pitems[hi] ) != 0 )
    {
        return NULL;
    }

    return &pthis->pitems[hi];
}

void svec_sort( vec_t* pthis )
{
    if( pthis->nitems > 1 )
    {
        qsort( pthis->pitems, pthis->nitems, sizeof(str_t), svec_compare );
    }
}

/*****************************************************************************
 * vector iterator
 */

void veciter_destroy( veciter_t* pthis )
{
    /* empty */
}

str_t* veciter_get( veciter_t* pthis )
{
    if( pthis->plist == NULL || pthis->index >= pthis->plist->nitems )
    {
        return NULL;
    }

    return &pthis->plist->pitems[pthis->index];
}

bool_t veciter_equal( veciter_t* pthis, veciter_t* pthat )
{
    if( pthis->plist != pthat->plist ||
        pthis->index != pthat->index )
    {
        return false;
    }

    return true;
}

bool_t veciter_hasitem( veciter_t* pthis )
{
    if( pthis->plist == NULL || pthis->index >= pthis->plist->nitems )
    {
        return false;
    }
    return true;
}

bool_t veciter_prev( veciter_t* pthis )
{
    if( pthis->index == 0 )
    {
        return false;
    }
    pthis->index--;
    return true;
}

bool_t veciter_next( veciter_t* pthis )
{
    pthis->index++;
    if( pthis->index == pthis->plist->nitems )
    {
        return false;
    }
    return true;
}

void veciter_addafter( veciter_t* pthis, str_t* pstr )
{
    str_t* pitems;

    vec_setsize( pthis->plist, pthis->plist->nitems+1 );
    assert( pthis->index < pthis->plist->nitems );
    pitems = pthis->plist->pitems;

    if( pthis->index != pthis->plist->nitems-1 )
    {
        memmove( &pitems[pthis->index+2], &pitems[pthis->index+1],
                 (pthis->plist->nitems-pthis->index-1) * sizeof(str_t) );
    }

    pitems[pthis->index+1] = *pstr;
    pthis->plist->nitems++;
}

void veciter_addbefore( veciter_t* pthis, str_t* pstr )
{
    str_t* pitems;

    vec_setsize( pthis->plist, pthis->plist->nitems+1 );
    assert( pthis->index < pthis->plist->nitems );
    pitems = pthis->plist->pitems;

    memmove( &pitems[pthis->index+1], &pitems[pthis->index],
             (pthis->plist->nitems-pthis->index) * sizeof(str_t) );

    pitems[pthis->index] = *pstr;
    pthis->plist->nitems++;
}

void veciter_del( veciter_t* pthis )
{
    str_t* pitems;

    assert( pthis->plist->nitems > 0 );
    pthis->plist->nitems--;
    if( pthis->index < pthis->plist->nitems )
    {
        pitems = pthis->plist->pitems;
        memmove( &pitems[pthis->index], &pitems[pthis->index+1],
                 (pthis->plist->nitems-pthis->index) * sizeof(str_t) );
    }
}

#ifdef UNIT_TEST
int main( int argc, char** argv )
{
    vec_t       vl;
    veciter_t   iter;
    str_t*      pstr;
    uint        n;

    if( argc != 2 )
    {
        fprintf( stderr, "usage: %s <file>\n", argv[0] );
        return 1;
    }

    for( n = 0; n < 100; n++ )
    {
        vec_create( &vl );
        vec_load( &vl, argv[1] );

        vec_first( &vl, &iter );
        while( (pstr = veciter_get( &iter )) != NULL )
        {
            char  buf[256];
            char* p;
            if( pstr->len > 200 )
            {
                fprintf( stderr, "str too long: %u chars\n", pstr->len );
                break;
            }
            p = buf;
            strcpy( buf, "str: " );
            p += 6;
            memcpy( p, pstr->p, pstr->len );
            p += pstr->len;
            sprintf( p, " %u", pstr->count );
            puts( buf );

            veciter_next( &iter );
        }

        vec_destroy( &vl );
    }

    return 0;
}
#endif /* def UNIT_TEST */
