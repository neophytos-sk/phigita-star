#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot5.eps -width 300 -height 300 

# read in the file (x, y, misc, state)
Table -table scatter -file "data.scatterplot5"

# this defines one particular drawing area
Drawable -xrange 0,80 -yrange 0,80 -xoff 30 -yoff 30 -width 260 -height 260

# axes
AxesTicsLabels -yauto ,,10 -xauto ,,10 

# add a single diagonal line
PlotFunction -func {$x} -range 0,80 -step 10 -linewidth 0.25 -linecolor gray

# now plot the intervals and points
PlotPoints -table scatter -xfield x -yfield y -style label -labelfield state -labelsize 9.0

# now, do a closeup!
Drawable -drawable closeup -xrange 51,53 -yrange 55,57 -xoff 220 -yoff 100 -width 100 -height 50

# this is UGLY -- but such is life
Table -table closeup -columns [TableGetColNames -table scatter -separator ,]
TableSelect -from scatter -to closeup -where {($x>=51)&&($x<=51)} 
for {set r 0; set nx 51.2; set ny 56.5} {$r < [TableGetNumRows -table closeup]} {incr r} {
    set x  [__TableGetVal closeup x $r] 
    __TableSetVal closeup x $r $nx
    __TableSetVal closeup y $r $ny
    set nx [expr $nx + 0.3]
    if {$nx >= 52.4} {
	set nx 51.2
	set ny [expr $ny + 0.4]
    }
}
PlotPoints     -drawable closeup -table closeup -xfield x -yfield y -style label -labelfield state -labelsize 8.0
Line -coord 51,56:57.5,44 -arrow t -linecolor red -arrowlinecolor red -arrowfillcolor red 
Box -coord 58,30:79,42 -linecolor red

# all done
PsRender -file scatterplot5.eps


