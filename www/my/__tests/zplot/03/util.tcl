# tcl

variable _debug 0

proc Dputs {str} {
    variable _debug
    if {$_debug} {
	puts stderr $str
    }
}

proc Debug {level} {
    variable _debug
    set _debug $level
}

proc True {b} {
    switch -exact $b {
	"t"    { return 1 }
	"T"    { return 1 }
	"true" { return 1 }
	"True" { return 1 }
	"TRUE" { return 1 }
    }
    return 0
}

proc False {b} {
    switch -exact $b {
	"f"     { return 1 }
	"F"     { return 1 }
	"false" { return 1 }
	"False" { return 1 }
	"FALSE" { return 1 }
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
    Abort "Assertion Failed: $x doesn't equal $y"
}

proc AssertNotEqual {x y} {
    if {$x == $y} {
	Abort "Assertion Failed: $x doesn't equal $y"
    }
}

proc AssertGreaterThan {x y} {
    if {$x > $y} {
	return
    }
    Abort "Assertion Failed: $x is not greater than $y"
}

proc AssertGreaterThanOrEqual {x y} {
    if {$x >= $y} {
	return
    }
    Abort "Assertion Failed: $x is not greater than or equal to $y"
}

proc AssertIsNumber {x} {
    if {[string is double -strict $x]} {
	return 1
    }
    Abort "$x is not a number"
}

proc Abort {str} {
    puts stderr "Abort:: $str"
    PrintStackTrace
}





