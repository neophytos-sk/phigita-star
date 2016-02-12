#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core

config section ::persistence
config use "server"

package require persistence

::db_server::Persistence_Server localhost 9900

vwait forever

