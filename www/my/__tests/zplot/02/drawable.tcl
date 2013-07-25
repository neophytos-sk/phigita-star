# tcl

proc Placement {args} {
    set default {
	{"type"       "title"         "title,ylabel,xlabel,..."}
	{"params"     "center"        "center,left,right,..."}
	{"drawable"   "default"       "name of relevant drawable"}
    }
    ArgsProcessWithDashArgs Placement default args use \
	"Use this to get the coordinates of well-known things, like title, ylabel, xlabel, etc."
    # XXX - this isn't very good right now
    global _draw
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
	    Abort "bad option: $use(type)"
	}
    }
    return "$x $y"
}

proc Drawable {args} {
    set default {
	{"name"       "default"       "name of the drawable"}
	{"xoff"       "40"            "lower left point of drawable (x)"}
	{"yoff"       "30"            "lower left point of drawable (y)"}
	{"width"      "240"           "width of drawing area"}
	{"height"     "190"           "height of drawing area"}
	{"xrange"     ""              "x range which maps onto drawable"}
	{"yrange"     ""              "y range which maps onto drawable"}
	{"fill"       "false"         "fill the drawable's entire background"}
	{"fillcolor"  ""              "if filling, fill drawable's entire background with this color"}
	{"linewidth"  "1"             "if drawing an outline box, use this linewidth"}
	{"linecolor"  ""              "if drawing an outline box, use this linecolor"}
    }
    ArgsProcessWithDashArgs Drawable default args use ""

    AssertNotEqual $use(xrange) "" 
    AssertNotEqual $use(yrange) "" 
    
    global _draw
    if {[info exists _draw(name,$use(name))]} {
	Abort "drawable $use(name) already exists"
    }
    set _draw(name,$use(name)) 1

    # fill background
    if {[true $use(fill)]} {
	puts stderr "drawable '$use(name)' fill $use(xoff) $use(yoff) : [expr $use(xoff)+$use(width)] [expr $use(yoff)+$use(height)]"
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
    puts stderr "drawable '$use(name)'  ranges: x [expr $xrange(1) - $xrange(0)]    y [expr $yrange(1) - $yrange(0)]"
    
    # record other info for future use too
    foreach v {xoff yoff width height} {
	set _draw(info,$use(name),$v) [expr double($use($v))]
    }
    set _draw(info,$use(name),ywidth) [expr double($use(height))]
    set _draw(info,$use(name),xwidth) [expr double($use(width))]

    # find where 0,0 is on the drawable region
    set _draw(info,$use(name),x0) [expr $use(xoff) - double($xrange(0)) * ($_draw(info,$use(name),width) / $_draw(info,$use(name),xrange))]
    set _draw(info,$use(name),y0) [expr $use(yoff) - double($yrange(0)) * ($_draw(info,$use(name),height) / $_draw(info,$use(name),yrange))]

    puts stderr "drawable '$use(name)'  x0: $_draw(info,$use(name),x0) y0: $_draw(info,$use(name),y0)"
}

proc DrawableGet {drawable name} {
    global _draw
    return $_draw(info,$drawable,$name)
}

# scale: scale a value onto the drawable's range
proc Scale {drawable axis value} {
    global _draw
    return [expr double($value) * ($_draw(info,$drawable,${axis}width) / $_draw(info,$drawable,${axis}range))]
}

proc ScaleX {drawable x} {
    global _draw
    return [expr double($x) * ($_draw(info,$drawable,width) / $_draw(info,$drawable,xrange))]
}

proc ScaleY {drawable y} {
    global _draw
    return [expr double($y) * ($_draw(info,$drawable,height) / $_draw(info,$drawable,yrange))]
}

# translate: scale and then add the offset 
proc Translate {drawable axis value} {
    global _draw
    return [expr $_draw(info,$drawable,${axis}0) + [Scale $drawable $axis double($value)]]
}

proc TranslateY {drawable y} {
    global _draw
    return [expr $_draw(info,$drawable,y0) + [ScaleY $drawable $y]]
}

proc TranslateX {drawable x} {
    global _draw
    return [expr $_draw(info,$drawable,x0) + [ScaleX $drawable $x]]
}

