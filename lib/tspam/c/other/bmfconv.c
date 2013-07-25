/* $Id: bmfconv.c,v 1.9 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * bmfconv.c: bmf database converter
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "vec.h"
#include "dbh.h"

typedef enum
{
    none,
    db2text,
    text2db
} dir_t;

static void usage( void )
{
    printf( "\n"
            "Usage: " PACKAGE " [options]\n"
            "\t-f fmt\tSpecify database format (db|mysql).\n"
            "\t-d db\tSpecify database or directory name.\n"
            "\t-e\tExport  to  text files goodlist.txt and spamlist.txt.\n"
            "\t-i\tImport from text files goodlist.txt and spamlist.txt.\n"
            "\t-v\tShow version information and exit\n"
            "\t-h\tShow this message and exit\n"
            "\n" );
    exit( 2 );
}

static void version( void )
{
    printf( "\n"
            PACKAGE " version " VERSION " - a Bayesian mail filter\n"
            "Copyright (c) 2002 Tom Marshall\n"
            "\n"
            PACKAGE " comes with ABSOLUTELY NO WARRANTY.\n"
            "This is free software.  You are welcome to redistribute it under the terms\n"
            "of the GNU General Public License.  See the file LICENSE in the source\n"
            "distribution, or visit http://www.gnu.org/licenses/gpl.html\n"
            "\n" );
    exit( 2 );
}

int main( int argc, char** argv )
{
    int         ch;
    dbfmt_t     dbfmt = db_db;
    char*       dbname = NULL;
    bool_t      rdonly;

    dbh_t*      pdb;
    dbt_t*      ptable;
    dir_t       dir = none;

    while( (ch = getopt( argc, argv, "d:ef:ihv" )) != EOF )
    {
        switch( ch )
        {
        case 'd':
            free( dbname );
            dbname = strdup( optarg );
            break;
        case 'e':
            dir = db2text;
            break;
        case 'f':
            if( strcasecmp( optarg, "db" ) == 0 )
            {
                dbfmt = db_db;
            }
            else if( strcasecmp( optarg, "mysql" ) == 0 )
            {
                dbfmt = db_mysql;
            }
            else
            {
                usage();
            }
            break;
        case 'h':
            usage();
            break;  /* notreached */
        case 'i':
            dir = text2db;
            break;
        case 'v':
            version();
            break;  /* notreached */
        default:
            usage();
        }
    }
    if( dir == none )
    {
        usage();
    }

    pdb = dbh_open( dbfmt, "localhost", dbname, DB_USER, DB_PASS );
    if( pdb == NULL )
    {
        fprintf( stderr, "cannot open database\n" );
        exit( 1 );
    }
    rdonly = (dir == db2text ? true : false);

    ptable = pdb->opentable( pdb, "spamlist", rdonly );
    if( ptable == NULL )
    {
        fprintf( stderr, "cannot open spamlist\n" );
        exit( 1 );
    }
    if( dir == db2text )
    {
        if( !ptable->export( ptable, "spamlist.txt" ) )
        {
            fprintf( stderr, "cannot export spamlist\n" );
            exit( 1 );
        }
    }
    else
    {
        if( !ptable->import( ptable, "spamlist.txt" ) )
        {
            fprintf( stderr, "cannot import spamlist\n" );
            exit( 1 );
        }
    }
    ptable->close( ptable );
    free( ptable );

    ptable = pdb->opentable( pdb, "goodlist", rdonly );
    if( ptable == NULL )
    {
        fprintf( stderr, "cannot open goodlist\n" );
        exit( 1 );
    }
    if( dir == db2text )
    {
        if( !ptable->export( ptable, "goodlist.txt" ) )
        {
            fprintf( stderr, "cannot export goodlist\n" );
            exit( 1 );
        }
    }
    else
    {
        if( !ptable->import( ptable, "goodlist.txt" ) )
        {
            fprintf( stderr, "cannot import goodlist\n" );
            exit( 1 );
        }
    }
    ptable->close( ptable );
    free( ptable );

    pdb->close( pdb );
    free( pdb );

    return 0;
}
