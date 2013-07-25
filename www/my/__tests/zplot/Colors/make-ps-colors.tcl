#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

proc convert {val} {
    if [string is integer $val] {
	return $val
    }
    switch -exact $val {
	a {return 10}
	b {return 11}
	c {return 12}
	d {return 13}
	e {return 14}
	f {return 15}
    }
}

# convert colors
# source of colors: http://htmlhelp.com/cgi-bin/color.cgi
set fd [open colors.txt.2 r]

while {! [eof $fd]} {
    gets $fd line
    if {$line != ""} {
	if {[llength $line] != 2} {
	    puts stderr "bad line: $line"; exit 1
	}
	set color [string tolower [lindex $line 0]]
	set code  [string tolower [lindex $line 1]]

	set r1    [convert [string index $code 0]]
	set r2    [convert [string index $code 1]]
	set g1    [convert [string index $code 2]]
	set g2    [convert [string index $code 3]]
	set b1    [convert [string index $code 4]]
	set b2    [convert [string index $code 5]]

	set r     [expr $r2 + (16*$r1)]
	set g     [expr $g2 + (16*$g1)]
	set b     [expr $b2 + (16*$b1)]

	set r     [expr $r / 255.0]
	set g     [expr $g / 255.0]
	set b     [expr $b / 255.0]

	# puts "[format %20s $color] -- $code -- [format "%2d %2d %2d %2d %2d %2d" $r1 $r2 $g1 $g2 $b1 $b2] -- [format "%.2f %.2f %.2f" $r $g $b]"
	puts "        \{ \{ [format %20s $color] \} \{ [format "%.2f %.2f %.2f" $r $g $b] \} \}"
    }
}

close $fd

