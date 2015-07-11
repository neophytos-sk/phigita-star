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
    foreach cf [::persistence::ls $ks] {
        puts "  * $cf"
        foreach axis [::persistence::ls $ks $cf] {
            file mkdir ${dir}/${ks}
            set outfile ${dir}/${ks}/${cf}:${axis}
            set fp [open $outfile w]
            set cf_axis ${cf}/${axis}
            set num_rows [::persistence::num_rows $ks $cf_axis]
            #puts "    . $cf_axis $num_rows"
            ::util::io::write_int $fp $num_rows
            set rows_index [list]
            foreach row [::persistence::ls $ks $cf_axis] {
                set pos [tell $fp]
                lappend rows_index $row $pos
                set num_cols [::persistence::num_cols $ks $cf_axis $row]
                #puts "      - $row $num_cols"
                ::util::io::write_vartext $fp $row
                ::util::io::write_int $fp $num_cols
                foreach path [::persistence::list_path $ks $cf_axis $row] {
                    #puts "          $path"
                    set data ""
                    set filename [::persistence::get_column $ks $cf_axis $row [string trimleft $path {+/}] data]
                    ::util::io::write_vartext $fp $path
                    ::util::io::write_utf8 $fp $data
                    #::util::io::write_record [list utf8 utf8] $data
                    #puts $filename
                }
            }
            # index rows
            set index_offset [tell $fp]
            ::util::io::write_int $fp $num_rows
            foreach {row pos} $rows_index {
                ::util::io::write_vartext $fp $row
                ::util::io::write_int $fp $pos
                puts [list $row $pos]
            }
            ::util::io::write_int $fp $index_offset
            close $fp
        }
    }
}
