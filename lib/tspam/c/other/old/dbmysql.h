/* $Id: dbmysql.h,v 1.4 2002/10/06 06:46:53 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _DBMYSQL_H
#define _DBMYSQL_H

#ifdef HAVE_MYSQL

#include "mysql.h"

typedef struct _dbtmysql dbtmysql_t;
struct _dbtmysql
{
    bool_t      (*close)(dbtmysql_t*);
    bool_t      (*mergeclose)(dbtmysql_t*,vec_t*);
    bool_t      (*unmergeclose)(dbtmysql_t*,vec_t*);
    bool_t      (*import)(dbtmysql_t*,cpchar);
    bool_t      (*export)(dbtmysql_t*,cpchar);
    uint        (*getmsgcount)(dbtmysql_t*);
    uint        (*getcount)(dbtmysql_t*,str_t*);

    struct _dbhmysql*   pdb;
    char*               table;      /* table name */
    uint                nmsgs;      /* number of messages in table (cached) */
};

typedef struct _dbhmysql dbhmysql_t;
struct _dbhmysql
{
    bool_t      (*close)(dbhmysql_t*);
    dbt_t*      (*opentable)(dbhmysql_t*,cpchar,bool_t);

    MYSQL*      dbh;        /* database handle, if currently open */
};

dbh_t*  dbmysql_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass );
bool_t  dbmysql_db_close( dbhmysql_t* pthis );
dbt_t*  dbmysql_db_opentable( dbhmysql_t* pthis, cpchar table, bool_t rdonly );

bool_t  dbmysql_table_close( dbtmysql_t* pthis );
bool_t  dbmysql_table_mergeclose( dbtmysql_t* pthis, vec_t* pmsg );
bool_t  dbmysql_table_unmergeclose( dbtmysql_t* pthis, vec_t* pmsg );
bool_t  dbmysql_table_import( dbtmysql_t* pthis, cpchar filename );
bool_t  dbmysql_table_export( dbtmysql_t* pthis, cpchar filename );
uint    dbmysql_table_getmsgcount( dbtmysql_t* pthis );
uint    dbmysql_table_getcount( dbtmysql_t* pthis, str_t* pword );

#else /* def HAVE_MYSQL */

dbh_t*  dbmysql_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass );

#endif /* def HAVE_MYSQL */

#endif /* ndef _DBMYSQL_H */
