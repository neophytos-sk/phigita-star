/* $Id: dbtext.c,v 1.12 2002/10/19 09:59:35 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * dbtext.c: flatfile database handler
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"

#include "dbh.h"
#include "dbtext.h"

static void dbtext_table_setsize( dbttext_t* pthis, uint nsize )
{
    if( nsize > pthis->nalloc )
    {
        uint    nnewalloc;
        rec_t*  pnewitems;
        uint    n;

        nnewalloc = pthis->nalloc * 2;
        if( nnewalloc < nsize ) nnewalloc = nsize;
        pnewitems = (rec_t*)realloc( pthis->pitems, nnewalloc*sizeof(rec_t) );
        if( pnewitems == NULL )
        {
            exit( 2 );
        }
        for( n = pthis->nitems; n < nsize; n++ )
        {
            str_create( &pnewitems[n].w );
            pnewitems[n].n = 0;
        }
        pthis->pitems = pnewitems;
        pthis->nalloc = nnewalloc;
    }
}

dbh_t* dbtext_db_open( cpchar dbhost, cpchar dbname, cpchar dbuser, cpchar dbpass )
{
    dbhtext_t*  pthis;

    uint        dirlen;
    cpchar      phome;
    struct stat st;

    pthis = (dbhtext_t*)malloc( sizeof(dbhtext_t) );
    if( pthis == NULL )
    {
        goto bail;
    }
    pthis->close = dbtext_db_close;
    pthis->opentable = dbtext_db_opentable;
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

    return (dbh_t*)pthis;

bail:
    return NULL;
}

bool_t dbtext_db_close( dbhtext_t* pthis )
{
    free( pthis->dir );
    pthis->dir = NULL;
    return true;
}

dbt_t* dbtext_db_opentable( dbhtext_t* pthis, cpchar table, bool_t rdonly )
{
    dbttext_t*      ptable = NULL;

#ifndef NOLOCK
    struct flock    lock;
#endif /* ndef NOLOCK */
    char            szpath[PATH_MAX];
    int             flags;
    struct  stat    st;

    char*   pbegin;
    char*   pend;
    rec_t   r;
    uint    pos;

    if( pthis->dir == NULL )
    {
        goto bail;
    }

    ptable = (dbttext_t*)malloc( sizeof(dbttext_t) );
    if( ptable == NULL )
    {
        perror( "malloc()" );
        goto bail;
    }
    ptable->close = dbtext_table_close;
    ptable->mergeclose = dbtext_table_mergeclose;
    ptable->unmergeclose = dbtext_table_unmergeclose;
    ptable->import = dbtext_table_import;
    ptable->export = dbtext_table_export;
    ptable->getmsgcount = dbtext_table_getmsgcount;
    ptable->getcount = dbtext_table_getcount;
    ptable->fd = -1;
    ptable->pbuf = NULL;
    ptable->nmsgs = 0;
    ptable->nalloc = 0;
    ptable->nitems = 0;
    ptable->pitems = NULL;

    sprintf( szpath, "%s/%s.txt", pthis->dir, table );
    flags = (rdonly ? O_RDONLY|O_CREAT : O_RDWR|O_CREAT);
    ptable->fd = open( szpath, flags, 0644 );
    if( ptable->fd == -1 )
    {
        perror( "open()" );
        goto bail;
    }

#ifndef NOLOCK
    memset( &lock, 0, sizeof(lock) );
    lock.l_type = rdonly ? F_RDLCK : F_WRLCK;
    lock.l_start = 0;
    lock.l_whence = SEEK_SET;
    lock.l_len = 0;
    fcntl( ptable->fd, F_SETLKW, &lock );
