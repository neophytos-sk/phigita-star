#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require feed_reader

array set item [list urlsha1 "58d29ec7c4d08ced93c7969bddd69075875631c3" title "hello world" body "this is a test αυτή είναι μια δοκιμή" sort_date "20151012T1800"]

set bytes [::newsdb::news_item_t encode item]

set dir [file dirname [info script]]
set filename [file join $dir test.dat]

set ofp [open $filename "w"]
fconfigure $ofp -translation binary
puts $ofp $bytes
close $ofp

set ifp [open $filename]
fconfigure $ifp -translation binary
set binary_data [read $ifp]
close $ifp

puts [::newsdb::news_item_t decode $binary_data]
