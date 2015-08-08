#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core
set ch [socket localhost 9900]
chan configure $ch -translation binary
::util::io::write_string $ch [coalesce $argv "this is a test"]
flush $ch
gets $ch line
close $ch
puts line=$line
