/* $Id: dbtext.h,v 1.3 2002/10/02 04:45:40 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _DBTEXT_H
#define _DBTEXT_H

typedef struct _dbttext dbttext_t;
struct _dbttext
{
    bool_t      (*close)(dbttext_t*);
    bool_t      (*mergeclose)(dbttext_t*,vec_t*);
    bool_t      (*unmergeclose)(dbttext_t*,vec_t*);
    bool_t      (*import)(dbttext_t*,cpchar);
    bool_t      (*export)(dbttext_t*,cpchar);
    uint        (*getmsgcount)(dbttext_t*);
    uint        (*getcount)(dbttext_t*,str_t*);

    int         fd;         /* file descriptor, if currently open */
    char*       pbuf;       /* data buffer, if currently open */
    uint        nmsgs;      /* number of messages represented in list */
    uint        nalloc;     /* items alloced in pitems */
    uint        nitems;     /* items available */
    rec_t*      pitems;     /* growing vector of items */
};

typedef struct _dbhtext dbhtext_t;
struct _dbhtext
{
    bool_t      (*close)(dbhtext_t*);
    dbt_t*      (*opentable)(dbhtext_t*,cpchar,bool_t);

    char*       dir;
};

dbh_t*  dbtext_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass );
bool_t  dbtext_db_close( dbhtext_t* pthis );
dbt_t*  dbtext_db_opentable( dbhtext_t* pthis, cpchar table, bool_t rdonly );

bool_t  dbtext_table_close( dbttext_t* pthis );
bool_t  dbtext_table_mergeclose( dbttext_t* pthis, vec_t* pmsg );
bool_t  dbtext_table_unmergeclose( dbttext_t* pthis, vec_t* pmsg );
bool_t  dbtext_table_import( dbttext_t* pthis, cpchar filename );
bool_t  dbtext_table_export( dbttext_t* pthis, cpchar filename );
uint    dbtext_table_getmsgcount( dbttext_t* pthis );
uint    dbtext_table_getcount( dbttext_t* pthis, str_t* pword );

#endif /* ndef _DBTEXT_H */
