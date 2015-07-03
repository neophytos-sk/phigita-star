#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence

namespace eval ::persistence::shell {
}

puts "keyspaces"
puts "---------"
puts [set keyspaces [::persistence::list_ks]]

puts "column families"
puts "---------------"
foreach ks $keyspaces {
    puts "* $ks"
    foreach cf [::persistence::list_cf $ks] {
        foreach axis [::persistence::list_axis $ks $cf] {
            set num_rows [::persistence::num_rows $ks $cf/$axis]
            puts "  + $cf/$axis $num_rows"
            #foreach row [::persistence::list_row $ks $cf/$axis] {
            #    puts "    . $row"
            #}
        }
    }
}
