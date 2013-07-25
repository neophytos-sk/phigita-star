#!/usr/bin/tclsh
package require tdom
set fp [open stdin]
set data [read $fp]
close $fp
puts ${data}-hello
