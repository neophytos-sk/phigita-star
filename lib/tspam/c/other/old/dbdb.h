/* $Id: dbdb.h,v 1.7 2002/10/14 22:17:19 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _DBDB_H
#define _DBDB_H

#ifdef HAVE_LIBDB

#include <db.h>

typedef struct _dbtdb dbtdb_t;
struct _dbtdb
{
    bool_t      (*close)(dbtdb_t*);
    bool_t      (*mergeclose)(dbtdb_t*,vec_t*);
    bool_t      (*unmergeclose)(dbtdb_t*,vec_t*);
    bool_t      (*import)(dbtdb_t*,cpchar);
    bool_t      (*export)(dbtdb_t*,cpchar);
    uint        (*getmsgcount)(dbtdb_t*);
    uint        (*getcount)(dbtdb_t*,str_t*);

    DB*             dbp;        /* db handle */
#if defined(DB_VERSION_MAJOR) && DB_VERSION_MAJOR >= 3
    DB_ENV*         envp;       /* we don't own this */
#endif /* DB_VERSION_MAJOR */
    uint            nmsgs;      /* number of messages in table (cached) */
};

typedef struct _dbhdb dbhdb_t;
struct _dbhdb
{
    bool_t      (*close)(dbhdb_t*);
    dbt_t*      (*opentable)(dbhdb_t*,cpchar,bool_t);

    char*       dir;        /* directory for db files */
#if defined(DB_VERSION_MAJOR) && DB_VERSION_MAJOR >= 3
    DB_ENV*     envp;       /* db environment */
#endif /* DB_VERSION_MAJOR */
};

dbh_t*  dbdb_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass );
bool_t  dbdb_db_close( dbhdb_t* pthis );
dbt_t*  dbdb_db_opentable( dbhdb_t* pthis, cpchar table, bool_t rdonly );

bool_t  dbdb_table_close( dbtdb_t* pthis );
bool_t  dbdb_table_mergeclose( dbtdb_t* pthis, vec_t* pmsg );
bool_t  dbdb_table_unmergeclose( dbtdb_t* pthis, vec_t* pmsg );
bool_t  dbdb_table_import( dbtdb_t* pthis, cpchar filename );
bool_t  dbdb_table_export( dbtdb_t* pthis, cpchar filename );
uint    dbdb_table_getmsgcount( dbtdb_t* pthis );
uint    dbdb_table_getcount( dbtdb_t* pthis, str_t* pword );

#endif /* def HAVE_LIBDB */

#endif /* ndef _DBDB_H */
