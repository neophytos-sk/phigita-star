#!/usr/bin/tclsh

set dir [file dirname [info script]]
source [file join $dir "term_procs.tcl"]

proc command_handler {line} {
    if { $line eq {sayhi} } {
        puts "hello world"
    }
}

::util::term::read_eval_print_loop command_handler

exit 0

