#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot10.eps -width 3.5in -height 3.5in

# read in the file into a table called bar1
Table -table scatter -file "data.scatterplot10"
TableAddColumns -table scatter -columns ylo,yhi,xlo,xhi

# this defines one particular drawing area
Drawable -xrange 0.5,5.0 -yrange 0,70 -xmargin 10

# axes
AxesTicsLabels -yauto ,,10 -xauto ,,0.5

# put yval + yse into yhi, and yval - yse -> ylo 
TableMath -table scatter -expression {$yval + $yse} -destcol yhi
TableMath -table scatter -expression {$yval - $yse} -destcol ylo
TableMath -table scatter -expression {$xval + $xse} -destcol xhi
TableMath -table scatter -expression {$xval - $xse} -destcol xlo

# now plot the intervals and points
PlotVerticalIntervals -table scatter -xfield xval -ylofield ylo -yhifield yhi \
    -linecolor orange -linewidth 0.25 -devwidth 2
PlotHorizontalIntervals -table scatter -yfield yval -xlofield xlo -xhifield xhi \
    -linecolor orange -linewidth 0.25 -devwidth 2
PlotPoints -table scatter -xfield xval -yfield yval \
    -style circle -linewidth 0.0 -fill t -fillcolor blue -size 0.75

# add a single red line for the function y = 10.9x - 3.50
PlotFunction -func {(10.9 * $x) - 3.50} -range 0.75,5 -step 4.25 -linecolor red -linewidth 0.5
Label -anchor l -coord 3.25,30 -text "y = 10.9x - 3.50" -color red -fontsize 6.0

# all done
PsRender -file scatterplot10.eps


