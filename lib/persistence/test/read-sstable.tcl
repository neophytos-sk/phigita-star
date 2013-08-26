#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
source /web/repos/phigita/service-phigita/packages/kernel/tcl/20-xo/10-io/00-readwrite-procs.tcl

::xo::lib::require persistence
::xo::lib::require util_procs

proc print_usage_info {} {
    upvar argv0 argv0
    puts "${argv0} sstable_filename row_key column_name"
}

set argc [llength $argv]
if { $argc != 3 } {
    print_usage_info
}

set infile [lindex $argv 0]
set in_row_key [lindex $argv 1]
set in_column_name [lindex $argv 2]


set fp [open ${infile} "r"]
fconfigure $fp -encoding binary

set index_position [::xo::io::readLong ${fp}]

puts index_position=$index_position

seek ${fp} ${index_position}


set row_key ""
while { [set row_key [::xo::io::readVarText ${fp} "" utf-8]] ne ${in_row_key} } {
    # skip index pos
    ::xo::io::readInt ${fp}
}

if { ${row_key} eq ${in_row_key} } {

    # index to end of row record
    set pos [::xo::io::readInt ${fp}]
    seek ${fp} ${pos} start

    # read row_pos from end of record
    set row_pos [::xo::io::readInt ${fp}]
    seek ${fp} ${row_pos} start

    set row_key [::xo::io::readVarText ${fp} "" utf-8]
    puts row_key=${row_key}

    set found_p 0
    while { [tell ${fp}] < ${pos} } {

	set column_name [::xo::io::readVarText ${fp} "" utf-8]
	if { [string length ${column_name}] > 100 } {
	    puts [string range ${column_name} 0 200]
	    break
	}
	#puts column_name=${column_name}
	set column_value [::xo::io::readVarText ${fp} "" utf-8]

	if { ${column_name} eq ${in_column_name} } {
	    set found_p 1
	    break
	}

    }

    if { ${found_p} } {
	puts ${column_value}
    }
}

close ${fp}
