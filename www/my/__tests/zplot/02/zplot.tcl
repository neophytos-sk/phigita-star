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


# tcl

proc ArgsUsage {command infoStr defaultList__} {
    upvar $defaultList__ defaultList
    puts stderr "$infoStr"
    puts stderr "usage: $command"
    foreach d $defaultList {
	puts stderr [format "  -%s %20s (default: %s)" [lindex $d 0] [lindex $d 2] [lindex $d 1]]
    }
    exit 1
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

    if {[StringEq $command "Canvas"] == 0} {
	puts "% DEBUG $command $argList"
    }

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


#! /usr/bin/tclsh

# generic program info
set _c(program)  "zdraw"
set _c(version)  "1.0.0"

# date
set _c(date)     [clock format [clock seconds]]

# about this document
set _c(width)    300
set _c(height)   240
set _c(title)    "default.eps"

# set legal fonts
set _c(fontlist) "Helvetica"
set _c(allfonts) "Helvetica Helvetica-Bold Helvetica-Italic TimesRoman TimesRoman-Bold TimesRoman-Italic Courier Courier-Bold Courier-Italic"

proc true {b} {
    switch -exact $b {
	"t"    { return 1 }
	"T"    { return 1 }
	"true" { return 1 }
	"True" { return 1 }
	"TRUE" { return 1 }
    }
    return 0
}

proc false {b} {
    switch -exact $b {
	"f"     { return 1 }
	"F"     { return 1 }
	"false" { return 1 }
	"False" { return 1 }
	"FALSE" { return 1 }
    }
    return 0
}


proc addfont {font} {
    global _c
    # make sure fonts are legal
    if {[lsearch -exact $_c(allfonts) $font] == -1} {
	puts stderr "bad font: $font"
	exit 1
    }

    # add to font list
    if {[lsearch -exact $_c(fontlist) $font] == -1} {
	set _c(fontlist) [list $_c(fontlist) $font]
    }
}

proc PsHeader {width height} {
    global _c
    
    # xxx
    set _c(width)  $width
    set _c(height) $height

    # generic eps header
    puts "%!PS-Adobe-3.0"
    puts "%%Title: $_c(title)"
    puts "%%Creator: $_c(program) version $_c(version)"
    puts "%%CreationDate: $_c(date)"
    puts "%%DocumentFonts: (atend)"
    puts "%%BoundingBox: 0 0 $width $height"
    puts "%%Orientation: Portrait"
    puts "%%EndComments"

    # zdraw dictionary
    puts "% zdraw dictionary"
    puts "/zdict 256 dict def"
    puts "zdict begin"
    puts "/m {moveto} bind def"
    puts "/l {lineto} bind def"
    puts "/mr {rmoveto} bind def"
    puts "/lr {rlineto} bind def"
    puts "/lshow { show } def"
    puts "/rshow { dup stringwidth pop neg 0 mr show } def"
    puts "/cshow { dup stringwidth pop -2 div 0 mr show } def"
    puts "/lbshow { show } def"
    puts "/rbshow { dup stringwidth pop neg 0 mr show } def"
    puts "/cbshow { dup stringwidth pop -2 div 0 mr show } def"
    puts "/lmshow { dup stringwidth -2 div 0 exch mr pop show } def"
    puts "/rmshow { dup stringwidth -2 div 0 exch mr neg 0 mr show } def"
    puts "/cmshow { dup stringwidth -2 div 0 exch mr -2 div 0 mr show } def"
    puts "/ltshow { dup stringwidth neg 0 exch mr pop show } def"
    puts "/rtshow { dup stringwidth neg div 0 exch mr neg 0 mr show } def"
    puts "/ctshow { dup stringwidth neg div 0 exch mr -2 div 0 mr show } def"
    puts "end"
    puts "zdict begin"
}


proc color {c} {
    if {[string compare [string index $c 0] "%"] == 0} {
	# this is a raw color, of the form: %r,g,b
	# where r,g,b are each between 0 and 1 and can be decimal
	return [split [lindex [split $c %] 1] ","]
    }
    switch -exact $c {
	"black"  { return "0 0 0" }
	"white"  { return "1 1 1" }
	"dgray"  { return "0.25 0.25 0.25" }
	"gray"   { return "0.5 0.5 0.5" }
	"lgray"  { return "0.75 0.75 0.75" }
	"blue"   { return "0 0 1" }
	"dblue"  { return "0 0 0.5" }
	"red"    { return "1 0 0" }
	"dred"   { return "0.5 0 0" }
	"green"  { return "0 1 0" }
	"dgreen" { return "0 0.5 0" }
	"orange" { return "1 0.5 0" }
	default  { puts stderr "color: bad color $c" }
    }
}

# 
# postscript commands
# 
proc setcolor {c} {
    puts "$c setrgbcolor"
}

proc setlinewidth {lw} {
    puts "$lw setlinewidth"
}

proc setlinecap {lc} {
    puts "$lc setlinecap"
}

proc setdash {d} {
    puts "\[$d\] 0 setdash"
}

proc moveto {x y} {
    puts "$x $y m"
}

proc lineto {x y} {
    puts "$x $y l"
}

proc newpath {} {
    puts "newpath"
}

proc closepath {} {
    puts "closepath"
}

proc fill {} {
    puts "fill"
}

proc stroke {} {
    puts "stroke"
}

proc gsave {} {
    puts "gsave"
}

proc grestore {} {
    puts "grestore"
}

proc arc {x y r ba ea} {
    puts "$x $y $r $ba $ea arc"
}

proc clip {} {
    puts "clip"
}

proc rotate {angle} {
    puts "$angle rotate"
}

proc setfont {face size} {
    puts "($face) findfont $size scalefont setfont"
}

proc show {text anchor} {
    puts "($text)"
    switch -exact $anchor {
	"c" { puts "cshow" }
	"l" { puts "lshow" }
	"r" { puts "rshow" }
	default { puts "bad anchor: $anchor"; exit 1 }
    }
}

proc rectangle {x1 y1 x2 y2} {
    moveto $x1 $y1
    lineto $x1 $y2
    lineto $x2 $y2
    lineto $x2 $y1 
}

# 
# high-level postscript commands
# 
proc PsCanvas {args} {
    set default {
	{"width"      "300"   "width of drawing canvas"}
	{"height"     "240"   "height of drawing canvas"}
    }
    ArgsProcessWithDashArgs Canvas default args use ""

    # make the header
    PsHeader $use(width) $use(height)
}

proc PsRender {} {
    global _c

    # generic eps trailer
    puts "% zdraw epilogue"
    puts "end"
    puts "showpage"
    puts "%%Trailer"
    puts "%%DocumentFonts: $_c(fontlist)"

}

proc PsLine {args} {
    set default {
	{"coord"     "0,0:0,0"     "x1,y1: ... :xn,yn"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
	{"linecap"   "0"           "linecap: 0, 1, or 2"}
	{"closepath" "false"       "whether to close the path or not"}
	{"dash"      "0"           "define dashes for the line"}
    }
    ArgsProcessWithDashArgs PsLine default args use ""

    # start the path
    gsave
    newpath

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    moveto $coords(0,n1) $coords(0,n2) 
    for {set p 1} {$p < $count} {incr p} {
	lineto $coords($p,n1) $coords($p,n2) 
    }
    if [true $use(closepath)] {
	closepath
    }
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)
    setlinecap $use(linecap)
    if {$use(dash) != 0} {
	setdash $use(dash)
    }
    stroke
    grestore
}

proc PsBox {args} {
    set default {
	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs box default args use ""

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    AssertEqual $count 2

    set x1 $coords(0,n1)
    set y1 $coords(0,n2)
    set x2 $coords(1,n1)
    set y2 $coords(1,n2)

    # do filled one first
    # we are doing this twice but probably don't have to...
    gsave
    if [true $use(fill)] {
	if {[string compare $use(fillstyle) solid] == 0} {
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; 
	    setcolor [color $use(fillcolor)]; fill
	} elseif {[string compare $use(fillstyle) hlines] == 0} {
	    set all   [split $use(fillparams) ","]
	    set width [lindex $all 0]
	    set skip  [lindex $all 1]
	    # set clipping space
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; clip
	    # now, draw the lines
	    setlinewidth $width
	    setcolor [color $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$width]} {
		newpath
		rectangle $x1 $cy $x2 [expr $cy+$width] 
		closepath; fill; stroke
	    }
	    
	} elseif {[string compare $use(fillstyle) vlines] == 0} {
	    set all   [split $use(fillparams) ","]
	    set width [lindex $all 0]
	    set skip  [lindex $all 1]
	    # set clipping space
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; clip
	    # now, draw the lines
	    setlinewidth $width
	    setcolor [color $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$width]} {
		newpath
		rectangle $cx $y1 [expr $cx+$width] $y2
		closepath; fill; stroke
	    }
	} else {
	    puts stderr "bad fill style: $use(fillstyle)"
	    exit 1
	}
    }
    grestore

    # start the path
    gsave
    newpath

    # now do the movetos and closepath
    rectangle $x1 $y1 $x2 $y2
    closepath

    # colors and 
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)

    # finish up
    stroke
    grestore
}

