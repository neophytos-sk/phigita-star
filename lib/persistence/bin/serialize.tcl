#!/usr/bin/tclsh


package require core
package require persistence

namespace eval ::persistence::shell {
}


set dir [file dirname [info script]]/tmp
file mkdir $dir

puts "keyspaces"
puts "---------"
puts [set keyspaces [::persistence::ls]]

puts "column families"
puts "---------------"
foreach ks $keyspaces {
    puts "@ $ks"
    foreach cf_axis [::persistence::ls $ks] {
        puts "  * $cf_axis"
        file mkdir ${dir}/${ks}
        set outfile ${dir}/${ks}/$cf_axis
        set fp [open $outfile w]
        set rows [::persistence::ls $ks $cf_axis]
        set num_rows [llength $rows]
        #puts "    . $cf_axis $num_rows"
        ::util::io::write_int $fp $num_rows
        set rows_index [list]
        foreach row $rows {
            set pos [tell $fp]
            lappend rows_index $row $pos
            set revs [::persistence::get_leafs ${ks}/${cf_axis}/${row}/+]
            set num_revs [llength $revs]
            ::util::io::write_vartext $fp $row
            ::util::io::write_int $fp $num_revs
            foreach rev $revs {
                set data [::persistence::get $rev]
                ::util::io::write_string $fp $rev
                ::util::io::write_string $fp $data
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
