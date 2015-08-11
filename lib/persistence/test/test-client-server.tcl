#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require persistence

set str "αυτή είναι μια δοκιμή"
#set data [binary format a* $str]
set data [encoding convertto utf-8 $str]

set response [::db_client::exec_cmd ping $data]

set response [encoding convertfrom utf-8 $response]

puts $response
