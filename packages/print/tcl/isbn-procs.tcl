namespace eval ::isbn {;}
proc ::isbn::valid_checksum_p isbn {
     set digits 0
     set sum 0
     foreach d [split $isbn {}] {
 	if {![string is digit $d]} { ;# Not a digit...
 	    if {(${digits} == 9 && ${d} ne {x} && ${d} ne {X}) || (${digits}<9 && ${d} eq {-})} {
 		# ... Nor a 'x' as last character. Skip it.
 		continue
 	    } else {
		return 0
	    }
 	}
 	incr digits
 	if {$d eq {x} || $d eq {X}} {set d 10}
 	set sum [expr {$sum+($d*(11-$digits))}]
     }
     if {$digits == 10 && ($sum % 11) == 0} {return 1}
     return 0
 }

proc ::isbn::valid_ean13_p { ean13 } {

    set ean13_no_dashes [string map {- {}} ${ean13}]
    if { [string length ${ean13_no_dashes}] != 13 } {
	return 0
    }
    set first12digits [string range ${ean13_no_dashes} 0 11]
    return [expr {[::isbn::ean13_csum ${first12digits}]==[string index ${ean13_no_dashes} end]}]
}

proc ::isbn::ean13_csum { number } {
	set odd 1
	set sum 0
	foreach digit [split $number ""] {
	    set odd [expr {!$odd}]
	    #puts "$sum += ($odd*2+1)*$digit :: [expr {($odd*2+1)*$digit}]"
	    incr sum [expr {($odd*2+1)*$digit}]
	}
	set check [expr {$sum % 10}]
	if { ${check} > 0 } {
	    return [expr {10 - ${check}}]
	}	
	return ${check}
}

proc ::isbn::convert_to_ean13 {isbn} {
	if { [isbn::valid_checksum_p ${isbn}] } {
		set isbn10_no_dashes [string map {- {}} ${isbn}]
		set first12digits "978[string range ${isbn10_no_dashes} 0 end-1]"
		return "${first12digits}[ean13_csum ${first12digits}]"
	}
	return {}
}

