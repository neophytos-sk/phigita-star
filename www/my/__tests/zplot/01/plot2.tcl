#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# use zdraw library
source zall.tcl

# define the canvas
Canvas -width 300 -height 240 

# read in the file into a table called bar1
TableRead -file "data.bar" -table bar1

# this is actually defining one particular drawing area
Drawable -x0 40 -y0 30 -drawwidth 240 -drawheight 190 -xrange 0,6 -yrange 0,25

# now draw the axis
# can use this moment to do autoaxis type stuff if one desires
# also, can allow some color control and Tufte-like optimizations
# what about allowing a second y-axis? 
Axis -xrange 0,6 -yrange 0,25

# tick marks and labels
# XXX - make this real, flexible, really flexible
Tics -style x -major 0,6,2    -numlabel 0,6,1
Tics -style y -major "0 25 5" -numlabel 0,25,5

# labels
# XXX - more control, options over placement
Title -text "A Good Example" -placement manual -x 150 -y 220
Label -style y -text "Height (cm)"
Label -style x -text "Measured Thing"

# style
# XXX anything at all here would be nice
# StyleSet -name orangebar -barwidth 0.9 -fill t -fillcolor orange 

# legend
# XXX 
# does this have to interact with style options?

# make the bar plot
BarPlot -table bar1 -x count -y height -barwidth 0.9 -fill t -fillcolor orange
# BarPlot -table bar1 -x count -y height -style orangebar

# and finally, render it all
Render