proc PsCircle {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"radius"    "1"           "radius of circle"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
    }
    ArgsProcessWithDashArgs circle default args use ""

    # start the path
    gsave
    newpath

    # pull out each element of the path
    set xy [split $use(coord) ","]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]

    # now do the movetos and closepath
    arc $x $y $use(radius) 0 360

    # colors and 
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)

    # finish up
    stroke
    grestore
}

proc PsText {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"color"     "black"       "color of text"}
	{"text"      "text"        "the text on the canvas"}
	{"font"      "Helvetica"   "which font: Helvetica, TimesRoman, Courier"}
	{"size"      "10"          "size of the type face"}
	{"rotate"    "0"           "angle of rotation"}
	{"anchor"    "c"           "l (left), c (center), r (right)"}
    }
    ArgsProcessWithDashArgs PsText default args use ""

    addfont $use(font)
    
    set s [split $use(coord) ","]
    set x [lindex $s 0]
    set y [lindex $s 1]

    gsave
    newpath
    setcolor [color $use(color)]
    setfont $use(font) $use(size)
    moveto $x $y
    if {$use(rotate) != 0} {
	rotate $use(rotate)
    }
    show $use(text) $use(anchor)
    stroke
    grestore
}

# tcl

proc Drawable {args} {
    set default {
	{"name"       "default"       "name of the drawable"}
	{"xoff"       "40"            "lower left point of drawable (x)"}
	{"yoff"       "30"            "lower left point of drawable (y)"}
	{"width"      "240"           "width of drawing area"}
	{"height"     "190"           "height of drawing area"}
	{"xrange"     ""              "x range which maps onto drawable"}
	{"yrange"     ""              "y range which maps onto drawable"}
    }
    ArgsProcessWithDashArgs Drawable default args use ""

    AssertNotEqual $use(xrange) "" 
    AssertNotEqual $use(yrange) "" 
    
    global _drawable
    if {[info exists _drawable(name,$use(name))]} {
	Abort "drawable $use(name) already exists"
    }
    set _drawable(name,$use(name)) 1

    # pull out xrange, yrange
    set count [ArgsParseNumbers $use(xrange) xrange]
    AssertEqual $count 2
    set _drawable(info,$use(name),xmin)   [expr double($xrange(0))]
    set _drawable(info,$use(name),xmax)   [expr double($xrange(1))]
    set _drawable(info,$use(name),xrange) [expr $xrange(1) - $xrange(0)]
    
    set count [ArgsParseNumbers $use(yrange) yrange]
    AssertEqual $count 2
    set _drawable(info,$use(name),ymin)   [expr double($yrange(0))]
    set _drawable(info,$use(name),ymax)   [expr double($yrange(1))]
    set _drawable(info,$use(name),yrange) [expr $yrange(1) - $yrange(0)]
    puts stderr "ranges: x [expr $xrange(1) - $xrange(0)]    y [expr $yrange(1) - $yrange(0)]"
    
    # record other info for future use too
    foreach v {xoff yoff width height} {
	set _drawable(info,$use(name),$v) [expr double($use($v))]
    }

    # find where 0,0 is on the drawable region
    set _drawable(info,$use(name),x0) [expr $use(xoff) - double($xrange(0)) * ($_drawable(info,$use(name),width) / $_drawable(info,$use(name),xrange))]
    set _drawable(info,$use(name),y0) [expr $use(yoff) - double($yrange(0)) * ($_drawable(info,$use(name),height) / $_drawable(info,$use(name),yrange))]
    
}

