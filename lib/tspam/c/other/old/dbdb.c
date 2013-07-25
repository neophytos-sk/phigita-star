/* $Id: dbdb.c,v 1.22 2002/10/19 09:59:35 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * dbdb.c: berkeley database handler
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"

#include "dbh.h"
#include "dbdb.h"

#ifdef HAVE_LIBDB

#define DBT_init( pdbt ) memset( pdbt, 0, sizeof(DBT) )

#if !defined(DB_VERSION_MAJOR) /* v1 */
#define dbx_get(dbp,kp,vp)  dbp->get( dbp, kp, vp, 0 )
#define dbx_put(dbp,kp,vp)  dbp->put( dbp, kp, vp, 0 )
#define dbx_fd(dbp,fd)      fd = dbp->fd( dbp )
#else /* v2+ */
#define dbx_get(dbp,kp,vp)  dbp->get( dbp, NULL, kp, vp, 0 )
#define dbx_put(dbp,kp,vp)  dbp->put( dbp, NULL, kp, vp, 0 )
#define dbx_fd(dbp,fd)      dbp->fd( dbp, &fd )
#endif /* DB_VERSION_MAJOR */

#if !defined(DB_VERSION_MAJOR) /* v1 */
typedef DB DBC; /* no separate cursor type */
#define dbx_createcursor(dbp,dbcp)  ((dbcp = dbp) ? 0 : -1)
#define dbx_destroycursor(dbcp)     (dbcp = NULL)
#define dbx_first(dbcp,kp,vp)       dbcp->seq(dbcp,kp,vp,R_FIRST)
#define dbx_next(dbcp,kp,vp)        dbcp->seq(dbcp,kp,vp,R_NEXT)
#define dbx_prev(dbcp,kp,vp)        dbcp->seq(dbcp,kp,vp,R_PREV)
#define dbx_last(dbcp,kp,vp)        dbcp->seq(dbcp,kp,vp,R_LAST)
#elif DB_VERSION_MAJOR == 2
#define dbx_createcursor(dbp,dbcp)  dbp->cursor(dbp,NULL,&csrp)
#define dbx_destroycursor(dbcp)     dbcp->c_close(dbcp)
#define dbx_first(dbcp,kp,vp)       dbcp->c_get(dbcp,kp,vp,DB_FIRST)
#define dbx_next(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_NEXT)
#define dbx_prev(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_PREV)
#define dbx_last(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_LAST)
#else /* v3+ */
#define dbx_createcursor(dbp,dbcp)  dbp->cursor(dbp,NULL,&csrp,0)
#define dbx_destroycursor(dbcp)     dbcp->c_close(dbcp)
#define dbx_first(dbcp,kp,vp)       dbcp->c_get(dbcp,kp,vp,DB_FIRST)
#define dbx_next(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_NEXT)
#define dbx_prev(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_PREV)
#define dbx_last(dbcp,kp,vp)        dbcp->c_get(dbcp,kp,vp,DB_LAST)
#endif /* DB_VERSION_MAJOR */

static void char2DBT( DBT* pdbt, char* p )
{
    pdbt->data = p;
    pdbt->size = strlen(p);
}

static void uint2DBT( DBT* pdbt, uint* p )
{
    pdbt->data = p;
    pdbt->size = sizeof(uint);
}

static uint DBT2uint( DBT* pdbt )
{
    uint n;
    memcpy( &n, pdbt->data, sizeof(n) );
    return n;
}

dbh_t* dbdb_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    dbhdb_t*    pthis;

    uint        dirlen;
    cpchar      phome;
    struct stat st;

    pthis = (dbhdb_t*)malloc( sizeof(dbhdb_t) );
    if( pthis == NULL )
    {
        goto bail;
    }
    pthis->close = dbdb_db_close;
    pthis->opentable = dbdb_db_opentable;
    if( dbname != NULL && *dbname != '\0' )
    {
        dirlen = strlen( dbname );
        pthis->dir = strdup( dbname );
        if( pthis->dir[dirlen-1] == '/' )
        {
            pthis->dir[dirlen-1] = '\0';
        }
    }
    else
    {
        phome = getenv( "HOME" );
        if( phome == NULL || *phome == '\0' )
        {
            phome = ".";
        }
        pthis->dir = (char*)malloc( strlen(phome)+5+1 );
        if( pthis->dir == NULL )
        {
            goto bail;
        }
        sprintf( pthis->dir, "%s/.bmf", phome );
    }

    /* ensure config directory exists */
    if( stat( pthis->dir, &st ) != 0 )
    {
        if( errno == ENOENT )
        {
            if( mkdir( pthis->dir, S_IRUSR|S_IWUSR|S_IXUSR ) != 0 )
            {
                goto bail;
            }
        }
        else
        {
            goto bail;
        }
    }
    else
    {
        if( !S_ISDIR( st.st_mode ) )
        {
            goto bail;
        }
    }

