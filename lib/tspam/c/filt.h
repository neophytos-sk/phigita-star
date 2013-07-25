/* $Id: filt.h,v 1.1 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _FILT_H
#define _FILT_H

typedef struct
{
    str_t       key;
    double      prob;
} discrim_t;

typedef struct
{
    double      spamicity;
    uint        keepers;
    discrim_t*  extrema;
} stats_t;

void statdump( stats_t* pstat, int fd );
void bayesfilt( dbt_t* pglist, dbt_t* pblist, vec_t* pmlist, stats_t* pstats );

bool_t  bvec_loadmsg( vec_t* pthis, lex_t* plex, tok_t* ptok );

#endif /* ndef _FILT_H */
