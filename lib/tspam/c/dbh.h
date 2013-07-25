/* $Id: dbh.h,v 1.3 2002/10/02 04:45:40 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _DBH_H
#define _DBH_H

/* database formats */
typedef enum
{
    db_text,        /* flat text */
    db_db,          /* libdb */
    db_mysql        /* mysql */
} dbfmt_t;

/* record/field structure */
typedef struct _rec
{
    str_t   w;
    uint    n;
} rec_t;

/* database table */
typedef struct _dbt dbt_t;
struct _dbt
{
    bool_t      (*close)(dbt_t*);
    bool_t      (*mergeclose)(dbt_t*,vec_t*);
    bool_t      (*unmergeclose)(dbt_t*,vec_t*);
    bool_t      (*import)(dbt_t*,cpchar);
    bool_t      (*export)(dbt_t*,cpchar);
    uint        (*getmsgcount)(dbt_t*);
    uint        (*getcount)(dbt_t*,str_t*);
};

/* database instance */
typedef struct _dbh dbh_t;
struct _dbh
{
    bool_t      (*close)(dbh_t*);
    dbt_t*      (*opentable)(dbh_t*,cpchar,bool_t);
};

dbh_t*  dbh_open( dbfmt_t dbfmt, cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass );

#define BOGOFILTER_HEADER "# bogofilter wordlist (format version A): %u\n"
#define TEXTDB_MAXLINELEN    (MAXWORDLEN+32)

uint db_getnewcount( veciter_t* piter );

#endif /* ndef _DBH_H */
