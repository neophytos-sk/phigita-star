# tcl

proc ArgsUsage {command infoStr defaultList__} {
    upvar $defaultList__ defaultList
    puts stderr "Command: $command"
    if {$infoStr != ""} {
	puts stderr "Usage: $infoStr"
    } else {
	puts stderr "Usage: info string is UNDEFINED (you should complain)."
    }
    set max 0
    foreach d $defaultList {
	set flag [lindex $d 0]
	set len [llength $flag]
	if {$len > $max} {
	    set max $len
	}
    }
    puts stderr "Options: "
    foreach d $defaultList {
	set default [lindex $d 1]
	if {$default == ""} {
	    puts stderr [format " -%${max}s: %s (default: \"\")" [lindex $d 0] [lindex $d 4]]
	} else {
	    puts stderr [format " -%${max}s: %s (default: %s)" [lindex $d 0] [lindex $d 4] $default]
	}
    }
    PrintStackTrace ""
}

proc ArgsUsageWithDashArgs {command infoStr defaultList__} {
    upvar $defaultList__ defaultList
    puts stderr "Command: $command"
    if {$infoStr != ""} {
	puts stderr "Usage: $infoStr"
    } else {
	puts stderr "Usage: info string is UNDEFINED (you should complain)."
    }
    set max 0
    foreach d $defaultList {
	set flag [lindex $d 0]
	set len [llength $flag]
	if {$len > $max} {
	    set max $len
	}
    }
    puts stderr "Options: "
    foreach d $defaultList {
	set default [lindex $d 1]
	if {$default == ""} {
	    puts stderr [format " -%${max}s: %s (default: \"\")" [lindex $d 0] [lindex $d 2]]
	} else {
	    puts stderr [format " -%${max}s: %s (default: %s)" [lindex $d 0] [lindex $d 2] $default]
	}
    }
    PrintStackTrace ""
}

proc ArgsPrint {theArray__} {
    upvar $theArray__ theArray
    set rlist ""
    foreach n [array names theArray] {
	if {$rlist == ""} {
	    set rlist "($n:$theArray($n))" 
	} else {
	    set rlist "$rlist ($n:$theArray($n))" 
	}
    }
    return $rlist
}


proc ArgsProcessWithDashArgs {command defaultList__ argList__ resultArray__ infoStr} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	if {$val == ""} {
	    set resultArray($name) {}
	} else {
	    set resultArray($name) $val
	}
    }

    # look for (-name value) pairs
    set namesearch 1
    foreach a $argList {
	if {$namesearch == 1} {
	    set f [string index $a 0]
	    if {$f != "-"} {
		puts stderr "Arg parse error: looking for a flag (like -foo), got a non-flag ($a).\n"
		ArgsUsageWithDashArgs $command $infoStr defaultList
	    }
	    set name [string range $a 1 end]
	    if {[info exists resultArray($name)] == 0} {
		puts stderr "Invalid flag: '${name}'.\n"
		ArgsUsageWithDashArgs $command $infoStr defaultList
	    }
	} else {
	    set val $a
	    if {[array names resultArray $name] == ""} {
		puts stderr "Invalid argument: '-$name' is not an option.\n"
		ArgsUsageWithDashArgs $command $infoStr defaultList
	    }
	    set resultArray($name) $val
	}
	set namesearch [expr 1 - $namesearch]
    }
}

#
# these routines are used with type checked args processing
#

proc isNull {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    return 1
}

proc isFile {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    return [file exists $value]
}


proc isFormatString {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    # XXX
    return 1
}

proc isFunction {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    # XXX: should be defined on xrange, oh well
    # set x 1
    # puts stderr "In $command"
    return 1
}

proc isFillStyle {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [psFillStyleValid $value styles] {
	return 1
    } else {
	puts stderr "In $command: Bad fill style '$value' passed to -$index.\n   (should be one of '$styles')\n"
    }
}

proc isPointStyle {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [psPointStyleValid $value styles] {
	return 1
    } else {
	puts stderr "In $command: Bad point style '$value' passed to -$index.\n   (should be one of '$styles')\n"
    }
}

proc isFont {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if {[psFontValid $value] == 1} {
	return 1
    } else {
	puts stderr "In $command: Bad font '$value' passed to -$index.\n"
	return 0
    }
}

