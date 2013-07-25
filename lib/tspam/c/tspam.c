#include "config.h"
#include "str.h"
#include "lex.h"
#include "vec.h"
#include "dbh.h"
#include "filt.h"

dbt_t* pblist = NULL;
dbt_t* pglist = NULL;

int tspam_init() {
  dbfmt_t     dbfmt = db_text;
  //char*       dbname = NULL;
  char       dbname[] = "/web/servers/service-phgt-0/lib/tspam/dict";
  bool_t      rdonly;

  dbh_t*      pdb;

  pdb = dbh_open( dbfmt, "localhost", dbname, DB_USER, DB_PASS );
  if( pdb == NULL ){
    fprintf( stderr, "pdb: cannot open database\n");
    //exit( 2 );
    return 0;
  }
  rdonly = 1; // mode test

  pblist = pdb->opentable( pdb, "spamlist", rdonly );
  if( pblist == NULL ) {
    fprintf( stderr, "cannot open spamlist\n" );
    // exit( 2 );
    return 0;
  }

  pglist = pdb->opentable( pdb, "goodlist", rdonly );
  if( pglist == NULL ) {
    fprintf( stderr, "open goodlist\n");
    // exit( 2 );
    return 0;
  }
  pdb->close( pdb );
  free( pdb );

  fprintf( stderr, "tspam_init: all is good\n");

  return 1;
}

int tspam_classify(const char *infile) {

  int         ch;

  mbox_t      mboxtype = detect;
  bool_t      do_passthru = false;

  vec_t       mlist;
  stats_t     stats;
  lex_t       lex;
  tok_t       tok;
  bool_t      is_spam;

  // static dbt_t*      pblist=NULL;
  // static dbt_t*      pglist=NULL;

  // make sure goodlist and badlist are loaded
  if (!pblist || !pglist) {
    tspam_init();
  }
  
  stats.keepers = DEF_KEEPERS;
  stats.extrema = (discrim_t*)malloc( stats.keepers*sizeof(discrim_t) );

  // int fd = STDIN_FILENO;
  int fd = open( infile, O_RDONLY );
  if( fd == -1 ) {
    // fprintf( stderr, "%s: cannot open input file '%s': %s\n",
    //         argv[0], infile, strerror(errno) );
    // exit( 2 );
  }

  lex_create( &lex, mboxtype );
  if( !lex_load( &lex, fd ) ) {
    fprintf( stderr, "lex_load: cannot read input\n");
    // exit( 2 );
    return 0;
  }

  lex_nexttoken( &lex, &tok );
  if( tok.tt == eof ) {
    fprintf( stderr, "tok.tt==eod: no input available\n");
    // exit( 2 );
    return 0;
  }
  while( tok.tt != eof ) {
    if( mboxtype == mbox && tok.tt != from ) {
      fprintf( stderr, "mboxtype==mbox && tok.tt != from: input does not look like an mbox message\n");
      // exit( 2 );
      return 0;
    }

    vec_create( &mlist );
    bvec_loadmsg( &mlist, &lex, &tok );

    bayesfilt( pglist, pblist, &mlist, &stats );
    is_spam = (stats.spamicity > SPAM_CUTOFF);

    vec_destroy( &mlist );

  }
	
  lex_destroy( &lex );
  	
  if( infile != NULL ) {
    // free( infile );
    close( fd );
  }
  free( stats.extrema );

  return is_spam;
}


void tspam_cleanup() {
  fprintf(stderr,"tspam_cleanup\n");
  pglist->close( pglist );
  free( pglist );
  pblist->close( pblist );
  free( pblist );
}


int main(int argc, const char *argv[]) {
  printf("is_spam: %d\n",tspam_classify(argv[1]));
  return 0;
}
