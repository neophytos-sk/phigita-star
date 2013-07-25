#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "barwithdevs.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
Table -table bar -file "data.barwithdevs" -separator ":"
set ymax [TableGetMax -column c1 -table bar]
set categories [TableGetUniqueValues -table bar -column c0 -number n]
puts "table has $n entries: $categories"
Drawable -xscale category -xrange "[TableGetUniqueValues -table bar -column c0 -empties 1,1]" \
    -yrange "0,[expr $ymax+2]" -xoff 30 

AxesTicsLabels -xtitle  "A Bar Plot" -ytitle "Height (cm)" -title "Measured Thing" -ytitleshift -2,0

# finally, bars and some neat labels
PlotVerticalBars -table bar -xfield c0 -yfield c1 -barwidth 0.8 \
    -fill t -fillstyle solid -fillcolor gray -legend Widgets 
PlotPoints -table bar -xfield c0 -yfield c3 -style label \
    -labelfont Courier -labelfield c4 -labelcolor red -labelsize 9 -labelrotate 90 -labelanchor l,c -labelshift 0,5
PlotVerticalIntervals -table bar -xfield c0 -ylofield c2 -yhifield c3 

# draw a legend
Legend -drawable canvas -coord 200,180 -height 10 -width 10 -fontsize 10.0 


# and finally, render it all
PsRender -file barwithdevs.eps