proc isTextAnchor {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    set s [split $value ","]
    if {[llength $s] == 1} {
	set xanchor $s
	set yanchor "l"
    } elseif {[llength $s] == 2} {
	set xanchor [lindex $s 0]
	set yanchor [lindex $s 1]
    } else {
	puts stderr "In $command: Bad text anchor '$value' passed to -$index.   Should take the form 'xanchor' or 'xanchor,yanchor', where xanchor can be 'c, l, or r' (center, left, or right) and yanchor can be 'c, l, or h' (center, low, or high).\n"
	return 0
    }

    if {[lsearch -exact "c l r" $xanchor] < 0} {
	puts stderr "In $command: Bad text anchor '$value' passed to -$index.\n   xanchor is '$xanchor' (should be c (center), l (left), or r (right))"
    }
    if {[lsearch -exact "c l h" $yanchor] < 0} {
	puts stderr "In $command: Bad text anchor '$value' passed to -$index.\n   yanchor is '$yanchor' (should be c (center), l (low), or h (high))"
    }

    # puts stderr "In $command: Bad text anchor '$value' passed to -$index.\n"
    return 1
}

proc isBoolean {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    set v [string tolower $value]
    switch -exact $v {
	t     {return 1}
	true  {return 1}
	f     {return 1}
	false {return 1}
    }
    puts stderr "In $command: -$index should be a boolean (but instead is '$value').\n"
    return 0
}

proc isDrawable {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [drawableExists $value] {
	return 1
    } else {
	puts stderr "In $command: -$index passed a bad value ($value).\n   (drawable does not exist)\n"
	return 0
    }
}

proc isString {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [StringEqual $arg "-"] {
	return 1
    } elseif [string is integer $arg] {
	set count [ArgsParseCommaList $value tmp]
	if {$count != $arg} {
	    puts stderr "In $command: -$index was passed a bad value ($value)\n   (must be a comma-separated list of strings with $arg elements)\n"
	    return 0
	}
	for {set i 0} {$i < $count} {incr i} {
	    set resultArray($index,$i) $tmp($i)
	}
    } else {
	PrintStackTrace "INTERNAL ERROR: isString has been passed arg '$arg'\n"
    }
    return 1
}

proc isNumeric {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [StringEqual $arg "-"] {
	# this means it is a number list, of arbitrary length
	set count [ArgsParseCommaList $value tmp]
	if {$count < 1} {
	    puts stderr "In $command: Poorly formed number list for -$index (value $value).\n   (must be a comma-separated list of numbers)\n"
	    return 0
	}
	for {set i 0} {$i < $count} {incr i} {
	    if {[string is double $tmp($i)] == 0} {
		puts stderr "In $command: Poorly formed number list for -$index (value $value).\n   (must be a comma-separated list of numbers; '$tmp($i)' is not a number)\n"
		return 0
	    }
	    set resultArray($index,$i) $tmp($i)
	}
    } elseif [string is integer $arg] {
	if {$arg == 1} {
	    if [string is double $value] {
		return 1
	    } else {
		puts stderr "In $command: Expecting a single number for -$index.\n   (got '$value' instead)\n"
		return 0
	    }
	} elseif {$arg > 1} {
	    set count [ArgsParseCommaList $value tmp]
	    if {$arg != $count} {
		puts stderr "In $command: Number list not right length for -$index (value $value).\n   (should be a comma-separated list of length $arg)\n"
		return 0
	    }
	    for {set i 0} {$i < $count} {incr i} {
		if {[string is double $tmp($i)] == 0} {
		    puts stderr "In $command: Poorly formed number list for -$index (value $value).\n   (must be a comma-separated list of $arg numbers; '$tmp($i)' is not a number)\n"
		    return 0
		}
		set resultArray($index,$i) $tmp($i)
	    }
	} else {
	    PrintStackTrace "INTERNAL ERROR: isNumeric has been passed arg '$arg'"
	}
    } else {
	PrintStackTrace "INTERNAL ERROR: isNumeric has been passed arg '$arg'"
    }
    return 1
}

proc isColor {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [psColorValid $value] {
	return 1
    } else {
	puts stderr "In $command: Bad color '$value' passed to -$index.\n   (call \[PsColors] for the full list)\n"
	return 0
    }
}

proc isTable {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    if [tableExists $value] {
	return 1
    } else {
	puts stderr "In $command: Bad table '$value' passed to -$index.\n   (Table does not exist)\n"
	return 0
    }
}

proc isTableField {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    set table $resultArray($arg)

    if {[tableExists $table] == 0} {
	puts stderr "In $command: Table '$table' does not exist.\n"
	return 0
    }

    if [tableFieldExists $table $value] {
	return 1
    } else {
	puts stderr "In $command: table '$table' has no field '$value'.\n   (must be one of '[tableListFields $table]').\n"
	return 0
    }
}

proc isMember {command arg resultArray__ index} {
    upvar $resultArray__ resultArray
    set value $resultArray($index)
    set count [ArgsParseCommaList $arg tmp]
    for {set i 0} {$i < $count} {incr i} {
	if [StringEqual $value $tmp($i)] {
	    return 1
	}
    }
    puts stderr "In $command: Setting '-$index' to value '$value' is not valid.\n   (must be one of these: $arg).\n"
    return 0
}

