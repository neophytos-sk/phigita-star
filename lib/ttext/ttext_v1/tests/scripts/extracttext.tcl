#!/usr/bin/tclsh
set alphabet "αβγδεζηθικλμνξοπρσςτυφχψωάέήίόύώΑΒΓΔΕΖΗΘΙΚΛΜΝΞ ΟΠΡΣΤΥΦΧΨΩΪϊϋ"
set result ""

if {$argc > 0} {

    set filename [ lindex $argv 0 ]
    set inf [ open $filename r ]
    set str [ read $inf ]
    set slen [ string length ${str} ]
    close $inf

    for {set i 0} {$i < $slen} {incr i} {
	set char [ string index ${str} $i ]
	set index [ string first ${char} ${alphabet} 0 ]
	if {$index != -1} {
	    set result "${result}${char}"
	}
    }

    if {$argc > 1} {
	set filename [ lindex $argv 1 ]
	set outf [ open $filename w ]
	puts $outf $result
	close $outf
    } else { puts $result }
} else { puts "wrong arguments" }