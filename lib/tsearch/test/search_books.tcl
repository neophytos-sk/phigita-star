#!/usr/bin/tclsh

if { [llength $argv] < 3 } {
    set cmd $argv0
    puts "Usage: $cmd query direction limit"
    exit
}

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require utilities
::xo::lib::require critbit_tree
#::xo::lib::require tsearch

set words_cbt [::cbt::create $::cbt::STRING_KEYS "books_ts_words.cbt_db"]
set books_cbt [::cbt::create $::cbt::UINT32_KEYS "books_ts_index.cbt_db"]

#set dir [file join [acs_root_dir] lib tsearch]
#::cbt::restore $words_cbt [file join $dir data/books_ts_words.cbt_db]
#::cbt::restore $books_cbt [file join $dir data/books_ts_index.cbt_db]

set dir /tsearch-data/
::cbt::restore $words_cbt [file join $dir books_ts_words.cbt_db]
::cbt::restore $books_cbt [file join $dir books_ts_index.cbt_db]

puts encoding=[encoding system]

#set search_term "DDC#700"
set search_keywords [lindex $argv 0]
set search_term [join [lsort -dictionary $search_keywords] {,}]
#set search_term [encoding convertto utf-8 $search_term]
#set search_term [binary format a* $search_term]
#binary scan $search_keywords a* search_term

# just testing for now (we'll read the number from the words cbt)
#set search_term [::util::uint32_to_bin [lindex $argv 0]]

set search_term [encoding convertto utf-8 $search_term]
set word_id [lindex [split [::cbt::get $words_cbt "${search_term}="] "="] 1]
puts word_id=$word_id
set search_term [::util::uint32_to_bin $word_id]




set direction [lindex $argv 1]
set limit [lindex $argv 2]
set exact 1 ;# 0=match longest prefix 1=match exact

## NOTE: the equal (=) sign after the search_term is to ensure that 
## we only want the key of the search term in the result (returned data) to match exactly 
## (see below for an example of results that matches the key prefix)
## without the equal (=) sign we would get the first of the allprefixed results

#set result1 [encoding convertfrom utf-8 [::cbt::prefix_match $books_cbt ${search_term}=]]
#puts $result1

## allprefixed results
#set result2 [encoding convertfrom utf-8 [::cbt::allprefixed $books_cbt ${search_term}]]
#puts $result2

## what we actually want for search:
puts length_of_term=[string length $search_term]
set startTime [clock clicks]
set result3 [::cbt::prefix_match $books_cbt "${search_term}=" $direction $limit $exact]
set endTime [clock click]
#puts [encoding convertfrom utf-8 $result3]

puts result_size=[llength $result3]
#puts [::util::bin_to_uint32 $result3]

set duration [expr { $endTime - $startTime }]
puts "Search took ${duration} clock clicks"

#puts [::cbt::to_string $books_cbt]

::cbt::destroy $books_cbt
::cbt::destroy $words_cbt
