/* $Id: filt.c,v 1.1 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * filt.c: The Bayes filter implementation.
 *   See http://www.paulgraham.com/spam.html for discussion.
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"
#include "dbh.h"
#include "filt.h"

#define DEVIATION(n)    fabs((n)-0.5f)

/* Dump the contents of a statistics structure */
void statdump( stats_t* pstat, int fd )
{
    char        iobuf[IOBUFSIZE];
    char*       p;
    discrim_t*  pp;

    p = iobuf;
    p += sprintf( iobuf, "# Spamicity: %f\n", pstat->spamicity );

    for (pp = pstat->extrema; pp < pstat->extrema + pstat->keepers; pp++)
    {
        if (pp->key.len)
        {
            strcpy( p, "# '" ); p += 3;
            strncpylwr( p, pp->key.p, pp->key.len ); p += pp->key.len;
            p += snprintf( p, 28, "' -> %f\n", pp->prob );
            if( p+MAXWORDLEN+32 > (iobuf+1) )
            {
                write( fd, iobuf, p-iobuf );
                p = iobuf;
            }
        }
    }
    if( p != iobuf )
    {
        write( fd, iobuf, p-iobuf );
    }
}

void bayesfilt( dbt_t* pglist, dbt_t* pblist, vec_t* pmlist, stats_t* pstats )
{
    veciter_t   iter;
    str_t*      pword;

    double prob, product, invproduct, dev;
    double slotdev, hitdev;

#ifdef NON_EQUIPROBABLE
    /* There is an argument that we should (go?) by number of *words* here. */
    double msg_prob = ((double)pblist->nitems / (double)pglist->nitems);
#endif

    discrim_t* pp;
    discrim_t* hit;

    for (pp = pstats->extrema; pp < pstats->extrema+pstats->keepers; pp++)
    {
        pp->key.p = NULL;
        pp->key.len = 0;
        pp->prob = 0.5f;
    }

    vec_first( pmlist, &iter );
    while( (pword = veciter_get( &iter )) != NULL )
    {
        double goodness = pglist->getcount( pglist, pword );
        double spamness = pblist->getcount( pblist, pword );
        uint goodtotal = pglist->getmsgcount( pglist );
        uint spamtotal = pblist->getmsgcount( pblist );

        if( goodness + spamness < MINIMUM_FREQ )
        {
#ifdef NON_EQUIPROBABLE
            /*
             * In the absence of evidence, the probability that a new word will
             * be spam is the historical ratio of spam words to nonspam words.
             */
            prob = msg_prob;
#else
            prob = UNKNOWN_WORD;
#endif
        }
        else
        {
            double goodprob = goodtotal ? min( 1.0, (goodness / goodtotal) ) : 0.0;
            double spamprob = spamtotal ? min( 1.0, (spamness / spamtotal) ) : 0.0;
            assert( goodtotal > 0 || spamtotal > 0 );

#ifdef NON_EQUIPROBABLE
            prob = (spamprob * msg_prob) / ((goodprob * (1 - msg_prob)) + (spamprob * msg_prob));
#else
            prob = spamprob / (goodprob + spamprob);
#endif

            prob = minmax( prob, 0.01, 0.99 );
        }

        /* update the list of tokens with maximum deviation */
        dev = DEVIATION(prob);
        hit = NULL;
        hitdev = 0;
        for (pp = pstats->extrema; pp < pstats->extrema+pstats->keepers; pp++)
        {
            /* don't allow duplicate tokens in the stats.extrema */
            if( pp->key.len > 0 && str_casecmp( pword, &pp->key ) == 0 )
            {
                hit = NULL;
                break;
            }

            slotdev = DEVIATION(pp->prob);
            if (dev>slotdev && dev>hitdev)
            {
                hit = pp;
                hitdev = slotdev;
            }
        }
        if (hit)
        {
            hit->prob = prob;
            hit->key = *pword;
        }

        veciter_next( &iter );
    }
    veciter_destroy( &iter );

    /*
     * Bayes' theorem.
     * For discussion, see <http://www.mathpages.com/home/kmath267.htm>.
     */
    product = invproduct = 1.0f;
    for (pp = pstats->extrema; pp < pstats->extrema+pstats->keepers; pp++)
    {
        if( pp->prob == 0 )
        {
            break;
        }
        else
        {
            product *= pp->prob;
            invproduct *= (1 - pp->prob);
        }
    }
    pstats->spamicity = product / (product + invproduct);
}

bool_t bvec_loadmsg( vec_t* pthis, lex_t* plex, tok_t* ptok )
{
    str_t   w;

    lex_nexttoken( plex, ptok ); 
    while( ptok->tt != eof && ptok->tt != from )
    {
        w.p = ptok->p;
        w.len = ptok->len;
        vec_addtail( pthis, &w );
        lex_nexttoken( plex, ptok );
    }

    return true;
}
