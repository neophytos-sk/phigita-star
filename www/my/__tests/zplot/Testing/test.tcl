#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

proc spaceit {s} {
    for {set i 0} {$i < $s} {incr i} {
	puts -nonewline " "
    }
}

proc Abort {} {
    set level   [info level]
    set stack   [info level [expr $level-1]]
    # puts "stack: $stack"
    set cmdargs [info args [lindex $stack 0]]
    puts "Problem occurred in: [lindex $stack 0] \{[lrange $stack 1 end]\}"

    set space 1
    for {set i [expr $level-2]} {$i > 0} {incr i -1} {
	set stack   [info level $i]
	set cmdargs [info args [lindex $stack 0]]
	spaceit $space
	puts "which was called by: [lindex $stack 0] \{[lrange $stack 1 end]\}"
	incr space 1
    }
}

proc AssertEqual {a b s} {
    if {$a != $b} {
	puts stderr "$s"
	Abort 
    }
}

proc c {arg} {
    AssertEqual $arg 2 "'arg' should be equal to two"
}

proc b {arg} {
    c $arg
}

proc a {arg} {
    b $arg
}

a 1

exit 0


proc psConvertToPoints {value numeric__ units__} {
    upvar $numeric__ numeric
    upvar $units__   units
    # should be of form number,...,number,letter,...,letter
    set value [string trim $value]
    set numbers 1
    set endOfNum [string length $value]
    for {set i 0} {$i < [string length $value]} {incr i} {
	set c [string index $value $i]
	if {([string is integer $c] == 0) && ([string compare $c "."] != 0)} {
	    set endOfNum $i
	    break
	}
    }
    set numeric [string range $value 0 [expr $endOfNum-1]]
    set units   [string trim [string range $value $endOfNum end]]
}

psConvertToPoints 0.55in    n t
psConvertToPoints "0.55 in" n t
psConvertToPoints "90.55i"  n t
psConvertToPoints "90.55p"  n t
psConvertToPoints "90.55pts" n t
psConvertToPoints "90.55" n t
psConvertToPoints " 90.55  " n t
puts "$n $t"
exit 0

1 { set c .55 }


proc foo {str} {
    set all [split [string map {"<br>" "<"} $str] "<"]
    foreach e $all {
	puts "piece: $e"
    }
}

set str "hello<br>good sirs!"
# puts $str
foo $str
exit 0

puts "__empty"
puts "[string length __empty]"
exit 0

proc makeIntoLegitString {v} {
    return [string map {" " __whitespace__ "\t" "__whitespace__"} $v]
}

puts "a b --> [makeIntoLegitString "a b"]"
puts "a   b --> [makeIntoLegitString "a   b"]"
puts "a\tb --> [makeIntoLegitString "a\tb"]"


exit 0

set lst "a b {a c} {c d}"
puts $lst
foreach e [lsort $lst] {
    puts "s: $e"
}

set x({a}) 0
set x(a) 1
set x(b) 2
puts "$x({a}) $x(a) $x(b)"



exit 0

# source the library
source libs.tcl
namespace import Zplot::*

PsCanvas -title "test.eps" -width 300 -height 240 
Drawable -xrange 0,10 -yrange 0,100 -xoff 40 -width 240
AxesTicsLabels -style x -xauto ,,2 -yauto ,,20 -labels t -yformat %i -xformat %i -ticstyle centered -labelstyle out -minortics t -tics
PsRender -file "/tmp/test.eps" 

exit 0


puts "10 [expr log10(10.0)]"
exit 0

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





