#!/usr/bin/tclsh

if { [llength $argv] == 0 } {
    set dirname [pwd]
} else {
    set dirname [file normalize [lindex $argv 0]]
}

if { ![string match /web/service-phgt-0/* $dirname] } {
    puts "Out of sync scope dirname=$dirname"
    exit
}

set files [glob -nocomplain -types {d f} -directory ${dirname} *]
puts $files

puts "Under construction"