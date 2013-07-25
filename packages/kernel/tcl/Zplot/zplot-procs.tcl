# tcl

namespace eval Zplot {
    # 
    # all the source files for zplot are included here
    # 


    # begin including util.tcl
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
        #exit 1
	rp_returnerror
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
    
        #exit 1
	rp_returnerror
    }
    
    
    
    
    
    
    # end including util.tcl

    # begin including args.tcl
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
        #exit 1
	rp_returnerror
    }
    
    # end including args.tcl

    # begin including ps.tcl
    #! /usr/bin/tclsh
    
    # namespace relevant
    variable _ps
    #HERE: set _ps(__dummy__) ""
    
    # expect things of this form:
    #   X in  -> X inches
    #   Xin   -> X inches
    #   X i   -> X inches
    #   Xi    -> X inches
    #   X pts -> X points
    #   Xpts -> X points
    #   X p  -> X points
    #   Xp   -> X points
    #   X    -> X points
    # NOTE: X can have a decimal value
    proc psParsePoints {value numeric__ units__} {
        upvar $numeric__ numeric
        upvar $units__   units
        # should be of form number,...,number,letter,...,letter
        set value [string trim $value]
        set numbers 1
        set endOfNum [string length $value]
        for {set i 0} {$i < [string length $value]} {incr i} {
    	set c [string index $value $i]
    	if {([string is integer $c] == 0) && ([string compare $c "-"] != 0) && ([string compare $c "."] != 0)} {
    	    set endOfNum $i
    	    break
    	}
        }
        set numeric [string range $value 0 [expr $endOfNum-1]]
        set units   [string trim [string range $value $endOfNum end]]
    }
    
    proc psConvertToPoints {value} {
        psParsePoints $value result units
        if {[StringEqual $units "i"] || [StringEqual $units "in"] || [StringEqual $units "inches"]} {
    	set value [expr $result * 72.0]
        } else {
    	set value $result
        }
        return $value
    }
      
    # 
    # this is a complete hack, and can be very wrong depending on the fontface
    # (which it should clearly be dependent upon)
    # the problem, of course: only the ps interpreter really knows
    # how wide the string is: e.g., put the string on the stack and call 'stringwidth'
    # but of course, we don't want to have to invoke that to get the result (a pain)
    # we could build in a table that has all the answers for supported fonts (Helvetica, TimesRoman, etc.)
    # but that is a complete pain as well
    # so, for now, we just make a rough guess based on the length of the string and the size of the font
    # 
    
    proc psGetStringWidth {str fontsize} {
        variable _ps
    
        set len [string length $str]
        set sum 0.0
        for {set i 0} {$i < $len} {incr i} {
    	set c [string index $str $i]
    	if [string match {[A-HJ-Z234567890]} $c] {
    	    set add 0.69
    	} elseif [string match {[abcdeghkmnopqrsuvwxyz1I]} $c] {
    	    set add 0.54
    	} elseif [string match {[.fijlt]} $c] {
    	    set add 0.3
    	} elseif {[string compare $c "-"] == 0} {
    	    set add 0.3
    	} else {
    	    # be conservative for all others
    	    set add 0.65
    	}
    	# puts "s:$c --> $add"
    	set sum [expr $sum + $add]
        }
        return [expr $fontsize * $sum]
    
        # DEAD CODE
        if {[info exists _ps(guess)] == 0} {
    	set _ps(guess) 0.50
        } else {
    	set _ps(guess) [expr $_ps(guess) + 0.02]
        }
        puts "guess: $_ps(guess)"
        return [expr $len * ($fontsize * $_ps(guess))]
    }
    
    proc psFontValid {font} {
        variable _ps
        if {[lsearch -exact $_ps(allfonts) $font] == -1} {
    	return 0
        }
        return 1
    }
    
    proc psAddfont {font} {
        variable _ps
        # make sure fonts are legal
        if {[lsearch -exact $_ps(allfonts) $font] == -1} {
    	Abort "bad font: $font"
        }
    
        # add to font list
        if {[lsearch -exact $_ps(fontlist) $font] == -1} {
    	set _ps(fontlist) [list $_ps(fontlist) $font]
        }
    }
    
    proc psColor {c} {
        if {[string compare [string index $c 0] "%"] == 0} {
    	# this is a raw color, of the form: %r,g,b
    	# where r,g,b are each between 0 and 1 and can be decimal
    	return [split [lindex [split $c %] 1] ","]
        }
        variable _ps
        if {[ArgsSwitchProcess $_ps(colors) $c color] == 0} {
    	puts stderr "Color '$c' is not a valid color"
    	ArgsSwitchUsage $_ps(colors) $c
        } 
        return $color
    }
    
    proc psColorValid {c} {
        variable _ps
        return [ArgsSwitchProcess $_ps(colors) $c color]
    }
    
    proc psLast {type value} {
        return 0 ;# XXX NOT IN USE, DOES NOT WORK RIGHT NOW
        variable _last
        if {[info exists _last($type)] == 0} {
    	# doesn't exist, so init it and return 0
    	set _last($type) $value 
    	return 0
        }
        # exists: does it match?
        if {[StringEq $_last($type) $value]} {
    	return 1
        } 
        set _last($type) $value
        return 0
    }
    
    # 
    # postscript commands
    # 
    
    proc psComment {str} {
        variable _ps
        # set _ps(comment) 1
        if {[info exists _ps(comment)]} {
    	if {$_ps(comment) == 1} {
    	    psPuts "% $str"
    	}
        }
    }
    
    proc psSetcolor {c} {
        AssertEqual [llength $c] 3
        AssertIsNumber [lindex $c 0]
        AssertIsNumber [lindex $c 1]
        AssertIsNumber [lindex $c 2]
        
        # setrgbcolor
        psPuts "$c sc"
    }
    
    proc psSetlinewidth {lw} {
        AssertIsNumber $lw
        psPuts "$lw slw"
    }
    
    proc psSetlinecap {lc} {
        AssertIsNumber $lc
        psPuts "$lc slc"
    }
    
    proc psSetlinejoin {lj} {
        AssertIsNumber $lj
        psPuts "$lj slj"
    }
    
    # expects a list that describes the dash pattern
    proc psSetdash {d} {
        set n [ArgsParseCommaList $d dashes]
        AssertIsNumber $dashes(0)
        set dashList $dashes(0)
        for {set i 1} {$i < $n} {incr i} {
    	AssertIsNumber $dashes($i)
    	set dashList "$dashList $dashes($i)"
        }
        # should probably allow people to set the offset (currently 0)
        psPuts "\[$dashList\] 0 sd"
    }
    
    proc psMoveto {x y} {
        AssertIsNumber $x
        AssertIsNumber $y
        psPuts "[format %.2f $x] [format %.2f $y] m"
    }
    
    proc psRmoveto {x y} {
        AssertIsNumber $x
        AssertIsNumber $y
        psPuts "[format %.2f $x] [format %.2f $y] mr"
    }
    
    proc psLineto {x y} {
        AssertIsNumber $x
        AssertIsNumber $y
        psPuts "[format %.2f $x] [format %.2f $y] l"
    }
    
    proc psRlineto {x y} {
        AssertIsNumber $x
        AssertIsNumber $y
        psPuts "[format %.2f $x] [format %.2f $y] lr"
    }
    
    proc psNewpath {} {
        psPuts "np"
    }
    
    proc psClosepath {} {
        psPuts "cp"
    }
    
    proc psFill {} {
        psPuts "fl"
    }
    
    proc psStroke {} {
        psPuts "st"
    }
    
    proc psGsave {} {
        psPuts "gs"
        variable _ps
        incr _ps(gsaveCnt)
    }
    
    proc psGrestore {} {
        psPuts "gr"
        variable _ps
        incr _ps(grestoreCnt)
    }
    
    proc psArc {x y r ba ea} {
        AssertIsNumber $x
        AssertIsNumber $y
        AssertIsNumber $r
        AssertIsNumber $ba
        AssertIsNumber $ea
        # xxx could be more sophisticated here
        psPuts "$x $y $r $ba $ea arc"
    }
    
    proc psClip {} {
        psPuts "clip"
    }
    
    proc psRotate {angle} {
        AssertIsNumber $angle
        psPuts "$angle rotate"
    }
    
    proc psSetfont {face size} {
        # could check fonts here, but already do elsewhere
        AssertIsNumber $size
        psPuts "($face) findfont $size scalefont setfont"
    }
    
    proc psShow {text anchor} {
        switch -exact $anchor {
    	"c" { psPuts "($text) cshow" }
    	"l" { psPuts "($text) lshow" }
    	"r" { psPuts "($text) rshow" }
    	default { Abort "bad anchor: $anchor" }
        }
    }
    
    # could just use built in rectangle command in postscript
    proc psRectangle {x1 y1 x2 y2} {
        AssertIsNumber $x1
        AssertIsNumber $x2
        AssertIsNumber $y1
        AssertIsNumber $y2
        psMoveto $x1 $y1
        psLineto $x1 $y2
        psLineto $x2 $y2
        psLineto $x2 $y1 
    }
    
    # 
    # high-level postscript commands
    # 
    proc psCanvasDefined {} {
        variable _ps
        return $_ps(defined)
    }
    
    proc psCanvasWidth {} {
        variable _ps
        return $_ps(width)
    }
    
    proc psCanvasHeight {} {
        variable _ps
        return $_ps(height)
    }
    
    #
    # EXPORTED FUNCTIONS
    #
    
    proc psInit {program version} {
        variable _ps
    
        if {[info exists _ps(init)]} {
    	return
        }
        set _ps(init)     1
    
        # generic program info
        set _ps(program)  $program
        set _ps(version)  $version
    
        # date
        set _ps(date)     [clock format [clock seconds]]
    
        # about this document
        # set _ps(defined)  0
    
        # set legal fonts
        set _ps(fontlist) "Helvetica"
        set _ps(allfonts) "Helvetica Helvetica-Bold Helvetica-Italic TimesRoman TimesRoman-Bold TimesRoman-Italic Courier Courier-Bold Courier-Italic"
    
        set _ps(gsaveCnt)    0
        set _ps(grestoreCnt) 0
    
        set _ps(colors) {
            { {            aliceblue } { 0.94 0.97 1.00 } }
            { {         antiquewhite } { 0.98 0.92 0.84 } }
            { {                 aqua } { 0.00 1.00 1.00 } }
            { {           aquamarine } { 0.50 1.00 0.83 } }
            { {                azure } { 0.94 1.00 1.00 } }
            { {                beige } { 0.96 0.96 0.86 } }
            { {               bisque } { 1.00 0.89 0.77 } }
            { {                black } { 0.00 0.00 0.00 } }
            { {       blanchedalmond } { 1.00 0.92 0.80 } }
            { {                 blue } { 0.00 0.00 1.00 } }
            { {           blueviolet } { 0.54 0.17 0.89 } }
            { {                brown } { 0.65 0.16 0.16 } }
            { {            burlywood } { 0.87 0.72 0.53 } }
            { {            cadetblue } { 0.37 0.62 0.63 } }
            { {           chartreuse } { 0.50 1.00 0.00 } }
            { {            chocolate } { 0.82 0.41 0.12 } }
            { {                coral } { 1.00 0.50 0.31 } }
            { {       cornflowerblue } { 0.39 0.58 0.93 } }
            { {             cornsilk } { 1.00 0.97 0.86 } }
            { {              crimson } { 0.86 0.08 0.24 } }
            { {                 cyan } { 0.00 1.00 1.00 } }
            { {             darkblue } { 0.00 0.00 0.55 } }
            { {             darkcyan } { 0.00 0.55 0.55 } }
            { {        darkgoldenrod } { 0.72 0.53 0.04 } }
            { {             darkgray } { 0.66 0.66 0.66 } }
            { {            darkgreen } { 0.00 0.39 0.00 } }
            { {            darkkhaki } { 0.74 0.72 0.42 } }
            { {          darkmagenta } { 0.55 0.00 0.55 } }
            { {       darkolivegreen } { 0.33 0.42 0.18 } }
            { {           darkorange } { 1.00 0.55 0.00 } }
            { {           darkorchid } { 0.60 0.20 0.80 } }
            { {              darkred } { 0.55 0.00 0.00 } }
            { {           darksalmon } { 0.91 0.59 0.48 } }
            { {         darkseagreen } { 0.55 0.74 0.56 } }
            { {        darkslateblue } { 0.28 0.24 0.55 } }
            { {        darkslategray } { 0.18 0.31 0.31 } }
            { {        darkturquoise } { 0.00 0.87 0.82 } }
            { {           darkviolet } { 0.58 0.00 0.83 } }
            { {             deeppink } { 1.00 0.08 0.58 } }
            { {          deepskyblue } { 0.00 0.75 1.00 } }
            { {              dimgray } { 0.41 0.41 0.41 } }
            { {           dodgerblue } { 0.12 0.56 1.00 } }
            { {            firebrick } { 0.70 0.13 0.13 } }
            { {          floralwhite } { 1.00 0.98 0.94 } }
            { {          forestgreen } { 0.13 0.55 0.13 } }
            { {              fuchsia } { 1.00 0.00 1.00 } }
            { {            gainsboro } { 0.86 0.86 0.86 } }
            { {           ghostwhite } { 0.97 0.97 1.00 } }
            { {                 gold } { 1.00 0.84 0.00 } }
            { {            goldenrod } { 0.85 0.65 0.13 } }
            { {                 gray } { 0.50 0.50 0.50 } }
            { {                green } { 0.00 0.50 0.00 } }
            { {          greenyellow } { 0.68 1.00 0.18 } }
            { {             honeydew } { 0.94 1.00 0.94 } }
            { {              hotpink } { 1.00 0.41 0.71 } }
            { {            indianred } { 0.80 0.36 0.36 } }
            { {               indigo } { 0.29 0.00 0.51 } }
            { {                ivory } { 1.00 1.00 0.94 } }
            { {                khaki } { 0.94 0.90 0.55 } }
            { {             lavender } { 0.90 0.90 0.98 } }
            { {        lavenderblush } { 1.00 0.94 0.96 } }
            { {            lawngreen } { 0.49 0.99 0.00 } }
            { {         lemonchiffon } { 1.00 0.98 0.80 } }
            { {            lightblue } { 0.68 0.85 0.90 } }
            { {           lightcoral } { 0.94 0.50 0.50 } }
            { {            lightcyan } { 0.88 1.00 1.00 } }
            { { lightgoldenrodyellow } { 0.98 0.98 0.82 } }
            { {           lightgreen } { 0.56 0.93 0.56 } }
            { {            lightgrey } { 0.83 0.83 0.83 } }
            { {            lightpink } { 1.00 0.71 0.76 } }
            { {          lightsalmon } { 1.00 0.63 0.48 } }
            { {        lightseagreen } { 0.13 0.70 0.67 } }
            { {         lightskyblue } { 0.53 0.81 0.98 } }
            { { lightslategray lightgray } { 0.47 0.53 0.60 } }
            { {       lightsteelblue } { 0.69 0.77 0.87 } }
            { {          lightyellow } { 1.00 1.00 0.88 } }
            { {                 lime } { 0.00 1.00 0.00 } }
            { {            limegreen } { 0.20 0.80 0.20 } }
            { {                linen } { 0.98 0.94 0.90 } }
            { {              magenta } { 1.00 0.00 1.00 } }
            { {               maroon } { 0.50 0.00 0.00 } }
            { {     mediumaquamarine } { 0.40 0.80 0.67 } }
            { {           mediumblue } { 0.00 0.00 0.80 } }
            { {         mediumorchid } { 0.73 0.33 0.83 } }
            { {         mediumpurple } { 0.58 0.44 0.86 } }
            { {       mediumseagreen } { 0.24 0.70 0.44 } }
            { {      mediumslateblue } { 0.48 0.41 0.93 } }
            { {    mediumspringgreen } { 0.00 0.98 0.60 } }
            { {      mediumturquoise } { 0.28 0.82 0.80 } }
            { {      mediumvioletred } { 0.78 0.08 0.52 } }
            { {         midnightblue } { 0.10 0.10 0.44 } }
            { {            mintcream } { 0.96 1.00 0.98 } }
            { {            mistyrose } { 1.00 0.89 0.88 } }
            { {             moccasin } { 1.00 0.89 0.71 } }
            { {          navajowhite } { 1.00 0.87 0.68 } }
            { {                 navy } { 0.00 0.00 0.50 } }
            { {              oldlace } { 0.99 0.96 0.90 } }
            { {            olivedrab } { 0.42 0.56 0.14 } }
            { {               orange } { 1.00 0.65 0.00 } }
            { {            orangered } { 1.00 0.27 0.00 } }
            { {               orchid } { 0.85 0.44 0.84 } }
            { {        palegoldenrod } { 0.93 0.91 0.67 } }
            { {            palegreen } { 0.60 0.98 0.60 } }
            { {        paleturquoise } { 0.69 0.93 0.93 } }
            { {        palevioletred } { 0.86 0.44 0.58 } }
            { {           papayawhip } { 1.00 0.94 0.84 } }
            { {            peachpuff } { 1.00 0.85 0.73 } }
            { {                 peru } { 0.80 0.52 0.25 } }
            { {                 pink } { 1.00 0.78 0.80 } }
            { {                 plum } { 0.87 0.63 0.87 } }
            { {           powderblue } { 0.69 0.88 0.90 } }
            { {               purple } { 0.50 0.00 0.50 } }
            { {                  red } { 1.00 0.00 0.00 } }
            { {            rosybrown } { 0.74 0.56 0.56 } }
            { {            royalblue } { 0.25 0.41 0.88 } }
            { {          saddlebrown } { 0.55 0.27 0.07 } }
            { {               salmon } { 0.98 0.50 0.45 } }
            { {           sandybrown } { 0.96 0.64 0.38 } }
            { {             seagreen } { 0.18 0.55 0.34 } }
            { {             seashell } { 1.00 0.96 0.93 } }
            { {               sienna } { 0.63 0.32 0.18 } }
            { {               silver } { 0.75 0.75 0.75 } }
            { {              skyblue } { 0.53 0.81 0.92 } }
            { {            slateblue } { 0.42 0.35 0.80 } }
            { {                 snow } { 1.00 0.98 0.98 } }
            { {          springgreen } { 0.00 1.00 0.50 } }
            { {            steelblue } { 0.27 0.51 0.71 } }
            { {                  tan } { 0.82 0.71 0.55 } }
            { {                 teal } { 0.00 0.50 0.50 } }
            { {              thistle } { 0.85 0.75 0.85 } }
            { {               tomato } { 1.00 0.39 0.28 } }
            { {            turquoise } { 0.25 0.88 0.82 } }
            { {               violet } { 0.93 0.51 0.93 } }
            { {                wheat } { 0.96 0.87 0.70 } }
            { {                white } { 1.00 1.00 1.00 } }
            { {           whitesmoke } { 0.96 0.96 0.96 } }
            { {               yellow } { 1.00 1.00 0.00 } }
            { {          yellowgreen } { 0.60 0.80 0.20 } }
        }
    }
    
    proc PsColors {} {
        variable _ps
        psInit "" ""
        set colorlist ""
        foreach entry $_ps(colors) {
    	set color [lindex [lindex $entry 0] 0]
    	if {$colorlist == ""} {
    	    set colorlist $color 
    	} else {
    	    set colorlist "$colorlist $color"
    	}
        }
        return $colorlist
    }
    
    # probably shouldn't use this a lot
    proc PsRaw {args} {
        set default {
    	{"raw"     ""      "raw postscript string to add into the output; DO NOT USE UNLESS A SUPER PRO"}
        }
        ArgsProcessWithDashArgs PsRaw default args use \
    	"Use this to add raw postscript into your output."
        psComment "PsRaw:: [ArgsPrint use]"
        if {$use(raw) != ""} {
    	psPuts $use(raw)
        }
    }
    
    
    proc psCanvasPrecondition {} {
        variable _ps
        # can only make one canvas, alas
        if [info exists _ps(defined)] {
    	puts stderr "In PsCanvas: Can only call PsCanvas once (right now) -- sorry!\n"
    	return 0
        }
        return 1
    }
    
    proc PsCanvas {args} {
        set default {
    	{"title"      "default.eps" + "isString 1"        "name of eps file"}
    	{"dimensions" ","           + "isString 2"        "width,height of drawing canvas"}
    	{"width"      "300"         + "isString 1"        "width of drawing canvas; in inches (e.g., '7in' or '7i') or points (e.g., '7pts' or '7p' or '7')"}
    	{"height"     "240"         + "isString 1"        "height of drawing canvas"}
        }
        ArgsProcessWithTypeChecking PsCanvas default args use psCanvasPrecondition \
    	    "Use this routine to define the canvas"
    
        # init variables
        psInit zplot 1.0
    
        # which units?
        set w [psConvertToPoints $use(width)]
        set h [psConvertToPoints $use(height)]
    
        # dimensions (newer argument) takes precedence
        if {$use(dimensions,0) != ""} {
    	set w [psConvertToPoints $use(dimensions,0)]
        } 
        if {$use(dimensions,1) != ""} {
    	set h [psConvertToPoints $use(dimensions,1)]
        }
    
        variable _ps
        set _ps(defined)   1
        set _ps(width)     $w
        set _ps(height)    $h
        set _ps(title)     $use(title)
        set _ps(firstLine) "%!PS-Adobe-2.0 EPSF-2.0"
    
        # generic eps header
        psPuts $_ps(firstLine)
        psPuts "%%Title: $use(title)"
        psPuts "%%Creator: $_ps(program) version $_ps(version)"
        psPuts "%%CreationDate: $_ps(date)"
        psPuts "%%DocumentFonts: (atend)"
        psPuts "%%BoundingBox: 0 0 $w $h"
        psPuts "%%Orientation: Portrait"
        psPuts "%%EndComments"
    
        # zdraw dictionary
        psPuts "% zdraw dictionary"
        psPuts "/zdict 256 dict def"
        psPuts "zdict begin"
        psPuts "/cpx 0 def"
        psPuts "/cpy 0 def"
        psPuts "/recordcp {currentpoint /cpy exch def /cpx exch def} bind def"
        psPuts "/m {moveto} bind def"
        psPuts "/l {lineto} bind def"
        psPuts "/mr {rmoveto} bind def"
        psPuts "/lr {rlineto} bind def"
        psPuts "/np {newpath} bind def"
        psPuts "/cp {closepath} bind def"
        psPuts "/st {stroke} bind def"
        psPuts "/fl {fill} bind def"
        psPuts "/gs {gsave} bind def"
        psPuts "/gr {grestore} bind def"
        psPuts "/slw {setlinewidth} bind def"
        psPuts "/slc {setlinecap} bind def"
        psPuts "/slj {setlinejoin} bind def"
        psPuts "/sc  {setrgbcolor} bind def"
        psPuts "/sd  {setdash} bind def"
        psPuts "/triangle {pop pop pop} bind def"  ;# XXX -- not implemented (yet) -- expects x y size on stack
        psPuts "/lshow {show recordcp} def"
        psPuts "/rshow {dup stringwidth pop neg 0 mr show recordcp} def"
        psPuts "/cshow {dup stringwidth pop -2 div 0 mr show recordcp} def"
        psPuts "end"
        psPuts "zdict begin"
    
        Dputs ps "Canvas: [ArgsPrint use]"
    }
    
    proc PsCanvasInfo {args} {
        set default {
    	{"info"          ""         "pass in field you wish to get info about: width,height"}
        }
        ArgsProcessWithDashArgs PsCanvasInfo default args use \
    	"Use this to get info about the defined canvas. Current options to -info are 'width', which returns the width of the canvas in points, or 'height', which returns the height. "
        AssertEqual [psCanvasDefined] 1
        
        switch -exact $use(info) {
    	width  { return [psCanvasWidth] }
    	height { return [psCanvasHeight] }
    	default { Abort "Bad parameter to PsCanvasInfo: $use(info)" }
        }
    }
    
    proc PsRender {args} {
        set default {
    	{"file"     "stdout"     + "isString 1" "the file to print postscript to; stdout means stdout though"}
        }
        ArgsProcessWithTypeChecking PsRender default args use "" \
    	"Use this routine to print out all the postscript commands you've been queueing up to a file or 'stdout' (default)."
    
        # do some checks
        variable _ps
        if {$_ps(gsaveCnt) != $_ps(grestoreCnt)} {
    	puts stderr "INTERNAL ERROR: gsavecnt != grestorecnt (bad postscript possible)"
	    #exit 1
	    rp_returnerror
        }
    
        # generic eps trailer
        psPuts "% zdraw epilogue"
        psPuts "end"
        psPuts "showpage"
        psPuts "%%Trailer"
        psPuts "%%DocumentFonts: $_ps(fontlist)"
    
        # and now, dump it all
        if {[StringEqual $use(file) "stdout"] == 0} {
    	set fd [open $use(file) w]
    	psPutsDump $fd
    	close $fd
        } else {
    	psPutsDump stdout
        }
    }
    
    proc PsLine {args} {
        set default {
    	{"coord"          "0,0:0,0"     "x1,y1: ... :xn,yn"}
    	{"linecolor"      "black"       "color of the line"}
    	{"linewidth"      "1"           "width of the line"}
    	{"linecap"        "0"           "linecap: 0, 1, or 2 (see postscript manual for details)"}
    	{"linejoin"       "0"           "linejoin: 0, 1, or 2 (see postscript manual for details)"}
    	{"linedash"       "0"           "define dashes for the line"}
    	{"closepath"      "false"       "whether to close the path or not"}
    	{"arrow"          "false"       "add an arrowhead at end"}
    	{"arrowheadlength" "4"          "length of the arrowhead"}
    	{"arrowheadwidth" "3"           "width of the arrowhead"}
    	{"arrowlinecolor" "black"       "linecolor of the arrowhead"}
    	{"arrowlinewidth" "0.5"         "linewidth of the arrowhead"}
    	{"arrowfill"      "true"        "fill the arrowhead"}
    	{"arrowfillcolor" "black"       "the color to fill the arrowhead with"}
    	{"arrowstyle"     "normal"      "types of arrowheads: normal is only one right now"}
        }
        ArgsProcessWithDashArgs PsLine default args use \
    	"Use this to draw a line on the canvas."
        psComment "PsLine:: [ArgsPrint use]"
    
        # save the context to begin
        psGsave
    
        # first, draw the line, one component at a time
        set count [ArgsParseItemPairList $use(coord) coords]
        psNewpath
        psMoveto $coords(0,n1) $coords(0,n2) 
        for {set p 1} {$p < $count} {incr p} {
    	psLineto $coords($p,n1) $coords($p,n2) 
        }
        if [True $use(closepath)] {
    	psClosepath
        }
        if {[StringEqual $use(linecolor) "black"] == 0} {
    	psSetcolor [psColor $use(linecolor)]
        }
        if {$use(linewidth) != 1} {
    	psSetlinewidth $use(linewidth)
        }
        if {$use(linecap) != 0} {
    	psSetlinecap $use(linecap)
        }
        if {$use(linejoin) != 0} {
    	psSetlinejoin $use(linejoin)
        }
        if {$use(linedash) != 0} {
    	psSetdash $use(linedash)
        }
        psStroke
    
        # now, do the arrow 
        if [True $use(arrow)] {
    	set sx    $coords([expr $count-2],n1)
    	set sy    $coords([expr $count-2],n2)
    	set ex    $coords([expr $count-1],n1)
    	set ey    $coords([expr $count-1],n2)
    	# use the last line segment to compute the orthogonal vectors for the arrowhead
    
    	set vx    [expr ($ex-$sx)]
    	set vy    [expr ($ey-$sy)]
    	set hypot [expr hypot($vx,$vy)]
    	# get angle of last line segment
    	set angle [expr (360.0*asin($vy/$hypot))/(4.0*acos(0))]
    
    	set aw    [expr $use(arrowheadwidth)/2.0]
    	set al    $use(arrowheadlength)
    
    	for {set i 0} {$i < 2} {incr i} {
    	    psGsave
    
    	    psNewpath
    	    psMoveto $ex $ey
    	    psRotate $angle
    	    psRlineto 0 $aw
    	    psRlineto $al [expr -$aw]
    	    psRlineto [expr -$al] [expr -$aw]
    	
    	    psClosepath
    	    if {$i == 1} {
    		psSetcolor [psColor $use(arrowlinecolor)]
    		psSetlinewidth $use(arrowlinewidth)
    		psStroke
    	    } else {
    		psSetcolor [psColor $use(arrowfillcolor)]
    		psFill
    	    }
    	    psGrestore
    	}
        }
    
        # restore context at end
        psGrestore
    }
    
    proc psClipbox {x1 y1 x2 y2} {
        psNewpath
        psRectangle $x1 $y1 $x2 $y2
        psClosepath
        psClip
    }
    
    proc psMakeBoxBigger {x1__ y1__ x2__ y2__ delta} {
        upvar $x1__ x1
        upvar $x2__ x2
        upvar $y1__ y1
        upvar $y2__ y2
    
        AssertGreaterThanOrEqual $x2 $x1
        AssertGreaterThanOrEqual $y2 $y1
    
        set x1 [expr $x1 - $delta]
        set y1 [expr $y1 - $delta]
        set x2 [expr $x2 + $delta]
        set y2 [expr $y2 + $delta]
    }
    
    proc psFillStyleValid {style styles__} {
        upvar $styles__ styles
        set styles "solid hline vline dline1 dline2 circle square triangle utriangle"
        if {[lsearch -exact $styles $style] > -1} {
    	return 1
        }
        return 0
    }
    
    proc psMakePattern {args} {
        set default {
    	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
    	{"fillcolor"  "black"       "fill color"}
    	{"fillstyle"  "solid"       "solid,hline,vline,dline1,dline2,circle,square,..."}
    	{"fillsize"   "3"           "size of the pattern object"}
    	{"fillskip"   "4"           "space between each object in pattern"}
        }
        ArgsProcessWithDashArgs psMakePattern default args use \
    	"Use this to fill a rectangular region with one of many specified patterns."
    
        # bound box
        set count [ArgsParseItemPairList $use(coord) xy]
        AssertEqual $count 2
        set x1 $xy(0,n1)
        set y1 $xy(0,n2)
        set x2 $xy(1,n1)
        set y2 $xy(1,n2)
    
        switch -exact $use(fillstyle) {
    	"solid" {
    	    psNewpath
    	    psRectangle $x1 $y1 $x2 $y2
    	    psClosepath
    	    psSetcolor [psColor $use(fillcolor)]
    	    psFill
    	}
    	"hline" {
    	    set size  $use(fillsize)
    	    set skip  $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0
    	    psSetlinewidth $size
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
    		psNewpath
    		psRectangle $x1 $cy $x2 [expr $cy+$size] 
    		psClosepath
    		psFill
    		psStroke
    	    }
    	}
    	"vline" {
    	    set size  $use(fillsize)
    	    set skip  $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0
    	    psSetlinewidth $size
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$size]} {
    		psNewpath
    		psMoveto $cx $y1
    		psLineto $cx $y2
    		psStroke
    	    } 
    	}
    	"dline1" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetlinewidth $size
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
    		psNewpath
    		psMoveto $x1 $cy
    		psLineto $x2 [expr ($x2-$x1)+$cy]
    		psStroke
    	    } 
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$size]} {
    		psNewpath
    		psMoveto $cx $y1
    		psLineto [expr $cx+($y2-$y1)] $y2
    		psStroke
    	    } 
    	}
    	"dline2" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetlinewidth $size
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
    		psNewpath
    		psMoveto $x2 $cy
    		psLineto $x1 [expr ($x2-$x1)+$cy]
    		psStroke
    	    } 
    	    for {set cx $x2} {$cx >= $x1} {set cx [expr $cx-($skip+$size)]} {
    		psNewpath
    		psMoveto $cx $y1
    		psLineto [expr $cx-($y2-$y1)] $y2
    		psStroke
    	    } 
    	}
    	"circle" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
    		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
    		    psNewpath
    		    psArc $cx $cy $size 0 360
    		    psFill
    		    psStroke
    		}
    	    }
    	}
    	"square" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
    		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
    		    psNewpath
    		    psRectangle $cx $cy [expr $cx+$size] [expr $cy+$size]
    		    psFill
    		    psStroke
    		}
    	    }
    	}
    	"triangle" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
    		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
    		    psNewpath
    		    psMoveto [expr $cx-$size/2.0] $cy 
    		    psLineto [expr $cx+$size/2.0] $cy 
    		    psLineto $cx [expr $cy+$size]
    		    psClosepath
    		    psFill
    		    psStroke
    		}
    	    }
    	}
    	"utriangle" {
    	    set size $use(fillsize)
    	    set skip $use(fillskip)
    	    psMakeBoxBigger x1 y1 x2 y2 10.0 
    	    psSetcolor [psColor $use(fillcolor)]
    	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
    		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
    		    psNewpath
    		    psMoveto [expr $cx-$size/2.0] [expr $cy+$size]
    		    psLineto [expr $cx+$size/2.0] [expr $cy+$size]
    		    psLineto $cx $cy 
    		    psClosepath
    		    psFill
    		    psStroke
    		}
    	    }
    	}
    	default {
    	    puts stderr "bad fill style: $use(fillstyle)"
    	    Abort "should be one of 'solid', 'vline', 'hline', 'dline1', 'dline2', 'circle', 'square'"
    	}
        }
    }
    
    proc PsPolygon {args} {
        set default {
    	{"coord"      ""            "x1,y1:...:xn,yn"}
    	{"linecolor"  "black"       "color of the line"}
    	{"linewidth"  "1"           "width of the line"}
    	{"linecap"    "0"           "linecap: 0, 1, or 2 (see postscript manual for details)"}
    	{"linedash"   "0"           "define dashes for the line; 0 means solid line"}
    	{"fill"       "false"       "fill the box or not"} 
    	{"fillcolor"  "black"       "fill color (if used)"}
    	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
    	{"fillsize"   "3"           "size of object in pattern"}
    	{"fillskip"   "4"           "space between object in pattern"}
    	{"bgcolor"    ""            "if not empty, make the polyground have this color background"}
        }
        ArgsProcessWithDashArgs PsPolygon default args use ""
        psComment "PsPolygon:: [ArgsPrint use]"
    
        # pull out each element of the path
        set count [ArgsParseItemPairList $use(coord) coords]
        AssertGreaterThan $count 0
    
        # find minx,miny and maxx,maxy
        set minX $coords(0,n1) 
        set minY $coords(0,n2) 
        set maxX $minX
        set maxY $minY
        for {set p 1} {$p < $count} {incr p} {
    	if {$coords($p,n1) < $minX} {
    	    set minX $coords($p,n1)
    	}
    	if {$coords($p,n2) < $minY} {
    	    set minY $coords($p,n2)
    	}
    	if {$coords($p,n1) > $maxX} {
    	    set maxX $coords($p,n1)
    	}
    	if {$coords($p,n2) > $maxY} {
    	    set maxY $coords($p,n2)
    	}
        }
    
        # if the background should be filled, do that here
        if {$use(bgcolor) != ""} {
    	psGsave
    	psMoveto $coords(0,n1) $coords(0,n2) 
    	for {set p 1} {$p < $count} {incr p} {
    	    psLineto $coords($p,n1) $coords($p,n2) 
    	}
    	psClosepath
    	psSetcolor [psColor $use(bgcolor)]
    	psFill
    	psGrestore
        }
    
        # do filled one first
        if {[True $use(fill)]} {
    	# need to draw proper path to then clip it
    	psGsave
    	psMoveto $coords(0,n1) $coords(0,n2) 
    	for {set p 1} {$p < $count} {incr p} {
    	    psLineto $coords($p,n1) $coords($p,n2) 
    	}
    	psClosepath
    	psClip
    	# use minimal x,y pair and max x.y pair to determine patternbox
    	psMakePattern -coord "$minX,$minY : $maxX,$maxY" -fillcolor $use(fillcolor) \
    	    -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
    	psGrestore
        }
    
        # now draw outline of polygon
        if {$use(linewidth) > 0} {
    	psGsave
    	psMoveto $coords(0,n1) $coords(0,n2) 
    	for {set p 1} {$p < $count} {incr p} {
    	    psLineto $coords($p,n1) $coords($p,n2) 
    	}
    	psClosepath
    	psSetcolor [psColor $use(linecolor)]
    	psSetlinewidth $use(linewidth)
    	if {$use(linecap) != 0} {
    	    psSetlinecap $use(linecap)
    	}
    	if {$use(linedash) != 0} {
    	    psSetdash $use(linedash)
    	}
    	psStroke
    	psGrestore
        }
    }
    
    proc PsBox {args} {
        set default {
    	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
    	{"linecolor"  "black"       "color of the line"}
    	{"linewidth"  "1"           "width of the line"}
    	{"linedash"   "0"           "dash of the line"}
    	{"linecap"    "0"           "cap of the line"}
    	{"fill"       "false"       "fill the box or not"} 
    	{"fillcolor"  "black"       "fill color (if used)"}
    	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
    	{"fillsize"   "3"           "size of object in pattern"}
    	{"fillskip"   "4"           "space between object in pattern"}
    	{"bgcolor"     ""            "if not empty, background color for this box"}
        }
        ArgsProcessWithDashArgs PsBox default args use ""
        psComment "PsBox:: [ArgsPrint use]"
    
        # pull out each element of the path
        set count [ArgsParseItemPairList $use(coord) coords]
        AssertEqual $count 2
    
        set x1 $coords(0,n1)
        set y1 $coords(0,n2)
        set x2 $coords(1,n1)
        set y2 $coords(1,n2)
    
        # the code assumes y2 is bigger than y1, so switch them if need be
        if {$y1 > $y2} {
    	set tmp $y2
    	set y2 $y1
    	set y1 $tmp
        }
    
        # if the background should be filled, do that here
        if {$use(bgcolor) != ""} {
    	psGsave
    	psMakePattern -coord "$x1,$y1 : $x2,$y2" -fillcolor $use(bgcolor) -fillstyle solid 
    	psGrestore
        }
    
        # do filled one first
        if [True $use(fill)] {
    	psGsave
    	psClipbox $x1 $y1 $x2 $y2
    	psMakePattern -coord "$x1,$y1 : $x2,$y2" -fillcolor $use(fillcolor) \
    	    -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
    	psGrestore
        }
    
        # draw outline box
        if {$use(linewidth) > 0} {
    	psGsave
    	psNewpath
    	psRectangle $x1 $y1 $x2 $y2
    	psClosepath
    	psSetcolor [psColor $use(linecolor)]
    	psSetlinewidth $use(linewidth)
    	if {$use(linedash) != 0} {
    	    psSetdash $use(linedash)
    	}
    	if {$use(linedash) != 0} {
    	    psSetdash $use(linedash)
    	}
    	psStroke
    	psGrestore
        }
    }
    
    proc PsCircle {args} {
        set default {
    	{"coord"      "0,0"         "x1,y1"}
    	{"radius"     "1"           "radius of circle"}
    	{"linecolor"  "black"       "color of the line"}
    	{"linewidth"  "1"           "width of the line"}
    	{"linedash"   "0"           "dash pattern of the line"}
    	{"fill"       "false"       "fill the box or not"} 
    	{"fillcolor"  "black"       "fill color (if used)"}
    	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
    	{"fillsize"   "3"           "size of object in pattern"}
    	{"fillskip"   "4"           "space between object in pattern"}
    	{"bgcolor"     ""            "if not empty, make the polyground have this color background"}
        }
        ArgsProcessWithDashArgs PsCircle default args use ""
        psComment "PsCircle:: [ArgsPrint use]"
    
        # pull out each element of the path
        set xy [split $use(coord) ","]
        set x  [lindex $xy 0]
        set y  [lindex $xy 1]
        set r  $use(radius)
    
        # if the background should be filled, do that here
        if {$use(bgcolor) != ""} {
    	psGsave
    	psNewpath
    	psArc $x $y $use(radius) 0 360
    	psSetcolor [psColor $use(bgcolor)]
    	psFill
    	psGrestore
        }
    
        # do fill first
        if [True $use(fill)] {
    	psGsave
    	psNewpath
    	psArc $x $y $use(radius) 0 360
    	psClosepath
    	psClip
    	psMakePattern -coord "[expr $x-$r],[expr $y-$r] : [expr $x+$r],[expr $y+$r]" \
    	    -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
    	psGrestore
        }
    
        # make the circle outline now
        if {$use(linewidth) > 0} {
    	psGsave
    	psNewpath
    	psArc $x $y $use(radius) 0 360
    	psSetcolor [psColor $use(linecolor)]
    	psSetlinewidth $use(linewidth)
    	if {$use(linedash) != 0} {
    	    psSetdash $use(linedash)
    	}
    	psStroke
    	psGrestore
        }
    }
    
    proc PsText {args} {
        set default {
    	{"coord"      "0,0"         "x1,y1"}
    	{"text"       "text"        "the text on the canvas"}
    	{"font"       "Helvetica"   "which font: Helvetica, TimesRoman, Courier"}
    	{"color"      "black"       "color of text"}
    	{"size"       "10"          "size of the type face"}
    	{"rotate"     "0"           "angle of rotation"}
    	{"anchor"     "c"           "the x-directional anchor: l (left), c (center), r (right); or, if you need y-directional alignment too: xanchor,l (low), xanchor,c (center), xanchor,h (high)"}
    	{"bgcolor"    ""           "if non-empty, fill the background of the text with this color, then draw text upon it"}
    	{"bgborder"   "1"          "if filling the background, how much of a border to have around the text?"}
        }
        ArgsProcessWithDashArgs PsText default args use \
    	"Use this routine to place text on the canvas. Most options are obvious (the expected coordinate pair, color, text, font, size (the size of the font), rotation (which way the text should be rotated), but the anchor can be a bit confusing. Basically, the anchor determines where, relative to the coordinate pair (x,y), the text should be placed. Simple anchoring includes left (l), center (c), or right (r), which determines whether the text starts at the x position specified (left), ends at x (right), or is centered on the x (center). Adding a second anchor (xanchor,yanchor) specifies a y position anchoring as well. The three options there are low (l), which is the default if none is specified, high (h), and middle (m), again all determining the placement of the text relative to the y coordinate specified. "
        psComment "PsText:: [ArgsPrint use]"
    
        psAddfont $use(font)
    
        # pull our coords
        set count [ArgsParseCommaList $use(coord) coord]
        AssertEqual $count 2
        set x $coord(0)
        set y $coord(1)
    
        # pull out anchors
        set count [ArgsParseCommaList $use(anchor) anchor]
        if {$count == 1} {
    	# just one anchor, assume it is the x anchor
    	set xanchor $anchor(0)
    	set yanchor "l"
        } elseif {$count == 2} {
    	# two anchors
    	set xanchor $anchor(0)
    	set yanchor $anchor(1)
        } else {
    	Abort "Bad anchor: $use(anchor)"
        }
    
        psGsave
    
        # XXX - this is just a bit ugly and messy, sorry postscript
        if {$use(bgcolor) != ""} {
    	psNewpath
    	psSetcolor [psColor $use(bgcolor)]
    	psSetfont $use(font) $use(size)
    	psMoveto $x $y
    	if {$use(rotate) != 0} {
    	    psGsave
    	    psRotate $use(rotate)
    	}
    	# now, adjust based on yanchor
    	switch -exact $yanchor {
    	    l { } 
    	    c { psRmoveto 0 [expr -0.36 * $use(size)] } 
    	    h { psRmoveto 0 [expr -0.72 * $use(size)] } 
    	    default { Abort "yanchor should be: l, c, or h" }
    	}
    	# now, adjust based on xanchor
    	switch -exact $xanchor {
    	    l { psPuts "($use(text)) stringwidth pop dup" } 
    	    c { psPuts "($use(text)) stringwidth pop dup -2 div 0 rmoveto dup" } 
    	    r { psPuts "($use(text)) stringwidth pop dup -1 div 0 rmoveto dup" } 
    	    default { Abort "xanchor should be: l, c, or r" }
    	}	
    	# now get width of string and draw the box
    	psPuts "-$use(bgborder) -$use(bgborder) rmoveto"                      ;# move to left-bottom including borders
    	psPuts "[expr 2 * $use(bgborder)] add 0 rlineto"                      ;# add border*2 to the width (on the stack) and move over
    	psPuts "0 [expr (0.72 * $use(size)) + (2 * $use(bgborder))] rlineto"  ;# move a line up by the height of characters + border
    	psPuts "neg [expr -2 * $use(bgborder)] add 0 rlineto"                 ;# move back down and closepath to finish
    	psClosepath 
    	psFill 
    	if {$use(rotate) != 0} {
    	    psGrestore
    	}
        }
    
        # now, just draw the text
        psNewpath
        psSetcolor [psColor $use(color)]
        if {$use(bgcolor) == ""} {
    	psSetfont $use(font) $use(size)
        }
        psMoveto $x $y
        if {$use(rotate) != 0} {
    	psGsave
    	psRotate $use(rotate)
        }
        # 0.36: a magic adjustment to center text in y direction
        # based on years of postscript experience, only change if you actually
        # know something about how this works, unlike me
        switch -exact $yanchor {
    	l { } 
    	c { psRmoveto 0 [expr -0.36 * $use(size)] } 
    	h { psRmoveto 0 [expr -0.72 * $use(size)] } 
    	default { Abort "yanchor should be: l, c, or h" }
        }
        # need to mark parens specially in postscript (as they are normally used to mark strings)
        set text [string map { ( \\( ) \\) } $use(text)]
        # puts "text: $use(text) --> $text"
        psShow $text $xanchor
        if {$use(rotate) != 0} {
    	psGrestore
        }
        psStroke
    
        psGrestore
    }
    
    proc psPointStyleValid {style styles__} {
        upvar $styles__ styles
        set styles "label hline vline plusline xline dline1 dline2 square circle triangle utriangle diamond star asterisk"
        if {[lsearch -exact $styles $style] > -1} {
    	return 1
        }
        return 0
    }
    
    proc PsShape {args} {
        set default {
    	{"style"        ""            "the possible shapes"}
    	{"x"            ""            "x position of shape"}
    	{"y"            ""            "y position of shape"}
    	{"size"         ""            "size of shape"}
    	{"linecolor"    "black"       "color of the line of the marker"}
    	{"linewidth"    "1"           "width of lines used to draw the marker"}
    	{"fill"         "f"           "for some shapes, filling makes sense; if desired, mark this true"}
    	{"fillcolor"    "black"       "if filling, use this fill color"}
    	{"fillstyle"    "solid"       "if filling, which fill style to use"}
    	{"fillsize"      "3"         "size of object in pattern"}
    	{"fillskip"      "4"         "space between object in pattern"}
        }
        ArgsProcessWithDashArgs PsShape default args use \
    	"Use this to draw a shape on the plotting surface. Lots of possibilities, including square, circle, triangle, utriangle, plusline, hline, vline, xline, dline1, dline2, diamond, asterisk, ..."
    
        # pull out some params
        set x $use(x)
        set y $use(y)
        set s $use(size)
    
        switch -exact $use(style) {
    	"square" { 
    	    PsBox -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize $use(fillsize) -fillskip $use(fillskip) 
    	    }
    	"circle" { 
    	    PsCircle -coord $x,$y -radius $s \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
    	    }
    	"triangle" {
    	    PsPolygon -coord "[expr $x-$s],[expr $y-$s] : $x,[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
    	    }
    	"utriangle" {
    	    PsPolygon -coord "[expr $x-$s],[expr $y+$s] : $x,[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
    	}
    	"plusline" { 
    	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" -linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" -linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"xline" { 
    	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"dline1" { 
    	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"dline2" { 
    	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"hline" { 
    	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"vline" { 
    	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	"diamond" {
    	    PsPolygon -coord "[expr $x-$s],$y : $x,[expr $y+$s] : [expr $x+$s],$y : $x,[expr $y-$s] " \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
    	}
    	"star" {
    	    XXX
    	    PsPolygon -coord "[expr $x-$s],[expr $y-$s] : $x,[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
    	}
    	"asterisk" {
    	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) 
    	}
    	default {
    	    Abort "bad choice of point style: $use(style)"
    	}
        }
    }
    
    
    #
    #
    # PS Code generator
    #
    #
    
    variable psCounter 0
    variable psArray
    #HERE: set psArray(__dummy__) ""
    
    proc psPuts {str} {
        variable psCounter 
        variable psArray
        set psArray($psCounter) $str
        incr psCounter 1
    }
    
    proc psSimpleCodeGen {fd} {
        variable psCounter 
        variable psArray
        variable _ps

    
        # ORIG CODE - DEAD
        for {set i 0} {$i < $psCounter} {incr i} {
    	puts $fd $psArray($i)
    	set psArray($i) ""
        }
        set psCounter 0
    }
    
    # XXX -- this is incomplete, don't use it yet
    proc psOptimizingCodeGen {fd} {
        variable psCounter 
        variable psArray
        variable _ps
    
        # is printing on ...
        set on 0
        set n 0
    
        # read in first context
        for {set i 0} {$i < $psCounter} {incr i} {
    	set curr $psArray($i)
    
    	if [StringEqual $curr "gs"] {
    	    set on 1
    	}
    
    	if {$on} {
    	    puts "printing $i:$curr"
    	    set currArray($n) $curr
    	    incr n
    	}
    
    	if [StringEqual $curr "gr"] {
    	    puts "BREAK"
    	    break
    	}
    
    	# zero out ps array
    	# set psArray($i) ""
        }
    
        set currCnt $n
    
        # mark which lines constitute the environment
        puts "First one has $currCnt entries"
        for {set i 0} {$i < $currCnt} {incr i} {
    	set cmd [lindex $currArray($i) [expr [llength $currArray($i)] - 1]]
    	switch -exact $cmd {
    	    slw { puts -nonewline "ENVIRONMENT :: " }
    	}
    	puts "FIRST: $i $currArray($i)"
    	
        }
        
        # environment consists of 
    
        # put actual thing to be rendered into a different array
        for {set i 0} {$i < $psCounter} {incr i} {
    	set curr $psArray($i)
    
    	# OUTPUT (for now)
    	puts $fd $curr
    
    	# zero out ps array
    	set psArray($i) ""
        }
        set psCounter 0
        
    }
    
    proc psPutsDump {fd} {
        variable psCounter 
        variable psArray
        variable _ps
    
        if {$psCounter > 0} {
    	if {[StringEqual $psArray(0) $_ps(firstLine)] == 0} {
    	    Abort "First line of postscript looks wrong: Did you call PsCanvas first in your script?"
    	}
        }
    
        psSimpleCodeGen $fd
        # psOptimizingCodeGen $fd
    }
    
    
    # end including ps.tcl

    # begin including drawable.tcl
    # tcl
    
    variable _draw
    
    proc drawableExists {drawable} {
        variable _draw
        return [info exists _draw(__nameSpace__,$drawable)]
    }
    
    proc drawableGetScaleType {drawable axis} {
        variable _draw
        return $_draw($drawable,scaleType,$axis)
    }
    
    proc drawableGetWidth {drawable axis} {
        variable _draw
        return $_draw($drawable,${axis}width)
    }
    
    proc drawableGetVirtualMin {drawable axis} {
        variable _draw
        return $_draw($drawable,$axis,virtualMin)
    }
    
    proc drawableGetVirtualMax {drawable axis} {
        variable _draw
        return $_draw($drawable,$axis,virtualMax)
    }
    
    proc drawableGetLinearMin {drawable axis} {
        variable _draw
        return $_draw($drawable,$axis,linearMin)
    }
    
    proc drawableGetLinearMax {drawable axis} {
        variable _draw
        return $_draw($drawable,$axis,linearMax)
    }
    
    proc drawableGetLinearRange {drawable axis} {
        variable _draw
        return $_draw($drawable,$axis,linearRange)
    }
    
    proc drawableGetRangeIterator {drawable axis min max step} {
        variable _draw
    
        set tlist "empty"
        set scale $_draw($drawable,scaleType,$axis)
        switch -exact $scale {
    	linear { 
    	    for {set i $min} {$i <= $max} {set i [expr $i + $step]} {
    		set tlist "$tlist $i"
    	    }
    	}
    	log2     { 
    	    for {set i $min} {$i <= $max} {set i [expr $i * $step]} {
    		set tlist "$tlist $i"
    	    }
    	}
    	log10    { 
    	    for {set i $min} {$i <= $max} {set i [expr $i * $step]} {
    		set tlist "$tlist $i"
    	    }
    	}
        }
        return [lrange $tlist 1 end]
    }
    
    proc drawablePreconditions {} {
        if [psCanvasDefined] {
    	return 1
        }
        puts stderr "In Drawable: must call PsCanvas to define the canvas before you do anything else.\n"
        return 0
    }
    
    proc Drawable {args} {
        set default {
    	{"drawable"   "default" + "isString 1"         "name of the drawable"}
    	{"coord"      ","       + "isString 2"         "lower-left (x,y) position of drawable; if blank, use best guess"}
    	{"dimensions" ","       + "isString 2"         "(width,height) of drawing area; if blank, use best guess"}
    	{"xrange"     ""        + "isNumeric 2"        "x range which maps onto drawable (min,max)"}
    	{"yrange"     ""        + "isNumeric 2"        "y range which maps onto drawable (min,max)"}
    	{"xscale"     "linear"  + "isMember linear,log10,log2" "what type of data will be on this axis: linear, log10, log2, ..."}
    	{"yscale"     "linear"  + "isMember linear,log10,log2" "what type of data will be on this axis: linear, log10, log2, ..."}
    	{"fill"       "false"   + "isBoolean 1"        "fill the drawable's entire background"}
    	{"fillcolor"  "white"   + "isColor 1"          "if filling, fill drawable's entire background with this color"}
    	{"outline"    "false"   + "isBoolean 1"        "make an outline for this box"}
    	{"linewidth"  "1"       + "isNumeric 1"        "if drawing an outline box, use this linewidth"}
    	{"linecolor"  "black"   + "isColor 1"          "if drawing an outline box, use this linecolor"}
        }
        ArgsProcessWithTypeChecking Drawable default args use drawablePreconditions \
    	"Creates a drawable region onto which graphs can be drawn. Must define the xrange and yrange, which are each min,max pairs, so that the drawable can translate data in table into points on the graph. Also, must select which type of scale each axis is, e.g., linear, log10, and so forth. If unspecified, coordinates (the x,y location of the lower left of the drawable) and dimensions (the width,height of the drawable) will be guessed at; specifying these allows control over where and how big the drawable is. Other options do things like place a background color behind the entire drawable or make an outline around it."
    
        # for ease of use
        set draw $use(drawable)
    
        # where all the info goes
        variable _draw
    
        # make sure this is a new drawable 
        if [StringEqual $draw __nameSpace__] {
    	Abort "drawable cannot be called '__nameSpace__'"
        }
        if {[info exists _draw(__nameSpace__,$draw)]} {
    	Abort "drawable $draw already exists"
        }
        set _draw(__nameSpace__,$draw) 1
    
        # now, check if height and width have been specified
        set use(xoff)  [psConvertToPoints $use(coord,0)]
        set use(yoff)  [psConvertToPoints $use(coord,1)]
    
        set use(width)  [psConvertToPoints $use(dimensions,0)]
        set use(height) [psConvertToPoints $use(dimensions,1)]
    
        set use(xmargin) 5
        set use(ymargin) 15
    
        if {($use(width) != "") && ($use(width) < 0)} {
    	set use(xmargin) [expr -$use(width)]
    	set use(width) ""
        } 
        if {($use(height) != "") && ($use(height) < 0)} {
    	set use(ymargin) [expr -$use(height)]
    	set use(height) ""
        }
    
        if {$use(xoff) == ""} {
    	set use(xoff) 35.0
        }
        if {$use(yoff) == ""} {
    	set use(yoff) 30.0
        }
        if {$use(width) == ""} {
    	set use(width) [expr [psCanvasWidth] - $use(xoff) - $use(xmargin)]
    	AssertGreaterThan $use(width) 30.0
        }
        if {$use(height) == ""} {
    	set use(height) [expr [psCanvasHeight] - $use(yoff) - $use(ymargin)]
    	AssertGreaterThan $use(height) 30.0
        }
    
        # fill background
        if {[True $use(fill)]} {
    	PsBox -coord "$use(xoff),$use(yoff) : [expr $use(xoff)+$use(width)],[expr $use(yoff)+$use(height)]" -fill t -fillcolor $use(fillcolor) -linewidth $use(linewidth) -linecolor $use(linecolor)
        }
        # make an outline for this drawable
        if {[True $use(outline)]} {
    	PsBox -coord "$use(xoff),$use(yoff) : [expr $use(xoff)+$use(width)],[expr $use(yoff)+$use(height)]" -fill f -linewidth $use(linewidth) -linecolor $use(linecolor)
        }
    
        set _draw($draw,scaleType,x) $use(xscale)
        set _draw($draw,scaleType,y) $use(yscale)
    
        foreach axis {x y} {
    	set range(0) $use(${axis}range,0)
    	set range(1) $use(${axis}range,1)
    	switch -exact $use(${axis}scale) {
    	    "log10" {
    		set _draw($draw,$axis,linearMin)   [expr log10(double($range(0)))]
    		set _draw($draw,$axis,linearMax)   [expr log10(double($range(1)))]
    		set _draw($draw,$axis,virtualMin)  $range(0)
    		set _draw($draw,$axis,virtualMax)  $range(1)
    	    } 
    	    "log2" {
    		set _draw($draw,$axis,linearMin)   [expr log2(double($range(0)))]
    		set _draw($draw,$axis,linearMax)   [expr log2(double($range(1)))]
    		set _draw($draw,$axis,virtualMin)  $range(0)
    		set _draw($draw,$axis,virtualMax)  $range(1)
    	    }
    	    "linear" {
    		set _draw($draw,$axis,linearMin)   [expr double($range(0))]
    		set _draw($draw,$axis,linearMax)   [expr double($range(1))]
    		set _draw($draw,$axis,virtualMin)  $range(0)
    		set _draw($draw,$axis,virtualMax)  $range(1)
    	    }
    	    default {
    		Abort "INTERNAL ERROR: Should never get here (unknown scale type)"
    	    }
    	}
    
    	# and record the linear range (for use in scaling)
    	set _draw($draw,$axis,linearRange) [expr $_draw($draw,$axis,linearMax) - $_draw($draw,$axis,linearMin)]
        }    
    
        # record other misc info for future use too
        foreach v {xoff yoff width height} {
    	set _draw($draw,$v) [expr double($use($v))]
        }
        # and instead of height and width, called them xwidth and ywidth
        set _draw($draw,ywidth) [expr double($use(height))]
        set _draw($draw,xwidth) [expr double($use(width))]
    }
    
    #
    # VALUES have three possible types
    #   Virtual    : what they are in the specifed scale type (log, linear, etc.)
    #   Linear     : what they are once the mapping has been applied (log(virtual), etc.)
    #   Scaled     : in Postscript points, scaled as if the drawable is at 0,0
    #   Translated : in Postscript points, scaled + offset of drawable
    #
    # How to go from one to the other?
    #   to translate from Virtual -> Linear, call [Map]
    #   to translate from Linear  -> Scaled, call [Scale]
    #   to translate from Scaled  -> Translated, call [Translate]
    # 
    
    # Map: take value, map it onto a linear value scale
    proc drawableMap {drawable axis value} {
        variable _draw
        set scale $_draw($drawable,scaleType,$axis)
    
        switch -exact $scale {
    	linear   { set r $value }
    	log2     { set r [expr log2($value)] }
    	log10    { set r [expr log10($value)] }
        }
        return $r
    }
    
    # Scale: scale a linear value onto the drawable's range
    proc drawableScale {drawable axis value} {
        variable _draw
        if {[StringEqual $drawable "canvas"]} {
    	puts stderr "returning SCALED CANVAS value"
    	return $value
        }
        set width [drawableGetWidth $drawable $axis]
        set range [drawableGetLinearRange $drawable $axis]
    
        # which type of scaling is this?
        return [expr double($value) * ($width / $range)] 
    }
    
    # Translate: scale and then add the offset 
    proc drawableTranslate {drawable axis value} {
        variable _draw
        if {[StringEqual $drawable "canvas"]} {
    	return $value
        }
        # need two linear values: then subtract, scale, and add offset
        set min    [drawableGetLinearMin $drawable $axis]  ;# precompute this
        set value  [drawableMap $drawable $axis $value]
    
        # offset + scaled difference = what we want
        set result [expr $_draw($drawable,${axis}off) + [drawableScale $drawable $axis [expr $value - $min]]]
        return $result
    }
    
    # end including drawable.tcl

    # begin including style.tcl
    # tcl
    
    proc StyleSet {args} {
        set default {
    	{"name"      "default"       "what is the name of the style you are defining?"}
        }
        
    }
    # end including style.tcl

    # begin including plot.tcl
    # tcl
    
    # 
    # get the lo point (could be from a field, from a single value, or default: the min of yrange)
    # 
    proc tableGetLoFieldY {use__ row} {
        upvar $use__ use
        if {$use(ylofield) != ""} {
    	return [__TableGetVal $use(table) $use(ylofield) $row]
        } else {
    	if {$use(yloval) == ""} {
    	    # THIS SHOULD BE TRANSLATABLE (i.e., not mapped)
    	    return [drawableGetVirtualMin $use(drawable) y]
    	} else {
    	    return $use(yloval)
    	}
        }
    }
    
    proc tableGetLoFieldX {use__ row} {
        upvar $use__ use
        if {$use(xlofield) != ""} {
    	return [__TableGetVal $use(table) $use(xlofield) $row]
        } else {
    	if {$use(xloval) == ""} {
    	    # THIS SHOULD BE TRANSLATABLE (i.e., not mapped)
    	    return [drawableGetVirtualMin $use(drawable) x]
    	} else {
    	    return $use(xloval)
    	}
        }
    }
    
    proc limit {value min max} {
        if {$value < $min} {
    	return $min
        } elseif {$value > $max} {
    	return $max
        } else {
    	return $value
        }
    }
    
    #
    # exported plot functions
    #
    proc PlotFunction {args} {
        set default {
    	{"drawable"   "default"   + "isDrawable -" "name of the drawable area"}
    	{"func"       "default"   + "isFunction -" "describe the function, using the variable x to express f(x) (e.g., linear would be {\$x}, whereas a simple parabola would be {\$x * \$x})"}
    	{"range"      "0,10"      + "isNumeric 2"  "the x-range the function should be plotted over, in xmin,xmax form"}
    	{"step"       "1"         + "isNumeric 1"  "given the range of xmin to xmax, step determines at which x values the function is evaluated and a line is drawn to; thus, the more ups and downs the function has, the smaller step that should be chosen"}
    	{"linewidth"  "1"         + "isNumeric 1"  "the linewidth to use"}
    	{"linecolor"  "black"     + "isColor 1"    "the color of the line"}
    	{"linedash"   "0"         + "isNumeric -"  "the dash pattern (if non-zero)"}
        }
        ArgsProcessWithTypeChecking PlotFunction default args use "" \
    	"Use PlotFunction to plot a function right onto a drawable. The function should simply use the variable \$x wherever it needs to in order to express the desired function. For example, to plot y = x, the caller should pass the following flag: -func \{\$x\}. The caller should place curly braces around the function to prevent the Tcl interpreter from interpreting what is inside of the braces before it is passed to the PlotFunction routine."
    
        set min  $use(range,0)
        set max  $use(range,1)
        set step $use(step)
        
        # get first point
        set x $min
        set y [eval "expr $use(func)"]
        set lineList "[drawableTranslate $use(drawable) x $x],[drawableTranslate $use(drawable) y $y]"
        for {set x [expr $min+$step]} {$x <= $max} {set x [expr $x+$step]} {
    	# now iterate and plot the rest of the points
    	set y [eval "expr $use(func)"]
    	set lineList "$lineList : [drawableTranslate $use(drawable) x $x],[drawableTranslate $use(drawable) y $y]"
        }
    
        # now draw the line
        PsLine -coord $lineList -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash)
    }
    
    proc setAnchorAndPlace {use__ anchor__ place__ y1 y2} {
        upvar $use__    use
        upvar $anchor__ anchor
        upvar $place__  place
    
        if {$y2 < $y1} {
    	# this is an upside down bar, so switch position of anchor and 'place'
    	if [StringEqual $use(labelplace) "i"] {
    	    set place "+3"
    	} else {
    	    set place "-3"
    	}
        } else {
    	# normal bar (not upside down)
    	if [StringEqual $use(labelplace) "i"] {
    	    set place "-3"
    	} else {
    	    set place "+3"
    	}
        }
    
        if {$use(labelanchor) == ""} {
    	# autospecifying the anchor
    	if {$place < 0} {
    	    set anchor "c,h"
    	} else {
    	    set anchor "c,l"
    	}
        } else {
    	set anchor $use(labelanchor)
        }
    }
    
    proc PlotVerticalBars {args} {
        set default {
    	{"drawable"      "default"   + "isDrawable -"        "name of the drawable area"}
    	{"table"         "default"   + "isTable -"           "name of table to use"}
    	{"xfield"        "x"         + "isTableField table"  "table column with x data"}
    	{"yfield"        "y"         + "isTableField table"  "table column with y data"}
    	{"ylofield"      ""          - "isTableField table"  "if specified, table column with ylo data; use if bars don't start at the minimum of the range"}
    	{"yloval"        ""          - "isNumeric 1"         "if there is no ylofield, use this single value to fill down to; if empty, just use the min of y-range"}
    	{"limit"        "t"          + "isBoolean 1"        "if true, limit values to the drawable; if not, let values go beyond the range of the drawable"}
    	{"barwidth"      "1"         + "isNumeric 1"        "bar width"}
    	{"cluster"       "0,1"       + "isNumeric 2"        "should be of the form n,m; thus, each x-axis data point actually will have 'm' bars plotted upon it; 'n' specifies which cluster of the 'm' this one is (from 0 to m-1); width of each bar is 'barwidth/m'; normal bar plots (without clusters) are just the default, '0,1'"}
    	{"linecolor"     "black"     + "isColor 1"          "color of the line"}
    	{"linewidth"     "0.25"      + "isNumeric 1"        "width of the line; set to 0 if you don't want a surrounding line on the box"}
    	{"fill"          "false"     + "isBoolean 1"        "fill the box or not"} 
    	{"fillcolor"     "gray"      + "isColor 1"          "fill color (if used)"}
    	{"fillstyle"     "solid"     + "isFillStyle 1"      "solid, boxes, circles, ..."}
    	{"fillsize"      "3"         + "isNumeric 1"        "size of object in pattern"}
    	{"fillskip"      "4"         + "isNumeric 1"        "space between object in pattern"}
    	{"bgcolor"       ""          - "isColor 1"          "color background for the bar; empty means none (patterns may be see through)"}
    	{"labelfield"    ""          - "isTableField table" "if specified, table column with labels for each bar"}
    	{"labelformat"   "%s"        + "isFormatString -"   "use this format for the labels; can prepend and postpend arbitrary text"}
    	{"labelrotate"   "0"         + "isNumeric 1"        "rotate labels"}
    	{"labelanchor"   ""          - "isTextAnchor 1"     "text anchor if using a labelfield; empty means use a best guess"}
    	{"labelplace"    "o"         + "isMember o,i"       "place label (o) outside of bar or (i) inside of bar"}
    	{"labelshift"    "0,0"       + "isNumeric 2"        "shift text in x,y direction"}
    	{"labelfont"     "Helvetica" + "isFont 1"           "if using labels, what font should be used"}
    	{"labelsize"     "10.0"      + "isNumeric 1"        "if using labels, font for label"}
    	{"labelcolor"    "black"     + "isColor 1"          "if using labels, what color font should be used"}
    	{"labelbgcolor"  ""          - "isColor 1"          "if specified, fill this color in behind each text item"}
    	{"legend"        ""          - "isString 1"         "add this entry to the legend"}
        }    
        ArgsProcessWithTypeChecking PlotVerticalBars default args use "" \
    	"Use this to plot vertical bars on a drawable. A basic plot will specify the table, xfield, and yfield. Bars will be drawn from the minimum of the range to the y value found in the table. If the bars should start at some value other than the minimum of the range (for example, when the yaxis extends below zero, or you are building a stacked bar chart), two options are available: ylofield and yloval. ylofield specifies a column of a table that has the low values for each bar, i.e., a bar will be drawn at the value specifed by the xfield starting at the ylofield value and going up to the yfield value. yloval can be used instead when there is just a single low value to draw all bars down to. Some other interesting options: labelfield, which lets you add a label to each bar by giving a column of labels (use rotate, anchor, place, font, fontsize, and fontcolor flags to control details of the labels); barwidth, which determines how wide each bar is in the units of the x-axis; linecolor, which determines the color of the line surrounding the box, and linewidth, which determines its thickness (or 0 to not have one); and of course the color and fill of the bar, as determined by fillcolor, fillstyle, and fillsize and fillskip."
    
        # XXX: should add specific cluster type check
        set n        [expr double($use(cluster,0))]
        set clusters [expr double($use(cluster,1))]
        AssertGreaterThanOrEqual $n 0
        AssertLessThan $n $clusters
    
        set barwidth  [drawableScale $use(drawable) x $use(barwidth)]
        set ubarwidth [expr $barwidth / $clusters]
    
        set shift(0) $use(labelshift,0)
        set shift(1) $use(labelshift,1)
    
        if [True $use(limit)] {
    	set xmax [drawableGetVirtualMax $use(drawable) x]
    	set xmin [drawableGetVirtualMin $use(drawable) x]
    	set ymax [drawableGetVirtualMax $use(drawable) y]
    	set ymin [drawableGetVirtualMin $use(drawable) y]
        }
        
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x   [__TableGetVal $use(table) $use(xfield) $r]
    	set y   [__TableGetVal $use(table) $use(yfield) $r]
    	set ylo [tableGetLoFieldY use $r]
    
    	if [True $use(limit)] {
    	    # THIS ONLY WORKS FOR NUMERIC VALUES, not CATEGORIES
    	    # skip if x is out of bounds
    	    if {($x < $xmin) || ($x > $xmax)} {
    		continue
    	    } 
    	    if {($y < $ymin) && ($ylo < $ymin)} {
    		continue
    	    }
    	    if {($y > $ymax) && ($ylo > $ymax)} {
    		continue
    	    }
    	    set y   [limit $y $ymin $ymax]
    	    set ylo [limit $ylo $ymin $ymax]
    	}
    
    	set x1 [expr [drawableTranslate $use(drawable) x $x] - ($barwidth/2.0) + ($ubarwidth * $n)]
    	set y1 [drawableTranslate $use(drawable) y $ylo]
    	set x2 [expr $x1 + ($barwidth/$clusters)]
    	set y2 [drawableTranslate $use(drawable) y $y] 
    
    	# auto set anchor, etc.
    	setAnchorAndPlace use anchor place $y1 $y2
    
    	# make the arg list and call the box routine
    	PsBox -coord $x1,$y1:$x2,$y2 -linecolor  $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor  $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
    
    	if {$use(labelfield) != ""} {
    	    set label  [format $use(labelformat) [__TableGetVal $use(table) $use(labelfield) $r]]
    	    set xlabel [expr $x1 + ($barwidth/2.0) + $shift(0)]
    	    set ylabel [expr [drawableTranslate $use(drawable) y $y] + $place + $shift(1)]
    	    PsText -coord $xlabel,$ylabel -text $label -anchor $anchor -rotate $use(labelrotate) \
    		-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor) -bgcolor $use(labelbgcolor)
    	}
        }
    
        if {$use(legend) != ""} {
    	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmm,__Ymm:__Xpm,__Ypm -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -linewidth [expr $use(linewidth)/4.0] -linecolor $use(linecolor)"
        }
    }
    
    proc PlotHorizontalBars {args} {
        set default {
    	{"drawable"   "default" + "isDrawable -"        "name of the drawable area"}
    	{"table"      "default" + "isTable -"           "name of table to use"}
    	{"xfield"     "x"       + "isTableField table"  "table column with x data"}
    	{"yfield"     "y"       + "isTableField table"  "table column with y data"}
    	{"xlofield"   ""        - "isTableField table"  "if specified, column with xlo data; use if bars don't start at x=0"}
    	{"xloval"     ""        - "isNumeric 1"         "if there is no xlofield, use this single value to fill down to; if empty, just use the min of x-range"}
    	{"barwidth"   "1"       + "isNumeric 1"         "bar width (in units of the y-axis)"}
    	{"linecolor"  "black"   + "isColor 1"           "color of the line"}
    	{"linewidth"  "1"       + "isNumeric 1"         "width of the line"}
    	{"fill"       "false"   + "isBoolean 1"         "fill the box or not"} 
    	{"fillcolor"  "gray"    + "isColor 1"           "fill color (if used)"}
    	{"fillstyle"  "solid"   + "isFillStyle 1"       "solid, boxes, circles, ..."}
    	{"fillsize"      "3"    + "isNumeric 1"         "size of object in pattern"}
    	{"fillskip"      "4"    + "isNumeric 1"         "space between object in pattern"}
    	{"bgcolor"     ""       - "isColor 1"           "color background for the bar; empty means none (patterns may be see through)"}
    	{"legend"     ""        - "isString 1"          "add this entry to the legend"}
        }    
        ArgsProcessWithTypeChecking PlotHorizontalBars default args use "" \
    	"Use this to plot horizontal bars. The options are quite similar to the vertical cousin of this routine, except (somehow) less feature-filled (lazy programmer)."
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x   [__TableGetVal $use(table) $use(xfield) $r]
    	set y   [__TableGetVal $use(table) $use(yfield) $r]
    	set xlo [tableGetLoFieldX use $r]
    
    	set barwidth [drawableScale $use(drawable) y $use(barwidth)]
    
    	set x1 [drawableTranslate $use(drawable) x $xlo]
    	set y1 [expr [drawableTranslate $use(drawable) y $y] - ($barwidth/2.0)]
    	set x2 [drawableTranslate $use(drawable) x $x]
    	set y2 [expr [drawableTranslate $use(drawable) y $y] + ($barwidth/2.0)]
    
    	# make the arg list and call the box routine
    	PsBox -coord $x1,$y1:$x2,$y2  -linecolor  $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
        }
    
        if {$use(legend) != ""} {
    	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmm,__Ymm:__Xpm,__Ypm -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize   $use(fillsize) -fillskip   $use(fillskip) -linewidth [expr $use(linewidth)/4.0] -linecolor $use(linecolor)"
        }
    }
    
    proc PlotVerticalIntervals {args} {
        set default {
    	{"drawable"   "default"     + "isDrawable -"       "name of the drawable area"}
    	{"table"      "default"     + "isTable -"          "name of table to use"}
    	{"xfield"     "x"           + "isTableField table" "table column with x data"}
    	{"ylofield"   "ylo"         + "isTableField table" "table column with ylo data"}
    	{"yhifield"   "yhi"         + "isTableField table" "table column with yhi data"}
    	{"align"      "c"           + "isMember c,l,r,n"   "c - center, l - left, r - right, n - none"}
    	{"linecolor"  "black"       + "isColor 1"          "color of the line"}
    	{"linewidth"  "1"           + "isNumeric 1"        "width of all lines"}
    	{"devwidth"   "3"           + "isNumeric 1"        "width of interval marker on top"}
        }
        ArgsProcessWithTypeChecking PlotVerticalIntervals default args use "" \
    	"Use this to plot interval markers in the y direction. The x column has the x value for each interval, and draws the interval between the ylo and yhi column values. The marker can take on many forms, as specified by the 'align' flag. Note the 'b' type in particular, which can be used to assemble box plots. "
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x   [__TableGetVal $use(table) $use(xfield) $r]
    	set ylo [__TableGetVal $use(table) $use(ylofield) $r]
    	set yhi [__TableGetVal $use(table) $use(yhifield) $r]
    
    	set xp   [drawableTranslate $use(drawable) x $x]
    	set ylop [drawableTranslate $use(drawable) y $ylo]
    	set yhip [drawableTranslate $use(drawable) y $yhi]
    
    	set dw   [expr $use(devwidth) / 2.0]
    	set hlw  [expr $use(linewidth) / 2.0]
    
    	switch -exact $use(align) {
    	    c {
    		PsLine -coord "$xp,$ylop : $xp,$yhip" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    l {
    		PsLine -coord "[expr $xp-$dw+$hlw],$ylop : [expr $xp-$dw+$hlw],$yhip" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    r {
    		PsLine -coord "[expr $xp+$dw-$hlw],$ylop : [expr $xp+$dw-$hlw],$yhip" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    n {
    		# no little lines on top and bottom
    	    }
    	    default {
    		Abort "Bad alignment ($use(align): should be c, l, r, or n"
    	    }
    	}
    
    	# vertical line between two end marks
    	PsLine -coord "[expr $xp-$dw],$yhip : [expr $xp+$dw],$yhip" \
    	    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	PsLine -coord "[expr $xp-$dw],$ylop : [expr $xp+$dw],$ylop" \
    	    -linecolor $use(linecolor) -linewidth $use(linewidth)
        }
    }
    
    proc PlotHorizontalIntervals {args} {
        set default {
    	{"drawable"   "default"     + "isDrawable -"       "name of the drawable area"}
    	{"table"      "default"     + "isTable -"          "name of table to use"}
    	{"yfield"     "y"           + "isTableField table" "table column with x data"}
    	{"xlofield"   "xlo"         + "isTableField table" "table column with xlo data"}
    	{"xhifield"   "xhi"         + "isTableField table" "table column with xhi data"}
    	{"align"      "c"           + "isMember c,u,l,n"   "c - center, u - upper, l - lower, n - none"}
    	{"linecolor"  "black"       + "isColor 1"          "color of the line"}
    	{"linewidth"  "1"           + "isNumeric 1"        "width of all lines"}
    	{"devwidth"   "3"           + "isNumeric 1"        "width of interval marker on top"}
        }
        ArgsProcessWithTypeChecking PlotHorizontalIntervals default args use "" \
    	"Use this to plot interval markers in the x direction. The y column has the y value for each interval, and draws the interval between the ylo and yhi column values. The marker can take on many forms, as specified by the 'align' flag. Note the 'b' type in particular, which can be used to assemble box plots. "
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set y   [__TableGetVal $use(table) $use(yfield) $r]
    	set xlo [__TableGetVal $use(table) $use(xlofield) $r]
    	set xhi [__TableGetVal $use(table) $use(xhifield) $r]
    
    	set yp   [drawableTranslate $use(drawable) y $y]
    	set xlop [drawableTranslate $use(drawable) x $xlo]
    	set xhip [drawableTranslate $use(drawable) x $xhi]
    
    	set dw   [expr $use(devwidth) / 2.0]
    	set hlw  [expr $use(linewidth) / 2.0]
    
    	switch -exact $use(align) {
    	    c {
    		PsLine -coord "$xlop,$yp : $xhip,$yp" \
    		-linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    l {
    		PsLine -coord "$xlop,[expr $yp-$dw+$hlw] : $xhip,[expr $yp-$dw+$hlw] " \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    u {
    		PsLine -coord "$xlop,[expr $yp+$dw-$hlw] : $xhip,[expr $yp+$dw-$hlw] " \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	    }
    	    n {
    		# no little lines
    	    }
    	    default {
    		Abort "Bad alignment ($use(align): should be c, l, or r"
    	    }
    	}
    
    	# vertical line between two end marks
    	PsLine -coord "$xhip,[expr $yp-$dw] : $xhip,[expr $yp+$dw] " \
    	    -linecolor $use(linecolor) -linewidth $use(linewidth)
    	PsLine -coord "$xlop,[expr $yp-$dw] : $xlop,[expr $yp+$dw] " \
    	    -linecolor $use(linecolor) -linewidth $use(linewidth)
        }
    }
    
    proc PlotHeat {args} {
        set default {
    	{"drawable"   "default"     + "isDrawable -"       "name of the drawable area"}
    	{"table"      "default"     + "isTable -"          "name of table to use"}
    	{"xfield"     "x"           + "isTableField table" "table column with x data"}
    	{"yfield"     "y"           + "isTableField table" "table column with y data"}
    	{"hfield"     "heat"        + "isTableField table" "table column with heat data"}
    	{"width"      "1"           + "isNumeric 1"        "width of each rectangle"}
    	{"height"     "1"           + "isNumeric 1"        "height of each rectangle"}
    	{"divisor"    "1"           + "isNumeric 1"        "how much to divide heat value by"}
    	{"label"      "false"       + "isBoolean 1"        "if true, add labels to each heat region reflecting count value"}
    	{"labelfont"  "Helvetica"   + "isFont 1"          "if using labels, what font should be used"}
    	{"labelcolor" "orange"      + "isColor 1"         "if using labels, what color is the font"}
    	{"labelsize"  "6.0"         + "isNumeric 1"       "if using labels, what font size should be used"}
        }
        # XXX - default is to use hfield as label field -- does this make sense?
        ArgsProcessWithTypeChecking PlotHeat default args use "" \
    	"Use this to plot a heat map. A heat map takes x,y,heat triples and plots a gray-shaded box with darkness proportional to (heat/divisor) and of size (width by height) at each (x,y) coordinate."
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x   [__TableGetVal $use(table) $use(xfield) $r]
    	set y   [__TableGetVal $use(table) $use(yfield) $r]
    
    	set tx   [drawableTranslate $use(drawable) x $x]
    	set ty   [drawableTranslate $use(drawable) y $y]
    
    	set val  [__TableGetVal $use(table) $use(hfield) $r]
    	set heat [expr $val / double($use(divisor))]
    
    	set w    [drawableScale $use(drawable) x $use(width)]
    	set h    [drawableScale $use(drawable) y $use(height)]
    
    	# absence of color is black (0,0,0)
    	set scolor [expr 1.0 - $heat]
    	set color  "%$scolor,$scolor,$scolor"
    	# puts stderr "val:$val heat:$heat --> $color"
    
    	# make the arg list and call the box routine
    	PsBox -coord "$tx,$ty : [expr $tx+$w],[expr $ty+$h]" \
    	    -linecolor  "" -linewidth 0 -fill t -fillcolor $color -fillstyle solid 
    
    	if {[True $use(label)]} {
    	    PsText -anchor c -text [format "%3.0f" $val] -coord [expr $tx+($w/2.0)],[expr $ty+($h/2.0)] \
    		-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor)
    	}
    
        }
    }
    
    
    proc PlotPoints {args} {
        set default {
    	{"drawable"     "default" + "isDrawable -"       "name of the drawable area"}
    	{"table"        "default" + "isTable -"          "name of table to use"}
    	{"xfield"       "x"       + "isTableField table" "table column with x data"}
    	{"yfield"       "y"       + "isTableField table" "table column with y data"}
    	{"size"         "2"       + "isNumeric 1"        "overall size of marker; used unless sizefield is specified"}
    	{"style"        "xline"   + "isPointStyle 1"      "label,hline,vline,plusline,xline,dline1,dline2,square,circle,triangle,utriangle,diamond,star,asterisk"}
    	{"sizefield"    ""        - "isTableField table" "if specified, table column with sizes for each point"}
    	{"sizediv"      "1"       + "isNumeric 1"        "if using sizefield, use sizediv to scale each value (sizefield gets divided by sizediv to determine the size of the point)"}
    	{"linecolor"    "black"   + "isColor 1"          "color of the line of the marker"}
    	{"linewidth"    "1"       + "isNumeric 1"        "width of lines used to draw the marker"}
    	{"fill"         "f"       + "isBoolean 1"        "for some shapes, filling makes sense; if desired, mark this true"}
    	{"fillcolor"    "black"   + "isColor 1"          "if filling, use this fill color"}
    	{"fillstyle"    "solid"   + "isFillStyle 1"      "if filling, which fill style to use"}
    	{"fillsize"     "3"       + "isNumeric 1"        "size of object in pattern"}
    	{"fillskip"     "4"       + "isNumeric 1"        "space between object in pattern"}
    	{"labelfield"   ""        - "isTableField table" "if specified, table column with labels for each point"}
    	{"labelrotate"  "0"       + "isNumeric 1"        "if using labels, rotate labels"}
    	{"labelanchor"  "c,c"     + "isTextAnchor 1"     "if using labels, center 'c' or right 'r' or left 'l' x-alignment for label text, or 'xanchor,l', 'xanchor,c', or 'xanchor,h' for x and y alignment of text (l - low, c - center, h - high alignment in y direction)"}
    	{"labelplace"  "c"        + "isMember c,s,n,w,e" "if using labels, place text: (c) centered on point, (s) below point, (n) above point, (w) west of point, (e) east of point"}
    	{"labelshift"   "0,0"     + "isNumeric 2"       "shift text in x,y direction"}
    	{"labelfont"    "Helvetica" + "isFont 1"        "if using labels, what font should be used"}
    	{"labelsize"    "6.0"     + "isNumeric 1"       "if using labels, font for label"}
    	{"labelcolor"   "black"   + "isColor 1"         "if using labels, what color font should be used"}
    	{"labelbgcolor" ""        - "isColor 1"         "if using labels, put a background color behind each"}
    	{"legend"       ""        - "isString 1"        "add this entry to the legend"}
        }
        ArgsProcessWithTypeChecking PlotPoints default args use "" \
    	"Use this to draw some points on a drawable. There are some obvious parameters: which drawable, which table, which x and y columns from the table to use, the color of the point, its linewidth, and the size of the marker. 'style' is a more interesting parameter, allowing one to pick a box, circle, horizontal line (hline), and 'x' that marks the spot, and so forth. However, if you set 'style' to label, PlotPoints will instead use a column from the table (as specified by the 'label' flag) to plot an arbitrary label at each (x,y) point. Virtually all the rest of the flags pertain to these text labels: whether to rotate them, how to anchor them, how to place them, font, size, and color. " 
    
        set t1 [clock clicks -milliseconds]
    
        set shift(0) $use(labelshift,0)
        set shift(1) $use(labelshift,1)
    
        # timing notes: 
        #   just getting values :   30ms / 2000pts
        #   + translation       :  130ms / 2000pts
        #   + filledcircle      : 1014ms / 2000pts (or 2pts/ms -- ouch!)
        #   + box               :  350ms / 2000pts 
        #   + switchstatement   : 1030ms / 2000pts 
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x [drawableTranslate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]
    	set y [drawableTranslate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]
    	if {$use(sizefield) == ""} {
    	    # empty -> a single size should be used
    	    set s $use(size)
    	} else {
    	    # non-empty -> sizefield should be used (i.e., ignore use(size))
    	    set s [expr [__TableGetVal $use(table) $use(sizefield) $r] / $use(sizediv)]
    	}
    
    	if [StringEqual $use(style) "label"] {
    		AssertNotEqual $use(labelfield) ""
    		set label [__TableGetVal $use(table) $use(labelfield) $r]
    		switch -exact $use(labelplace) {
    		    c { }
    		    s { set y [expr $y - $use(labelsize)] }
    		    n { set y [expr $y + $use(labelsize)] }
    		    w { set x [expr $x - $s - 2.0] }
    		    e { set x [expr $x + $s + 2.0] }
    		    default { Abort "bad 'place' flag ($use(flag)); should be c, s, n, w, or e" }
    		}
    		PsText -coord [expr $x+$shift(0)],[expr $y+$shift(1)] -text $label \
    		    -anchor $use(labelanchor) -rotate $use(labelrotate) \
    		    -font $use(labelfont) -size $use(labelsize) \
    		    -color $use(labelcolor) -bgcolor $use(labelbgcolor)
    		
    	} else {
    	    PsShape -style $use(style) -x $x -y $y -size $s \
    		-linecolor $use(linecolor) -linewidth $use(linewidth) \
    		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    		-fillsize $use(fillsize) -fillskip $use(fillskip) 
    	}
        }
    
        set t2 [clock clicks -milliseconds]
        Dputs table "PlotPoints: Plotted [TableGetNumRows -table $use(table)] points in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
    
        if {$use(legend) != ""} {
    	LegendAdd -text $use(legend) -picture "PsShape -style $use(style) -x __Xx -y __Yy -size __M2 -linecolor $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)" 
        }
    }
    
    proc doLabel {use__ x y row shiftx shifty offset} {
        upvar $use__ use
        set label  [__TableGetVal $use(table) $use(labelfield) $row]
        set labelx [expr $x + $shiftx]
        set labely [expr $y + $offset + $shifty]
        PsText -coord $labelx,$labely -text $label -anchor $use(labelanchor) \
    	-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor) -rotate $use(labelrotate) \
    	-bgcolor $use(labelbgcolor)
    }
    
    # XXX - should be PlotHorizontalLines
    proc PlotLines {args} {
        set default {
    	{"drawable"    "default"   + "isDrawable -"        "name of the drawable area"}
    	{"table"       "default"   + "isTable -"           "name of table to use"}
    	{"xfield"      "x"         + "isTableField table"  "table column with x data"}
    	{"yfield"      "y"         + "isTableField table"  "table column with y data"}
    	{"stairstep"   "false"     + "isBoolean 1"         "plot the data in a stairstep manner"}
    	{"linecolor"   "black"     + "isColor 1"           "color of the line of the marker"}
    	{"linewidth"   "1"         + "isNumeric 1"         "width of lines used to draw the marker"}
    	{"linedash"    "0"         + "isNumeric -"         "use dashes for this line (0 means no dashes)"}
    	{"labelfield"  ""          - "isTableField table"  "if specified, table column with labels for each point in line"}
    	{"labelplace"  "n"         + "isMember n,s"        "place the labels n (north) of the line, or s (south)"}
    	{"labelfont"   "Helvetica" + "isFont 1"            "font for labels"}
    	{"labelsize"   "8"         + "isNumeric 1"         "font size for labels"}
    	{"labelcolor"  "black"     + "isColor 1"           "font color for labels"}
    	{"labelanchor" "c"         + "isTextAnchor 1"      "anchor for the text"}
    	{"labelrotate" "0"         + "isNumeric 1"         "rotate the text this much"}
    	{"labelshift"  "0,0"       + "isNumeric 2"         "how much to shift the text"}
    	{"labelbgcolor" ""         - "isColor 1"           "if not empty, put this background color behind each text marking"}
    	{"legend"       ""         - "isString 1"          "add this entry to the legend"}
        }
        ArgsProcessWithTypeChecking PlotLines default args use "" \
    	"Use this function to plot lines. It is one of the simplest routines there is -- basically, it takes the x and y fields and plots a line through them. It does NOT sort them, though, so you might need to do that first if you want the line to look pretty. The usual line arguments can be used, including color, width, and dash pattern. "
    
        # get some things straight before looping
        switch -exact $use(labelplace) {
    	n { set offset +3 }
    	s { set offset -3 }
        }
    
        psGsave
        psNewpath
    
        # get text shifts for labelfield
        set cnt [ArgsParseCommaList $use(labelshift) shift]
        AssertEqual $cnt 2
    
        # XXX: nothing is drawn if there is just ONE point -- is this bad?
        set x [drawableTranslate $use(drawable) x [__TableGetVal $use(table) $use(xfield) 0]]  
        set y [drawableTranslate $use(drawable) y [__TableGetVal $use(table) $use(yfield) 0]]
        if {$use(labelfield) != ""} {
    	doLabel use $x $y 0 $shift(0) $shift(1) $offset
        }
        set lasty $y
        psMoveto $x $y
    
        for {set r 1} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set x [drawableTranslate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]
    	set y [drawableTranslate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]
    
    	# label the point, if desired
    	if {$use(labelfield) != ""} {
    	    doLabel use $x $y $r $shift(0) $shift(1) $offset
    	}
    	if [True $use(stairstep)] {
    	    psLineto $x $lasty
    	}
    	psLineto $x $y
    	set lasty $y
        }
    
        psSetcolor [psColor $use(linecolor)]
        psSetlinewidth $use(linewidth)
        if {$use(linedash) != 0} {
    	psSetdash $use(linedash)
        }
        psStroke
        psGrestore
    
        # now do legend stuff
        if {$use(legend) != ""} {
    	LegendAdd -text $use(legend) -picture "PsLine -coord __Xmw,__Yy:__Xpw,__Yy -linewidth $use(linewidth) -linecolor $use(linecolor)"
        }
    }
    
    
    proc PlotVerticalFill {args} {
        set default {
    	{"drawable"    "default" + "isDrawable -"       "name of the drawable area"}
    	{"table"       "default" + "isTable -"          "name of table to use"}
    	{"xfield"      "x"       + "isTableField table" "table column with x data"}
    	{"yfield"      "y"       + "isTableField table" "table column with y data"}
    	{"ylofield"    ""        - "isTableField table" "if not empty, use this table column to fill down to this value"}
    	{"yloval"      ""        - "isNumeric 1"        "if there is no ylofield, use this single value to fill down to; if empty, just use the min of y-range"}
    	{"fillcolor"   "gray"    + "isColor 1"          "fill color (if used)"}
    	{"fillstyle"   "solid"   + "isFillStyle 1"      "solid, boxes, circles, ..."}
    	{"fillsize"      "3"     + "isNumeric 1"        "size of object in pattern"}
    	{"fillskip"      "4"     + "isNumeric 1"        "space between object in pattern"}
    	{"legend"      ""        - "isString 1"         "add this entry to the legend"}
        }
        ArgsProcessWithTypeChecking PlotVerticalFill default args use "" \
    	"Use this function to fill a vertical region between either the values in yfield and the minimum of the y-range (default), the yfield values and the values in the ylofield, or the yfield values and a single yloval. Any pattern and color combination can be used to fill the filled space. "
    
        # get first point
        set xlast   [drawableTranslate $use(drawable) x [__TableGetVal $use(table) $use(xfield) 0]]  
        set ylast   [drawableTranslate $use(drawable) y [__TableGetVal $use(table) $use(yfield) 0]]
        set ylolast [drawableTranslate $use(drawable) y [tableGetLoFieldY use 0]]
        
        # now, get rest of points
        for {set r 1} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	# get the new points
    	set xcurr   [drawableTranslate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]  
    	set ycurr   [drawableTranslate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]
    	set ylocurr [drawableTranslate $use(drawable) y [tableGetLoFieldY use $r]]
    
    	# draw the stinking polygon between the last pair of points and the current points
    	psComment "PsPolygon $xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr"
    	PsPolygon -coord "$xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr" \
    	    -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    	    -fillsize $use(fillsize) -fillskip $use(fillskip) \
    	    -linewidth 0.1 -linecolor $use(fillcolor)
    	# xxx - make a little bit of linewidth so as to overlap neighboring regions
    	# the alternate is worse: having to draw one huge polygon
    
    	# move last points to current points
    	set xlast   $xcurr
    	set ylast   $ycurr
    	set ylolast $ylocurr
        }
    
        if {$use(legend) != ""} {
    	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmw,__Ymh:__Xpw,__Yph -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -linewidth 0.1 -linecolor $use(fillcolor)"
        }
    
    }
    
    # end including plot.tcl

    # begin including etc.tcl
    # tcl
    
    proc Circle {args} {
        set default {
    	{"drawable"   "default"     "the drawable; if 'canvas', just draw onto canvas directly (no translation)"}
    	{"coord"      "0,0"         "x1,y1"}
    	{"radius"     "1"           "radius of circle"}
    	{"linecolor"  "black"       "color of the line"}
    	{"linewidth"  "1"           "width of the line"}
    	{"fill"       "false"       "fill the box or not"} 
    	{"fillcolor"  "black"       "fill color (if used)"}
    	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
    	{"fillsize"   "3"           "object size in pattern"}
    	{"fillskip"   "4"           "space between objects in pattern"}
    	{"bgcolor"     ""           "if not empty, make the polyground have this color background"}
        }
    
        ArgsProcessWithDashArgs Circle default args use \
    	"Use this routine to draw a circle. Can be used to fill in a background or other accoutrement."
    
        set count [ArgsParseCommaList $use(coord) coord]
        AssertEqual $count 2
        set x1 [drawableTranslate $use(drawable) x $coord(0)]
        set y1 [drawableTranslate $use(drawable) y $coord(1)]
    
        PsCircle -coord $x1,$y1 \
    	-radius $use(radius) -linecolor $use(linecolor) -linewidth $use(linewidth) \
    	-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    	-fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
    }
    
    
    proc Box {args} {
        set default {
    	{"drawable"   "default"     "the drawable; if 'canvas', just draw onto canvas directly (no translation)"}
    	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
    	{"linecolor"  "black"       "color of the line"}
    	{"linewidth"  "1"           "width of the line"}
    	{"linedash"   "0"           "dash pattern for line"}
    	{"fill"       "false"       "fill the box or not"} 
    	{"fillcolor"  "black"       "fill color (if used)"}
    	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
    	{"fillsize"   "3"           "object size in pattern"}
    	{"fillskip"   "4"           "space between objects in pattern"}
    	{"bgcolor"    ""            "if not empty, background color for this box"}
        }
        ArgsProcessWithDashArgs Box default args use \
    	"Use this routine to draw a box. Can be used to fill in a background or other accoutrement."
    
        set count [ArgsParseItemPairList $use(coord) coord]
        AssertEqual $count 2
        set tx1 [drawableTranslate $use(drawable) x $coord(0,n1)]
        set ty1 [drawableTranslate $use(drawable) y $coord(0,n2)]
        set tx2 [drawableTranslate $use(drawable) x $coord(1,n1)]
        set ty2 [drawableTranslate $use(drawable) y $coord(1,n2)]
    
        PsBox -coord "$tx1,$ty1 : $tx2,$ty2" \
    	-linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
    	-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
    	-fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
    }
    
    proc Line {args} {
        set default {
    	{"drawable"       "default"     "the drawable; if 'canvas', just draw onto canvas directly"}
    	{"coord"          ""            "x1,y1: ... :xn,yn"}
    	{"linecolor"      "black"       "color of the line"}
    	{"linewidth"      "1"           "width of the line"}
    	{"linedash"       "0"           "define dashes for the line: how many points the dash is turned on for, then how many off, etc."}
    	{"closepath"      "false"       "whether to close the path or not"}
    	{"arrow"          "false"       "add an arrowhead at end"}
    	{"arrowheadlength" "4"          "length of the arrowhead"}
    	{"arrowheadwidth"  "3"          "width of the arrowhead"}
    	{"arrowlinecolor" "black"       "linecolor of the arrowhead"}
    	{"arrowlinewidth" "0.5"         "linewidth of the arrowhead"}
    	{"arrowfill"      "true"        "fill the arrowhead"}
    	{"arrowfillcolor" "black"       "the color to fill the arrowhead with"}
    	{"arrowstyle"     "normal"      "types of arrowheads: normal is only one right now"}
        }
        ArgsProcessWithDashArgs Line default args use \
    	"Use this to draw a line on a drawable. The most basic thing to specify is a list of points the line must be drawn through: x1,y1:x2,y2:...:xn,yn. 'closepath' is a postscript feature that should only be used when drawing a closed path and you wish for the line corners to match up; see a postscript manual for details. Lots of other options are available, including the color and width of the line, whether the line should be dashed, and whether to add an arrow at the end of the line (and its associated options). "
        set d $use(drawable)
    
        # translate each and every coord, then reassemble and pass to PsLine to do the real work
        AssertNotEqual $use(coord) ""
        set count [ArgsParseItemPairList $use(coord) coord]
        AssertGreaterThan $count 0
        set ucoord "[drawableTranslate $d x $coord(0,n1)],[drawableTranslate $d y $coord(0,n2)]"
        for {set i 1} {$i < $count} {incr i} {
    	set ucoord "$ucoord : [drawableTranslate $d x $coord($i,n1)],[drawableTranslate $d y $coord($i,n2)]"
        }
    
        # call the beast of a function: PsLine
        PsLine -coord $ucoord -linecolor $use(linecolor) -linewidth $use(linewidth) \
    	-closepath $use(closepath) -linedash $use(linedash) \
    	-arrow $use(arrow) -arrowheadlength $use(arrowheadlength) -arrowheadwidth $use(arrowheadwidth) \
    	-arrowlinecolor $use(arrowlinecolor) -arrowlinewidth $use(arrowlinewidth) \
    	-arrowfill $use(arrowfill) -arrowfillcolor $use(arrowfillcolor) \
    	-arrowstyle $use(arrowstyle)
    }
    
    proc Label {args} {
        set default {
    	{"drawable"  "default"   "drawable, if appropriate; if 'canvas', just label the canvas"}
    	{"text"      ""          "text to place on graph"}
    	{"font"      "Helvetica" "font face label"}
    	{"fontsize"  "10"        "font size of label"}
    	{"color"     "black"     "color of text"}
    	{"coord"     ""          "x,y (native ps coordinates by default)"}
    	{"rotate"    "0"         "angle to rotate text"}
    	{"anchor"    "c"         "c, l, r: anchor text on center, left, or right"}
    	{"shift"     "0,0"       "x,y: move label left or right (-x or +x), up or down (+y or -y)"}
    	{"bgcolor"    ""          "if not empty, put background behind the text of this color"}
        }
        ArgsProcessWithDashArgs Label default args use \
    	"Use this to place a text label on the canvas. Units are in raw canvas coordinates."
    
        set count [ArgsParseCommaList $use(coord) coord]
        AssertEqual $count 2
    
        set scount [ArgsParseCommaList $use(shift) shift]
        AssertEqual $scount 2
    
        set tx [expr [drawableTranslate $use(drawable) x $coord(0)] + $shift(0)]
        set ty [expr [drawableTranslate $use(drawable) y $coord(1)] + $shift(1)]
        PsText -coord $tx,$ty -text $use(text) -size $use(fontsize) -font $use(font) \
    	-rotate $use(rotate) -anchor $use(anchor) -color $use(color) -bgcolor $use(bgcolor)
    }
    
    proc reverse {s} {
        set s   [split $s ":"]
        set len [llength $s]
        set r   ""
        for {set i [expr $len-1]} {$i >= 0} {incr i -1} {
    	set e [lindex $s $i]
    	if {$r == ""} {
    	    set r $e
    	} else {
    	    set r "$r : $e"
    	}
        }
        return $r
    }
    
    proc GraphBreak {args} {
        set default {
    	{"drawable"  "default"   "drawable, if appropriate; if 'canvas', just label the canvas"}
    	{"coord"     ""          "starting x,y of graphbreak"}
    	{"width"     "4"         "width of a single break element"}
    	{"height"    "4"         "height of a single break element"}
    	{"gap"       "4"         "gap between each line in break"}
    	{"elements"  "4"         "number of breaks to draw"}
    	{"linewidth" "1"         "width of the line"}
    	{"linecolor" "black"     "line color"}
    	{"bgcolor"   "white"     "if non-empty, fill in the break w/ this color"}
        }
        ArgsProcessWithDashArgs GraphBreak default args use \
    	"Use this to draw a break symbol on a graph. Particularly useful for separating two drawables of the same graph that have a break in the y-axis. Limits: Only for y-axis right now."
    
        set count [ArgsParseCommaList $use(coord) coord]
        AssertEqual $count 2
        set ty [drawableTranslate $use(drawable) y $coord(1)]
    
        set halfwidth [expr ($use(elements)/2.0) * $use(width)]
    
        # make points of top line
        set j 0
        foreach ty "$ty [expr $ty-$use(gap)]" {
    	set tx [expr [drawableTranslate $use(drawable) x $coord(0)] - $halfwidth]
    	set clist($j) ""
    	for {set i 0} {$i <= $use(elements)} {incr i} {
    	    set x $tx
    	    if {[expr $i % 2] == 1} {
    		set y [expr $ty + $use(height)]
    	    } else {
    		set y [expr $ty]
    	    }
    	    if {$clist($j) != ""} {
    		set clist($j) "$clist($j) : $x,$y"
    	    } else {
    		set clist($j) "$x,$y"
    	    }
    	    set tx [expr $tx + $use(width)]
    	}
    	incr j
        }
    
        if {$use(bgcolor) != ""} {
    	PsPolygon -coord "$clist(0) : [reverse $clist(1)]" -linewidth 0 -bgcolor $use(bgcolor) 
        }
        PsLine -coord $clist(0) -linewidth $use(linewidth) -linecolor $use(linecolor)
        PsLine -coord $clist(1) -linewidth $use(linewidth) -linecolor $use(linecolor)
    }
    # end including etc.tcl

    # begin including newaxis.tcl
    # tcl
    
    proc isThisAnInt {value} {
        set nvalue [expr double(int($value))]
        if {$nvalue == $value} {
    	return 1
        }
        return 0
    }
    
    proc findMajorStep {drawable axis min max} {
        set scaleType [drawableGetScaleType $drawable $axis] 
        set ticsPerInch 3.5 ;# xxx pretty random here too
        set width [expr [drawableGetWidth $drawable ${axis}] / 72.0]
        set tics  [expr $width * $ticsPerInch]
        set step  [expr 1 + int(($max - $min) / $tics)]
        return $step
    }
    
    proc getOppositeAxis {axis} {
        switch -exact $axis {
    	x {return y}
    	y {return x}
        }
        Abort "bad axis: $axis" 
    }
    
    # fill in:
    #   labelbox(x,xlo)
    #   labelbox(x,xhi)
    #   labelbox(x,ylo)
    #   labelbox(x,yhi)
    # and same for y,*
    proc recordLabel {use__ labelbox__ axis x y label font fontsize anchor rotate} {
        upvar $use__      use
        upvar $labelbox__ labelbox
    
        # height and width
        set height $use(fontsize)
        set width  [psGetStringWidth $label $fontsize]
    
        # get anchors
        set count [ArgsParseCommaList $anchor a]
        if {$count == 2} {
    	set xanchor $a(0)
    	set yanchor $a(1)
        } elseif {$count == 1} {
    	set xanchor $a(0)
    	set yanchor l
        } else {
    	Abort "Bad anchor: $anchor"
        }
    
        # XXX deal with rotation XXX
        
        # now, find bounding box 
        switch -exact $xanchor {
    	l { set v(xlo) [expr $x] }
    	c { set v(xlo) [expr $x - ($width/2.0)] }
    	r { set v(xlo) [expr $x - $width] }
        }
        switch -exact $yanchor {
    	l { set v(ylo) [expr $y] }
    	c { set v(ylo) [expr $y - ($height/2.0)] }
    	h { set v(ylo) [expr $y - $height] }
        }
        set v(xhi) [expr $v(xlo) + $width]
        set v(yhi) [expr $v(ylo) + $height]
    
        # PsLine -coord "$v(xlo),$v(ylo) : $v(xlo),$v(yhi) : $v(xhi),$v(yhi) : $v(xhi),$v(ylo)" -closepath t -linecolor yellowgreen
    
        if [info exists labelbox($axis,xlo)] {
    	foreach value {xlo ylo} {
    	    if {$v($value) < $labelbox($axis,$value)} {
    		set labelbox($axis,$value) $v($value)
    	    }
    	}
    	foreach value {xhi yhi} {
    	    if {$v($value) > $labelbox($axis,$value)} {
    		set labelbox($axis,$value) $v($value)
    	    }
    	}
        } else {
    	foreach value {xlo xhi ylo yhi} {
    	    set labelbox($axis,$value) $v($value)
    	}
        }
    
        # PsBox -coord "$labelbox($axis,xlo),$labelbox($axis,ylo) : $labelbox($axis,xhi),$labelbox($axis,yhi)" -linecolor red -linewidth 0.25
    }
    
    # lots of guesses as to where xtitle, ytitle, and overall title will go
    # these will later get adjusted by doLabels and doTics, so as to avoid
    # the problem of writing the titles over the labels and tics (surprise)
    proc doTitleInit {use__ title__ labelbox__ t__} {
        upvar $use__      use
        upvar $title__    title
        upvar $labelbox__ labelbox
        upvar $t__        t
    
        # some space between titles and the nearest text to them; 3 is randomly chosen
        set offset 3.0
    
        if {$use(title) != ""} {
    	set title(title,y) [expr $t(yrange,max) + $offset]
    	# XXX: if the xtitle exists, and its labelstyle is 'in', and it is high enough
    	#      it may run into the title, then what?
    	switch -exact $use(titleplace) {
    	    c {
    		set title(title,x)      [expr ($t(xrange,min) + $t(xrange,max)) / 2.0]
    		set title(title,anchor) c,l
    	    }
    	    l {
    		set title(title,x)      [expr $t(xrange,min) + $offset]
    		set title(title,anchor) l,l
    	    }
    	    r {
    		set title(title,x)      [expr $t(xrange,max) - $offset]
    		set title(title,anchor) r,l
    	    }
    	    default { Abort "Bad titleanchor: Must be c, l, or r" }
    	}
    	# allow user override of this option, of course
    	if {$use(titleanchor) != ""} {
    	    set title(title,anchor) $use(titleanchor)
    	}
        }
    
        if {$use(ytitle) != ""} {
    	switch -exact $use(labelstyle) {
    	    in  { 
    		set title(ytitle,x) [expr $t(yaxis,pos) + $offset]
    		set yanchor         h
    	    }
    	    out { 
    		set title(ytitle,x) [expr $t(yaxis,pos) - $offset]
    		set yanchor         l
    	    }
    	    default { Abort "bad labelstyle" }
    	}
    	
    	switch -exact $use(ytitleplace) {
    	    c {
    		set title(ytitle,y)      [expr ($t(yrange,max) + $t(yrange,min)) / 2.0] 
    		set xanchor              c
    	    }
    	    l {
    		set title(ytitle,y)      [expr $t(yrange,min) + $offset]
    		set xanchor              l
    	    }
    	    u {
    		set title(ytitle,y)      [expr $t(yrange,max) - $offset]
    		set xanchor              r
    	    }
    	    default { Abort "Bad titleanchor: Must be c, l, or u" }
    	}
    	# allow user override of this option, of course
    	if {$use(ytitleanchor) != ""} {
    	    set title(ytitle,anchor) $use(ytitleanchor)
    	} else {
    	    set title(ytitle,anchor) $xanchor,$yanchor
    	}
    
    	# try to move ytitle based on labelbox(y,*)
    	if [True $use(labels)] {
    	    if [StringEqual $use(labelstyle) out] {
    		if {($title(ytitle,x) >= $labelbox(y,xlo))} {
    		    set title(ytitle,x) [expr $labelbox(y,xlo) - $offset]
    		}
    	    } 
    	    if [StringEqual $use(labelstyle) in] {
    		if {($title(ytitle,x) <= $labelbox(y,xhi))} {
    		    set title(ytitle,x) [expr $labelbox(y,xhi) + $offset]
    		}
    	    } 
    	}
        }
    
        if {$use(xtitle) != ""} {
    	switch -exact $use(labelstyle) {
    	    in  { 
    		set title(xtitle,y) [expr $t(xaxis,pos) + $offset]
    		set yanchor         l
    	    }
    	    out { 
    		set title(xtitle,y) [expr $t(xaxis,pos) - $offset]
    		set yanchor         h
    	    }
    	    default { Abort "bad labelstyle" }
    	}
    
    	switch -exact $use(xtitleplace) {
    	    c {
    		set title(xtitle,x)      [expr ($t(xrange,min) + $t(xrange,max)) / 2.0]
    		set xanchor              c
    	    }
    	    l {
    		set title(xtitle,x)      [expr $t(xrange,min) + $offset]
    		set xanchor              l
    	    }
    	    r {
    		set title(xtitle,x)      [expr $t(xrange,max) - $offset]
    		set xanchor              r
    	    }
    	    default { Abort "Bad titleanchor: Must be c, l, or r" }
    	}
    	# allow user override of this option, of course
    	if {$use(xtitleanchor) != ""} {
    	    set title(xtitle,anchor) $use(xtitleanchor)
    	} else {
    	    set title(xtitle,anchor) $xanchor,$yanchor
    	}
    
    	if [True $use(labels)] {
    	    if {($title(xtitle,y) >= $labelbox(x,ylo))} {
    		set title(xtitle,y) [expr $labelbox(x,ylo) - $offset]
    	    }
    	}
        }
    }
    
    proc doTitleFini {use__ title__ labelbox__ t__} {
        upvar $use__      use
        upvar $title__    title
        upvar $labelbox__ labelbox
        upvar $t__        t
    
        # finish up
        if {$use(title) != ""} {
    	set count [ArgsParseCommaList $use(titleshift) shift]
    	AssertEqual $count 2
    	PsText -coord [expr $shift(0)+$title(title,x)],[expr $shift(1)+$title(title,y)] -text $use(title) \
    	    -font $use(titlefont) -size $use(titlesize) -color $use(titlecolor) \
    	    -anchor $title(title,anchor) -bgcolor $use(titlebgcolor) -rotate $use(titlerotate)
        }
    
        if {$use(ytitle) != ""} {
    	set count [ArgsParseCommaList $use(ytitleshift) shift]
    	AssertEqual $count 2
    	PsText -coord [expr $shift(0)+$title(ytitle,x)],[expr $shift(1)+$title(ytitle,y)] -text $use(ytitle) \
    	    -font $use(ytitlefont) -size $use(ytitlesize) -color $use(ytitlecolor) \
    	    -anchor $title(ytitle,anchor) -bgcolor $use(ytitlebgcolor) -rotate $use(ytitlerotate)
        }
    
        if {$use(xtitle) != ""} {
    	set count [ArgsParseCommaList $use(xtitleshift) shift]
    	AssertEqual $count 2
    	PsText -coord [expr $shift(0)+$title(xtitle,x)],[expr $shift(1)+$title(xtitle,y)] -text $use(xtitle) \
    	    -font $use(xtitlefont) -size $use(xtitlesize) -color $use(xtitlecolor) \
    	    -anchor $title(xtitle,anchor) -bgcolor $use(xtitlebgcolor) -rotate $use(xtitlerotate)
        }
    }
    
    proc doTitle  {use__ labelbox__ t__} {
        upvar $use__      use
        upvar $labelbox__ labelbox
        upvar $t__        t
    
        doTitleInit use title labelbox t
        doTitleFini use title labelbox t
    }
    
    # this pulls everything out into a usable format
    proc doUnpackDescription {use__ axis labels__ rangemin rangemax} {
        upvar $use__    use
        upvar $labels__ labels
    
        # pull out vars that are axis dependent (why, well, just to make the code a little more readable)
        set uauto   $use(${axis}auto)
        set umanual $use(${axis}manual)
        set uformat $use(${axis}labelformat)
        set utimes  $use(${axis}labeltimes)
    
        # now, unpack label and tic info
        if {$umanual != ""} {
    	# if manual is not empty, use it (override auto)
    	set labels(cnt) [ArgsParseItemPairList $umanual labels]
        } else {
    	# manual is empty --> use auto description
    	set count [ArgsParseCommaList $uauto auto]
    	AssertEqual $count 3
    	# expecting min, max, step
    	if {$auto(0) == ""} {
    	    set r(label,min) $rangemin
    	} else {
    	    set r(label,min) $auto(0)
    	}
    
    	if {$auto(1) == ""} {
    	    set r(label,max) $rangemax
    	} else {
    	    set r(label,max) $auto(1)
    	}
    
    	if {$auto(2) == ""} {
    	    # XXX ;# this assumes that rangemin, max are linear values, whereas they MIGHT NOT BE
    	    # more proper to: take virtual values, map them to linear, figure out what to do then
    	    set r(label,step) [findMajorStep $use(drawable) $axis $rangemin $rangemax]
    	} else {
    	    set r(label,step) $auto(2)
    	}
    
    	# here, we are supposed to figure out how to format the labels on the axis
    	# challenge: may be one of many types
    	# right now, base on scale type:
    	#   if category --> use %s
    	#   if anything else --> figure out if %d makes sense, otherwise use %f
    	if {$uformat == ""} {
    	    # XXX have to do different things depending on the scaleType
    	    set scaleType [drawableGetScaleType $use(drawable) $axis] 
    	    if [StringEqual $scaleType "category"] {
    		set uformat "%s"
    	    } else {
    		# this means we have to guess; is it an integer, or a float?
    		set test 0
    		foreach v "min max step" {
    		    if {! [isThisAnInt [expr $utimes * $r(label,$v)]]} {
    			incr test
    		    }
    		}
    		if {$test > 0} {
    		    # if it's a float, how many decimal points do we need?
    		    # XXX -- need to better compute how many XXX we need
    		    set uformat "%.1f"
    		} else {
    		    set uformat "%i"
    		}
    	    }
    	}
    	
    	# fill in array 'labels' with (n1=position,n2=label) pairs
    	# these are used by doTics and doLabels to draw tics and labels at the specified spots
    	set i     0
    	set scale [drawableGetScaleType $use(drawable) $axis]
    	foreach v [drawableGetRangeIterator $use(drawable) $axis $r(label,min) $r(label,max) $r(label,step)] {
    	    # drawableGetRangeIterator returns a set of virtual positions
    	    set labels($i,n1) $v
    
    	    # here, look for %i or %d 
    	    # if you see it, cast result with int(), otherwise just take in raw form
    	    #   (otherwise, if you say try to print a float (like 3.34) as a %d, Tcl will barf)
    	    set uformatptr [string index $uformat [expr [string length $uformat] - 1]]
    	    if {[StringEqual $uformatptr "d"] || [StringEqual $uformatptr "i"]} {
    		set labels($i,n2) [format $uformat [expr int($v * $utimes)]]
    	    } else {
    		set labels($i,n2) [format $uformat [expr ($v * $utimes)]]
    	    }
    
    	    # i is the index into the labels array, hence important
    	    incr i
    	}
    	set labels(cnt) $i
        }
    }
    
    proc toggleStyle {style} {
        if [StringEqual $style "in"] {
    	return "out"
        } elseif [StringEqual $style "out"] {
    	return "in"
        } else {
    	return "centered"
        }
    }
    
    
    proc doLabels {use__ labels__ axis axispos ticstyle labelbox__} {
        upvar $use__      use
        upvar $labels__   labels
        upvar $labelbox__ labelbox
    
        # how much space between fonts and tics, basically
        set offset 3.0 
    
        # set t(pt) to the place where labels should be drawn
        #   for yaxis, this is the x position of the labels
        #   for xaxis, this is the y position of the labels
        # t(pt) thus does not changed and is used to draw each of the labels
        if [StringEqual $use(labelstyle) "out"] {
    	set xanchor c,h
    	set yanchor r,c
    	switch -exact $ticstyle {
    	    in       { set t(pt) [expr $axispos - $offset] }
    	    out      { set t(pt) [expr $axispos - $use(ticmajorsize) - $offset] }
    	    centered { set t(pt) [expr $axispos - ($use(ticmajorsize)/2.0) - $offset] }
    	}
        }
        if [StringEqual $use(labelstyle) "in"] {
    	set xanchor c,l
    	set yanchor l,c
    	switch -exact $ticstyle {
    	    in       { set t(pt) [expr $axispos + $use(ticmajorsize) + $offset] }
    	    out      { set t(pt) [expr $axispos + $offset] }
    	    centered { set t(pt) [expr $axispos + ($use(ticmajorsize)/2.0) + $offset] }
    	}
        }
    
        # allow intelligent override, otherwise provide solid guess as to label placement
        if {$use(xlabelanchor) == ""} {
    	set use(xlabelanchor) $xanchor
        }
        if {$use(ylabelanchor) == ""} {
    	set use(ylabelanchor) $yanchor
        }
    
        # draw the labels
        for {set i 0} {$i < $labels(cnt)} {incr i} {
    	set label $labels($i,n2)
    	
    	# see if this is an "empty" label; if so, don't draw it
    	# set index [string compare -length [string length [drawableGetEmptyMarker]] $label [drawableGetEmptyMarker]]
    	# if {$index == 0} {
    	    # this is an empty label, thus do not draw to screen
    	#     set label ""
    	# }
    
    	set v     $labels($i,n1)
    	set t(v)  [drawableTranslate $use(drawable) $axis $v]
    	switch -exact $axis {
    	    x { 
    		set count [ArgsParseCommaList $use(xlabelshift) shift]
    		AssertEqual $count 2
    		set x [expr $t(v)+$shift(0)]
    		set y [expr $t(pt)+$shift(1)]
    		PsText -coord $x,$y -text "$label" \
    		    -font $use(font) -size $use(fontsize) -color $use(fontcolor) \
    		    -anchor $use(xlabelanchor) -rotate $use(xlabelrotate) -bgcolor $use(xlabelbgcolor)
    
    		# record where text is s.t. later title positions are properly placed 
    		recordLabel use labelbox x $x $y $label $use(font) $use(fontsize) $use(xlabelanchor) $use(xlabelrotate)
    	    }
    	    y {
    		set count [ArgsParseCommaList $use(ylabelshift) shift]
    		AssertEqual $count 2
    		set x [expr $t(pt)+$shift(0)]
    		set y [expr $t(v)+$shift(1)]
    		PsText -coord $x,$y -text "$label" \
    		    -font $use(font) -size $use(fontsize) -color $use(fontcolor) \
    		    -anchor $use(ylabelanchor) -rotate $use(ylabelrotate) -bgcolor $use(ylabelbgcolor)
    
    		# record where text is s.t. later title positions are properly placed 
    		recordLabel use labelbox y $x $y $label $use(font) $use(fontsize) $use(ylabelanchor) $use(ylabelrotate)
    	    }
    	}
        }
    }
    
    
    proc doTics {use__ labels__ axis axispos ticstyle ticsize title__} {
        upvar $use__    use
        upvar $labels__ labels
        upvar $title__  title
    
        # calculate disposition of tics based on user preference
        switch -exact $ticstyle {
    	in {
    	    set t(hi) [expr $axispos + $ticsize]
    	    set t(lo) $axispos
    	}
    	out {
    	    set t(hi) $axispos
    	    set t(lo) [expr $axispos - $ticsize]
    	}
    	centered {
    	    set t(hi) [expr $axispos + ($ticsize/2.0)]
    	    set t(lo) [expr $axispos - ($ticsize/2.0)]
    	}
        }
    
        # draw the tic marks AT EACH LABEL in labels array
        for {set i 0} {$i < $labels(cnt)} {incr i} {
    	set v    $labels($i,n1)
    	set t(v) [drawableTranslate $use(drawable) $axis $v]
    	switch -exact $axis {
    	    x { 
    		PsLine -coord "$t(v),$t(lo):$t(v),$t(hi)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    }
    	    y {
    		PsLine -coord "$t(lo),$t(v):$t(hi),$t(v)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
    	    }
    	}
        }
    }
    
    proc AxesTicsLabels {args} {
        set default {
    	{"drawable"      "default"    "the relevant drawable"}
    
    	{"linecolor"     "black"      "color of axis line"}
    	{"linewidth"     "1"          "width of axis line"}
    	{"linedash"      "0"          "dash parameters; will make axes dashed, but not tic marks"}
    
    	{"style"         "xy"         "which axes to draw: 'xy', 'x', 'y', 'box' are options"}
    	{"labelstyle"    "out"        "are labels 'in' or 'out'? for xaxis, 'out' means below/'in' above; for yaxis, 'out' means left/'in' right"}
    	{"ticstyle"      "out"        "are tics 'in', 'out', or 'centered'? (inside the axes, outside the axes, or centered upon the axes)"}
    
    	{"axis"          "true"       "whether to draw the actual axes or not"}
    	{"labels"        "true"       "whether to put labels on or not; useful to set to false, for example, when "}
    	{"majortics"     "true"       "whether to put majortics on axes or not"}
    	{"minortics"     "false"      "whether to put minortics on axes or not"}
    
    	{"xaxisrange"    ""           "min and max values to draw xaxis between; empty means whole range"}
    	{"yaxisrange"    ""           "min and max values to draw yaxis between; empty means whole range"}
    	{"xaxisposition" ""           "which y value x-axis is located at; if empty, min of range; ignored by 'box' style"}
    	{"yaxisposition" ""           "which x value y-axis is located at; if empty, min of range; ignored by 'box' style"}
    
    	{"xauto"         ",,"         "'x1,x2,step' (will put labels and major tics from x1 to x2 with step between each); can leave any of these empty and the routine will fill in a guess (either the min or max of the range, or a guess for the step), e.g., 0,,2 means start at 0, fill in the max of the xrange for a max value, and set the step to 2. The default is to guess all of these values"}
    	{"xmanual"       ""           "just specify location of labels/major tics all by hand with a list of form: 'x1,label1:x2,label2:...'"}
    	{"yauto"         ",,"         "similar to xauto, but for the yaxis"}
    	{"ymanual"       ""           "similar to xmanual, but for the yaxis"}
    
    	{"ticmajorsize"  "4"          "size of the major tics"}
    	{"ticminorsize"  "2.5"        "size of the minor tics"}
    
    	{"xticminorcnt"  "2"          "how many minor tics per major tic (x axis)"}
    	{"yticminorcnt"  "2"          "how many minor tics per major tic (y axis)"}
    
    	{"font"          "Helvetica"  "font to use (if any)"}
    	{"fontsize"      "10"         "font size of labels (if any)"}
    	{"fontcolor"     "black"      "font color"}
    
    	{"xlabelbgcolor"  ""           "if non-empty, put a background colored square behind the xlabels"}
    	{"ylabelbgcolor"  ""           "just like xbgcolor, but for ylabels"}
    
    	{"xlabelrotate"   "0"          "use specified rotation for x labels"}
    	{"ylabelrotate"   "0"          "use specified rotation for y labels"}
    
    	{"xlabelanchor"   ""           "text anchor for labels along the x axis; empty means routine should guess"}
    	{"ylabelanchor"   ""           "same as xanchor, but for labels along the y axis"}
    
    	{"xlabelformat"   ""           "format string to use for xlabels; e.g., %i or %d for integers, %f for floats, %.1f for floats with one decimal point, etc.; empty (the default) implies the routine's best guess; can also use this to add decoration to the label, e.g., '%i %%' will add a percent sign to each integer label, and so forth"}
    	{"ylabelformat"   ""           "similar to xformat, but for ylabels"}
    
    	{"xlabeltimes"   "1"          "what to multiple xlabel by; e.g., if 10, 1->10, 2->20, etc., if 0.1, 1->0.1, etc."}
    	{"ylabeltimes"   "1"          "similar to xmul, but for ylabels"}
    
    	{"xlabelshift"   "0,0"        "shift xlabels left/right, up/down (e.g., +4,-3 -> shift right 4, shift down 3)"}
    	{"ylabelshift"   "0,0"        "similar to xshift, but for ylabels"}
    
    	{"xtitle"        ""           "title along the x axis"}
    	{"xtitlefont"    "Helvetica"  "xtitle font to use"}
    	{"xtitlesize"    "10"         "xtitle font size"}
    	{"xtitlecolor"   "black"      "xtitle font color"}
    	{"xtitleplace"   "c"          "c - center, l - left, r - right"}
    	{"xtitlecoord"   ""           "coordinates of title; if empty, use best guess (can micro-adjust with -titleshift)"}
    	{"xtitleshift"   "0,0"        "use this to micro-adjust the placement of the title"}
    	{"xtitlerotate"  "0"          "how much to rotate the title"}
    	{"xtitleanchor"  ""           "how to anchor the text; empty means we will guess"}
    	{"xtitlebgcolor" ""           "if not-empty, put this color behind the title"}
    
    	{"ytitle"        ""           "title along the y axis"}
    	{"ytitlefont"    "Helvetica"  "ytitle font to use"}
    	{"ytitlesize"    "10"         "ytitle font size"}
    	{"ytitlecolor"   "black"      "ytitle font color"}
    	{"ytitleplace"   "c"          "c - center, l - lower, u - upper"}
    	{"ytitlecoord"   ""           "coordinates of title; if empty, use best guess (can micro-adjust with -titleshift)"}
    	{"ytitleshift"   "0,0"        "use this to micro-adjust the placement of the title"}
    	{"ytitlerotate"  "90"         "how much to rotate the title"}
    	{"ytitleanchor"  ""           "how to anchor the text; empty means we will guess"}
    	{"ytitlebgcolor" ""           "if not-empty, put this color behind the title"}
    
    	{"title"         ""           "title along the y axis"}
    	{"titlefont"     "Helvetica"  "title font to use"}
    	{"titlesize"     "10"         "title font size"}
    	{"titlecolor"    "black"      "title font color"}
    	{"titleplace"    "c"          "c - center, l - left, r - right"}
    	{"titleshift"    "0,0"        "use this to micro-adjust the placement of the title"}
    	{"titlerotate"   "0"          "how much to rotate the title"}
    	{"titleanchor"   ""           "how to anchor the text; empty means we will guess"}
    	{"titlebgcolor"  ""           "if not-empty, put this color behind the title"}
        }
        ArgsProcessWithDashArgs AxesTicsLabels default args use \
    	"Use this to draw some axes. It is supposed to be simpler and easier to use than the older package. We will see about that..."
    
        # get min and max of ranges
        # this is done in the VIRTUAL space
        #   thus, must be Translated to get to points we can draw 
        set r(xrange,min) [drawableGetVirtualMin $use(drawable) x]
        set r(xrange,max) [drawableGetVirtualMax $use(drawable) x]
        set r(yrange,min) [drawableGetVirtualMin $use(drawable) y]
        set r(yrange,max) [drawableGetVirtualMax $use(drawable) y]
    
        # figure out where axes will go
        if {$use(xaxisposition) != ""} {
    	set r(xaxis,pos) $use(xaxisposition)
        } else {
    	set r(xaxis,pos) $r(yrange,min)
        }
        if {$use(yaxisposition) != ""} {
    	set r(yaxis,pos) $use(yaxisposition)
        } else {
    	set r(yaxis,pos) $r(xrange,min)
        }
    
        # find out ranges of each axis
        if {$use(xaxisrange) != ""} {
    	set count [ArgsParseCommaList $use(xaxisrange) xrange]
    	AssertEqual $count 2
    	set r(xaxis,min) $xrange(0)
    	set r(xaxis,max) $xrange(1)
        } else {
    	set r(xaxis,min) $r(xrange,min)
    	set r(xaxis,max) $r(xrange,max)
        }
        if {$use(yaxisrange) != ""} {
    	set count [ArgsParseCommaList $use(yaxisrange) yrange]
    	AssertEqual $count 2
    	set r(yaxis,min) $yrange(0)
    	set r(yaxis,max) $yrange(1)
        } else {
    	set r(yaxis,min) $r(yrange,min)
    	set r(yaxis,max) $r(yrange,max)
        }
    
        # translate each of these values into points
        foreach v "xaxis,min xaxis,max xrange,min xrange,max yaxis,pos" {
    	set t($v) [drawableTranslate $use(drawable) x $r($v)]
    	# puts "translating: $v --> $t($v)"
        }
        foreach v "yaxis,min yaxis,max yrange,min yrange,max xaxis,pos" {
    	set t($v) [drawableTranslate $use(drawable) y $r($v)]
    	# puts "translating: $v :: $r($v) --> $t($v)"
        }
    
        # adjust for linewidths
        set half [expr $use(linewidth)/2.0]
        foreach min "xaxis,min yaxis,min" {
    	set t($min) [expr $t($min) - $half]
        }
        foreach max "xaxis,max yaxis,max" {
    	set t($max) [expr $t($max) + $half]
        }
    
        AssertIsMemberOf $use(style) "x y xy box"
    
        # first, draw axis lines
        #   these basically take the min and max of each virtual range
        #   and draw lines to connect them (depending on whether x, y, xy, or box is preferred)
        if [True $use(axis)] {
    	switch -exact $use(style) {
    	    x {
    		PsLine -coord "$t(xaxis,min),$t(xaxis,pos):$t(xaxis,max),$t(xaxis,pos)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    	    }
    	    y {
    		PsLine -coord "$t(yaxis,pos),$t(yaxis,min):$t(yaxis,pos),$t(yaxis,max)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    	    }
    	    xy {
    		PsLine -coord "$t(xaxis,min),$t(xaxis,pos):$t(xaxis,max),$t(xaxis,pos)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    		PsLine -coord "$t(yaxis,pos),$t(yaxis,min):$t(yaxis,pos),$t(yaxis,max)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    	    }
    	    box {
    		PsLine -coord "$t(xaxis,min),$t(yrange,min):$t(xaxis,max),$t(yrange,min)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    		PsLine -coord "$t(xrange,min),$t(yaxis,min):$t(xrange,min),$t(yaxis,max)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    		PsLine -coord "$t(xaxis,min),$t(yrange,max):$t(xaxis,max),$t(yrange,max)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    		PsLine -coord "$t(xrange,max),$t(yaxis,min):$t(xrange,max),$t(yaxis,max)" \
    		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
    	    }
    	}
        }
    
        # get description of which tics, labels to make
        doUnpackDescription use x xlabels $r(xrange,min) $r(xrange,max) 
        doUnpackDescription use y ylabels $r(yrange,min) $r(yrange,max) 
    
        # now, tic marks
        if [True $use(majortics)] {
    	AssertIsMemberOf $use(ticstyle) "in out centered"
    	
    	switch -exact $use(style) {
    	    x {
    		doTics use xlabels x $t(xaxis,pos) $use(ticstyle) $use(ticmajorsize) label
    	    }
    	    y {
    		doTics use ylabels y $t(yaxis,pos) $use(ticstyle) $use(ticmajorsize) label
    	    }
    	    xy {
    		doTics use xlabels x $t(xaxis,pos) $use(ticstyle) $use(ticmajorsize) label
    		doTics use ylabels y $t(yaxis,pos) $use(ticstyle) $use(ticmajorsize) label
    	    }
    	    box {
    		doTics use xlabels x $t(yrange,min) $use(ticstyle) $use(ticmajorsize) label
    		doTics use ylabels y $t(xrange,min) $use(ticstyle) $use(ticmajorsize) label
    		doTics use xlabels x $t(yrange,max) [toggleStyle $use(ticstyle)] $use(ticmajorsize) label
    		doTics use ylabels y $t(xrange,max) [toggleStyle $use(ticstyle)] $use(ticmajorsize) label
    	    }
    	}
        }
    
        # minor tics
        if [True $use(minortics)] {
    	# calculate x positions for x-axis minortics
    	# XXX
    	Abort "minor tics not implemented"
    	set c 0
    	for {set i 0} {$i < [expr $xlabels(cnt)-1]} {incr i} {
    	    for {set j 0} {$j < $use(xminorratio)} {incr j} {
    		set xminorlabels($c,n1) [expr $xlabels($i,n1) + (($xlabels([expr $i+1],n1) - $xlabels($i,n1)) / $use(xminorratio))]
    		# puts "$c :: $xminorlabels($c,n1)"
    		incr c
    	    }
    	}
    	set xminorlabels(cnt) $i
    	
    	switch -exact $use(style) {
    	    x {
    		doTics use xminorlabels x $t(xaxis,pos) $use(ticstyle) $use(ticminorsize) label
    	    }
    	    y {
    		doTics use yminorlabels y $t(yaxis,pos) $use(ticstyle) $use(ticminorsize) label
    	    }
    	    xy {
    		doTics use xminorlabels x $t(xaxis,pos) $use(ticstyle) $use(ticminorsize) label
    		doTics use yminorlabels y $t(yaxis,pos) $use(ticstyle) $use(ticminorsize) label
    	    }
    	    box {
    		doTics use xminorlabels x $t(yrange,min) $use(ticstyle) $use(ticminorsize) label
    		doTics use yminorlabels y $t(xrange,min) $use(ticstyle) $use(ticminorsize) label
    		doTics use xminorlabels x $t(yrange,max) [toggleStyle $use(ticstyle)] $use(ticminorsize) label
    		doTics use yminorlabels y $t(xrange,max) [toggleStyle $use(ticstyle)] $use(ticminorsize) label
    	    }
    	}
        }
    
        # now, labels
        if [True $use(labels)] {
    	switch -exact $use(style) {
    	    x {
    		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
    	    }
    	    y {
    		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
    	    }
    	    xy {
    		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
    		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
    	    }
    	    box {
    		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
    		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
    	    }
    	}
        }
    
        # finally, do the three titles: overall title, yaxis title, xaxis title
        doTitle use labelbox t
    }
    
    # does the work for Grid
    proc doGrid {use__ uaxis ustep urange} {
        upvar $use__ use
    
        AssertNotEqual $ustep {}
        set otherAxis [getOppositeAxis $uaxis]
    
        # autoextract ranges
        if {$urange == ""} {
    	# THIS SHOULD BE TRANSLATABLE
    	set range(0) [drawableGetVirtualMin $use(drawable) $uaxis]
    	set range(1) [drawableGetVirtualMax $use(drawable) $uaxis]
        } else {
    	set count [ArgsParseCommaList $urange range]
    	AssertEqual $count 2
        }
    
        # THIS SHOULD BE TRANSLATABLE
        # finally, draw some grid marks
        set otherMin [drawableGetVirtualMin $use(drawable) $otherAxis]
        set otherMax [drawableGetVirtualMax $use(drawable) $otherAxis]
    
        # iterate over the range
        foreach v [drawableGetRangeIterator $use(drawable) $uaxis $range(0) $range(1) $ustep] {
    	switch -exact $uaxis {
    	    x {
    		Line -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
    		    -coord $v,$otherMin:$v,$otherMax
    	    } 
    	    y {
    		Line -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
    		    -coord $otherMin,$v:$otherMax,$v
    	    }
    	}
        }
    }
    
    proc Grid {args} {
        set default {
    	{"drawable"   "default"    "the relevant drawable"}
    	{"linecolor"  "black"      "color of axis line"}
    	{"linewidth"  "0.5"        "width of axis line"}
    	{"linedash"   "0"          "dash parameters; will make axes dashed, but not tic marks"}
    	{"x"          "true"       "specify false to turn off grid in x direction (vertical lines)"}
    	{"y"          "true"       "specify false to turn off grid in y direction (horizontal lines)"}
    	{"xrange"     ""           "empty means whole range, otherwise a 'y1,y2' as beginning and end of the  range to draw vertical lines upon"}
    	{"xstep"      ""           "how much space to skip between each grid line; if log scale, this will be used in a multiplicative way"}
    	{"yrange"     ""           "empty means whole range, otherwise a 'x1,x2' as beginning and end of the  range to draw horizontal lines upon"}
    	{"ystep"      ""           "how much space to skip between each grid line; if log scale, this will be used in a multiplicative way"}
        }
        ArgsProcessWithDashArgs Grid default args use \
    	"Use this to draw a grid onto "
    
        # do the work in each direction
        if [True $use(x)] {
    	doGrid use x $use(xstep) $use(xrange)
        }
        if [True $use(y)] {
    	doGrid use y $use(ystep) $use(yrange)
        }
    }
    # end including newaxis.tcl

    # begin including legend.tcl
    # tcl
    
    variable _legend
    
    proc LegendAdd {args} {
        set default {
    	{"text"       ""          "text for the legend"}
    	{"entry"      ""          "entry number: which legend entry this should be"}
    	{"picture"    ""          "code to add the picture to the legend: COORDX and COORDY should be used to specify the lower-left point of the picture key; WIDTH and HEIGHT should be used to specify the width and height of the picture. "}
        }
        ArgsProcessWithDashArgs LegendAdd default args use \
    	"Internal command used to add some info about a legend to the legend list. If 'entry' is specified, this will add the text (if any) to the existing text in that spot, and also add the picture to the list of pictures to be drawn for this entry. If 'entry' is not specified, simply use the current counter and add this to the end of the list."
    
        variable _legend
    
        if {$use(entry) == ""} {
    	if {[info exists _legend(count)] == 0} {
    	    set _legend(count) 0
    	}
    	# puts stderr "legend adding $_legend(count):: $use(text) :: $use(picture)"
    	set _legend($_legend(count),text)    $use(text)
    	set _legend($_legend(count),picture) $use(picture)
    	incr _legend(count)
        } else {
    	# XXX
    	# don't quite feel like doing this now ...
        }
    }
    
    proc replace {string indexStr newStr} {
        set start 0
        set result [string map "$indexStr $newStr" $string]
        # puts stderr "replacing '$indexStr' with '$newStr' in original '$string' --> $result"
        return $result
    }
    
    proc Legend {args} {
        set default {
    	{"drawable"     "default"   "which drawable to place this on (canvas can be specified too)"}
    	{"coord"        ""          "where to place the legend (lower left point)"}
    	{"style"        "right"     "which side to place the text on, right or left?"}
    	{"width"        "10"        "width of the picture to be drawn in the legend"}
    	{"height"       "10"        "height of the picture to be drawn in the legend"}
    	{"vskip"        "3"         "number of points to skip when moving to next legend entry"}
    	{"hspace"       "4"         "space between pictures and text"}
    	{"down"         "t"         "go downward from starting spot when building the legend; false goes upward"}
    	{"skipnext"     ""          "if non-empty, how many rows of legend to print before skipping to a new column"}
    	{"skipspace"    "25"        "how much to move over if the -skipnext option is used to start the next column"}
    	{"font"         "Helvetica" "which font face to use"}
    	{"fontsize"     "10"        "size of font of legend"}
    	{"fontcolor"    "black"     "color of font"}
        }
        ArgsProcessWithDashArgs Legend default args use \
    	"Use this to draw a legend given the current entries in the legend. Lots of options are available, including: XXX."
    
        variable _legend
        
        set count [ArgsParseCommaList $use(coord) coord]
        AssertEqual $count 2
        set x  [drawableTranslate $use(drawable) x $coord(0)]
        set y  [drawableTranslate $use(drawable) y $coord(1)]
        set w  $use(width)
        set h  $use(height)
    
        if {$w < $h} {
    	set min $w
        } else {
    	set min $h
        }
    
        set overcounter 0
        for {set i 0} {$i < $_legend(count)} {incr i} {
    	switch -exact $use(style) {
    	    left  { 
    		set cx [expr $x+$use(hspace)+($w/2.0)] 
    		set tx $x
    	    }
    	    right { 
    		set cx [expr $x+($w/2.0)] 
    		set tx [expr $x+$w+$use(hspace)]
    	    }
    	}
    
    	# PsCircle -coord $tx,$y -linecolor blue -radius 1 ;# x for text
    	# PsCircle -coord $cx,$y -linecolor red -radius 1  ;# x for pictures
    
    	# make replacements for coordinates in legend pictures
    	set mapped [string map "__Xx $cx __Yy $y __Ww $w __Hh $h __Mm $min __W2 [expr $w/2.0] __H2 [expr $h/2.0] __M2 [expr $min/2.0] __Xmm [expr $cx-($min/2.0)] __Xpm [expr $cx+($min/2.0)] __Ymm [expr $y-($min/2.0)] __Ypm [expr $y+($min/2.0)] __Xmw [expr $cx-($w/2.0)] __Xpw [expr $cx+($w/2.0)] __Ymh [expr $y-($h/2.0)] __Yph [expr $y+($h/2.0)]" $_legend($i,picture)]
    	# puts "  BEFORE $_legend($i,picture)"
    	# puts "  AFTER  $mapped"
    
    	switch -exact $use(style) {
    	    left {
    		PsText -coord $tx,$y -anchor r,c -text $_legend($i,text) \
    		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
    		eval $mapped
    	    }
    	    right {
    		eval $mapped
    		PsText -coord $tx,$y -anchor l,c -text $_legend($i,text) \
    		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
    	    }
    	    default {
    		Abort "Bad style: $use(style): try right or left"
    	    }
    	}
    	if [True $use(down)] {
    	    set y [expr $y - $use(height) - $use(vskip)]
    	} else {
    	    set y [expr $y + $use(height) + $use(vskip)]
    	}
    
    	if {$use(skipnext) != ""} {
    	    incr overcounter
    	    if {$overcounter >= $use(skipnext)} {
    		set x  [expr $x + $use(skipspace)]
    		set y  [drawableTranslate $use(drawable) y $coord(1)]
    		set overcounter 0
    	    } 
    	}
        }
    }
    
    # end including legend.tcl

    # begin including table.tcl
    # tcl
    
    # where all table info is stored (amazingly)
    variable _table
    
    proc tableExists {tablename} {
        variable _table
        if {[info exists _table(inuse,$tablename)]} {
    	AssertEqual $_table(inuse,$tablename) 1
    	return 1
        }
        return 0
    }
    
    # this is quite inefficient, only call rarely
    proc tableFieldExists {table column} {
        variable _table
        if {[tableExists $table] == 0} {
    	puts stderr "Table '$table' does not exist."
    	return 0
        }
        for {set c 0} {$c < $_table($table,columns)} {incr c} {
    	if {[StringEqual $_table($table,columnname,$c) $column]} {
    	    return 1
    	}
        }
        # special case: can pass in "rownumber" and you will get 0, 1, ...
        if [StringEqual $column "rownumber"] {
    	return 1
        }
        return 0
    }
    
    proc tableListFields {table} {
        variable _table
        # XXX: should check if table exists
        if {[tableExists $table] == 0} {
    	return ""
        }
        set tlist $_table($table,columnname,0)
        for {set c 1} {$c < $_table($table,columns)} {incr c} {
    	set tlist "$tlist $_table($table,columnname,$c)"
        }
        return $tlist
    }
    
    proc tableAllocate {tablename} {
        variable _table
        if {[info exists _table(inuse,$tablename)]} {
    	Abort "Table $tablename is already in use"
        }
        set _table(inuse,$tablename) 1
        # allocate some other stuff about table?
    }
    
    proc tableGetNextNumber {} {
        variable _table
        if {[info exists _table(uniquenumber)]} {
    	set s $_table(uniquenumber)
    	incr _table(uniquenumber)
    	return $s
        } else {
    	set _table(uniquenumber) 1
    	return 0
        }
    }
    
    proc tableCheckUnique {columns__ count} {
        upvar $columns__ columns
    
        set cnameList $columns(0)
        for {set c 1} {$c < $count} {incr c} {
    	set cnameList "$cnameList $columns($c)"
        }    
        set origLen [llength $cnameList]
        set uniqLen [llength [lsort -uniq $cnameList]]
        if {$uniqLen != $origLen} {
    	Abort "Columns must have unique names. You specified '$cnameList', which has duplicates."
        }
    }
    
    proc tableFillColsFromTable {table columns__} {
        upvar $columns__ columns
        set cnt 0
        foreach c [TableGetColNames -table $table] {
    	set columns($cnt) $c
    	incr cnt
        }
        return $cnt
    }
    
    # 
    # EXTERNAL ROUTINES
    # 
    proc TableCopy {args} {
        set default {
    	{"from"     ""         "copy some columns from this table"}
    	{"to"       ""         "copy some columns to this table"}
    	{"fcolumns" ""         "copy from these columns"}
    	{"tcolumns" ""         "copy to these columns"}
        }
        ArgsProcessWithDashArgs TableCopy default args use \
    	"Use this to copy some columns from one table to the other. Will overwrite the existing contents of the destination table. Assumes the columns already exist in the destination."
        
        AssertNotEqual $use(from) ""
        AssertNotEqual $use(to) ""
    
        set fcount [ArgsParseCommaList $use(fcolumns) fcolumns]
        set tcount [ArgsParseCommaList $use(tcolumns) tcolumns]
        AssertEqual $fcount $tcount
    
        for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
    	# XXX NOT IMPLEMENTED YET, NOT SURE WHETHER TO ASSUME A PREALLOCATED TABLE, ETC.
        }
    }
    
    proc TableAddRow {args} {
        set default {
    	{"table"      "default"       "table to add row to"}
    	{"data"       ""              "list of 'column name, value' pairs, separated by colons, to add to the table"}
        }
        ArgsProcessWithDashArgs TableAddRow default args use \
    	"Use this to add a new row of data to a table. For example, if a table has columns x and y, and you wish to add an entry with x = 3 and y = 100, you would call 'TableAddRow -table whatever -data x,3:y,100' and the magic would be done. Note: you have to fill in ALL the column values. Also note: there is NOT a ton of error checking done here, so you can probably mess things up if you like."
    
        variable _table
        set count [ArgsParseItemPairList $use(data) values]
        AssertEqual $count $_table($use(table),columns)
        set row $_table($use(table),rows)
        for {set c 0} {$c < $count} {incr c} {
    	set column $values($c,n1)
    	set value  $values($c,n2)
    	# insert into table
    	# AssertEqual [tableIsColumnValid $table $column] 1
    	set _table($use(table),$column,$row) $value
        }
        incr _table($use(table),rows)
    }
    
    # XXX -- this can be made more useful
    proc TableDump {args} {
        set default {
    	{"table"      "default"   "which table to get data from"}
    	{"fd"         "stderr"    "which descriptor to print to"}
        }
        ArgsProcessWithDashArgs TableDump default args use \
    	"Use this to print out the contents of the table to a descriptor: default is stderr"
    
        variable _table
        puts $use(fd) "Dumping Table $use(table) ::"
        for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
    	puts -nonewline $use(fd) "  Row $r :: "
    	for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
    	    set colname $_table($use(table),columnname,$c)
    	    puts -nonewline $use(fd) "($colname: $_table($use(table),$colname,$r)) "
    	}
    	puts $use(fd) ""
        }
    }
    
    proc TableSelect2 {args} {
        set default {
    	{"from"     "table1" "select values from this table"}
    	{"to"       "table2" "put results into this table"}
    	{"where"    "x > 3"  "selection criteria in 'from' table"}
    	{"fcolumns" "x,y"    "columns to include from 'from' table"}
    	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
        }
        ArgsProcessWithDashArgs TableSelect2 default args use \
    	"Use this to select values from a table and put the results in a different table."
    
        set fcnt [ArgsParseCommaList $use(fcolumns) fcolumns]
        set tcnt [ArgsParseCommaList $use(tcolumns) tcolumns]
        AssertEqual $fcnt $tcnt
    
        for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
    	for {set i 0} {$i < $fcnt} {incr i} {
    	    set $fcolumns($i) [__TableGetVal $use(from) $fcolumns($i) $r]
    	}
    	if { [eval $use(where)] } { 
    	    set str "$tcolumns(0),$fcolumns(0)"
    	    for {set i 1} {$i < $tcnt} {incr i} {
    		set str "$str:$tcolumns($i),$fcolumns($i)"
    	    }
    	    TableAddRow -table $use(to) -data $str
    	}
        }
    }
    
    proc TableMath {args} {
        set default {
    	{"table"       "default"             "table which we are doing column math upon"}
    	{"expression"  "$x+$y"               "math expression to apply to each row of table"}
    	{"destcol"     "x"                   "destination column for expression"}
        }
        ArgsProcessWithDashArgs TableMath default args use \
    	"Use this to perform math on each row of a table. Specifically, specifying something like -expression {x + y} with '-destcol x' means for each row, take the values of x and y, add them together, and put the result back in column x. "
        AssertNotEqual $use(expression) ""
    
        set colnames [TableGetColNames -table $use(table)]
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	# get all the values (XXX - inefficient)
    	foreach col $colnames {
    	    set val [__TableGetVal $use(table) $col $r]
    	    set $col $val
    	}
    
    	# do expression
    	set val [eval "expr $use(expression)"]
    	# puts stderr "setting '$use(destcol)' to expression '$use(expression)' which evals to $val"
    	
    	# now set value
    	__TableSetVal $use(table) $use(destcol) $r $val
        }
        
    }
    
    # BUG or FEATURE?: ORDER of column names matters
    # select -fcolumns x,y -tcolumns y,x will switch the two ...
    proc TableSelect {args} {
        set default {
    	{"from"     "table1" "select values from this table"}
    	{"to"       "table2" "put results into this table"}
    	{"where"    "x > 3"  "selection criteria in 'from' table"}
    	{"fcolumns" ""       "comma-separated list of columns to include from 'from' table; empty implies all columns"}
    	{"tcolumns" ""       "comma-separated list of columns to insert into in the 'to' table; empty implies all columns"}
        }
        ArgsProcessWithDashArgs TableSelect default args use \
    	"Use this to select values from a table and put the results in a different table."
    
        set t1 [clock clicks -milliseconds]
    
        # if column list is empty, use ALL columns from specified table
        if {$use(fcolumns) != ""} {
    	set fcnt [ArgsParseCommaList $use(fcolumns) fcolumns]
        } else {
    	set fcnt [tableFillColsFromTable $use(from) fcolumns]
        }
        if {$use(tcolumns) != ""} {
    	set tcnt [ArgsParseCommaList $use(tcolumns) tcolumns]
        } else {
    	set tcnt [tableFillColsFromTable $use(to) tcolumns]
        }
        AssertEqual $fcnt $tcnt
    
        set s [tableGetNextNumber]
        set fd [open /tmp/select w]
        puts $fd "proc Select_$s \{from to\} \{"
        puts $fd "    for \{set r 0\} \{\$r < \[TableGetNumRows -table \$from]\} \{incr r\} \{ "
        for {set i 0} {$i < $fcnt} {incr i} {
    	puts $fd "        set $fcolumns($i) \[__TableGetVal \$from $fcolumns($i) \$r] "
        }
        puts $fd "        if \{ $use(where) \} \{ "
        # assemble addval string
        set str "$tcolumns(0),\$$fcolumns(0)"
        for {set i 1} {$i < $tcnt} {incr i} {
    	set str "$str:$tcolumns($i),\$$fcolumns($i)"
        }
        puts $fd "            TableAddRow -table \$to -data $str"
        puts $fd "        \}"
        puts $fd "    \}"
        puts $fd "\}"
        close $fd
    
        # now source the file and call the routine
        source /tmp/select
        Select_$s $use(from) $use(to)
        exec /bin/rm -f /tmp/select >@stdout 2>@stderr
    
        set t2 [clock clicks -milliseconds]
        Dputs table "Table: Select ran in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
    } 
    
    proc TableProject {args} {
        set default {
    	{"from"    "table1"   "source table for projection"}
    	{"to"      "table2"   "destination table for projection"}
        }
        # XXX
        # this should make a new table with fewer columns than the first (a subset, or 'projection')
    }
    
    proc TableGetMax {args} {
        variable _table
        set default {
    	{"table"  "default"         "table (can be a comma/space separated list"}
    	{"column" "x"               "column to get max over (also can be a list)"}
        }
        ArgsProcessWithDashArgs TableGetMax default args use \
    	"Use this to get the max value of a particular column of a table."
    
        set cnt  [ArgsParseCommaList $use(table) table]
        AssertGreaterThan $cnt 0
        set cnt2 [ArgsParseCommaList $use(column) column]
        AssertEqual $cnt2 $cnt
    
        for {set c 0} {$c < $cnt} {incr c} {
    	AssertEqual [tableExists $table($c)] 1
        }
    
        # get first value in table
        set max $_table($table(0),$column(0),0)
        for {set c 0} {$c < $cnt} {incr c} {
    	for {set r 0} {$r < $_table($table($c),rows)} {incr r} {
    	    set val $_table($table($c),$column($c),$r)
    	    if {$val > $max} {
    		set max $val
    	    }
    	}
        }
        return $max
    }
    
    proc TableGetMin {args} {
        set default {
    	{"table"  "default"         "table (can be a comma/space separated list"}
    	{"column" "x"               "column to get min over (also can be a list)"}
        }
        ArgsProcessWithDashArgs TableGetMin default args use \
    	"Use this to get the min value of a particular column of a table."
    
        variable _table
        set cnt  [ArgsParseCommaList $use(table) table]
        AssertGreaterThan $cnt 0
        set cnt2 [ArgsParseCommaList $use(column) column]
        AssertEqual $cnt2 $cnt
    
        for {set c 0} {$c < $cnt} {incr c} {
    	AssertEqual [tableExists $table($c)] 1
        }
    
        # get first value in table
        set min $_table($table(0),$column(0),0)
        for {set c 0} {$c < $cnt} {incr c} {
    	# ok, ok, so we check one extra value ...
    	for {set r 0} {$r < $_table($table($c),rows)} {incr r} {
    	    set val $_table($table($c),$column($c),$r)
    	    if {$val < $min} {
    		set min $val
    	    }
    	}
        }
        return $min
    }
    
    proc TableGetRange {args} {
        set default {
    	{"table"  "default"         "table"}
    	{"column" "x"               "column to get min/max over"}
    	{"border" "0"               "how much to subtract/add to min/max of range"}
        }
        ArgsProcessWithDashArgs TableGetRange default args use \
    	"Use this to get the min/max value of a particular column of a table. Returned as 'x,y' pair"
    
        set min [TableGetMin -table $use(table) -column $use(column)]
        set max [TableGetMax -table $use(table) -column $use(column)]
        Dputs table "TableGetRange: $min,$max"
        return "[expr $min-$use(border)],[expr $max+$use(border)]"
    }
    
    
    proc TableStore {args} {
        set default {
    	{"table"  "default"         "name to call table"}
    	{"file"   "/no/such/file"   "file to read from"}
        }
        ArgsProcessWithDashArgs TableStore default args use \
    	"Use this routine to store the contents of a table to a file."
    
        variable _table
        AssertEqual [tableExists $use(table)] 1
        set fd [open $use(file) "w"]
    
        # make header first
        puts -nonewline $fd "\# "
        for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
    	puts -nonewline $fd "$_table($use(table),columnname,$c) "
        }
        puts $fd ""
    
        # now, fill in data
        for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
    	for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
    	    set colname $_table($use(table),columnname,$c)
    	    puts -nonewline $fd "$_table($use(table),$colname,$r) "
    	}
    	puts $fd ""
        }
    
        # all done
        close $fd
    }
    
    proc Table {args} {
        set default {
    	{"table"     "default"  + "isString 1" "name to call table"}
    	{"file"      ""         - "isFile 1"   "file to read from"}
    	{"columns"   ""         - "isString -" "if a new table, specify the columns in this table"}
    	{"separator" ""         - "isString 1" "if empty, whitespace; otherwise, whatever you specify, e.g., a colon"}
        }
        ArgsProcessWithTypeChecking Table default args use "" \
    	"Create a table. If '-file' is specified, load the table from a file. Otherwise, '-columns' must be specified and give a comma-separated list of columns in the table (e.g., '-columns x,y,mean'). "
    
        variable _table
        if {$use(file) == ""} {
    	# creating a new empty table, don't load from a file
    	tableAllocate $use(table)
    	set count [ArgsParseCommaList $use(columns) columns]
    	set _table($use(table),columns) $count
    	tableCheckUnique columns $count
    	for {set c 0} {$c < $count} {incr c} {
    	    set _table($use(table),columnname,$c) $columns($c)
    	}
    	set _table($use(table),rows) 0
    	# all done, just return
    	return
        } 
    
        # puts "creating table: '$use(table)'"
    
        # the rest of this assumes the table is being loaded from a file...
        if {$use(columns) != ""} {
    	Abort "Can't specify both -file and -columns; must pick one or the other"
        }
        set t1 [clock clicks -milliseconds]
    
        # get data
        set fd [open $use(file) r]
    
        # table name is ...
        set tablename $use(table)
        tableAllocate $tablename
    
        # get first line
        #   should have the format: "# col1_name col2_name ... colN_name"
        #   thus, N columns, each with a name, and the leading pound
        gets $fd schema
        if {[string index $schema 0] == "\#"} {
    	set schema [string range $schema 1 end]
    	if {$use(separator) != ""} {
    	    set schema [split $schema $use(separator)]
    	}
    	set _table($tablename,columns) [llength $schema]
    	for {set c 0} {$c < $_table($tablename,columns)} {incr c} {
    	    set val [lindex $schema $c]
    	    set _table($tablename,columnname,$c) [string trim $val]
    	}
        } else {
    	# just assume a numerical naming for each column (c0, c1, etc.)
    	# note: now 'schema' is just the first line of data
    	if {$use(separator) != ""} {
    	    set schema [split $schema $use(separator)]
    	}
    	set _table($tablename,columns) [llength $schema]
    	for {set c 0} {$c < $_table($tablename,columns)} {incr c} {
    	    set _table($tablename,columnname,$c) c$c
    	}
    
    	# rewind, so that subsequent table load will NOT miss first line of data
    	seek $fd 0
        }
    
        # associated file name for this table
        set _table($tablename,file) $use(file)
    
        # now, get all the data
        set rows 0
        while {! [eof $fd]} {
    	gets $fd line
    	# skip blank lines
    	if {$line != ""} {
    	    # skip comment lines too
    	    if {[string index $line 0] != "#"} {
    		if {$use(separator) != ""} {
    		    set line [split $line $use(separator)]
    		}
    		set len [llength $line]
    		if {$len != $_table($tablename,columns)} {
    		    Abort "Table:: bad row in $tablename (len:$len  cols:$_table($tablename,columns)) (file: $_table($tablename,file))"
    		}
    
    		# go over the columns, insert each entry into the table
    		for {set c 0} {$c < $len} {incr c} {
    		    set colname $_table($tablename,columnname,$c)
    		    set _table($tablename,$colname,$rows) [string trim [lindex $line $c]]
    		    # XXX: do max, min here?
    		}
    		incr rows
    	    }
    	}
        }
        set _table($tablename,rows) $rows
        close $fd
    
        set t2 [clock clicks -milliseconds]
        Dputs table "Table: Loaded $rows rows in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
    }
    
    
    proc TableGetColNames {args} {
        set default {
    	{"table"        "default"  "which table to get names from"}
    	{"separator"    " "        "what to use to separate list of names that is returned"}
        }
        ArgsProcessWithDashArgs TableGetColNames default args use \
    	"Use this routine to get the names of each column of the specified table"
    
        variable _table
        AssertEqual [tableExists $use(table)] 1
        if {$_table($use(table),columns) < 1} {
    	return ""
        }
        set nlist [list $_table($use(table),columnname,0)]
        for {set c 1} {$c < $_table($use(table),columns)} {incr c} {
    	set nlist "$nlist$use(separator)$_table($use(table),columnname,$c)"
        }
        return $nlist
    }
    
    proc TableGetNumRows {args} {
        set default {
    	{"table"        "default"    "which table to get names from"}
        }
        ArgsProcessWithDashArgs TableGetNumRows default args use \
    	"Use this routine to get the number of rows in a table"
    
        variable _table
        AssertEqual [tableExists $use(table)] 1
        return $_table($use(table),rows)
    }
    
    proc TableBucketize {args} {
        set default {
    	{"from"         ""         "table to get raw data from"}
    	{"fcolumns"     "x,y"      "columns to get data from"}
    	{"to"           ""         "table to put data into"}
    	{"tcolumns"     "x,y,heat" "columns to put data into"}
    	{"xbucketsize"  "1.0"      "size of each bucket for first fcolumn (x)"}
    	{"ybucketsize"  "1.0"      "size of each bucket for second fcolumn (x)"}
        }
        ArgsProcessWithDashArgs TableBucketize default args use \
    	"Use this to turn a table with x,y data into a bucketized table with x,y,frequency counts. The bigger you make the buckets, the higher the counts will (likely) be."
    
        set t1 [clock clicks -milliseconds]
    
        set fcnt [ArgsParseCommaList $use(fcolumns) fcol]
        AssertEqual $fcnt 2
        set tcnt [ArgsParseCommaList $use(tcolumns) tcol]
        AssertEqual $tcnt 3
    
        AssertNotEqual $use(from) ""
        AssertNotEqual $use(to)   ""
    
        set rows [TableGetNumRows -table $use(from)]
        for {set r 0} {$r < $rows} {incr r} {
    	set x [__TableGetVal $use(from) $fcol(0) $r]
    	set y [__TableGetVal $use(from) $fcol(1) $r]
    	set bx [expr int($x / $use(xbucketsize))]
    	set by [expr int($y / $use(ybucketsize))]
    	if {[info exists data($bx,$by)] == 0} {
    	    set data($bx,$by) 1
    	} else {
    	    incr data($bx,$by)
    	}
        }
    
        foreach index [array names data] {
    	set vals [split $index ","]
    	set x [lindex $vals 0]
    	set y [lindex $vals 1]
    	TableAddRow -table $use(to) -data "$tcol(0),$x : $tcol(1),$y : $tcol(2),$data($x,$y)"
        }
    
        set t2 [clock clicks -milliseconds]
        Dputs table "Table: Bucketized $rows rows in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
    }
    
    proc TableAddColumns {args} {
        set default {
    	{"table"         "default"         "name of table we are adding columns to"}
    	{"columns"       "x"               "column list to add to table"}
    	{"value"         "0"               "default value of each added entry"}
        }
        ArgsProcessWithDashArgs TableAddColumns default args use \
    	"Use this to add one or more columns to an existing table. If adding more than one, specify using either a space-separated  (\"f g\") or comma-separated list. The 'value' flag is used to initialize each entry."
        AssertEqual [tableExists $use(table)] 1
    
        set count [ArgsParseCommaList $use(columns) columns]
        AssertGreaterThan $count 0
    
        # inc column count
        variable _table
        set curr $_table($use(table),columns)
        set _table($use(table),columns) [expr $curr + $count]
    
        for {set c 0} {$c < $count} {incr c} {
    	set _table($use(table),columnname,$curr) $columns($c)
    	incr curr
        }
        AssertEqual $curr $_table($use(table),columns)
        # check for duplicate column names
        for {set i 0} {$i < $curr} {incr i} {
    	set tmp($i) $_table($use(table),columnname,$i)
        }
        tableCheckUnique tmp $curr
    
        # init values
        for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
    	for {set c 0} {$c < $count} {incr c} {
    	    set column $columns($c)
    	    set _table($use(table),$column,$r) $use(value)
    	}
        }
    }
    
    
    proc TableMakeAxisLabels {args} {
        set default {
    	{"table"      "default"         "table to get data from"}
    	{"name"       ""                "column to get name data from"}
    	{"number"     ""                "column to get numeric data from"}
        }
        ArgsProcessWithDashArgs TableMakeAxisLabels default args use \
    	"Use this to pass in two columns -name and -number and get back something to pass to the axis generator to label the columns, with a 'name' appearing at each spot that 'number' specifies."
    
        set ulist ""
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set number [__TableGetVal $use(table) $use(number) $r]
    	set name   [__TableGetVal $use(table) $use(name) $r]
    	if {$ulist == ""} {
    	    set ulist "$number,$name"
    	} else {
    	    set ulist "${ulist}:$number,$name"
    	}
        }    
        return $ulist
    }
    
    proc TableMap {args} {
        set default {
    	{"table"      "default"         "table to get data from"}
    	{"from"       ""                "column to get data from"}
    	{"to"         ""                "column to map data into"}
        }
        ArgsProcessWithDashArgs TableMap default args use \
    	"Use this to map non-numerical data onto a numerical range."
    
        # puts "Mapping: '$use(table)'"
        set ucnt 0
    
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set value [__TableGetVal $use(table) $use(from) $r]
    	set nval  [string map {{ } ___SPACE___} $value]
    
    	if {[info exists ulist($nval)] == 0} {
    	    # assign unique value to this named category
    	    set ulist($nval) $ucnt
    	    incr ucnt
    	} 
    	# assign the mapping to the destination column 'use(to)'
    	__TableSetVal $use(table) $use(to) $r $ulist($nval)
        }
        return $ucnt
    }
    
    proc TableGetUniqueValues {args} {
        set default {
    	{"table"      "default"         "table to get data from"}
    	{"column"     ""                "column to get data from"}
    	{"separator"  ","               "what to use to separate the values in the list; comma is default"}
    	{"empties"    "0,0"             "how many empty to fields to add to the beginning, end of category"}
    	{"number"     ""                "if not empty, name of variable to store the number of unique values in"}
        }
        ArgsProcessWithDashArgs TableGetUniqueValues default args use \
    	"Use this to get the unique values found in a column."
    
        set count [ArgsParseCommaList $use(empties) empties]
        AssertEqual $count 2
        if {$empties(0) > 0} {
    	set ulist [drawableGetEmptyMarker]
    	for {set i 1} {$i < $empties(0)} {incr i} {
    	    set ulist "${ulist}$use(separator)[drawableGetEmptyMarker]"
    	}
        } else {    
    	set ulist ""
        }
    
        set ucnt 0
        for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
    	set value [__TableGetVal $use(table) $use(column) $r]
    	if {$ulist == ""} {
    	    set ulist $value
    	} else {
    	    if {[lsearch -exact $ulist $value] < 0} {
    		set ulist "${ulist}$use(separator)$value"
    	    } 
    	}
    	incr ucnt
        }
        if {$empties(1) > 0} {
    	for {set i 0} {$i < $empties(1)} {incr i} {
    	    set ulist "${ulist}$use(separator)[drawableGetEmptyMarker]"
    	}
        } 
    
        if {$use(number) != ""} {
    	upvar $use(number) number
    	set number $ucnt
        }
        return $ulist
    }
    
    
    
    
    proc TableComputeMeanEtc {args} {
        set default {
    	{"from"       ""                "table to get data from"}
    	{"to"         ""                "table to put data into"}
    	{"fcolumns"   "x,y"             "list of columns to get data from (should be two)"}
    	{"tcolumns"   "mean,c0:dev,c1"  "list of (function,column) pairs, e.g., compute the 'mean' over the data and put it into the c0 column, compute the deviation and put it in c1; list of functions to compute over the data are mean,dev,meanminusdev,meanplusdev,var,p5,p95,min,max"}
        }
        ArgsProcessWithDashArgs TableComputeMeanEtc default args use \
    	"Use this to compute a bunch of numerical values over data. Data should be in x,y format, and each x=c value should have multiple y values in the table (e.g., the data might contain (1,2), (1,3) (1,4) and (2,2) (2,4) (2,6). What the function then does is compute a bunch of functions (as you specify) and put them into the columns of the -to table, also as specified. For example, if you specify '-tcolumns mean,c0', TableComputeMeanEtc would compute the mean of the data and put it into column c0. From the data above, c0 would end up with (1,3) and (2,4) in it (i.e., the mean is computed per unique x-value). Many possible functions are available: mean (the mean), dev (standard deviation), avgminusdev (average minus the deviation), avgplusdev (average plus the deviation), var (the variance), min (the minimum), max (the maximum), and so forth."
    
        set count [ArgsParseCommaList $use(fcolumns) fcols]
        AssertEqual $count 2
    
        for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
    	set x [__TableGetVal $use(from) $fcols(0) $r]
    	set y [__TableGetVal $use(from) $fcols(1) $r]
    
    	# mark that this x-value has been seen
    	set values($x) 1
    
    	# compute count and total
    	set tmp(count,$x) [expr 1 + [Deref tmp(count,$x) 0.0]]
    	set tmp(total,$x) [expr $y + [Deref tmp(total,$x) 0.0]]
    	# min, max too
    	if {$y < [Deref tmp(min,$x) $y]} {
    	    set tmp(min,$x) $y
    	}
    	if {$y > [Deref tmp(max,$x) $y]} {
    	    set tmp(max,$x) $y
    	}
        }
    
        # calculate mean
        foreach x [lsort -increasing [array names values -glob *]] {
    	set tmp(mean,$x) [expr double($tmp(total,$x)) / double($tmp(count,$x))]
        }
    
        # now, sum up the variance 
        for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
    	set x [__TableGetVal $use(from) $fcols(0) $r]
    	set y [__TableGetVal $use(from) $fcols(1) $r]
        
    	# compute sum of variances
    	set diff [expr $y-$tmp(mean,$x)]
    	set tmp(varsum,$x) [expr ($diff*$diff) + [Deref tmp(varsum,$x) 0.0]]
        }
    
        # now compute variances, deviations, 95/5% confidences
        foreach x [lsort -increasing [array names values -glob *]] {
    	set tmp(var,$x) [expr $tmp(varsum,$x) / ($tmp(count,$x) - 1)]
    	set tmp(dev,$x) [expr sqrt($tmp(var,$x))]
    	set tmp(meanminusdev,$x) [expr $tmp(mean,$x) - $tmp(dev,$x)]
    	set tmp(meanplusdev,$x) [expr $tmp(mean,$x) + $tmp(dev,$x)]
    	set tmp(p5,$x) [expr $tmp(mean,$x) - (2.0*$tmp(dev,$x))]
    	set tmp(p95,$x) [expr $tmp(mean,$x) + (2.0*$tmp(dev,$x))]
        }
    
        # put together list of what will be added
        set count [ArgsParseItemPairList $use(tcolumns) tcols]
        AssertGreaterThan $count 0
    
        # finally, insert it all into a table
        foreach x [lsort -increasing [array names values -glob *]] {
    	# make the list of things AddRow must do
    	set tlist "x,$x"
    	for {set i 0} {$i < $count} {incr i} {
    	    set tlist "$tlist : $tcols($i,n2),$tmp($tcols($i,n1),$x)"
    	}
    	# puts stderr "The list: $tlist"
    	TableAddRow -table $use(to) -data $tlist
        }
    }
    
    # these routine are different: they generally should not be used
    # particularly: they do NOT do the usual arg processing, rather they take direct args
    # XXX - should probably check legality of column
    #       and of row number, but oh well
    proc __TableGetVal {tablename colname row} {
        variable _table
        if [StringEqual $colname "rownumber"] {
    	return $row
        }
        return $_table($tablename,$colname,$row)
    }
    
    proc __TableSetVal {tablename colname row val} {
        variable _table
        AssertEqual [tableExists $tablename] 1
        set _table($tablename,$colname,$row) $val
    }
    
    # end including table.tcl

    # 
    # these are the names of available routines (all else are internal)
    # 

    # debugging stuff
    namespace export Debug

    # manipulating data
    namespace export Table
    namespace export TableStore
    namespace export TableSelect
    namespace export TableGetMax
    namespace export TableGetMin
    namespace export TableGetRange
    namespace export TableGetColNames
    namespace export TableGetNumRows
    namespace export TableMap
    namespace export TableMakeAxisLabels
    namespace export TableGetUniqueValues
    namespace export TableAddRow
    namespace export TableAddColumns
    namespace export TableBucketize
    namespace export TableMath
    namespace export TableDump
    namespace export TableComputeMeanEtc

    # these are only meant to be called if you "know what you are doing"
    namespace export __TableGetVal
    namespace export __TableSetVal

    # doing raw PS kinds of things
    namespace export PsCanvas
    namespace export PsCanvasInfo 
    namespace export PsRender
    namespace export PsCircle
    namespace export PsBox
    namespace export PsLine
    namespace export PsPolygon
    namespace export PsText
    namespace export PsRaw
    namespace export PsColors
    
    # the drawable abstraction
    namespace export Drawable
    namespace export Drawable2

    # decorations
    namespace export AxesTicsLabels
    namespace export Grid

    # and more decorations
    namespace export Label
    namespace export Line
    namespace export Box
    namespace export Circle
    namespace export GraphBreak

    # plot functions
    namespace export PlotHeat
    namespace export PlotVerticalBars
    namespace export PlotHorizontalBars
    namespace export PlotVerticalIntervals
    namespace export PlotHorizontalIntervals
    namespace export PlotPoints
    namespace export PlotLines
    namespace export PlotFunction
    namespace export PlotVerticalFill

    # making a legend 
    namespace export Legend
}











#namespace import Zplot::*
