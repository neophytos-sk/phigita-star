#!/usr/bin/tclsh
source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require htmltidy

set filename [lindex $argv 0]

set fp [open $filename]
set input_html [read $fp]
close $fp

set html [::htmltidy::tidy $input_html]

puts $html