#if !defined(DB_VERSION_MAJOR) || DB_VERSION_MAJOR < 3
    /* no initialization */
#else /* DB_VERSION_MAJOR >= 3 */
    if( db_env_create( &pthis->envp, 0 ) != 0 )
    {
        goto bail;
    }
    if( pthis->envp->open( pthis->envp, pthis->dir, DB_INIT_LOCK|DB_INIT_MPOOL|DB_CREATE, 0644 ) != 0 )
    {
        goto bail;
    }
#endif /* DB_VERSION_MAJOR */

    return (dbh_t*)pthis;

bail:
    free( pthis );
    return NULL;
}

bool_t dbdb_db_close( dbhdb_t* pthis )
{
#if !defined(DB_VERSION_MAJOR) || DB_VERSION_MAJOR < 3
    /* no cleanup */
#else /* DB_VERSION_MAJOR >= 3 */
    pthis->envp->close( pthis->envp, 0 );
#endif /* DB_VERSION_MAJOR */

    free( pthis->dir );
    pthis->dir = NULL;

    return true;
}

dbt_t* dbdb_db_opentable( dbhdb_t* pthis, cpchar table, bool_t rdonly )
{
    dbtdb_t*    ptable;
    DB*         dbp;
    DBT         key;
    DBT         val;

    char        szpath[PATH_MAX];

    ptable = (dbtdb_t*)malloc( sizeof(dbtdb_t) );
    if( ptable == NULL )
    {
        return NULL;
    }
    ptable->close = dbdb_table_close;
    ptable->mergeclose = dbdb_table_mergeclose;
    ptable->unmergeclose = dbdb_table_unmergeclose;
    ptable->import = dbdb_table_import;
    ptable->export = dbdb_table_export;
    ptable->getmsgcount = dbdb_table_getmsgcount;
    ptable->getcount = dbdb_table_getcount;
    ptable->dbp = NULL;

    sprintf( szpath, "%s/%s.db", pthis->dir, table );
#if !defined(DB_VERSION_MAJOR)
    if( (dbp = dbopen( szpath, O_CREAT|O_RDWR, 0644, DB_BTREE, NULL)) == NULL )
    {
        goto bail;
    }
#elif DB_VERSION_MAJOR == 2
    if( db_open( szpath, DB_BTREE, DB_CREATE, 0644, NULL, NULL, &dbp ) != 0 )
    {
        goto bail;
    }
#elif (DB_VERSION_MAJOR == 3) || (DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR == 0)
    ptable->envp = pthis->envp;
    if( db_create( &dbp, NULL, 0 ) != 0 )
    {
        goto bail;
    }
    if( dbp->open( dbp, szpath, NULL, DB_BTREE, DB_CREATE, 0644 ) != 0 )
    {
        goto bail;
    }
#else /* v4.1+ */
    ptable->envp = pthis->envp;
    if( db_create( &dbp, NULL, 0 ) != 0 )
    {
        goto bail;
    }
    if( dbp->open( dbp, NULL, szpath, NULL, DB_BTREE, DB_CREATE, 0644 ) != 0 )
    {
        goto bail;
    }
#endif /* DB_VERSION_MAJOR */
    ptable->dbp = dbp;

    DBT_init( &key );
    DBT_init( &val );
    ptable->nmsgs = 0;
    char2DBT( &key, MSGCOUNT_KEY );
    if( dbx_get( dbp, &key, &val ) == 0 )
    {
        ptable->nmsgs = DBT2uint( &val );
    }

    return (dbt_t*)ptable;

bail:
    free( ptable );
    return NULL;
}

