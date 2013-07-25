# tcl

variable _debug 0

# if it does exist, simply return it (ala the $ operator)
# if the variable doesn't exist, initialize it to 'init'
proc Deref {var__ init} {
    upvar $var__ var
    
    if [info exists var] {
	return $var
    } else {
	set var $init
	return $var
    }
}

proc Dputs {keyword str} {
    variable _debug
    set debugIsOn [lindex $_debug 0]
    if {$debugIsOn} {
	set keywordList [lrange $_debug 1 end]
	if {[lsearch -exact $keywordList $keyword] != -1} {
	    puts stderr $str
	}
    }
}

proc Debug {on keyword} {
    variable _debug
    set debugIsOn [lindex $_debug 0]
    if {$debugIsOn} {
	set keywordList [lrange $_debug 1 end]
	set _debug "$on [list $keywordList $keyword]"
	puts stderr "Debug1: $_debug"
    } else {
	set _debug "$on $keyword"
	puts stderr "Debug2: $_debug"
    }
}

proc True {b} {
    set b [string tolower $b]
    switch -exact $b {
	"t"    { return 1 }
	"true" { return 1 }
    }
    return 0
}

proc False {b} {
    set b [string tolower $b]
    switch -exact $b {
	"f"     { return 1 }
	"false" { return 1 }
    }
    return 0
}

proc StringEqual {s1 s2} {
    if {[string compare $s1 $s2] == 0} {
	return 1
    }
    return 0
}

proc AssertEqual {x y} {
    if {$x == $y} {
	return
    }
    PrintStackTrace "Assertion Failed: '$x' doesn't equal '$y'"
}

proc AssertNotEqual {x y} {
    if {$x == $y} {
	PrintStackTrace "Assertion Failed: '$x' equals '$y'"
    }
}

proc AssertLessThan {x y} {
    if {$x < $y} {
	return
    }
    PrintStackTrace "Assertion Failed: '$x' is not less than '$y'"
}

proc AssertGreaterThan {x y} {
    if {$x > $y} {
	return
    }
    PrintStackTrace "Assertion Failed: '$x' is not greater than '$y'"
}

proc AssertGreaterThanOrEqual {x y} {
    if {$x >= $y} {
	return
    }
    PrintStackTrace "Assertion Failed: '$x' is not greater than or equal to '$y'"
}

proc AssertIsNumber {x} {
    if {[string is double -strict $x]} {
	return 1
    }
    PrintStackTrace "Assertion Failed: '$x' is not a number"
}

proc AssertIsMemberOf {x group} {
    foreach m $group {
	if [StringEqual $x $m] {
	    return 1
	}
    }
    PrintStackTrace "$x is not a member of the group $group"
}

proc Abort {str} {
    if {$str != ""} {
	puts stderr $str
    }
    exit 1
}

proc AddSpaces {s} {
    for {set i 0} {$i < $s} {incr i} {
	puts -nonewline " "
    }
}

# note: also exits
proc PrintStackTrace {str} {
    if {$str != ""} {
	puts stderr $str
    }

    set level   [info level]
    set stack   [info level [expr $level-1]]
    # puts "Problem occurred in: [lindex $stack 0] args:\{[lrange $stack 1 end]\}"
    puts "Problem occurred in: [lindex $stack 0]"

    set space 2
    for {set i [expr $level-2]} {$i > 0} {incr i -1} {
	set stack   [info level $i]
	AddSpaces $space
	# puts "which was called by: [lindex $stack 0] args:\{[lrange $stack 1 end]\}"
	puts "which was called by: [lindex $stack 0]"
	incr space 2
    }

    exit 1
}






