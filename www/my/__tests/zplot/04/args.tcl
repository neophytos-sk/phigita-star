# tcl

proc ArgsUsage {command infoStr defaultList__} {
    upvar $defaultList__ defaultList
    puts stderr "$infoStr"
    puts stderr "usage: $command"
    foreach d $defaultList {
	set default [lindex $d 1]
	if {$default == ""} {
	    puts stderr [format " %15s %60s (default: \"\")" -[lindex $d 0] [lindex $d 2]]
	} else {
	    puts stderr [format " %15s %60s (default: %s)" -[lindex $d 0] [lindex $d 2] $default]
	}
    }
    exit 1
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

proc ArgsProcess {command defaultList__ argList__ resultArray__} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    puts "% DEBUG $command $argList"

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	# puts "% DEBUG defaults: setting resultArray($name) to $val"
	set resultArray($name) $val
    }

    foreach a $argList {
	# puts "% DEBUG arg: ($a)"
	set name  [lindex $a 0]
	set val   [lrange $a 1 end]
	if {[array names resultArray $name] == ""} {
	    puts stderr "bad name of an argument: ($name) ($val)"
	    ArgsUsage $command "" $defaultList
	}
	# puts "% DEBUG overrides: setting resultArray($name) to $val"
	set resultArray($name) $val
    }
}

proc ArgsProcess2 {command defaultList__ argList__ resultArray__} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    puts "% DEBUG $command $argList"

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	set resultArray($name) $val
    }

    foreach a $argList {
	set s [split $a ":"]
	set name  [lindex $s 0]
	set val   [lrange $s 1 end]
	if {[array names resultArray $name] == ""} {
	    puts stderr "bad name of an argument: (name:$name) (value:$val)"
	    ArgsUsage $command "" $defaultList
	}
	set resultArray($name) $val
    }
}

proc ArgsProcessWithDashArgs {command defaultList__ argList__ resultArray__ infoStr} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    # puts "% DEBUG $command $argList"

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	set resultArray($name) $val
    }

    # look for (-name value) pairs
    set namesearch 1
    foreach a $argList {
	if {$namesearch == 1} {
	    set f [string index $a 0]
	    if {$f != "-"} {
		puts stderr "arg parse error: looking for -name, got $a"
		exit 1
	    }
	    set name [string range $a 1 end]
	} else {
	    set val $a
	    if {[array names resultArray $name] == ""} {
		puts stderr "bad name of an argument: $name"
		ArgsUsage $command $infoStr defaultList
	    }
	    set resultArray($name) $val
	}
	set namesearch [expr 1 - $namesearch]
    }
}

# 
# what can a numList look like?
#   x,y:x2,y2
#   x, y : x2,y2
#   x y : x2 y2
# 
# but NOT
#   x y x2 y2
#   x y x2 y2 x3,y3
# 
proc ArgsParseNumbersList {numList resultArray__} {
    upvar $resultArray__ resultArray
    set resultCount 0
    set s [split $numList ":"]
    foreach e $s {
	set trimmed [string trim $e]                  ;# remove extra whitespace
	set mapped  [string map {"," " "} $trimmed]   ;# turn commas into whitespace
        set regsubd [regsub -all { +} $mapped " "]    ;# remove resulting extra whitespace
        set tmp     [split $regsubd " "]              ;# split into a list and ...
	if {[llength $tmp] == 2} {
	    set x [string trim [lindex $tmp 0]]
	    set y [string trim [lindex $tmp 1]]
	} else {
	    puts stderr "poorly formed number list: ($numList)"
	    return -1
	}
	set resultArray($resultCount,n1) $x
	set resultArray($resultCount,n2) $y
	incr resultCount
    }
    # puts "$numList --> "
    # printList resultArray resultCount
    return $resultCount
}

proc ArgsParseNumbers {numbers resultArray__} {
    upvar $resultArray__ resultArray
    # puts stderr "Parsing: $numbers" 
    set tmp [split [string map {"," " "} [string trim $numbers]] " "]
    set len [llength $tmp]
    for {set i 0} {$i < $len} {incr i} {
	set resultArray($i) [lindex $tmp $i]
    }
    return $len
}

proc ArgsSwitch {slist dkey abortMsg} {
    for {set i 0} {$i < [llength $slist]} {incr i} {
	set elem [lindex $slist $i]
	set keyList [lindex $elem 0]
	# search entire list of keys for key to match
	if {[lsearch -exact $keyList $dkey] > -1} {
	    set result [lindex $elem 1]
	    return $result
	}
    }

    puts stderr $abortMsg
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

proc printList {r__ c__} {
    upvar $r__ r
    upvar $c__ c
    
    for {set i 0} {$i < $c} {incr i} {
	puts "  $i : $r(x,$i) $r(y,$i)"
    }
}

proc test {} {
    set count [ArgsParseNumbersList "1,2" result]
    set count [ArgsParseNumbersList "1,2:3,4:5,6" result]
    set count [ArgsParseNumbersList "3,4:5,6 : 7,8" result]
    set count [ArgsParseNumbersList "7,8 : 9,10" result ]
    set count [ArgsParseNumbersList "7 8 : 9 10" result ]
    set count [ArgsParseNumbersList "7 8 : 9,10,11" result]
    set count [ArgsParseNumbersList "7 8 : 9 10 11" result]
}

# to test, uncomment the following, and type 'tclsh zargs.tcl'
# also, uncomment "exit 1" above
# test


