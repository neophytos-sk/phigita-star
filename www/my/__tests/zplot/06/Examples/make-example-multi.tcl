#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# input the library
source zplot.tcl
namespace import Zplot::*

# describe the drawing surface
PsCanvas -title "example-multi.eps" -width 300 -height 205

Table -table t -file "file.data"
TableAddColumns -table t -columns ylower,yhigher
TableMath -table t -expression {$ylo-1} -destcol ylower
TableMath -table t -expression {$yhi+1} -destcol yhigher

# lines
Drawable -drawable d1 -xrange 0,11 -yrange 0,10 -xoff 10 -yoff 10 -width 60 -height 40
AxesTicsLabels -title Lines -drawable d1 -majortics f -labels f
PlotLines -table t -drawable d1 -xfield x -yfield y -linewidth 0.5

# points
Drawable -drawable d23 -xrange 0,11 -yrange 0,10 -xoff 80 -yoff 10 -width 60 -height 40
AxesTicsLabels -title "Points" -drawable d23 -majortics f -labels f
PlotPoints -table t -drawable d23 -xfield x -yfield y -style xline -linewidth 0.5

# linespoints
Drawable -drawable d2 -xrange 0,11 -yrange 0,10 -xoff 150 -yoff 10 -width 60 -height 40
AxesTicsLabels -title "Lines & Points" -drawable d2 -majortics f -labels f
PlotLines -table t -drawable d2 -xfield x -yfield y -linewidth 0.5
PlotPoints -table t -drawable d2 -xfield x -yfield y -style xline -linewidth 0.5

# filled 
Drawable -drawable d3 -xrange 0,11 -yrange 0,10 -xoff 220 -yoff 10 -width 60 -height 40
PlotVerticalFill -table t -drawable d3 -xfield x -yfield y 
PlotLines -table t -drawable d3 -xfield x -yfield y -linewidth 0.5
AxesTicsLabels -title "Filled" -drawable d3 -majortics f -labels f

# error bars
Drawable -drawable da -xrange 0,11 -yrange 0,10 -xoff 10 -yoff 80 -width 60 -height 40
AxesTicsLabels -title "Error Bars" -drawable da -majortics f -labels f
PlotVerticalIntervals -table t -drawable da -xfield x -ylofield ylo -yhifield yhi -linewidth 0.5
PlotPoints -table t -drawable da -xfield x -yfield y -style circle -linewidth 0.5 -size 0.5

# box plots
Drawable -drawable db -xrange 0,11 -yrange 0,10 -xoff 80 -yoff 80 -width 60 -height 40
AxesTicsLabels -title "Box Plots" -drawable db -majortics f -labels f
PlotVerticalIntervals -table t -drawable db -xfield x -ylofield ylower -yhifield yhigher -linewidth 0.5
PlotVerticalBars -table t -drawable db -xfield x -ylofield ylo -yfield yhi -fill t -fillcolor gray -linewidth 0.5 -barwidth 0.8
PlotPoints -table t -drawable db -xfield x -yfield y -style circle -linewidth 0.5 -size 0.5 

# hintervals
Drawable -drawable dc -xrange 0,10 -yrange 0,11 -xoff 150 -yoff 80 -width 60 -height 40
AxesTicsLabels -title "Intervals" -drawable dc -majortics f -labels f
PlotHorizontalIntervals -table t -drawable dc -yfield x -xlofield ylo -xhifield yhi -linewidth 0.5

# functions
Drawable -drawable dd -xrange 0,10 -yrange 0,11 -xoff 220 -yoff 80 -width 60 -height 40
AxesTicsLabels -title "Functions" -drawable dd -majortics f -labels f
PlotFunction -drawable dd -func {$x} -range 0,10 -step 0.1 -linewidth 0.5
PlotFunction -drawable dd -func {2*$x} -range 0,5 -step 0.1 -linewidth 0.5
PlotFunction -drawable dd -func {$x*$x} -range 0,3.3 -step 0.1 -linewidth 0.5
Label -drawable dd -coord 1.5,9 -text "y=x*x" -fontsize 6
Label -drawable dd -coord 5.5,8 -text "y=x" -fontsize 6
Label -drawable dd -coord 7.5,5 -text "y=2x" -fontsize 6

# bars
Drawable -drawable d5 -xrange 0,11 -yrange 0,10 -xoff 10 -yoff 150 -width 60 -height 40
AxesTicsLabels -title "Vertical Bars" -drawable d5 -majortics f -labels f
PlotVerticalBars -table t -drawable d5 -xfield x -yfield y -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t

# stacked bars
Drawable -drawable d55 -xrange 0,11 -yrange 0,10 -xoff 80 -yoff 150 -width 60 -height 40
AxesTicsLabels -title "Stacked Bars" -drawable d55 -majortics f -labels f
PlotVerticalBars -table t -drawable d55 -xfield x -yfield y -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t
Table -table t2 -file "file2.data"
PlotVerticalBars -table t2 -drawable d55 -xfield x -yfield y -barwidth 0.8 -fillcolor black -linewidth 0 -fill t

# bars
Drawable -drawable d6 -xrange 0,10 -yrange 0,11 -xoff 150 -yoff 150 -width 60 -height 40
AxesTicsLabels -title "Horizontal Bars" -drawable d6 -majortics f -labels f
PlotHorizontalBars -table t -drawable d6 -xfield y -yfield x -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t

# heat
Table -table h -file "file.heat"
Drawable -drawable d7 -xrange 0,6 -yrange 0,6 -xoff 220 -yoff 150 -width 60 -height 40
PlotHeat -table h -drawable d7 -xfield c0 -yfield c1 -hfield c2 -divisor 4.0
AxesTicsLabels -title "Heat" -drawable d7 -majortics f -labels f



# finally, output the graph to a file
PsRender -file "example-multi.eps"
