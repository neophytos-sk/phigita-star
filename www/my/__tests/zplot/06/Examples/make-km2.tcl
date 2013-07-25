#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# data
Table -table km2 -file data.km2

# canvas and a single drawable
PsCanvas -title "km2.eps" -width 4in -height 2.5in
Drawable -xrange "0,36" -yrange "0.3,1" -width [expr [PsCanvasInfo -info width] - 50]

# now plot the data
PlotVerticalFill -table km2 -xfield T -yfield hi1 -ylofield lo1 -fillcolor lightblue -legend "95% CI"
PlotVerticalFill -table km2 -xfield T -yfield hi2 -ylofield lo2 -fillcolor lightblue
PlotLines -table km2 -xfield T -yfield val1 -linecolor blue -legend "Group A"
PlotLines -table km2 -xfield T -yfield val2 -linecolor red  -legend "Group B"

# axes, labels, legend
AxesTicsLabels -yauto ,,0.1 -xauto ,,12 -xtitle "Months" -xtitlefont Helvetica-Bold 
Legend -coord 8,.5 -style left 

# all done
PsRender -file km2.eps



