#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence
::xo::lib::require util_procs


if { [llength $argv] != 1 } {
    puts "usage: $argv0 filename"
    exit
}

set filename [lindex $argv 0]
set fp [open $filename]
set num_rows [::util::io::read_int $fp]
for {set i 0} {$i < $num_rows} {incr i} {
    set row [::util::io::read_vartext $fp]
    set num_cols [::util::io::read_int $fp]
    puts "$row $num_cols"
    for {set j 0} {$j < $num_cols} {incr j} {
        set path [::util::io::read_utf8 $fp]
        set data [::util::io::read_utf8 $fp]
        puts $path
        puts $data
    }
}
close $fp
