#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core
package require persistence

::db_client::exec_cmd $argv
