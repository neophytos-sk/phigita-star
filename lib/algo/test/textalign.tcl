#!/usr/bin/tclsh

package require algo

set dir [file dirname [info script]]
set filename [file join $dir data.txt]

set fp [open $filename]
set text [read $fp]
close $fp

textalign::adjust $text ;# 80
