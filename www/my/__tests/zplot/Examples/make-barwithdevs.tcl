#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# define the canvas
PsCanvas -title "barwithdevs.eps" -width 3.5in -height 2.75in

Table -file "data.barwithdevs" -separator ":"
set ymax [TableGetMax -column c1]
TableAddColumns -columns map
TableMap -from c0 -to map

Drawable -xrange "-0.5,4.5" -yrange "0,[expr $ymax+3]" -dimensions -10p,

PlotVerticalBars -xfield map -yfield c1 -barwidth 0.8 \
    -fill t -fillstyle solid -fillcolor gray -legend Widgets 
PlotPoints -xfield map -yfield c3 -style label \
    -labelfont Courier -labelfield c4 -labelcolor red -labelsize 9 \
    -labelrotate 90 -labelanchor l,c -labelshift 0,5
PlotVerticalIntervals -xfield map -ylofield c2 -yhifield c3 

AxesTicsLabels -xtitle  "A Bar Plot" -ytitle "Height (cm)" \
    -title "Measured Thing" -ytitleshift -2,0 -xmanual \
    [TableMakeAxisLabels -name c0 -number map]
Legend -coord 3.2,7.5 -height 10 -width 10 -fontsize 10.0 

# and finally, render it all
PsRender -file "barwithdevs.eps"













