/* $Id: dbh.c,v 1.2 2002/10/14 07:09:51 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * dbh.c: database handler interface
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"

#include "dbh.h"
#include "dbtext.h"
// #include "dbdb.h"
// #include "dbmysql.h"

/*
 * get count for new (incoming) word.  there may be duplicate entries for the
 * str, so sum the counts and leave the iterator at the last one.
 *
 * the list referenced in the iterator must be sorted.
 */
uint db_getnewcount( veciter_t* piter )
{
    str_t*      pstr;
    uint        count;
    veciter_t   curiter;
    str_t*      pcurstr;

    pstr = &piter->plist->pitems[piter->index];
    count = 0;

    curiter.plist = piter->plist;
    curiter.index = piter->index;
    pcurstr = &curiter.plist->pitems[curiter.index];

    while( curiter.index < curiter.plist->nitems && str_casecmp( pstr, pcurstr ) == 0 )
    {
        piter->index = curiter.index;
        count = min( MAXFREQ, count + 1 );
        veciter_next( &curiter );
        pcurstr = &curiter.plist->pitems[curiter.index];
    }

    return count;
}

dbh_t* dbh_open( dbfmt_t dbfmt, cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    dbh_t* pdb = NULL;

    switch( dbfmt )
    {
    case db_text:
        pdb = (dbh_t*)dbtext_db_open( dbhost, dbname, dbuser, dbpass );
        break;
	/*
    case db_db:
        pdb = (dbh_t*)dbdb_db_open( dbhost, dbname, dbuser, dbpass );
        break;
    case db_mysql:
        pdb = (dbh_t*) dbmysql_db_open( dbhost, dbname, dbuser, dbpass );
        break;
	*/
    default:
        assert(false);
    }

    return pdb;
}
