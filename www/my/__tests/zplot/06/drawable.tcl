# tcl

variable _draw

proc Drawable2 {args} {
    set default {
	{"drawable"   "default"       "name of the drawable"}
	{"coord"      ","             "lower-left (x,y) position of drawable; if blank, use best guess"}
	{"dimensions" ","             "(width,height) of drawing area; if blank, use best guess"}
	{"xrange"     ""              "x range which maps onto drawable"}
	{"yrange"     ""              "y range which maps onto drawable"}
	{"xscale"     "linear"        "what type of data will be on this axis: linear, log10, log2, category, ..."}
	{"yscale"     "linear"        "what type of data will be on this axis: linear, log10, log2, category, ..."}
        {"slide"      "0,0"           "how adjust the values on the xaxis,yaxis; useful for category plots"}
	{"fill"       "false"         "fill the drawable's entire background"}
	{"fillcolor"  "white"         "if filling, fill drawable's entire background with this color"}
	{"outline"    "false"         "make an outline for this box"}
	{"linewidth"  "1"             "if drawing an outline box, use this linewidth"}
	{"linecolor"  "black"         "if drawing an outline box, use this linecolor"}
    }
    ArgsProcessWithDashArgs Drawable default args use ""

    AssertEqual [psCanvasDefined] 1
    AssertNotEqual $use(xrange) "" 
    AssertNotEqual $use(yrange) "" 

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
    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2
    set use(xoff)  [psConvertToPoints $coord(0)]
    set use(yoff)  [psConvertToPoints $coord(1)]

    set count  [ArgsParseCommaList $use(dimensions) dim]
    AssertEqual $count 2
    set use(width)  [psConvertToPoints $dim(0)]
    set use(height) [psConvertToPoints $dim(1)]

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
	set use(xoff) 30.0
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

    AssertIsMemberOf $use(xscale) "linear log2 log10 category"
    AssertIsMemberOf $use(yscale) "linear log2 log10 category"

    set _draw($draw,scaleType,x) $use(xscale)
    set _draw($draw,scaleType,y) $use(yscale)

    set count [ArgsParseCommaList $use(slide) slide]
    AssertEqual $count 2
    set slide(x) $slide(0)
    set slide(y) $slide(1)

    # need deal w/ 'category' style of ranges
    foreach axis {x y} {
	MapRecordSlide $draw $axis $slide($axis)
	set count [ArgsParseCommaList $use(${axis}range) range]
	switch -exact $use(${axis}scale) {
	    "category" {
		# need to map range -> numerics
		for {set i 0} {$i < $count} {incr i} {
		    # foreach entry, record its mapping: 
		    if [StringEqual $range($i) [drawableGetEmptyMarker]] {
			set range($i) $range($i)__$i
		    }
		    MapInstall $draw $axis $range($i) $i
		}
		# linear units here (after mapping)
		set _draw($draw,$axis,linearMin)   0 ;# keep these in pretty integers for mapping ease
		set _draw($draw,$axis,linearMax)   [expr $count-1]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    "log10" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr log10(double($range(0)))]
		set _draw($draw,$axis,linearMax)   [expr log10(double($range(1)))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    } 
	    "log2" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr log2(double($range(0)))]
		set _draw($draw,$axis,linearMax)   [expr log2(double($range(1)))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    "linear" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr double($range(0))]
		set _draw($draw,$axis,linearMax)   [expr double($range(1))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    default {
		Abort "Bad scale type $use(${axis}scale): should be linear,log10,log2,category"
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



proc Drawable {args} {
    set default {
	{"drawable"   "default"       "name of the drawable"}
	{"xoff"       ""              "lower left point of drawable (x); if blank, guess based on canvas"}
	{"yoff"       ""              "lower left point of drawable (y); if blank, guess based on canvas"}
	{"width"      ""              "width of drawing area; if blank, guess based on canvas"}
	{"height"     ""              "height of drawing area; if blank, guess based on canvas"}
	{"xmargin"    "5"             "standard amount of space to the right of the xaxis before the end of the canvas"}
	{"ymargin"    "15"            "standard amount of space to the top of the yaxis before the end of the canvas"}
	{"xrange"     ""              "x range which maps onto drawable"}
	{"yrange"     ""              "y range which maps onto drawable"}
	{"xscale"     "linear"        "what type of data will be on this axis: linear, log10, log2, category, ..."}
	{"yscale"     "linear"        "what type of data will be on this axis: linear, log10, log2, category, ..."}
        {"slide"      "0,0"           "how adjust the values on the xaxis,yaxis; useful for category plots"}
	{"fill"       "false"         "fill the drawable's entire background"}
	{"fillcolor"  "white"         "if filling, fill drawable's entire background with this color"}
	{"outline"    "false"         "make an outline for this box"}
	{"linewidth"  "1"             "if drawing an outline box, use this linewidth"}
	{"linecolor"  "black"         "if drawing an outline box, use this linecolor"}
    }
    ArgsProcessWithDashArgs Drawable default args use ""

    AssertEqual [psCanvasDefined] 1
    AssertNotEqual $use(xrange) "" 
    AssertNotEqual $use(yrange) "" 

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

    AssertIsMemberOf $use(xscale) "linear log2 log10 category"
    AssertIsMemberOf $use(yscale) "linear log2 log10 category"

    set _draw($draw,scaleType,x) $use(xscale)
    set _draw($draw,scaleType,y) $use(yscale)

    set count [ArgsParseCommaList $use(slide) slide]
    AssertEqual $count 2
    set slide(x) $slide(0)
    set slide(y) $slide(1)

    # need deal w/ 'category' style of ranges
    foreach axis {x y} {
	MapRecordSlide $draw $axis $slide($axis)
	set count [ArgsParseCommaList $use(${axis}range) range]
	switch -exact $use(${axis}scale) {
	    "category" {
		# need to map range -> numerics
		for {set i 0} {$i < $count} {incr i} {
		    # foreach entry, record its mapping: 
		    if [StringEqual $range($i) [drawableGetEmptyMarker]] {
			set range($i) $range($i)__$i
		    }
		    MapInstall $draw $axis $range($i) $i
		}
		# linear units here (after mapping)
		set _draw($draw,$axis,linearMin)   0 ;# keep these in pretty integers for mapping ease
		set _draw($draw,$axis,linearMax)   [expr $count-1]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    "log10" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr log10(double($range(0)))]
		set _draw($draw,$axis,linearMax)   [expr log10(double($range(1)))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    } 
	    "log2" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr log2(double($range(0)))]
		set _draw($draw,$axis,linearMax)   [expr log2(double($range(1)))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    "linear" {
		AssertEqual $count 2
		set _draw($draw,$axis,linearMin)   [expr double($range(0))]
		set _draw($draw,$axis,linearMax)   [expr double($range(1))]
		set _draw($draw,$axis,virtualMin)  $range(0)
		set _draw($draw,$axis,virtualMax)  $range([expr $count-1])
	    }
	    default {
		Abort "Bad scale type $use(${axis}scale): should be linear,log10,log2,category"
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

proc DrawableIsLogScale {drawable axis} {
    variable _draw
    if [StringEqual $_draw($drawable,scaleType,$axis) "log10"] {
	return 1
    }
    return 0
}

proc DrawableGetScaleType {drawable axis} {
    variable _draw
    return $_draw($drawable,scaleType,$axis)
}

proc DrawableSlide {args} {
    set default {
	{"drawable" "default"   "the drawable"}
	{"slide"    "0,0"       "x,y amount to slide"}
    } 
    ArgsProcessWithDashArgs DrawableSlide default args use \
	"Use this to ..."
    set count [ArgsParseCommaList $use(slide) slide]
    AssertEqual $count 2
    if {$slide(0) != 0} {
	MapRecordSlide $use(drawable) x $slide(0)
    }
    if {$slide(1) != 0} {
	MapRecordSlide $use(drawable) y $slide(1)
    }
}

proc drawableGetEmptyMarker {} {
    return "___empty"
}

#
# VALUES have three possible types
#   Virtual    : what they are in the specifed scale type (log, linear, category, etc.)
#   Linear     : what they are once the mapping has been applied (log(virtual), category(virtual), etc.)
#   Scaled     : in Postscript points, scaled as if the drawable is at 0,0
#   Translated : in Postscript points, scaled + offset of drawable
#
# How to go from one to the other?
#   to translate from Virtual -> Linear, call [Map]
#   to translate from Linear  -> Scaled, call [Scale]
#   to translate from Scaled  -> Translated, call [Translate]
# 

proc MapRemoveWhitespace {str} {
    return [string map {" " __whitespace__ "\t" "__whitespace__"} $str]
}

proc MapPutWhitespaceBack {str} {
    return [string map {__whitespace__ " "} $str]
}

proc MapRecordSlide {drawable axis slide} {
    variable _draw
    # puts "recording slide: $slide"
    set _draw($drawable,$axis,categorySlide) $slide
}

proc MapInstall {drawable axis category value} {
    variable _draw
    set category [MapRemoveWhitespace $category]
    # puts "installing cat:$category as value:$value"
    set _draw($drawable,$axis,categoryMap,$category) $value
    set _draw($drawable,$axis,reverseMap,$value) $category
}

proc MapReverse {drawable axis value} {
    variable _draw
    # just for category mapping
    # set slide $_draw($drawable,$axis,categorySlide)
    # set value [expr int($value - $slide)]
    return [MapPutWhitespaceBack $_draw($drawable,$axis,reverseMap,$value)]
}

# Map: take value, map it onto a linear value scale
proc Map {drawable axis value} {
    variable _draw
    set scale $_draw($drawable,scaleType,$axis)

    switch -exact $scale {
	linear   { set r $value }
	log2     { set r [expr log2($value)] }
	log10    { set r [expr log10($value)] }
	category { 
	    set value [MapRemoveWhitespace $value]
	    # set r [expr $_draw($drawable,$axis,categoryMap,$value) + $_draw($drawable,$axis,categorySlide)]
	    set r $_draw($drawable,$axis,categoryMap,$value)
	}
    }
    return $r
}

# Scale: scale a linear value onto the drawable's range
proc Scale {drawable axis value} {
    variable _draw
    if {[StringEqual $drawable "canvas"]} {
	puts stderr "returning SCALED CANVAS value"
	return $value
    }
    set width [DrawableGetWidth $drawable $axis]
    set range [DrawableGetLinearRange $drawable $axis]

    # which type of scaling is this?
    return [expr double($value) * ($width / $range)] 
}

# Translate: scale and then add the offset 
proc Translate {drawable axis value} {
    variable _draw
    if {[StringEqual $drawable "canvas"]} {
	return $value
    }
    # need two linear values: then subtract, scale, and add offset
    set min    [DrawableGetLinearMin $drawable $axis]  ;# could get virtual min and then map it, but why not precompute?
    set value  [Map $drawable $axis $value]

    # offset + scaled difference = what we want
    set result [expr $_draw($drawable,${axis}off) + [Scale $drawable $axis [expr $value - $min]]]
    return $result
}

proc DrawableGetWidth {drawable axis} {
    variable _draw
    return $_draw($drawable,${axis}width)
}

proc DrawableGetVirtualMin {drawable axis} {
    variable _draw
    return $_draw($drawable,$axis,virtualMin)
}

proc DrawableGetVirtualMax {drawable axis} {
    variable _draw
    return $_draw($drawable,$axis,virtualMax)
}

proc DrawableGetLinearMin {drawable axis} {
    variable _draw
    return $_draw($drawable,$axis,linearMin)
}

proc DrawableGetLinearMax {drawable axis} {
    variable _draw
    return $_draw($drawable,$axis,linearMax)
}

proc DrawableGetLinearRange {drawable axis} {
    variable _draw
    return $_draw($drawable,$axis,linearRange)
}

proc DrawableGetRangeIterator {drawable axis min max step} {
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
	category { 
	    # first, take virtuals and turn them into a linear (integer) value
	    set imin [Map $drawable $axis $min]
	    set imax [Map $drawable $axis $max]
	    # step must be an integer value (only thing that makes sense for categories)
	    AssertEqual [string is integer $step] 1
	    for {set i $imin} {$i <= $imax} {set i [expr $i + $step]} {
		# UGH: this assumes that 0 ... max @ step are all defined
		set name [MapReverse $drawable $axis $i]
		# UGH: important to add {} around the name, in case it has spaces in it
		#      not using comma-separated list here simply because it is a pain and there are
		#      only a few places in the code that will call this routine (e.g., axis generation)
		set tlist "$tlist \{$name\}"
	    }
	}
    }
    return [lrange $tlist 1 end]
}

