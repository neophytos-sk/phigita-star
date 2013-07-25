# tcl

proc Table {name__ cols} {
    upvar $name__ name
    set name(rows) 0
    set name(cols) $cols
}
Table default "c1 c2"
puts $default(rows)
puts $default(cols)



exit 0

set default(c1,0) "d:c1:0"
set default(c2,0) "d:c2:0"
set default(c1,1) "d:c1:1"
set default(c2,1) "d:c2:1"

puts [array names default -glob *,*]
exit 0


proc testf {arg use__} {
    upvar $use__ use
    puts -nonewline "arg = ($arg) --> "
    if {$arg == ""} {
	puts "empty"
    } else {
	puts "NOT"
    }
    set use(test) {}
}

testf "" use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}
testf {} use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}
testf [list] use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}
set g "" 
testf $g use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}
set g {}
testf $g use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}
set g [list]
testf $g use
if {$use(test) == ""} {
    # 
} else {
    puts "PROBLEM"
}



exit 0


set x +

puts [expr 3 $x 4]


set info(a,b,xaxis) 1
set info(a,b,yaxis) 3

set var y
puts $info(a,b,xaxis)
puts $info(a,b,yaxis)
puts $info(a,b,${var}axis)



set _c(colors) {
    { {black}                   { "0 0 0" } }
    { {white}                   { "1 1 1" } }
    { {verydarkgray vdgray vdg} {  "0.1 0.1 0.1" } }
    { {darkgray dgray dg}       {  "0.25 0.25 0.25" } }
    { {gray}                    {  "0.5 0.5 0.5" } }
    { {lightgray lgray }        {  "0.75 0.75 0.75" } }
    { {verylightgray vlgray}    {  "0.9 0.9 0.9" } }
    { {blue}                    {  "0 0 1" } }
    { {darkblue dblue}          {  "0 0 0.5" } }
    { {red}                     {  "1 0 0" } }
    { {darkred dred}            {  "0.5 0 0" } }
    { {green}                   {  "0 1 0" } }
    { {darkgreen dgreen}        {  "0 0.5 0" } }
    { {yellow}                  {  "1 1 0"  } }
    { {lightyellow lyellow}     {  "1 1 0.39"  } }
    { {orange}                  {  "1 0.5 0" } }
    { {lightorange lorange}     {  "1 0.8 0.2" } }
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

ArgsSwitch $_c(colors) "orange" "Bad color"
ArgsSwitch $_c(colors) "lorange" "Bad color"
# ArgsSwitch $_c(colors) "ldorange" "Bad color"


puts "0 [string is double 0]"
puts "1.4 [string is double 1.4]"
puts "7a [string is double 7a]"





