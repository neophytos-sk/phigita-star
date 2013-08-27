#!/usr/bin/tclsh
#


set str ${argv}

set fp [open "test.bin" "wb"]
set len [string bytelength $str]
puts -nonewline $fp [binary format i $len]
puts -nonewline $fp [encoding convertto utf-8 $str]
close $fp

set fp [open test.bin rb]
binary scan [read $fp 4] i len
puts len=$len
set str [read ${fp} ${len}]
puts str=[encoding convertfrom $str]
close $fp
