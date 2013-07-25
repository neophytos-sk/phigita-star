#!/usr/bin/tclsh

set filename [lindex $argv 0]


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

#for {set i 0} {$i < 1000} {incr i} {
#    set max_occ($i) 0
#}


while {![eof $fp]} { 
    #set line [split [gets $fp] " "]
    set line [split [string trim [gets $fp]]]

    set itemset [lrange $line 0 end-1]
    set occ [string trim [lindex $line end] "()"]
    
#    set length [llength $itemset]
#    if { $occ > $max_occ($length) } {
#	set max_occ($length) $occ
#    }

    set row ""
    set skip_p false
    if { $occ ne {} && ${itemset} ne {} } {
	### puts "XXX $itemset [llength $itemset]"
	foreach id $itemset {
	    if {[catch {
		lappend row $data($id)
		### puts -nonewline "[list $data($id)] "
	    } errmsg]} {
		### puts "id=$id errmsg=$errmsg"
		set skip_p true
	    }
	}
	if { !${skip_p} } {
	    puts "$row ($occ)"
	}
    }
}
close $fp