proc ArgsProcessWithTypeChecking {command defaultList__ argList__ resultArray__ precondFunc infoStr} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    # set defaults first
    set namelist ""
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	set must [lindex $d 2]
	set func [lindex $d 3]

	if {$val == ""} {
	    set resultArray($name) {}
	} else {
	    set resultArray($name) $val
	}

	set funcArray($name,func) $func
	set funcArray($name,must) $must

	if {$namelist == ""} {
	    set namelist $name
	} else {
	    set namelist "$namelist $name"
	}
    }

    # look for (-name value) pairs, and set resultArray(name) to value
    set namesearch 1
    foreach a $argList {
	if {$namesearch == 1} {
	    set f [string index $a 0]
	    if {$f != "-"} {
		puts stderr "Arg parse error: looking for a flag (like '-foo'), got a non-flag ('$a').\n"
		ArgsUsage $command $infoStr defaultList
	    }
	    set name [string range $a 1 end]
	    # check validity of name RIGHT HERE
	    # puts "checking validity of $name as field"
	    if {[info exists resultArray($name)] == 0} {
		puts stderr "Invalid flag: '${name}'.\n"
		ArgsUsage $command $infoStr defaultList
	    }
	} else {
	    set val $a
	    if {[array names resultArray $name] == ""} {
		puts stderr "Invalid argument: '-$name' is not an option.\n"
		ArgsUsage $command $infoStr defaultList
	    }
	    set resultArray($name) $val
	}
	set namesearch [expr 1 - $namesearch]
    }

    # now do preconditions
    if {$precondFunc != ""} {
	if {[$precondFunc] == 0} {
	    ArgsUsage $command $infoStr defaultList
	}
    }

    # now do type checking
    foreach n $namelist {
	set func [lindex $funcArray($n,func) 0]
	set arg  [lindex $funcArray($n,func) 1]
	set must $funcArray($n,must)
	if {([StringEqual $must "-"]) && ($resultArray($n) == "")} {
	    # empty argument is OK here
	    # do nothing
	} else {
	    if {[$func $command $arg resultArray $n] == 0} {
		puts "failed when calling $func ($arg $resultArray($n))"
		ArgsUsage $command $infoStr defaultList
	    }
	}
    }
}

# 
# what can a numList look like?
#   x,y:x2,y2
#   x,y:x2 ,y2
#   x, y : x2  ,  y2
# 
# but NOT
#   x y : x2 y2
#   x y x2 y2
#   x y x2 y2 x3,y3
# 
proc ArgsParseItemPairList {numList resultArray__} {
    upvar $resultArray__ resultArray
    set resultCount 0
    set s [split $numList ":"]
    foreach e $s {
	set trimmed [string trim $e]                  ;# remove extra whitespace
	set tmp     [split $trimmed ","]
	if {[llength $tmp] == 2} {
	    set x [string trim [lindex $tmp 0]]
	    set y [string trim [lindex $tmp 1]]
	} else {
	    Abort "poorly formed number list: ($numList)"
	}
	set resultArray($resultCount,n1) $x
	set resultArray($resultCount,n2) $y
	incr resultCount
    }
    # puts "$numList --> "
    # printList resultArray resultCount
    return $resultCount
}

# used to be ArgsParseNumbers
proc ArgsParseCommaList {ilist resultArray__} {
    upvar $resultArray__ resultArray
    # use this one to accept both comma-separated and whitespace-separated lists
    # set tmp [split [string map {"," " "} [string trim $ilist]] " "]
    # use this next one if only comma-separated lists are allowed
    set tmp [split $ilist ","]
    set len [llength $tmp]
    for {set i 0} {$i < $len} {incr i} {
	set resultArray($i) [string trim [lindex $tmp $i]]
    }
    return $len
}


proc ArgsSwitchProcess {slist dkey returnVal__} {
    upvar $returnVal__ returnVal
    for {set i 0} {$i < [llength $slist]} {incr i} {
	set elem [lindex $slist $i]
	set keyList [lindex $elem 0]
	# search entire list of keys for key to match
	if {[lsearch -exact $keyList $dkey] > -1} {
	    set result [lindex $elem 1]
	    set returnVal [string trim $result]
	    return 1
	}
    }
    return 0
}

proc ArgsSwitchUsage {slist dkey} {
    puts stderr "  Bad key: '$dkey'"
    puts -nonewline stderr "  Valid options: "
    for {set i 0} {$i < [llength $slist]} {incr i} {
	set elem [lindex $slist $i]
	set keyList [lindex $elem 0]
	foreach k $keyList {
	    puts -nonewline stderr "$k "
	}
    }
    puts stderr ""
    exit 1
}