proc DrawableGet {drawable name} {
    global _drawable
    return $_drawable(info,$drawable,$name)
}

# scale: scale a value onto the drawable's range
proc ScaleY {drawable y} {
    global _drawable
    return [expr double($y) * ($_drawable(info,$drawable,height) / $_drawable(info,$drawable,yrange))]
}

proc ScaleX {drawable x} {
    global _drawable
    return [expr double($x) * ($_drawable(info,$drawable,width) / $_drawable(info,$drawable,xrange))]
}

# translate: scale and then add the offset 
proc TranslateY {drawable y} {
    global _drawable
    return [expr $_drawable(info,$drawable,y0) + [ScaleY $drawable $y]]
}

proc TranslateX {drawable x} {
    global _drawable
    return [expr $_drawable(info,$drawable,x0) + [ScaleX $drawable $x]]
}

# tcl

proc allocate {tablename} {
    global _table
    if {[info exists _table(inuse,$tablename)]} {
	Abort "Table $tablename is already in use"
    }
    set _table(inuse,$tablename) 1
}

proc getnextnumber {} {
    global _table
    if {[info exists _table(uniquenumber)]} {
	set s $_table(uniquenumber)
	incr _table(uniquenumber)
	return $s
    } else {
	set _table(uniquenumber) 1
	return 0
    }
}


