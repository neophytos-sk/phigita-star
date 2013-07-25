#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# data
Table -table km -file data.km

# canvas and a single drawable
PsCanvas -title "km.eps" -width 4in -height 2.5in
Drawable -xrange "0,50" -yrange "0.0,1.0" 

# now plot the data
PlotVerticalFill -table km -xfield T -yfield hi1 -ylofield lo1 -fillcolor  lightblue -legend "95% CI Group A"
PlotVerticalFill -table km -xfield T -yfield hi2 -ylofield lo2 -fillcolor       pink -legend "95% CI Group B"
PlotVerticalFill -table km -xfield T -yfield hi1 -ylofield lo2 -fillcolor lightgreen -legend "Overlap of CIs"
PlotLines -table km -xfield T -yfield val1 -linecolor blue -legend "Group A"
PlotLines -table km -xfield T -yfield val2 -linecolor red  -legend "Group B"

# axes, labels, legend
AxesTicsLabels -yauto ,,0.2 -xauto ,,12 -xtitle "Months" 
Label -coord 25,1 -text "Kaplan-Meier Example" -font Courier
Legend -drawable canvas -coord 260,158 -style left -down t -width 8 -height 8 -fontsize 8.0

# all done
PsRender -file km.eps




