/* $Id: dbmysql.c,v 1.9 2002/10/14 07:09:51 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * dbmysql.c: mysql database handler
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"

#include "dbh.h"
#include "dbmysql.h"

#ifdef HAVE_MYSQL

#define MAXQUERY 256

static MYSQL* g_mysql = NULL;

static void sql_escape( char* d, const char* s )
{
    while( *s != '\0' )
    {
        if( *s == '\'' )
        {
            *d++ = '\'';
        }
        *d++ = tolower(*s++);
    }
}

dbh_t* dbmysql_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    dbhmysql_t*     pthis;

    if( g_mysql == NULL )
    {
        g_mysql = mysql_init( NULL );
        if( g_mysql == NULL )
        {
            return NULL;
        }
    }

    pthis = (dbhmysql_t*)malloc( sizeof(dbhmysql_t) );
    if( pthis == NULL )
    {
        perror( "malloc()" );
        goto bail;
    }
    pthis->close = dbmysql_db_close;
    pthis->opentable = dbmysql_db_opentable;

    pthis->dbh = mysql_real_connect( g_mysql, dbhost, dbuser, dbpass, dbname, 0, NULL, 0 );
    if( pthis->dbh == NULL )
    {
        goto bail;
    }


    return (dbh_t*)pthis;

bail:
    fprintf( stderr, "cannot open mysql database '%s': %s\n", dbname, mysql_error(g_mysql) );
    free( pthis );
    return NULL;
}

bool_t dbmysql_db_close( dbhmysql_t* pthis )
{
    if( pthis->dbh != NULL )
    {
        mysql_close( pthis->dbh );
        pthis->dbh = NULL;
    }
    return true;
}

dbt_t* dbmysql_db_opentable( dbhmysql_t* pthis, cpchar table, bool_t rdonly )
{
    dbtmysql_t* ptable;

    char        query[MAXQUERY];
    MYSQL_RES*  res;
    MYSQL_ROW   row;

    ptable = (dbtmysql_t*)malloc( sizeof(dbtmysql_t) );
    if( ptable == NULL )
    {
        return NULL;
    }
    ptable->close = dbmysql_table_close;
    ptable->mergeclose = dbmysql_table_mergeclose;
    ptable->unmergeclose = dbmysql_table_unmergeclose;
    ptable->import = dbmysql_table_import;
    ptable->export = dbmysql_table_export;
    ptable->getmsgcount = dbmysql_table_getmsgcount;
    ptable->getcount = dbmysql_table_getcount;
    ptable->pdb = pthis;
    ptable->table = strdup( table );
    ptable->nmsgs = 0;

    sprintf( query, "SELECT count FROM %s WHERE name='%s'",
             table, MSGCOUNT_KEY );
    if( mysql_query( pthis->dbh, query ) != 0 )
    {
        goto bail;
    }
    if( (res = mysql_store_result( pthis->dbh )) == NULL )
    {
        goto bail;
    }
    while( (row = mysql_fetch_row( res )) )
    {
        ptable->nmsgs = atoi( row[0] );
    }

    return (dbt_t*)ptable;

bail:
    free( ptable->table );
    free( ptable );
    return NULL;
}

bool_t dbmysql_table_close( dbtmysql_t* pthis )
{
    if( pthis->pdb != NULL )
    {
        free( pthis->table );
        pthis->table = NULL;
        pthis->pdb = NULL;
    }
    return true;
}

bool_t dbmysql_table_mergeclose( dbtmysql_t* pthis, vec_t* pmsg )
{
    char        szword[MAXWORDLEN+1];
    char        szsqlword[MAXWORDLEN*2+1];
    veciter_t   msgiter;
    str_t*      pmsgstr;

    char        query[MAXQUERY];
    uint        count;

    if( pthis->pdb == NULL || pthis->pdb->dbh == NULL )
    {
        assert( false );
        return false;
    }

    pthis->nmsgs++;

    sprintf( query, "UPDATE %s SET count=%u WHERE name='%s'",
             pthis->table, pthis->nmsgs, MSGCOUNT_KEY );
    if( mysql_query( pthis->pdb->dbh, query ) != 0 )
    {
        goto bail;
    }
    if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
    {
        sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', %u )",
                 pthis->table, MSGCOUNT_KEY, pthis->nmsgs );
        mysql_query( pthis->pdb->dbh, query );
    }

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    while( pmsgstr != NULL )
    {
        assert( pmsgstr->len <= MAXWORDLEN );
        strncpylwr( szword, pmsgstr->p, pmsgstr->len );
        szword[pmsgstr->len] = '\0';
        sql_escape( szsqlword, szword );
        count = db_getnewcount( &msgiter );

        sprintf( query, "UPDATE %s SET count=count+%u WHERE name='%s'",
                 pthis->table, count, szsqlword );
        if( mysql_query( pthis->pdb->dbh, query ) != 0 )
        {
            goto bail;
        }
        if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
        {
            sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', %u )",
                     pthis->table, szsqlword, count );
            if( mysql_query( pthis->pdb->dbh, query ) != 0 )
            {
                goto bail;
            }
            if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
            {
                goto bail;
            }
        }

        veciter_next( &msgiter );
        pmsgstr = veciter_get( &msgiter );
    }

    veciter_destroy( &msgiter );
    return dbmysql_table_close( pthis );

bail:
    return false;
}

bool_t dbmysql_table_unmergeclose( dbtmysql_t* pthis, vec_t* pmsg )
{
    char        szword[MAXWORDLEN+1];
    char        szsqlword[MAXWORDLEN*2+1];
    veciter_t   msgiter;
    str_t*      pmsgstr;

    char        query[MAXQUERY];
    uint        count;

    if( pthis->pdb == NULL || pthis->pdb->dbh == NULL )
    {
        assert( false );
        return false;
    }

    if( pthis->nmsgs > 0 )
    {
        pthis->nmsgs--;
    }

    sprintf( query, "UPDATE %s SET count=%u WHERE name='%s'",
             pthis->table, pthis->nmsgs, MSGCOUNT_KEY );
    if( mysql_query( pthis->pdb->dbh, query ) != 0 )
    {
        goto bail;
    }
    if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
    {
        sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', %u )",
                 pthis->table, MSGCOUNT_KEY, pthis->nmsgs );
        mysql_query( pthis->pdb->dbh, query );
    }

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    while( pmsgstr != NULL )
    {
        assert( pmsgstr->len <= MAXWORDLEN );
        strncpylwr( szword, pmsgstr->p, pmsgstr->len );
        szword[pmsgstr->len] = '\0';
        sql_escape( szsqlword, szword );
        count = db_getnewcount( &msgiter );

        sprintf( query, "UPDATE %s SET count=GREATEST(0,count-%u) WHERE name='%s'",
                 pthis->table, count, szsqlword );
        if( mysql_query( pthis->pdb->dbh, query ) != 0 )
        {
            goto bail;
        }
        if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
        {
            /* this should not happen, so write with count=0 */
            sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', 0 )",
                     pthis->table, szsqlword );
            if( mysql_query( pthis->pdb->dbh, query ) != 0 )
            {
                goto bail;
            }
            if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
            {
                goto bail;
            }
        }

        veciter_next( &msgiter );
        pmsgstr = veciter_get( &msgiter );
    }

    veciter_destroy( &msgiter );
    return dbmysql_table_close( pthis );

