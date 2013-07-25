# tcl

variable _draw

proc Location {args} {
    set default {
	{"type"       "title"         "title,ylabel,xlabel,..."}
	{"params"     "center"        "center,left,right,..."}
	{"drawable"   "root"          "name of relevant drawable"}
    }
    ArgsProcessWithDashArgs Placement default args use \
	"Use this to get the coordinates of well-known things, like title, ylabel, xlabel, etc."
    # XXX - this isn't very good right now
    variable _draw
    set d $use(drawable)
    switch -regexp $use(type) {
	"title" { 
	    set x [expr ($_draw(info,$d,width)/2.0) + $_draw(info,$d,x0)]
	    set y [expr $_draw(info,$d,height) + $_draw(info,$d,yoff) + 5.0 ]
	}
	"ylabel" {
	    set x [expr $_draw(info,$d,xoff) * (0.25)]
	    set y [expr ($_draw(info,$d,height)/2.0) + $_draw(info,$d,yoff)]
	}
	"xlabel" {
	    set x [expr $_draw(info,$d,xoff) + ($_draw(info,$d,width)/2.0)]
	    set y [expr $_draw(info,$d,yoff) * (0.25)]
	}
	default {
	    Abort "Location: bad option $use(type), should be xlabel, ylabel, or title"
	}
    }
    return "$x $y"
}

proc Drawable {args} {
    set default {
	{"name"       "root"          "name of the drawable"}
	{"xoff"       ""              "lower left point of drawable (x); if blank, guess based on canvas"}
	{"yoff"       ""              "lower left point of drawable (y); if blank, guess based on canvas"}
	{"width"      ""              "width of drawing area; if blank, guess based on canvas"}
	{"height"     ""              "height of drawing area; if blank, guess based on canvas"}
	{"xrange"     ""              "x range which maps onto drawable"}
	{"yrange"     ""              "y range which maps onto drawable"}
	{"fill"       "false"         "fill the drawable's entire background"}
	{"fillcolor"  ""              "if filling, fill drawable's entire background with this color"}
	{"linewidth"  "1"             "if drawing an outline box, use this linewidth"}
	{"linecolor"  ""              "if drawing an outline box, use this linecolor"}
    }
    ArgsProcessWithDashArgs Drawable default args use ""

    AssertEqual [psCanvasDefined] 1
    AssertNotEqual $use(xrange) "" 
    AssertNotEqual $use(yrange) "" 
    
    variable _draw
    if {[info exists _draw(name,$use(name))]} {
	Abort "drawable $use(name) already exists"
    }
    set _draw(name,$use(name)) 1

    # now, check if height and width have been specified
    if {$use(xoff) == ""} {
	set use(xoff) 35.0
    }
    if {$use(yoff) == ""} {
	set use(yoff) 30.0
    }
    if {$use(width) == ""} {
	set use(width) [expr [psCanvasWidth] - $use(xoff) - 5.0]
	AssertGreaterThan $use(width) 30.0
    }
    if {$use(height) == ""} {
	set use(height) [expr [psCanvasHeight] - $use(yoff) - 15.0]
	AssertGreaterThan $use(height) 30.0
    }
    Dputs "Drawable: offset:$use(xoff)x$use(yoff) dimensions:$use(width)x$use(height)"

    # fill background
    if {[True $use(fill)]} {
	PsBox -coord "$use(xoff) $use(yoff) : [expr $use(xoff)+$use(width)] [expr $use(yoff)+$use(height)]" -fill t -fillcolor $use(fillcolor)  -linewidth $use(linewidth) -linecolor $use(linecolor)
    }

    # pull out xrange, yrange
    set count [ArgsParseNumbers $use(xrange) xrange]
    AssertEqual $count 2
    set _draw(info,$use(name),xmin)   [expr double($xrange(0))]
    set _draw(info,$use(name),xmax)   [expr double($xrange(1))]
    set _draw(info,$use(name),xrange) [expr $xrange(1) - $xrange(0)]
    
    set count [ArgsParseNumbers $use(yrange) yrange]
    AssertEqual $count 2
    set _draw(info,$use(name),ymin)   [expr double($yrange(0))]
    set _draw(info,$use(name),ymax)   [expr double($yrange(1))]
    set _draw(info,$use(name),yrange) [expr $yrange(1) - $yrange(0)]
    Dputs "drawable '$use(name)'  xrange: $xrange(0),$xrange(1) yrange: $yrange(0),$yrange(1)"
    
    # record other info for future use too
    foreach v {xoff yoff width height} {
	set _draw(info,$use(name),$v) [expr double($use($v))]
    }
    set _draw(info,$use(name),ywidth) [expr double($use(height))]
    set _draw(info,$use(name),xwidth) [expr double($use(width))]

    # find where 0,0 is on the drawable region
    set _draw(info,$use(name),x0) [expr $use(xoff) - double($xrange(0)) * ($_draw(info,$use(name),width) / $_draw(info,$use(name),xrange))]
    set _draw(info,$use(name),y0) [expr $use(yoff) - double($yrange(0)) * ($_draw(info,$use(name),height) / $_draw(info,$use(name),yrange))]
}

proc DrawableGet {drawable name} {
    variable _draw
    return $_draw(info,$drawable,$name)
}

# scale: scale a value onto the drawable's range
proc Scale {drawable axis value} {
    variable _draw
    if {[StringEqual $drawable "canvas"]} {
	return $value
    }
    return [expr double($value) * ($_draw(info,$drawable,${axis}width) / $_draw(info,$drawable,${axis}range))]
}

# translate: scale and then add the offset 
proc Translate {drawable axis value} {
    variable _draw
    if {[StringEqual $drawable "canvas"]} {
	return $value
    }
    return [expr $_draw(info,$drawable,${axis}0) + [Scale $drawable $axis double($value)]]
}

