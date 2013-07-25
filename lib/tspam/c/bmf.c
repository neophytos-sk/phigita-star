/* $Id: bmf.c,v 1.20 2002/10/20 18:19:17 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * bmf.c: top level Bayesian mail filter app.
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"
#include "vec.h"
#include "dbh.h"
#include "filt.h"

/* modes of operation (mutually exclusive) */
typedef enum
{
    mode_test,      /* test and produce report */
    mode_normal,    /* test and register result */
    mode_reg_s,     /* register as spam */
    mode_reg_n,     /* register as non-spam */
    mode_n_to_s,    /* undo non-spam registration and register as spam */
    mode_s_to_n     /* undo spam registration and register as non-spam */
} runmode_t;

static void usage( void )
{
    printf( "\n"
            "Usage: " PACKAGE " [mode] [options]\n"
            "\n"
            "Modes of operation (mutually exclusive; the last one specified is used):\n"
            "\t\tRegister message using historical data if no mode is specified.\n"
            "\t-n\tRegister message as non-spam.\n"
            "\t-s\tRegister message as spam.\n"
            "\t-N\tRegister message as non-spam and undo prior registration as spam.\n"
            "\t-S\tRegister message as spam and undo prior registration as non-spam.\n"
            "\t-t\tTest mode, print report and do not save results.\n"
            "\n"
            "Other options:\n"
            "\t-f fmt\tSpecify database format (text|db|mysql).\n"
            "\t-d db\tSpecify database or directory name.\n"
            "\t-i file\tSpecify file to read instead of stdin.\n"
            "\t-k n\tSpecify count of extrema to use (keepers), default is 15.\n"
            "\t-m type\t[DEPRECATED] Specify mail storage format (mbox|maildir)\n"
            "\t-p\tPassthrough mode, like SpamAssassin.\n"
            "\t-v\tIncrease verbosity level.\n"
            "\t-V\tShow version information and exit.\n"
            "\t-h\tShow this message and exit.\n"
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

    runmode_t   mode = mode_normal;
    mbox_t      mboxtype = detect;
    bool_t      do_passthru = false;

    dbh_t*      pdb;
    dbt_t*      pblist;
    dbt_t*      pglist;
    dbt_t*      ptable;
    vec_t       mlist;
    stats_t     stats;
    lex_t       lex;
    tok_t       tok;
    bool_t      is_spam;

    int fd = STDIN_FILENO;
    char* infile = NULL;

    srand(time(NULL));
    atexit( dump_alloc_heap );

#ifdef HAVE_LIBDB
    dbfmt = db_db;
#else
    dbfmt = db_text;
#endif

    stats.keepers = DEF_KEEPERS;
    while( (ch = getopt( argc, argv, "NSVd:f:i:hk:m:npstv" )) != EOF )
    {
        switch( ch )
        {
        case 'N':
            mode = mode_s_to_n;
            break;
        case 'S':
            mode = mode_n_to_s;
            break;
        case 'V':
            version();
            break;  /* notreached */
        case 'd':
            free( dbname );
            dbname = strdup( optarg );
            break;
        case 'f':
            if( strcasecmp( optarg, "text" ) == 0 )
            {
                dbfmt = db_text;
            }
            else if( strcasecmp( optarg, "db" ) == 0 )
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
            free( infile );
            infile = strdup( optarg );
            break;
        case 'k':
            stats.keepers = atoi( optarg );
            break;
        case 'm':
            if( strcasecmp( optarg, "mbox" ) == 0 )
            {
                mboxtype = mbox;
            }
            else if( strcasecmp( optarg, "maildir" ) == 0 )
            {
                mboxtype = maildir;
            }
            else
            {
                usage();
            }
            break;
        case 'n':
            mode = mode_reg_n;
            break;
        case 'p':
            do_passthru = true;
            break;
        case 's':
            mode = mode_reg_s;
            break;
        case 't':
            mode = mode_test;
            break;
        case 'v':
            g_verbose++;
            verbose( 1, "Verbose level now %u\n", g_verbose );
            break;
        default:
            usage();
        }
    }
    stats.extrema = (discrim_t*)malloc( stats.keepers*sizeof(discrim_t) );

    if( infile != NULL )
    {
        fd = open( infile, O_RDONLY );
        if( fd == -1 )
        {
            fprintf( stderr, "%s: cannot open input file '%s': %s\n",
                     argv[0], infile, strerror(errno) );
            exit( 2 );
        }
    }

    pdb = dbh_open( dbfmt, "localhost", dbname, DB_USER, DB_PASS );
    if( pdb == NULL )
    {
        fprintf( stderr, "%s: cannot open database\n", argv[0] );
        exit( 2 );
    }

    lex_create( &lex, mboxtype );
    if( !lex_load( &lex, fd ) )
    {
        fprintf( stderr, "%s: cannot read input\n", argv[0] );
        exit( 2 );
    }
    lex_nexttoken( &lex, &tok );
    if( tok.tt == eof )
    {
        fprintf( stderr, "%s: no input available\n", argv[0] );
        exit( 2 );
    }

    while( tok.tt != eof )
    {
        if( mboxtype == mbox && tok.tt != from )
        {
            fprintf( stderr, "%s: input does not look like an mbox message\n", argv[0] );
            exit( 2 );
        }

        rdonly = (mode == mode_test || mode == mode_reg_n);
        pblist = pdb->opentable( pdb, "spamlist", rdonly );
        if( pblist == NULL )
        {
            fprintf( stderr, "%s: cannot open spamlist\n", argv[0] );
            exit( 2 );
        }

        rdonly = (mode == mode_test || mode == mode_reg_s);
        pglist = pdb->opentable( pdb, "goodlist", rdonly );
        if( pglist == NULL )
        {
            fprintf( stderr, "%s: cannot open goodlist\n", argv[0] );
            exit( 2 );
        }

        vec_create( &mlist );
        bvec_loadmsg( &mlist, &lex, &tok );

        switch( mode )
        {
        case mode_test:
            bayesfilt( pglist, pblist, &mlist, &stats );
            is_spam = (stats.spamicity > SPAM_CUTOFF);
            break;
        case mode_normal:
            bayesfilt( pglist, pblist, &mlist, &stats );
            is_spam = (stats.spamicity > SPAM_CUTOFF);
            ptable = (is_spam ? pblist : pglist);
            svec_sort( &mlist );
            if( !ptable->mergeclose( ptable, &mlist ) )
            {
                fprintf( stderr, "%s: cannot merge/save list\n", argv[0] );
                exit( 2 );
            }
            break;
        case mode_reg_s:
            stats.spamicity = 1.0;
            is_spam = true;
            svec_sort( &mlist );
            if( !pblist->mergeclose( pblist, &mlist ) )
            {
                fprintf( stderr, "%s: cannot merge/save list\n", argv[0] );
                exit( 2 );
            }
            break;
        case mode_reg_n:
            stats.spamicity = 0.0;
            is_spam = false;
            svec_sort( &mlist );
            if( !pglist->mergeclose( pglist, &mlist ) )
            {
                fprintf( stderr, "%s: cannot merge/save list\n", argv[0] );
                exit( 2 );
            }
            break;
        case mode_n_to_s:
            stats.spamicity = 1.0;
            is_spam = true;
            svec_sort( &mlist );
            if( !pblist->mergeclose( pblist, &mlist ) ||
                !pglist->unmergeclose( pglist, &mlist ) )
            {
                fprintf( stderr, "%s: cannot merge/save list\n", argv[0] );
                exit( 2 );
            }
            break;
        case mode_s_to_n:
            stats.spamicity = 0.0;
            is_spam = false;
            svec_sort( &mlist );
            if( !pblist->unmergeclose( pblist, &mlist ) ||
                !pglist->mergeclose( pglist, &mlist ) )
            {
                fprintf( stderr, "%s: cannot merge/save list\n", argv[0] );
                exit( 2 );
            }
            break;
        default:
            usage();
        }

        if( mode == mode_test )
        {
            statdump( &stats, STDOUT_FILENO );
        }

        if( do_passthru )
        {
            lex_passthru( &lex, is_spam, stats.spamicity );
        }

        vec_destroy( &mlist );

        pglist->close( pglist );
        free( pglist );
        pblist->close( pblist );
        free( pblist );
    }

    lex_destroy( &lex );

    pdb->close( pdb );
    free( pdb );

    if( infile != NULL )
    {
        free( infile );
        close( fd );
    }
    free( stats.extrema );

    return ( (do_passthru || is_spam) ? 0 : 1 );
}
