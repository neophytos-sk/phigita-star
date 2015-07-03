#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence

namespace eval ::persistence::shell {
}

set dir [file dirname [info script]]/tmp
file mkdir $dir

puts "keyspaces"
puts "---------"
puts [set keyspaces [::persistence::list_ks]]

puts "column families"
puts "---------------"
foreach ks $keyspaces {
    puts "@ $ks"
    foreach cf [::persistence::list_cf $ks] {
        puts "  * $cf"
        foreach axis [::persistence::list_axis $ks $cf] {
            set outfile ${dir}/${ks}-${cf}-${axis}
            set fp [open $outfile w]
            set cf_axis ${cf}/${axis}
            set num_rows [::persistence::num_rows $ks $cf_axis]
            puts "    . $cf_axis $num_rows"
            foreach row [::persistence::list_row $ks $cf_axis] {
                set num_cols [::persistence::num_cols $ks $cf_axis $row]
                puts "      - $row $num_cols"
                puts -nonewline $fp $row
                puts -nonewline $fp $num_cols
                foreach path [::persistence::list_path $ks $cf_axis $row] {
                    puts "          $path"
                    set data ""
                    set filename [::persistence::get_column $ks $cf_axis $row [string trimleft $path {+/}] data]
                    puts -nonewline $fp $path
                    puts -nonewline $fp $data
                    puts $filename
                }
            }
            close $fp
        }
    }
}
