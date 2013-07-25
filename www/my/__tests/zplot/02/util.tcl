# tcl

proc StringEq {s1 s2} {
    if {[string compare $s1 $s2] == 0} {
	return 1
    }
    return 0
}

proc AssertEqual {x y} {
    if {$x == $y} {
	return
    }
    puts stderr "Assertion Failed: $x doesn't equal $y"
    AssertionFailed
}


proc AssertNotEqual {x y} {
    if {$x == $y} {
	puts stderr "Assertion Failed: $x doesn't equal $y"
	AssertionFailed
    }
}

proc Abort {str} {
    puts stderr "Abort:: $str"
    exit 1
}


