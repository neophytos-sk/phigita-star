#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree
#::xo::lib::require tsearch


puts "encoding=[encoding system]"

set blocks_cbt [::cbt::create $::cbt::STRING_KEYS]
set filename ../data/books.csv
set fp [open $filename]
#fconfigure $fp -encoding binary -translation binary
fconfigure $fp -encoding binary -translation binary
while { [gets $fp line] >= 0 } {
    lassign [split $line {|}] ean13 ts_vector

    foreach search_term $ts_vector {
	lassign [split $search_term {:}] term position_and_weight
	set key [string trim $term {'}]
	#puts [string bytelength $key]
	#set value [list $ean13 $position $weight]
	#set value [list $ean13 $rank] ;# rank is pre-computed with ts_rank
	set value $ean13
	set data "${key}=${value}"
	::cbt::insert $blocks_cbt ${data}
    }
}
close $fp

::cbt::write_to_file $blocks_cbt "../data/books_ts_index.cbt_db"
::cbt::destroy $blocks_cbt

# OLD CODE BELOW THIS LINE
#set data ${key}=${value}
#set data $lo=${hi_diff}_${location_id}
#::cbt::insert $blocks_cbt $key "    $value"
