#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require templating

set filename "[file dirname [info script]]/test.tdp"
set html [::xo::tdp::process $filename]

puts $html
