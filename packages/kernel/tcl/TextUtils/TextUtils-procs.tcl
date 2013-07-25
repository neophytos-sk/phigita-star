# Find the minimum indentation for a string, not counting blank lines.
proc indent_level {str} {

    set str \n${str}
    set regexp {\n( *)}

    if {[string length $str] == 0} {
	return 0
    }

    set minlevel -1
    set start 0
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
        foreach {subStart subEnd} $submatch break
        foreach {matchStart matchEnd} $match break
        incr matchStart -1
        incr matchEnd
        set level [expr $subEnd - $subStart + 1]
        if {${minlevel} > ${level} || ${minlevel} == -1} {
            set minlevel ${level}
        }
        set start $matchEnd
    }
    
    return ${minlevel}

}


# Compute the longest string which is common to all strings given to
# the command, and at the beginning of said strings, i.e. a prefix. If
# only one argument is specified it is treated as a list of the
# strings to look at. If more than one argument is specified these
# arguments are the strings to be looked at. If only one string is
# given, in either form, the string is returned, as it is its own
# longest common prefix.

proc longestCommonPrefix {args} {
    return [longestCommonPrefixList $args]
}

proc longestCommonPrefixList {list} {
    if {[llength $list] == 0} {
	return ""
    } elseif {[llength $list] == 1} {
	return [lindex $list 0]
    }

    set list [lsort  $list]
    set min  [lindex $list 0]
    set max  [lindex $list end]

    # Min and max are the two strings which are most different. If
    # they have a common prefix, it will also be the common prefix for
    # all of them.

    # Fast bailouts for common cases.

    set n [string length $min]
    if {$n == 0}                         {return ""}
    if {0 == [string compare $min $max]} {return $min}

    set prefix ""
    for {set i 0} {$i < $n} {incr i} {
	if {0 == [string compare [set x [string range $min 0 $i]] [string range $max 0 $i]]} {
	    set prefix $x
	    continue
	}
	break
    }
    return $prefix
}

