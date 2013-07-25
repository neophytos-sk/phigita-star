#!/usr/bin/tclsh

set filename [lindex $argv 0]
set fp [open $filename r]
while {![eof $fp]} {
    set line0 [gets $fp]
    set line1 [gets $fp]
    puts [join $line1 ,]
}
close $fp

