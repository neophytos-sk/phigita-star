# tcl




	switch -exact $use(style) {
	    "box" { 
		PsBox -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "circle" { 
		PsCircle -coord $x,$y -radius $use(size) \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "filledcircle" { 
		PsCircle -coord $x,$y -radius $use(size) \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -fill t -fillcolor $use(linecolor) }
	    "x" { 
		PsLine -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
		PsLine -coord "[expr $x-$s] [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "triangle" { XXX }
	    default {
		Abort "bad choice of point style: $use(style)"
	    }
