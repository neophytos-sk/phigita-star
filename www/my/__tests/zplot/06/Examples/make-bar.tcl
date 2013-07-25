#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# define the canvas
PsCanvas -title "bar.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
Table -table bar -file "data.bar" -separator ":"

# this defines one particular drawing area
set xmax [TableGetMax -column c0 -table bar]
set ymax [TableGetMax -column c1 -table bar]
Drawable -xrange "0,[expr $xmax+1]" -yrange "-6,[expr $ymax+2]" -xoff 30

# plot some data, for goodness sake
PlotVerticalBars -table bar -xfield c0 -yfield c1 -barwidth 0.9 -labelfield c1 -yloval 0 \
    -fill t -fillcolor darkred -fillstyle solid -fillsize 4 -fillskip 4 -legend "Widgets" 

# axis
AxesTicsLabels -xaxisposition 0 -xauto 1,5,1 -xlabelbgcolor white \
    -title "Bar Plot" \
    -titleplace c -xtitleplace c -ytitleplace c 
Label -coord 3,-6 -anchor c,h -text "Measured Thing"

# draw a legend
Legend -coord 190,170 -height 10 -width 10 -fontsize 10.0 

# and finally, render it all
PsRender -file "bar.eps"






