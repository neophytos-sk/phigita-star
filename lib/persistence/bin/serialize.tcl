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
        puts "  + $cf"
        foreach row [::persistence::list_row $ks $cf] {
            set num_cols [::persistence::num_cols $ks $cf $row]
            puts "    . $row $num_cols"
            #foreach col [::persistence::get_slice_names $ks $cf $row] {
            #puts $col
            #}
            foreach path [::persistence::list_path $ks $cf $row] {
                puts "      - $path"
                #set data ""
                #set filename [::persistence::get_column $ks $cf $row $path data]
                #puts $data
            }
        }
    }
}
