#!/usr/bin/tclsh

set dir [file dirname [info script]]
source [file join $dir helper-procs.tcl]

set filename [string trim [lindex $argv 0]]

if { $filename ne {} } {

    set fp [open $filename]
    set urls [split [read $fp] "|"]
    close $fp


} else {

    puts "Usage: $argv0 filename"

    puts "--->>> proceeding with example url"

    set urls [list "http://www1.macys.com/shop/product/polo-ralph-lauren-jacket-elmwood-down-jacket?ID=1059603&CategoryID=3763#fn=sp%3D1%26spc%3D773%26ruleId%3D78%26slotId%3D1"]

}

set max_count 0
set max_xpath ""
set max_text ""
array set xpath_count [list]
foreach url $urls {

    if { [incr count_iteration] > 3 } break

    set text ""
    set xpath [find_data_fragment $url text]
    set this_count [incr xpath_count(${xpath})]
    if { $this_count > $max_count && $max_xpath ne $xpath} {
        set max_count $this_count
        set max_xpath $xpath
        set max_text $text
    }

}

if { $max_xpath ne {} } {
    puts "--->> xpath=$max_xpath"
    puts "--->> highlighted_text= $max_text"
}

