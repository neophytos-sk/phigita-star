#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# get the table
Table -table "heat" -file "data.heat"

# define the canvas
PsCanvas -title "heat.eps" -width 3.75in -height 3in

# make a drawable
Drawable -xrange 0,17 -yrange 2,12 -xoff 50

# plot the heat graph, first getting maximumn heat value to pass to PlotHeat function
set max [TableGetMax -table heat -column count]
puts stderr "max heat: $max"
PlotHeat -table heat -xfield time -yfield syscall -hfield count -divisor $max -label true -labelcolor orange

# axes
AxesTicsLabels -xauto 0,17,2 -xlabeltimes 0.1 \
    -ymanual "2,open-R:3,open-C:4,open-A:5,open:6,read:7,write:8,access:9,close:10,fstat:11,unlink:12," \
    -ylabelshift 0,8 -fontsize 8 \
    -title "System Call Density during PostMark" -ytitle "System Call" -xtitle "Time (s)"

# and finally, render it all
PsRender -file heat.eps
