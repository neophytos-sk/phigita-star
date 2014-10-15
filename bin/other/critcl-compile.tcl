#!/usr/bin/tclsh

if { [llength $argv] ni { 1 2 } } {
    puts "Usage: $argv0 MODULE_NAME ?performance_mode_p?"
    exit
}

set dir [file dirname [info script]]

source [file join $dir .. lib/naviserver_compat/tcl/module-naviserver_compat.tcl]

set MODULE_NAME [lindex $argv 0]
set performance_mode_p [lsearch -inline -not [list [lindex $argv 1] 0] {}]

proc ::xo::kit::performance_mode_p {} [list return $performance_mode_p]

puts "compiling module $MODULE_NAME performance_mode_p=$performance_mode_p"

::xo::lib::require $MODULE_NAME
