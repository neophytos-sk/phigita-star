    #include <stdio.h>
    #include "mongo.h"

    static void tutorial_insert_batch (mongo *conn) {
      bson *p, **ps;
      char *names[4];
      int ages[] = { 29, 24, 24, 32 };
      int i, n = 4;
      names[0] = "Eliot"; names[1] = "Mike"; names[2] = "Mathias"; names[3] = "Richard";

      ps = ( bson ** )malloc( sizeof( bson * ) * n);

      for ( i = 0; i < n; i++ ) {
        p = ( bson * )malloc( sizeof( bson ) );
        bson_init( p );
        bson_append_new_oid( p, "_id" );
        bson_append_string( p, "name", names[i] );
        bson_append_int( p, "age", ages[i] );
        bson_finish( p );
        ps[i] = p;
      }

      mongo_insert_batch( conn, "tutorial.persons", ps, n );

      for ( i = 0; i < n; i++ ) {
        bson_destroy( ps[i] );
        free( ps[i] );
      }
    }

    static void tutorial_empty_query( mongo *conn) {
      mongo_cursor cursor[1];
      mongo_cursor_init( cursor, conn, "tutorial.persons" );

      while( mongo_cursor_next( cursor ) == MONGO_OK )
        bson_print( &cursor->current );

      mongo_cursor_destroy( cursor );
    }

    static void tutorial_simple_query( mongo *conn ) {
      bson query[1];
      mongo_cursor cursor[1];

      bson_init( query );
      bson_append_int( query, "age", 24 );
      bson_finish( query );

      mongo_cursor_init( cursor, conn, "tutorial.persons" );
      mongo_cursor_set_query( cursor, query );

      while( mongo_cursor_next( cursor ) == MONGO_OK ) {
        bson_iterator iterator[1];
        if ( bson_find( iterator, mongo_cursor_bson( cursor ), "name" )) {
            printf( "name: %s\n", bson_iterator_string( iterator ) );
        }
      }

      bson_destroy( query );
      mongo_cursor_destroy( cursor );
    }

    int main() {
      mongo conn[1];
      mongo_error_t status = mongo_connect( conn, "127.0.0.1", 27017 );

      if( status != MONGO_OK ) {
          switch ( conn->err ) {
            case MONGO_CONN_SUCCESS:    printf( "connection succeeded\n" ); break;
            // case MONGO_CONN_BAD_ARG:    printf( "bad arguments\n" ); return 1;
            case MONGO_CONN_NO_SOCKET:  printf( "no socket\n" ); return 1;
            case MONGO_CONN_FAIL:       printf( "connection failed\n" ); return 1;
            case MONGO_CONN_NOT_MASTER: printf( "not master\n" ); return 1;
          }
      }


  bson b[1];

  bson_init( b );
  bson_append_new_oid(b,"_id");
  bson_append_string( b, "name", "Joe" );
  bson_append_int( b, "age", 33 );
  bson_finish( b );

  mongo_insert( conn, "tutorial.people", b );

  bson_destroy( b );


  tutorial_insert_batch(conn);
  tutorial_empty_query(conn);
  tutorial_simple_query(conn);

      mongo_destroy( conn );

      return 0;
    }

