#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence
::xo::lib::require util_procs

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
            ::util::io::write_int $fp $num_rows
            foreach row [::persistence::list_row $ks $cf_axis] {
                set num_cols [::persistence::num_cols $ks $cf_axis $row]
                puts "      - $row $num_cols"
                ::util::io::write_vartext $fp $row
                ::util::io::write_int $fp $num_cols
                foreach path [::persistence::list_path $ks $cf_axis $row] {
                    puts "          $path"
                    set data ""
                    set filename [::persistence::get_column $ks $cf_axis $row [string trimleft $path {+/}] data]
                    ::util::io::write_utf8 $fp $path
                    ::util::io::write_utf8 $fp $data
                    puts $filename
                }
            }
            close $fp
        }
    }
}
