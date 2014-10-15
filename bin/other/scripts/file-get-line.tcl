#!/usr/bin/tclsh

set filename [lindex $argv 0]
set line_num [lindex $argv 1]

set fp [open $filename]
set count 0
while { ![eof $fp] } {
set line [gets $fp]
if { [incr count] == $line_num } { puts $line }
}
close $fp
