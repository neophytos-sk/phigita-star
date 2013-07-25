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