bail:
    return false;
}

bool_t dbmysql_table_import( dbtmysql_t* pthis, cpchar filename )
{
    int fd;
    struct stat st;
    char* pbuf;
    char* pbegin;
    char* pend;
    rec_t r;
    char szword[MAXWORDLEN+1];
    char szsqlword[MAXWORDLEN*2+1];
    char query[MAXQUERY];

    if( pthis->pdb == NULL || pthis->pdb->dbh == NULL )
    {
        return false;
    }
    if( (fd = open( filename, O_RDONLY, 0644 )) < 0 )
    {
        return false;
    }
    if( fstat( fd, &st ) != 0 )
    {
        goto bail;
    }
    if( st.st_size == 0 )
    {
        goto bail;
    }
    pbuf = (char*)malloc( st.st_size );
    if( pbuf == NULL )
    {
        goto bail;
    }
    if( read( fd, pbuf, st.st_size ) != st.st_size )
    {
        goto bail;
    }

    if( sscanf( pbuf, BOGOFILTER_HEADER, &pthis->nmsgs ) != 1 )
    {
        goto bail;
    }
    pbegin = pbuf;
    while( *pbegin != '\n' ) pbegin++;
    pbegin++;

    sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', %u )",
             pthis->table, MSGCOUNT_KEY, pthis->nmsgs );
    mysql_query( pthis->pdb->dbh, query );
    if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
    {
        goto bail;
    }

    while( pbegin < pbuf + st.st_size )
    {
        pend = pbegin;
        r.w.p = pbegin;
        r.w.len = 0;
        r.n = 0;

        while( *pend != '\n' )
        {
            if( pend >= pbuf + st.st_size )
            {
                goto bail;
            }
            *pend = tolower(*pend);
            if( *pend == ' ' )
            {
                r.w.len = (pend-pbegin);
                r.n = strtol( pend+1, NULL, 10 );
            }
            pend++;
        }
        if( pend > pbegin && *pbegin != '#' && *pbegin != ';' )
        {
            if( r.w.len == 0 || r.w.len > MAXWORDLEN )
            {
                fprintf( stderr, "dbh_loadfile: bad file format\n" );
                goto bail;
            }
            strncpylwr( szword, r.w.p, r.w.len );
            szword[r.w.len] = '\0';
            sql_escape( szsqlword, szword );

            sprintf( query, "INSERT INTO %s ( name, count ) VALUES ( '%s', %u )",
                     pthis->table, szsqlword, r.n );
            if( mysql_query( pthis->pdb->dbh, query ) != 0 )
            {
                goto bail;
            }
            if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
            {
                goto bail;
            }
        }
        pbegin = pend+1;
    }

    return true;

