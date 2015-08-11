#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core

config section ::persistence
config use "server"

package require persistence

set myaddr [config get ::persistence "address"]
set myport [config get ::persistence "port"]
log "starting server ${myaddr}:${myport}"
set channel [socket -server ::db_server::accept_client_async -myaddr $myaddr $myport]
chan configure $channel -blocking 0 -translation binary
vwait forever
