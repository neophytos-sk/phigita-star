#!/usr/bin/tclsh

set filename [lindex $argv 0]
set numTransactions [lindex $argv 1]

global data
set fp [open words.txt r]
while {![eof $fp]} {
    foreach {word id} [gets $fp] {
	set data($id) $word
    }
}
close $fp

set cmd "cat $filename"
set fp [open "|$cmd" r]



set solution ""
while {![eof $fp]} { 
    set line [split [gets $fp] " "]
    set itemset [lsort [lrange $line 0 end-1]]
    set occ($itemset) [string trim [lindex $line end] "()"]

    if { $itemset ne {} } {
	lappend solution $itemset
    }
}

set count "0"
foreach itemset $solution {

    set head [lindex $itemset 0]
    set body [lsort [lrange $itemset 1 end]]

    foreach id $body {
#	puts -nonewline "[list $data($id)] "
	puts -nonewline "$id "
    }

    if { $body ne {} } {
	puts -nonewline "($occ($body)) -> "
    }

#    puts -nonewline "$data($head)"
    puts -nonewline "$head"

    puts -nonewline " ($occ($head))"

    if { $body eq {} } { puts ""; continue }

    set support [expr { double($occ($head))/double($numTransactions) }]
    set confidence [expr {(double($occ($itemset))/double($occ($body)))/double($occ($head)) }]

    puts " ($support,$confidence)"
}

close $fp