bail:
    return false;
}

bool_t dbmysql_table_export( dbtmysql_t* pthis, cpchar filename )
{
    int     fd;
    char    iobuf[IOBUFSIZE];
    char*   p;

    char    query[MAXQUERY];
    MYSQL_RES* res;
    MYSQL_ROW  row;

    if( (fd = open( filename, O_CREAT|O_WRONLY|O_TRUNC, 0644 )) < 0 )
    {
        return false;
    }

    p += sprintf( p, BOGOFILTER_HEADER, pthis->nmsgs );

    sprintf( query, "SELECT name, count FROM %s",
             pthis->table );
    if( mysql_query( pthis->pdb->dbh, query ) != 0 )
    {
        goto bail;
    }
    if( mysql_affected_rows( pthis->pdb->dbh ) == 0 )
    {
        goto bail;
    }

    while( (row = mysql_fetch_row( res )) )
    {
        if( strcmp( row[0], MSGCOUNT_KEY ) == 0 )
        {
            continue;
        }

        p += sprintf( p, "%s %s\n", row[0], row[1] );
        if( p+TEXTDB_MAXLINELEN > (iobuf+1) )
        {
            write( fd, iobuf, p-iobuf );
            p = iobuf;
        }
    }
    if( p != iobuf )
    {
        write( fd, iobuf, p-iobuf );
    }
    close( fd );

    return true;

bail:
    return false;
}

uint dbmysql_table_getmsgcount( dbtmysql_t* pthis )
{
    return pthis->nmsgs;
}

uint dbmysql_table_getcount( dbtmysql_t* pthis, str_t* pword )
{
    uint count = 0;
    char szword[MAXWORDLEN+1];
    char szsqlword[MAXWORDLEN*2+1];

    char        query[MAXQUERY];
    MYSQL_RES*  res;
    MYSQL_ROW   row;

    assert( pword->len <= MAXWORDLEN );
    strncpylwr( szword, pword->p, pword->len );
    szword[pword->len] = '\0';
    sql_escape( szsqlword, szword );
    sprintf( query, "SELECT count FROM %s WHERE name='%s'",
             pthis->table, szsqlword );
    if( mysql_query( pthis->pdb->dbh, query ) != 0 )
    {
        goto bail;
    }
    if( (res = mysql_store_result( pthis->pdb->dbh )) == NULL )
    {
        goto bail;
    }
    while( (row = mysql_fetch_row( res )) )
    {
        count = atoi( row[0] );
    }

bail:
    return count;
}

#else /* def HAVE_MYSQL */

dbh_t* dbmysql_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    return NULL;
}

#endif /* def HAVE_MYSQL */

#ifdef UNIT_TEST
int main( int argc, char** argv )
{
    dbh_t*      pdb;
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
        pdb = dbh_open( "testlist", true );

        vec_first( &db, &iter );
        while( (pstr = veciter_get( &iter )) != NULL )
        {
            char  buf[MAXWORDLEN+32];
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

        dbh_close( &db );
    }

    return 0;
}
#endif /* def UNIT_TEST */