static bool_t dbdb_table_lock( dbtdb_t* pthis )
{
#ifndef NOLOCK
    struct flock lock;
    int fd;

    dbx_fd( pthis->dbp, fd );
    memset( &lock, 0, sizeof(lock) );
    lock.l_type = F_WRLCK;
    lock.l_start = 0;
    lock.l_whence = SEEK_SET;
    lock.l_len = 0;
    if( fcntl( fd, F_SETLKW, &lock ) != 0 )
    {
        return false;
    }
#endif /* ndef NOLOCK */
    return true;
}

static bool_t dbdb_table_unlock( dbtdb_t* pthis )
{
#ifndef NOLOCK
    struct flock lock;
    int fd;

    dbx_fd( pthis->dbp, fd );
    memset( &lock, 0, sizeof(lock) );
    lock.l_type = F_UNLCK;
    lock.l_start = 0;
    lock.l_whence = SEEK_SET;
    lock.l_len = 0;
    if( fcntl( fd, F_SETLK, &lock ) != 0 )
    {
        return false;
    }
#endif /* ndef NOLOCK */
    return true;
}

bool_t dbdb_table_close( dbtdb_t* pthis )
{
    DB* dbp = pthis->dbp;

    if( dbp != NULL )
    {
#if !defined(DB_VERSION_MAJOR) /* v1 */
        dbp->close( dbp );
#else /* v2+ */
        dbp->close( dbp, 0 );
#endif /* DB_VERSION_MAJOR */
        pthis->dbp = NULL;
    }

    return true;
}

bool_t dbdb_table_mergeclose( dbtdb_t* pthis, vec_t* pmsg )
{
    DB*         dbp = pthis->dbp;
    DBT         key;
    DBT         val;

    char        szword[MAXWORDLEN+1];
    uint        count;
    veciter_t   msgiter;
    str_t*      pmsgstr;

    if( pthis->dbp == NULL )
    {
        return false;
    }

    if( !dbdb_table_lock( pthis ) )
    {
        return false;
    }

    pthis->nmsgs++;

    DBT_init( &key );
    DBT_init( &val );

    char2DBT( &key, MSGCOUNT_KEY );
    uint2DBT( &val, &pthis->nmsgs );
    dbx_put( dbp, &key, &val );

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    while( pmsgstr != NULL )
    {
        assert( pmsgstr->len <= MAXWORDLEN );
        strncpylwr( szword, pmsgstr->p, pmsgstr->len );
        szword[pmsgstr->len] = '\0';
        count = db_getnewcount( &msgiter );

        char2DBT( &key, szword );
        if( dbx_get( dbp, &key, &val ) == 0 )
        {
            count += DBT2uint( &val );
        }
        char2DBT( &key, szword );
        uint2DBT( &val, &count );
        if( dbx_put( dbp, &key, &val ) != 0 )
        {
            goto bail;
        }

        veciter_next( &msgiter );
        pmsgstr = veciter_get( &msgiter );
    }

    veciter_destroy( &msgiter );
    dbdb_table_unlock( pthis );
    return dbdb_table_close( pthis );

bail:
    return false;
}

bool_t dbdb_table_unmergeclose( dbtdb_t* pthis, vec_t* pmsg )
{
    DB*         dbp = pthis->dbp;
    DBT         key;
    DBT         val;

    char        szword[MAXWORDLEN+1];
    uint        count;
    veciter_t   msgiter;
    str_t*      pmsgstr;

    if( pthis->dbp == NULL )
    {
        return false;
    }

    if( pthis->nmsgs > 0 )
    {
        pthis->nmsgs--;
    }

    if( !dbdb_table_lock( pthis ) )
    {
        return false;
    }

    DBT_init( &key );
    DBT_init( &val );

    char2DBT( &key, MSGCOUNT_KEY );
    uint2DBT( &val, &pthis->nmsgs );
    dbx_put( dbp, &key, &val );

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    while( pmsgstr != NULL )
    {
        assert( pmsgstr->len <= MAXWORDLEN );
        strncpylwr( szword, pmsgstr->p, pmsgstr->len );
        szword[pmsgstr->len] = '\0';
        count = db_getnewcount( &msgiter );

        char2DBT( &key, szword );
        if( dbx_get( dbp, &key, &val ) == 0 )
        {
            uint n = DBT2uint( &val );
            n = (n > count) ? (n - count) : 0;
            char2DBT( &key, szword );
            uint2DBT( &val, &n );
            if( dbx_put( dbp, &key, &val ) != 0 )
            {
                goto bail;
            }
        }

        veciter_next( &msgiter );
        pmsgstr = veciter_get( &msgiter );
    }

    veciter_destroy( &msgiter );
    dbdb_table_unlock( pthis );
    return dbdb_table_close( pthis );

bail:
    return false;
}