proc Table {args} {
    global _table
    set default {
	{"table"    "default"  "name to call table"}
	{"columns"  "x,y"      "columns in this table"}
    }
    ArgsProcessWithDashArgs Table default args use \
	"Create an empty table."

    allocate $use(table)

    set count [ArgsParseNumbers $use(columns) columns]
    set _table($use(table),columns) $count

    for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	set _table($use(table),columnname,$c) $columns($c)
    }
    set _table($use(table),rows) 0
}

# this is really poorly done right now (esp. w/ large numbers of columns)
proc checkvalid {table column} {
    # XXX 
    global _table
    for {set c 0} {$c < $_table($table,columns)} {incr c} {
	if {[StringEq $_table($table,columnname,$c) $column]} {
	    return 1
	}
    }
    return 0
}

proc TableAddVal {table valueList} {
    global _table
    set count [ArgsParseNumbersList $valueList values]
    AssertEqual $count $_table($table,columns)
    set row $_table($table,rows)
    for {set c 0} {$c < $count} {incr c} {
	set column $values($c,n1)
	set value  $values($c,n2)
	# puts stderr "$c: inserting into column '$column' the value '$value'"

	# insert into table
	checkvalid $table $column
	set _table($table,$column,$row) $value
    }
    incr _table($table,rows)
}

# XXX -- this can be made more useful
proc TableDump {table} {
    global _table
    puts stderr "Dumping Table $table ::"
    for {set r 0} {$r < $_table($table,rows)} {incr r} {
	puts -nonewline stderr "  Row $r :: "
	for {set c 0} {$c < $_table($table,columns)} {incr c} {
	    set colname $_table($table,columnname,$c)
	    puts -nonewline stderr "($colname: $_table($table,$colname,$r)) "
	}
	puts stderr ""
    }
}

proc TableSelect {args} {
    global _table
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" "x,y"    "columns to include from 'from' table"}
	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
    }
    ArgsProcessWithDashArgs TableSelect default args use \
	"Use this to select values from a table and put the results in a different table."

    set fcnt [ArgsParseNumbers $use(fcolumns) fcolumns]
    set tcnt [ArgsParseNumbers $use(tcolumns) tcolumns]
    AssertEqual $fcnt $tcnt

    set s [getnextnumber]
    set fd [open /tmp/select w]
    puts $fd "proc Select_$s \{from to\} \{"
    puts $fd "    for \{set r 0\} \{\$r < \[TableGetRows \$from]\} \{incr r\} \{ "
    for {set i 0} {$i < $fcnt} {incr i} {
	puts $fd "        set $fcolumns($i) \[TableGetVal \$from $fcolumns($i) \$r] "
    }
    puts $fd "        if \{ $use(where) \} \{ "
    # assemble addval string
    set str "$tcolumns(0),\$$fcolumns(0)"
    for {set i 1} {$i < $tcnt} {incr i} {
	set str "$str:$tcolumns($i),\$$fcolumns($i)"
    }
    puts $fd "            TableAddVal \$to $str"
    puts $fd "        \}"
    puts $fd "    \}"
    puts $fd "\}"
    close $fd

    # now source the file and call the routine
    source /tmp/select
    Select_$s $use(from) $use(to)
} 



