#!/usr/bin/tclsh

package require core
source [acs_root_dir]/packages/kernel/tcl/20-xo/10-io/00-readwrite-procs.tcl

::xo::lib::require persistence
::xo::lib::require util_procs

proc print_usage_info {} {
    upvar argv0 argv0
    puts "${argv0} cf_dir output_filename"
}

set argc [llength $argv]
if { $argc != 2 } {
    print_usage_info
}

set cf_dir [lindex $argv 0]
set outfile [lindex $argv 1]

set sorted_row_keys [lsort [glob -tails -directory ${cf_dir} *]] 

set fp [open ${outfile} "w"]

# seek to the position that the rows data begins
set offset 1000 ;# arbitrary value - todo: change me
seek ${fp} ${offset}

foreach row_key $sorted_row_keys {

    set sorted_column_names [lsort [glob -tails -directory ${cf_dir}/${row_key} *]]


    set row_pos [tell ${fp}]

    set bytelen 0

    incr bytelen [::xo::io::writeVarText ${fp} ${row_key} utf-8]

    foreach column_name ${sorted_column_names} {
	
	incr bytelen [::xo::io::writeVarText ${fp} ${column_name} utf-8]
	
	set column_value [::util::readfile ${cf_dir}/${row_key}/${column_name}]

	incr bytelen [::xo::io::writeVarText ${fp} ${column_value} utf-8]

    }

    set index(${row_key}) [tell ${fp}]

    #::xo::io::writeInt ${fp} ${bytelen}
    ::xo::io::writeInt ${fp} ${row_pos}

}


set index_position [tell ${fp}]

# now write the index 
foreach row_key [lsort [array names index]] {
    ::xo::io::writeString ${fp} ${row_key}
    ::xo::io::writeInt ${fp} $index(${row_key})
}

# store position of index at byte 0

seek ${fp} 0

::xo::io::writeLong ${fp} ${index_position}

close ${fp}