bool_t dbdb_table_import( dbtdb_t* pthis, cpchar filename )
{
    DB* dbp = pthis->dbp;
    int fd;
    struct stat st;
    char* pbuf;
    char* pbegin;
    char* pend;
    rec_t r;
    DBT key;
    DBT val;
    char szword[MAXWORDLEN+1];

    if( pthis->dbp == NULL )
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

    DBT_init( &key );
    DBT_init( &val );

    if( sscanf( pbuf, BOGOFILTER_HEADER, &pthis->nmsgs ) != 1 )
    {
        goto bail;
    }
    pbegin = pbuf;
    while( *pbegin != '\n' ) pbegin++;
    pbegin++;

    char2DBT( &key, MSGCOUNT_KEY );
    uint2DBT( &val, &pthis->nmsgs );
    if( dbx_put( dbp, &key, &val ) != 0 )
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
            char2DBT( &key, szword );
            uint2DBT( &val, &r.n );
            if( dbx_put( dbp, &key, &val ) != 0 )
            {
                goto bail;
            }
        }
        pbegin = pend+1;
    }

    free( pbuf );
    close( fd );

    return true;

bail:
    return false;
}

bool_t dbdb_table_export( dbtdb_t* pthis, cpchar filename )
{
    DB*     dbp = pthis->dbp;
    int     fd;
    char    iobuf[IOBUFSIZE];
    char*   p;

    DBC*    csrp;
    int     rc;
    DBT     key;
    DBT     val;

    if( (fd = open( filename, O_CREAT|O_WRONLY|O_TRUNC, 0644 )) < 0 )
    {
        goto bail;
    }
    if( dbx_createcursor( dbp, csrp ) != 0 )
    {
        goto bail;
    }

    DBT_init( &key );
    DBT_init( &val );

    p = iobuf;
    p += sprintf( p, BOGOFILTER_HEADER, pthis->nmsgs );

    rc = dbx_first( csrp, &key, &val );
    while( rc == 0 )
    {
        assert( key.data != NULL && key.size <= MAXWORDLEN );
        assert( val.data != NULL && val.size == sizeof(uint) );
        if( key.size != MSGCOUNT_KEY_LEN ||
            memcmp( key.data, MSGCOUNT_KEY, MSGCOUNT_KEY_LEN ) != 0 )
        {
            memcpy( p, key.data, key.size ); p += key.size;
            *p++ = ' ';
            p += sprintf( p, "%u\n", DBT2uint(&val) );
            if( p+TEXTDB_MAXLINELEN > (iobuf+1) )
            {
                write( fd, iobuf, p-iobuf );
                p = iobuf;
            }
        }
        rc = dbx_next( csrp, &key, &val );
    }
    dbx_destroycursor( csrp );
    if( p != iobuf )
    {
        write( fd, iobuf, p-iobuf );
    }
    close( fd );
    return true;

bail:
    return false;
}

uint dbdb_table_getmsgcount( dbtdb_t* pthis )
{
    return pthis->nmsgs;
}

uint dbdb_table_getcount( dbtdb_t* pthis, str_t* pword )
{
    DB*         dbp = pthis->dbp;
    DBT         key;
    DBT         val;

    char szword[MAXWORDLEN+1];
    uint count = 0;

    assert( pword->len <= MAXWORDLEN );
    strncpylwr( szword, pword->p, pword->len );
    szword[pword->len] = '\0';
    count = 0;

    DBT_init( &key );
    DBT_init( &val );

    char2DBT( &key, szword );
    if( dbx_get( dbp, &key, &val ) == 0 )
    {
        count = DBT2uint( &val );
    }

    return count;
}

#else /* def HAVE_LIBDB */

dbh_t* dbdb_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    return NULL;
}

#endif /* def HAVE_LIBDB */

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