proc TableProject {args} {
    global _table
    set default {
	{"from"    "table1"   "source table for projection"}
	{"to"      "table2"   "destination table for projection"}
    }
    XXX
}



proc TableLoad {args} {
    global _table
    set default {
	{"file"   "/no/such/file"   "file to read from"}
	{"table"  "default"         "name to call table"}
    }
    ArgsProcessWithDashArgs TableLoad default args use \
	"Use this routine to create and fill a table with values from a file."

    # get data
    set fd [open $use(file) r]

    # table name is ...
    set tablename $use(table)
    allocate $tablename

    # get first line
    #   should have the format: "# col1_name col2_name ... colN_name"
    #   thus, N columns, each with a name, and the leading pound
    gets $fd schema
    set _table($tablename,file)    $use(file)
    set _table($tablename,columns) [expr [llength $schema] - 1]
    for {set c 1} {$c <= $_table($tablename,columns)} {incr c} {
	set rc [expr $c - 1]
	set val [lindex $schema $c]
	set _table($tablename,columnname,$rc) $val
    }

    set rows 0
    while {! [eof $fd]} {
	gets $fd line
	if {$line != ""} {
	    if {[string index $line 0] != "#"} {
		set len [llength $line]
		if {$len != $_table($tablename,columns)} {
		    puts stderr "bad data:$tablename (file: $_table($tablename,file)"
		    exit 1
		}

		for {set c 0} {$c < $len} {incr c} {
		    set colname $_table($tablename,columnname,$c)
		    set _table($tablename,$colname,$rows) [lindex $line $c]
		}
		incr rows
	    }
	}
    }
    set _table($tablename,rows) $rows
    close $fd
}

proc TableColNames {tablename} {
    global _table
    if {$_table($tablename,columns) < 1} {
	return ""
    }
    set nlist [list $_table($tablename,columnname,0)]
    for {set c 1} {$c < $_table($tablename,columns)} {incr c} {
	set nlist "$nlist $_table($tablename,columnname,$c)"
    }
    return $nlist
}

proc TableGetVal {table colname row} {
    global _table
    return $_table($table,$colname,$row)
}

proc TableGetRows {table} {
    global _table
    return $_table($table,rows)
}

# tcl

proc Axis {args} {
    set default {
	{"drawable"   "default"  "the relevant drawable"}
	{"axis"       "x"        "x or y axis"}
	{"range"      ""         "min and max values to draw line between"}
	{"linecolor"  "black"    "color of axis line"}
	{"linewidth"  "1"        "width of axis line"}
	{"dash"       ""         "dash parameters"}
	{"offset"     "n"        "n or p, with n meaning 'left' or 'bottom', and p meaning 'right' or 'top', depending on x or y axis"}
    }
    ArgsProcessWithDashArgs Axis default args use ""

    if {$use(range) == ""} {
	# must automatically fetch the range of these from drawable
	set min [DrawableGet $use(drawable) $use(axis)min]
	set max [DrawableGet $use(drawable) $use(axis)max]
    } else {
	set count [ArgsParseNumbers $use(range) range]
	AssertEqual $count 2
	set min $range(0)
	set max $range(1)
    }

    if {[StringEq $use(axis) "x"]} {
	set min [TranslateX $use(drawable) $min]
	set max [TranslateX $use(drawable) $max]
	if {[StringEq $use(offset) "n"]} {
	    set y [TranslateY $use(drawable) 0.0]
	} else {
	    set y [TranslateY $use(drawable) [DrawableGet $use(drawable) ymax]]
	}
	PsLine -coord "[expr $min-0.5] $y : [expr $max+0.5] $y" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)
    } else {
	set min [TranslateY $use(drawable) $min]
	set max [TranslateY $use(drawable) $max]
	if {[StringEq $use(offset) "n"]} {
	    set x [TranslateX $use(drawable) 0.0]
	} else {
	    set x [TranslateX $use(drawable) [DrawableGet $use(drawable) xmax]]
	}
	PsLine -coord "$x [expr $min-0.5] : $x [expr $max+0.5]" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)

    }

    # DEBUG -- draw bounding box too (for testing)
    # PsLine -coord 0,0:0,239:299,239:299,0 -closepath t -linecolor black -linewidth 1
}

