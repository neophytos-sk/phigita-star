#!/bin/sh
#\
 exec tclsh "$0" "$@"

set ::__is_server_p ""

package require core
package require persistence

set myaddr 127.0.0.1
set myport 9900
log "starting server ${myaddr}:${myport}"
set channel [socket -server ::db_server::accept_client_async -myaddr $myaddr $myport]
chan configure $channel -blocking 0 -translation binary
vwait forever
