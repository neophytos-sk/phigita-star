#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence
::xo::lib::require util_procs

if { [llength $argv] ni {1 2} } {
    puts "usage: $argv0 filename ?row?"
    exit
}


lassign $argv filename row_id

proc read_index {fp} {

    seek $fp 0 end
    ::util::io::rskip_int $fp
    set index_offset [::util::io::read_int $fp]
    seek $fp $index_offset start

    set result [list]
    set num_rows [::util::io::read_int $fp]

    #puts index_offset=$index_offset
    #puts num_rows_in_index=$num_rows

    for {set i 0} {$i < $num_rows} {incr i} {
        set row [::util::io::read_vartext $fp]
        set pos [::util::io::read_int $fp]
        lappend result $row $pos
        #puts [list $row $pos]
    }
    return $result
}

proc read_row {fp} {
    set pos [tell $fp]
    #puts $pos
    
    set result [list]
    set row [::util::io::read_vartext $fp]
    set num_cols [::util::io::read_int $fp]
    lappend result $row $num_cols
    for {set j 0} {$j < $num_cols} {incr j} {
        set path [::util::io::read_utf8 $fp]
        set data [::util::io::read_utf8 $fp]

        lappend result $path $data

        #puts $data
        #lassign $data {*}$fields
        #puts [array get rec]
        #puts [format "%.35s %.35s" $rec(title) $rec(body)]
    }
    return $result
}

set fp [open $filename]

set fields [list rec(title) rec(body)]

if { $row_id ne {} } {
    array set index [read_index $fp]
    if { [info exists index($row_id)] } {
        puts index_of_row=$index($row_id)
        seek $fp $index($row_id) start
        set data [lassign [read_row $fp] row num_cols]
        puts row=$row
        puts num_cols=$num_cols
        for {set i 0} {$i < $num_cols} {incr i} {
            set data [lassign $data column_name column_data]
            lassign $column_data {*}${fields}
            puts "(column_name=${column_name})"
            puts $rec(title)
            puts ----------
            puts $rec(body)
        }
    } else {
        puts "not found"
    }
    exit
}

set num_rows [::util::io::read_int $fp]
for {set i 0} {$i < $num_rows} {incr i} {
    puts [read_row $fp]
}
close $fp