# XXX - needs to be real, do real arg processing
proc Tics {args} {
    set default {
	{"drawable"  "default" "the drawable"}
	{"axis"      "x"       "which axis: x or y"}
	{"tics"      ""        "n1,n2,step, e.g., 0,10,2 means 0 to 10 tics, by 2s"}
	{"ticsize"   "4"       "size of tics (4 for major, 2 for minor)"}
	{"labeltype" "none"    "none or numeric or manual"}
	{"label"     "0,10,2"  "numeric: 0 to 10, by 2s, or a manual list"}
	{"fontsize"  "10"      "font size of labels (if any)"}
	{"offset"    "0"       "offset from typical spot"}
	{"ytextoff"  "2"       "offset in pts of text from tics (y axis)"}
	{"xtextoff"  "0"       "offset in pts of text from tics (x axis)"}
	{"magic"     "0.3"     "magic number used to offset height placement in ylabels"}
    }
    ArgsProcessWithDashArgs Tics default args use ""

    # get tic info
    if {$use(tics) != ""} {
	set cnt [ArgsParseNumbers $use(tics) tics]
	AssertEqual $cnt 3
	set min  $tics(0)
	set max  $tics(1)
	set step $tics(2)
    }

    if {[StringEq $use(labeltype) "numeric"]} {
	set cnt [ArgsParseNumbers $use(label) tmp]
	AssertEqual $cnt 3
	set begin $tmp(0)
	set end   $tmp(1)
	set step  $tmp(2)
	set labelstr "$begin,$begin"
	for {set i [expr $begin+$step]} {$i <= $end} {set i [expr $i + $step]} {
	    set labelstr "$labelstr : $i,$i"
	}
    } elseif {[StringEq $use(labeltype) "manual"]} {
	set labelstr $use(label)
    } elseif {[StringEq $use(labeltype) "none"]} {
	set labelstr ""
    } else {
	Abort "Bad label type ($use(labeltype))"
    }

    set labelcnt [ArgsParseNumbersList $labelstr label]
    AssertNotEqual $labelcnt -1

    # draw x or y tics, labels, etc.
    if {[StringEq $use(axis) "x"]} {
	set y0 [expr [DrawableGet $use(drawable) y0] +[ScaleY $use(drawable) $use(offset)]]
	set y1 [expr $y0 - $use(ticsize)]

	if {$use(tics) != ""} {
	    for {set x $min} {$x <= $max} {set x [expr $x + $step]} {
		set tx [TranslateX $use(drawable) $x]
		PsLine -coord $tx,[expr $y0+0.5]:$tx,$y1 -linecolor black
	    }
	}

	# now labels
	if {$labelstr != ""} {
	    for {set i 0} {$i < $labelcnt} {incr i} {
		set x [expr double($label($i,n1))]
		set labelstr $label($i,n2)
		set tx [TranslateX $use(drawable) $x]
		set ytmp [expr $y1 - $use(fontsize) - $use(xtextoff)]
		PsText -coord $tx,$ytmp -text $labelstr -size $use(fontsize) -anchor c
	    }
	}

    } elseif {[StringEq $use(axis) "y"]} {
	set x0 [expr [DrawableGet $use(drawable) x0] +[ScaleX $use(drawable) $use(offset)]]
	set x1 [expr $x0 - $use(ticsize)]

	if {$use(tics) != ""} {
	    for {set y $min} {$y <= $max} {set y [expr $y + $step]} {
		set ty [TranslateY $use(drawable) $y]
		PsLine -coord [expr $x0+0.5],$ty:$x1,$ty -linecolor black
	    }
	}

	# now labels
	if {$labelstr != ""} {
	    for {set i 0} {$i < $labelcnt} {incr i} {
		set y [expr double($label($i,n1))]
		set labelstr $label($i,n2)
		set ty [TranslateY $use(drawable) $y]
		set xtmp [expr $x0 - $use(ticsize) - $use(ytextoff)]
		set ytmp [expr $ty - ($use(fontsize) * $use(magic))]  ;# see note below
		# note: 0.35 is a magic number that empirically works (for Helvetica)
		# is there a better way to get this number? (e.g., in postscript)
		PsText -coord $xtmp,$ytmp -text $labelstr -size $use(fontsize) -anchor r
	    }
	}
    } else {
	Abort "Bad axis ($use(axis)); should be x or y"
    }
}

