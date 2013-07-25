#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# data
Table -table km -file data.km

# canvas and a single drawable
PsCanvas -title "km.eps" -width 4 -height 2.5 -units inches
Drawable -xrange "0 50" -yrange "0.0 1.0" 

# now plot the data
PlotVerticalFill -table km -xfield T -yfield hi1 -ylofield lo1 -fillcolor lblue -legend "95% CI Group A"
PlotVerticalFill -table km -xfield T -yfield hi2 -ylofield lo2 -fillcolor pink -legend "95% CI Group B"
PlotVerticalFill -table km -xfield T -yfield hi1 -ylofield lo2 -fillcolor lgreen -legend "Overlap of CIs"
PlotLines -table km -xfield T -yfield val1 -linecolor blue -legend "Group A"
PlotLines -table km -xfield T -yfield val2 -linecolor red  -legend "Group B"

# axes, labels, legend
AxisTicsLabels -yticstep 0.1 -ylabelstep 0.2 -xlabelstep 12 -xticstep 12
Label -drawable canvas -coord [Location -type "xlabel"] -text "Months" -font Helvetica-Bold 
Label -drawable canvas -coord [Location -type "title"] -text "Kaplan-Meier Example" -font Courier
Legend -drawable canvas -coord 260,158 -style left -down f -width 8 -height 8 -fontsize 8.0

# all done
PsRender -file Output/km.eps




