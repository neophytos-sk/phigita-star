#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# data
Table -table km2 -file data.km2

# canvas and a single drawable
PsCanvas -title "km2.eps" -width 4 -height 2.5 -units inches
Drawable -xrange "0 36" -yrange "0.3 1" -width [expr [PsCanvasInfo -info width] - 50]

# now plot the data
PlotVerticalFill -table km2 -xfield T -yfield hi1 -ylofield lo1 -fillcolor lblue -legend "95% CI"
PlotVerticalFill -table km2 -xfield T -yfield hi2 -ylofield lo2 -fillcolor lblue
PlotLines -table km2 -xfield T -yfield val1 -linecolor blue -legend "Group A"
PlotLines -table km2 -xfield T -yfield val2 -linecolor red  -legend "Group B"

# axes, labels, legend
AxisTicsLabels -yticstep 0.1 -ylabelstep 0.1 -xlabelstep 12 -xticstep 12
Label -drawable canvas -coord [Location -type "xlabel"] -text "Months" -font Helvetica-Bold 
Legend -drawable canvas -coord 90,45 -style left

# all done
PsRender -file Output/km2.eps



