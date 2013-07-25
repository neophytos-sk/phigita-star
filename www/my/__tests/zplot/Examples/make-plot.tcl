#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "zplot.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar1
Table -table bar1devs -file "data.devs"
Table -table bar1 -file "data.bar"  -separator ":"
# TableDump bar1

# new table, to fill with selected values
Table -table gt -columns x,y,ylo
Table -table lt -columns x,y,ylo
TableSelect -from bar1 -fcolumns c0,c1,c2 -where {$c1 > 0} -to gt -tcolumns x,y,ylo
TableSelect -from bar1 -fcolumns c0,c1,c2 -where {$c1 <= 0} -to lt -tcolumns x,y,ylo

# this defines one particular drawing area
Drawable -xrange 0,6 -yrange -10,25 -coord 35,15

# plot some data, for goodness sake
PlotVerticalBars -table gt -xfield x -yfield y -yloval 0 \
    -barwidth 0.9 -fill t -fillcolor darkred -fillstyle dline1 -fillsize 0.5 -fillskip 3.5 -bgcolor white \
    -legend "Widgets"
PlotVerticalBars -table lt -xfield x -yfield y -yloval 0 \
   -barwidth 0.9 -fill t -fillcolor darkblue -fillstyle hline -fillsize .5 -fillskip 2.5 -bgcolor white \
    -legend "Gidgets"

# old style axis
AxesTicsLabels -style xy -xaxisposition 0.0 -xauto 1,6,1 \
    -title "A Good Example" -xtitle "Measured Thing" -ytitle "Height (cm)"

# draw a legend
# Legend -coord 50,20 -height 10 -width 10 -vskip 2 -fontsize 10.0 

# test out circles
PsCircle -coord 240,180 -radius 10 -fill t -fillcolor darkred -fillstyle square \
    -fillsize 2 -fillskip 2 -linewidth 0.25

Label -coord 1,6 -text "5"

# so easy you can even draw your own darn labels (if you like)
for {set i 1} {$i <= 6} {incr i} { 
    Label -coord $i,-9 -text $i -anchor r -rotate 90 -fontsize 6.0
}

# make little tiny version of graph too (and show how easy this is)
Table -table hbars -file "data.hbars"
Drawable -drawable tiny -coord 50,120 -dimensions 50,40 -xrange 0,15 -yrange 0,5
# so easy just to draw your own axes and title
Label -coord 7.5,5 -text "Tiny Title" -fontsize 6.0 -anchor c,l
Line -drawable tiny -coord "0,5 : 0,0 : 15,0" -linewidth 0.5

# Axis -drawable tiny -axis x -linewidth 0.5 ; Axis -drawable tiny -axis y -linewidth 0.5 
PlotHorizontalBars -drawable tiny -table hbars -xfield x -yfield y \
    -barwidth 0.9 -fill t -fillcolor orange -linewidth 0 -xlofield xlo

# points
Table -table points -file "data.pts"
Drawable -drawable pts -coord 105,120 -dimensions 50,40 -xrange 0,11 -yrange 0,15
AxesTicsLabels -drawable pts -style xy -majortics f -labels f
PlotPoints -drawable pts -table points -xfield x -yfield y -style square -size 2.0 \
    -linecolor orange -linewidth 0.25
PlotPoints -drawable pts -table points -xfield x -yfield y -style xline  -size 0.5 \
    -linecolor yellow -linewidth 0.25
PlotPoints -drawable pts -table points -xfield x -yfield y -style circle -size 1.0 \
    -linecolor black -linewidth 0.25

# and finally, render it all
PsRender -file plot.eps






