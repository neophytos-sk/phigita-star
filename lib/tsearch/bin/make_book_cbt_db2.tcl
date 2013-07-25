#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require utilities
::xo::lib::require critbit_tree
#::xo::lib::require tsearch


puts "encoding=[encoding system]"

set words_cbt [::cbt::create $::cbt::STRING]
set books_cbt [::cbt::create $::cbt::UINT32_STRING]
#set books_cbt [::cbt::create $::cbt::STRING]



set filename ../data/books.csv
set fp [open $filename]
fconfigure $fp -encoding binary -translation binary


array set words [list]
set word_id 0
set book_id 0
set insert_duration 0
while { [gets $fp line] >= 0 } {
    lassign [split $line {|}] ean13 ts_vector

    # TODO (we need to specify value type like we do for keys): set value [::util::uint32_to_bin [incr book_id]]
    set value $ean13
    foreach search_term $ts_vector {
	lassign [split $search_term {:}] term position_and_weight
	set word [string trim $term {'}]
	#set word [encoding convertto utf-8 $word]

	set u8word [encoding convertfrom utf-8 $word]
	if { [info exists words($u8word)] != [::cbt::exists $words_cbt ${word}=] } {
	    if { 2 != [set x [::cbt::insert $words_cbt ${word}=$words($u8word)]] } {
		puts "problem ::cbt::exists=0 <<<< ::cbt::insert!=2 (=$x)"
		exit
	    }

	    puts "word=$u8word difference between array exists and ::cbt::exists"
	    #puts [::cbt::to_string $words_cbt]
	    #exit

	}

	if { ![::cbt::exists $words_cbt ${word}=] } {
	    if { 2 != [::cbt::insert $words_cbt ${word}=[incr word_id]] } {
		puts "problem ::cbt::exists=0 ::cbt::insert=2"
		exit
	    }
	    set key [::util::uint32_to_bin $word_id]
	    set words($u8word) $word_id
	} else {
	    set key [::util::uint32_to_bin $words($u8word)]
	    #puts "$word exists"
	}

	#set key $word

	#puts [string bytelength $key]
	#set value [list $ean13 $position $weight]
	#set value [list $ean13 $rank] ;# rank is pre-computed with ts_rank

	set data "${key}=${value}"
	set startTime [clock clicks]
	set retval [::cbt::insert $books_cbt ${data}]
	# retval = 2 new node
	# retval = 1 existing node
	# retval = 0 insert failed
	#puts retval=$retval

	set endTime [clock clicks]
	incr insert_duration [expr { $endTime -$startTime }]
	if { $word_id % 1000000 == 0 } { 
	    puts "word_id=$word_id word=[encoding convertfrom utf-8 $word]" 
	    puts "size of books tree = [::cbt::size $books_cbt]"
	    puts "sleeping for one second..."
	    after 1000 ;# throttle requests
	}
    }
    
    #puts "size of tree (before delete) = [::cbt::size $books_cbt]"
    #::cbt::delete $books_cbt $data  ;# delete the last term inserted to test ::cbt::delete
    #puts "size of tree (after delete) = [::cbt::size $books_cbt]"
    #if {[incr count]==10000} break;
}
close $fp
ns_log notice "Insert to tree took: $insert_duration clock clicks"


set startTime [clock clicks]
::cbt::dump $words_cbt "../data/books_ts_words.cbt_db"
::cbt::dump $books_cbt "../data/books_ts_index.cbt_db"
set endTime [clock clicks]
set duration [expr { $endTime - $startTime }]
ns_log notice "Dump to file took: $duration clock clicks"

::cbt::destroy $books_cbt
::cbt::destroy $words_cbt

# OLD CODE BELOW THIS LINE
#set data ${key}=${value}
#set data $lo=${hi_diff}_${location_id}
#::cbt::insert $blocks_cbt $key "    $value"