#endif /* ndef NOLOCK */

    if( fstat( ptable->fd, &st ) != 0 )
    {
        perror( "fstat()" );
        goto bail_uc;
    }

    if( st.st_size == 0 )
    {
        return (dbt_t*)ptable;
    }

    ptable->pbuf = (char*)malloc( st.st_size );
    if( ptable->pbuf == NULL )
    {
        perror( "malloc()" );
        goto bail_uc;
    }

    if( read( ptable->fd, ptable->pbuf, st.st_size ) != st.st_size )
    {
        perror( "read()" );
        goto bail_fuc;
    }

    /* XXX: bogofilter compatibility */
    if( sscanf( ptable->pbuf, BOGOFILTER_HEADER, &ptable->nmsgs ) != 1 )
    {
        goto bail_fuc;
    }
    pbegin = ptable->pbuf;
    while( *pbegin != '\n' ) pbegin++;
    pbegin++;

    pos = 0;
    while( pbegin < ptable->pbuf + st.st_size )
    {
        pend = pbegin;
        r.w.p = pbegin;
        r.w.len = 0;
        r.n = 0;

        while( *pend != '\n' )
        {
            if( pend >= ptable->pbuf + st.st_size )
            {
                goto bail_fuc;
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
                goto bail_fuc;
            }
            dbtext_table_setsize( ptable, pos+1 );
            ptable->pitems[pos++] = r;
            ptable->nitems = pos;
        }
        pbegin = pend+1;
    }

    if( rdonly )
    {
#ifndef NOLOCK
        lock.l_type = F_UNLCK;
        fcntl( ptable->fd, F_SETLKW, &lock );
#endif /* ndef NOLOCK */
        close( ptable->fd );
        ptable->fd = -1;
    }

    return (dbt_t*)ptable;

bail_fuc:
    free( ptable->pbuf );

bail_uc:
#ifndef NOLOCK
    lock.l_type = F_UNLCK;
    fcntl( ptable->fd, F_SETLKW, &lock );
#endif /* ndef NOLOCK */

    close( ptable->fd );
    ptable->fd = -1;

bail:
    free( ptable );
    return NULL;
}

bool_t dbtext_table_close( dbttext_t* pthis )
{
    struct flock lockall;

    free( pthis->pbuf );
    pthis->pbuf = NULL;
    free( pthis->pitems );
    pthis->pitems = NULL;

    if( pthis->fd != -1 )
    {
#ifndef NOLOCK
        memset( &lockall, 0, sizeof(lockall) );
        lockall.l_type = F_UNLCK;
        lockall.l_start = 0;
        lockall.l_whence = SEEK_SET;
        lockall.l_len = 0;
        fcntl( pthis->fd, F_SETLKW, &lockall );
#endif /* ndef NOLOCK */
        close( pthis->fd );
        pthis->fd = -1;
    }

    return true;
}

bool_t dbtext_table_mergeclose( dbttext_t* pthis, vec_t* pmsg )
{
    /* note that we require both vectors to be sorted */

    uint        pos;
    rec_t*      prec;
    veciter_t   msgiter;
    str_t*      pmsgstr;
    uint        count;
    char        iobuf[IOBUFSIZE];
    char*       p;

    if( pthis->fd == -1 )
    {
        return false;
    }
    ftruncate( pthis->fd, 0 );
    lseek( pthis->fd, 0, SEEK_SET );

    pthis->nmsgs++;

    p = iobuf;
    p += sprintf( p, BOGOFILTER_HEADER, pthis->nmsgs );

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    pos = 0;
    while( pos < pthis->nitems || pmsgstr != NULL )
    {
        int cmp = 0;
        prec = &pthis->pitems[pos];
        if( pmsgstr != NULL && pos < pthis->nitems )
        {
            cmp = str_casecmp( &prec->w, pmsgstr );
        }
        else
        {
            /* we exhausted one list or the other (but not both) */
            cmp = (pos < pthis->nitems) ? -1 : 1;
        }
        if( cmp < 0 )
        {
            /* write existing str */
            assert( prec->w.p != NULL && prec->w.len > 0 );
            assert( prec->w.len <= MAXWORDLEN );
            count = prec->n;
            strncpylwr( p, prec->w.p, prec->w.len ); p += prec->w.len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            pos++;
        }
        else if( cmp == 0 )
        {
            /* same str, merge and write sum */
            assert( prec->w.p != NULL && prec->w.len > 0 );
            assert( pmsgstr->p != NULL && pmsgstr->len > 0 );
            assert( prec->w.len <= MAXWORDLEN );
            assert( pmsgstr->len <= MAXWORDLEN );
            count = db_getnewcount( &msgiter );
            count += prec->n;
            strncpylwr( p, prec->w.p, prec->w.len ); p += prec->w.len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            pos++;
            veciter_next( &msgiter );
            pmsgstr = veciter_get( &msgiter );
        }
        else /* cmp > 0 */
        {
            /* write new str */
            assert( pmsgstr->p != NULL && pmsgstr->len > 0 );
            assert( pmsgstr->len <= MAXWORDLEN );
            count = db_getnewcount( &msgiter );
            strncpylwr( p, pmsgstr->p, pmsgstr->len ); p += pmsgstr->len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            veciter_next( &msgiter );
            pmsgstr = veciter_get( &msgiter );
        }

        if( p+TEXTDB_MAXLINELEN > (iobuf+1) )
        {
            write( pthis->fd, iobuf, p-iobuf );
            p = iobuf;
        }
    }
    if( p != iobuf )
    {
        write( pthis->fd, iobuf, p-iobuf );
    }

    veciter_destroy( &msgiter );
    return dbtext_table_close( pthis );
}

