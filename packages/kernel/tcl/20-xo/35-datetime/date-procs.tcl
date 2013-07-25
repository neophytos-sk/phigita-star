namespace eval ::xo::dt {;}



### Trim the leading zeroes from the value, but preserve the value
### as "0" if it is "00"
proc ::xo::dt::leadingTrim { value } {
    set empty [string equal $value {}]
    set value [string trimleft $value 0]
    if { !$empty && [string equal $value {}] } {
	set value 0
    }
    return $value
}


proc ::xo::dt::now {} {
    return [clock seconds]
}

### Perform date comparison; same syntax as string compare
proc ::xo::dt::compare { s1 s2 } {
    if { $s1 > $s2 } {
	return -1
    } elseif { $s1 < $s2 } {
	return 1
    } else {
	return 0
    }
}

proc ::xo::dt::scan { date } {
    return [clock scan [lindex [split $date {.}] 0]]
}

proc ::xo::dt::add { s count unit } {
    return [clock add $s $count $unit]
}