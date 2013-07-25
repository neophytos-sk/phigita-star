namespace eval aux {;}

proc aux::decode {lval args} {

    foreach {rval value} $args {

	if { [string equal $lval $rval] } {
	    return $value
	}
    } 

    return ""
}


proc aux::mapobj {ff catalog} {    

    set result [list]

    foreach obj ${catalog} {
	lappend result [eval "${obj} ${ff}"]
    }

    return ${result}

}


proc aux::map {ff list} {

    set result [list]
    foreach value ${list} {
	lappend result [eval "${ff} ${value}"]
    }

    return ${result}
}