bool_t dbtext_table_unmergeclose( dbttext_t* pthis, vec_t* pmsg )
{
    /* note that we require both vectors to be sorted */

    uint        pos;
    rec_t*      prec;
    veciter_t   msgiter;
    str_t*      pmsgstr;
    uint        count;
    char        iobuf[IOBUFSIZE];
    char*       p;

    if( pthis->fd == -1 )
    {
        return false;
    }
    ftruncate( pthis->fd, 0 );
    lseek( pthis->fd, 0, SEEK_SET );

    pthis->nmsgs--;

    p = iobuf;
    p += sprintf( p, BOGOFILTER_HEADER, pthis->nmsgs );

    vec_first( pmsg, &msgiter );
    pmsgstr = veciter_get( &msgiter );

    pos = 0;
    while( pos < pthis->nitems || pmsgstr != NULL )
    {
        int cmp = 0;
        prec = &pthis->pitems[pos];
        if( pmsgstr != NULL && pos < pthis->nitems )
        {
            cmp = str_casecmp( &prec->w, pmsgstr );
        }
        else
        {
            /* we exhausted one list or the other (but not both) */
            cmp = (pos < pthis->nitems) ? -1 : 1;
        }
        if( cmp < 0 )
        {
            /* write existing str */
            assert( prec->w.p != NULL && prec->w.len > 0 );
            assert( prec->w.len <= MAXWORDLEN );
            count = prec->n;
            strncpylwr( p, prec->w.p, prec->w.len ); p += prec->w.len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            pos++;
        }
        else if( cmp == 0 )
        {
            /* same str, merge and write difference */
            assert( prec->w.p != NULL && prec->w.len > 0 );
            assert( pmsgstr->p != NULL && pmsgstr->len > 0 );
            assert( prec->w.len <= MAXWORDLEN );
            assert( pmsgstr->len <= MAXWORDLEN );
            count = db_getnewcount( &msgiter );
            count = (prec->n > count) ? (prec->n - count) : 0;
            strncpylwr( p, prec->w.p, prec->w.len ); p += prec->w.len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            pos++;
            veciter_next( &msgiter );
            pmsgstr = veciter_get( &msgiter );
        }
        else /* cmp > 0 */
        {
            /* this should not happen, so write with count=0 */
            assert( pmsgstr->p != NULL && pmsgstr->len > 0 );
            assert( pmsgstr->len <= MAXWORDLEN );
            db_getnewcount( &msgiter );
            count = 0;
            strncpylwr( p, pmsgstr->p, pmsgstr->len ); p += pmsgstr->len;
            *p++ = ' ';
            p += sprintf( p, "%u\n", count );

            veciter_next( &msgiter );
            pmsgstr = veciter_get( &msgiter );
        }

        if( p+TEXTDB_MAXLINELEN > (iobuf+1) )
        {
            write( pthis->fd, iobuf, p-iobuf );
            p = iobuf;
        }
    }
    if( p != iobuf )
    {
        write( pthis->fd, iobuf, p-iobuf );
    }

    veciter_destroy( &msgiter );
    return dbtext_table_close( pthis );
}

bool_t dbtext_table_import( dbttext_t* pthis, cpchar filename )
{
    return false;
}

bool_t dbtext_table_export( dbttext_t* pthis, cpchar filename )
{
    return false;
}

uint dbtext_table_getmsgcount( dbttext_t* pthis )
{
    return pthis->nmsgs;
}

uint dbtext_table_getcount( dbttext_t* pthis, str_t* pword )
{
    int lo, hi, mid;

    if( pthis->nitems == 0 )
    {
        return 0;
    }

    hi = pthis->nitems - 1;
    lo = -1;
    while( hi-lo > 1 )
    {
        mid = (hi+lo)/2;
        if( str_casecmp( pword, &pthis->pitems[mid].w ) <= 0 )
            hi = mid;
        else
            lo = mid;
    }
    assert( hi >= 0 && hi < pthis->nitems );

    if( str_casecmp( pword, &pthis->pitems[hi].w ) != 0 )
    {
        return 0;
    }

    return pthis->pitems[hi].n;
}

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
