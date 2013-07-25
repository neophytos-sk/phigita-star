#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# get the table
Table -table "heat" -file "data.heat"

# define the canvas
PsCanvas -title "heat.eps" -width 3.75 -height 3 -units inches

# make a drawable
Drawable -xrange 0,17 -yrange 2,12 -xoff 50

# plot the heat graph, first getting maximumn heat value to pass to PlotHeat function
set max [TableGetMax -table heat -column count]
puts stderr "max heat: $max"
PlotHeat -table heat -xfield time -yfield syscall -hfield count -divisor $max -label true -fontcolor orange

# axes
AxisTicsLabels -xrange 0,17 -yrange 2,12 \
    -xlabel "0,0 : 2,0.2 : 4,0.4 : 6,0.6 : 8,0.8 : 10,1.0 : 12,1.2 : 14,1.4 : 16,1.6" \
    -ylabel "2,open-R:3,open-C:4,open-A:5,open:6,read:7,write:8,access:9,close:10,fstat:11,unlink" \
    -ylabelyshift 10.0 -fontsize 8.0

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "System Call Density during PostMark"
Label -drawable canvas -coord [Location -type "ylabel"] -text "System Call" -rotate 90 
Label -drawable canvas -coord [Location -type "xlabel"] -text "Time (s)" -yshift -5

# and finally, render it all
PsRender -file Output/heat.eps
