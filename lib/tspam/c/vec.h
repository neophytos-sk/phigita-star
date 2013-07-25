/* $Id: vec.h,v 1.3 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _VEC_H
#define _VEC_H

/* item count for initial alloc */
#define VEC_INITIAL_SIZE    256

typedef struct _vec
{
    uint        nalloc;     /* items alloced in pitems */
    uint        nitems;     /* items available */
    str_t*      pitems;     /* growing vector of items */
} vec_t;

typedef struct _veciter
{
    struct _vec*        plist;
    uint                index;
} veciter_t;

/* class vector */
void    vec_create       ( vec_t* pthis );
void    vec_destroy      ( vec_t* pthis );

void    vec_addhead      ( vec_t* pthis, str_t* pstr );
void    vec_addtail      ( vec_t* pthis, str_t* pstr );
void    vec_delhead      ( vec_t* pthis );
void    vec_deltail      ( vec_t* pthis );

void    vec_first        ( vec_t* pthis, veciter_t* piter );
void    vec_last         ( vec_t* pthis, veciter_t* piter );

/* class sorted_vector */
void    svec_add         ( vec_t* pthis, str_t* pstr );
str_t*  svec_find        ( vec_t* pthis, str_t* pstr );
void    svec_sort        ( vec_t* ptthis );

/*      veciter_create not needed */
void    veciter_destroy  ( veciter_t* pthis );

str_t*  veciter_get      ( veciter_t* pthis );
bool_t  veciter_equal    ( veciter_t* pthis, veciter_t* pthat );
bool_t  veciter_hasitem  ( veciter_t* pthis );
bool_t  veciter_prev     ( veciter_t* pthis );
bool_t  veciter_next     ( veciter_t* pthis );
void    veciter_addafter ( veciter_t* pthis, str_t* pstr );
void    veciter_addbefore( veciter_t* pthis, str_t* pstr );
void    veciter_del      ( veciter_t* pthis );

#endif /* ndef _VEC_H */