# tcl

proc Title {args} {
    set default {
	{"placement" "center" "center,left,right,manual"}
	{"text"      ""       "title of the graph"}
	{"x"         "0"      "with manual placement, use this as x location"}
	{"y"         "0"      "with manual placement, use this as y location"}
    }
    ArgsProcessWithDashArgs Title default args use

    global _d

    # xxx - needs more work
    set x [expr ($_d(dwidth)/2.0) + $_d(x0)]
    set y [expr $_d(dheight) + $_d(y0) + 15.0 ]
    
    if {[string compare $use(placement) "manual"] == 0} {
	set x $use(x)
	set y $use(y)
    }

    PsText -coord $x,$y -text $use(text) -size 12 
}

proc Label {args} {
    set default {
	{"text"      ""       "title of the graph"}
	{"style"     "x"      "x label, y label, right y label, etc."}
    }
    ArgsProcessWithDashArgs Label default args use

    global _d

    if {[StringEq $use(style) "y"]} {
	set x [expr 10.0]
	set y [expr ($_d(dheight)/2.0) + $_d(y0)]
	set r 90
    } else {
	set x [expr ($_d(dwidth)/2.0) + $_d(x0)]
	set y [expr 5.0]
	set r 0
    }

    PsText -coord $x,$y -text $use(text) -rotate $r -anchor c
}


# tcl

# tcl

proc PlotBar {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"y"          "y"           "table column with y data"}
	{"style"      ""            "style to use; supplants args below"}
	{"barwidth"   "1"           "bar width"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "gray"        "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
    }    
    ArgsProcessWithDashArgs PlotBar default args use ""

    # if {$use(style) != ""} {
    # StyleGet $use(style) use
    # }

    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(x) $r]
	set y [TableGetVal $use(table) $use(y) $r]

	set barwidth [ScaleX $use(drawable) $use(barwidth)]

	set x1 [expr [TranslateX $use(drawable) $x] - ($barwidth/2.0)]
	set y1 [TranslateY $use(drawable) 0.0]
	set x2 [expr $x1 + $barwidth]
	set y2 [TranslateY $use(drawable) $y] 

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2 \
	    -linecolor  $use(linecolor) \
	    -linewidth  $use(linewidth) \
	    -fill       $use(fill) \
	    -fillcolor  $use(fillcolor) \
	    -fillstyle  $use(fillstyle) \
	    -fillparams $use(fillparams)
    }
}

proc PlotDevs {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"ylo"        "ylo"         "table column with ylo data"}
	{"yhi"        "yhi"         "table column with ylo data"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of all lines"}
	{"devwidth"   "3"           "width of little marker on top"}
    }
    ArgsProcessWithDashArgs PlotDevs default args use ""

    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set ylo [TableGetVal $use(table) $use(ylo) $r]
	set yhi [TableGetVal $use(table) $use(yhi) $r]

	set xp   [TranslateX $use(drawable) $x]
	set ylop [TranslateY $use(drawable) $ylo]
	set yhip [TranslateY $use(drawable) $yhi]

	set dw   [expr $use(devwidth) / 2.0]

	PsLine -coord "$xp $ylop : $xp $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $yhip : [expr $xp+$dw] $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $ylop : [expr $xp+$dw] $ylop" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)

    }

}


