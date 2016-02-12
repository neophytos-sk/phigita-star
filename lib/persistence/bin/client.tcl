#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core
package require persistence

puts output=[::db_client::exec_cmd $argv]
