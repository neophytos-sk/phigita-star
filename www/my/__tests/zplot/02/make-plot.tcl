#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source libs.tcl

# define the canvas
PsCanvas -title "zplot.eps" -width 300 -height 240 

# read in the file into a table called bar1
TableLoad -table bar1devs -file "data.devs"
TableLoad -table bar1 -file "data.bar"

# new table, to fill with selected values
Table -table gt -columns x,y
Table -table lt -columns x,y
TableSelect -from bar1 -fcolumns count,height -where {$height > 0} -to gt -tcolumns x,y
TableSelect -from bar1 -fcolumns count,height -where {$height <= 0} -to lt -tcolumns x,y

# this is actually defining one particular drawing area (default name: "default")
# Drawable -name default -x0 40 -y0 30 -width 240 -height 200 -xrange 0,6 -yrange 0,25
Drawable -xrange 0,6 -yrange -10,25 

# now, any drawing has to be relative to a drawable area
# PlotBar  -table bar1 -x count -y height -barwidth 0.9 -fill t -fillcolor lgray
PlotBar  -table gt -x x -y y -barwidth 0.9 -fill t -fillcolor darkgray   -legend "Darker"
PlotBar  -table lt -x x -y y -barwidth 0.9 -fill t -fillcolor lightgray  -legend "Lighter"
PlotDevs -table bar1devs -x count -ylo devlo -yhi devhi 

# axes 
Axis -axis x
Axis -axis y -dash "1 2"

# minor and major tics for xaxis
TicMarks -axis x -range 0,6 -step 1 
TicMarks -axis y -range -10,25 -step 5 
# TicLabels -axis x -range 0,6 -step 1
TicLabels -axis x -label " 1,1 : 2,2 : 5,5"
TicLabels -axis y -label " -10,-10 : 0,0 : 10,10 : 20, 20" 

# Tics 

# major y tics
# Tics -axis y -tics -10,25,5 -labeltype numeric -label -10,25,5 

# labels
Label -coord [Placement -type "title"]  -text "A Good Example"
Label -coord [Placement -type "ylabel"] -text "Height (cm)" -rotate 90
Label -coord [Placement -type "xlabel"] -text "Measured Thing"

# make little tiny version of graph too (and show how easy this is)
Drawable -name tiny -xoff 60 -yoff 160 -width 50 -height 40 -xrange 0,6 -yrange -10,25 
Axis -drawable tiny -axis x 
Axis -drawable tiny -axis y 
PlotBar -drawable tiny -table bar1 -x count -y height -barwidth 0.9 -fill t -fillcolor orange -linewidth 0.5

# points
TableLoad -table points -file "data.pts"
Drawable -name pts -xoff 120 -yoff 160 -width 50 -height 40 -xrange 0,11 -yrange 0,15
Axis -drawable pts -axis x; Axis -drawable pts -axis y 
PlotPoints -drawable pts -table points -x x -y y -style box    -size 2.0 -linecolor black -linewidth 0.25
PlotPoints -drawable pts -table points -x x -y y -style x      -size 0.5 -linecolor black -linewidth 0.25
PlotPoints -drawable pts -table points -x x -y y -style circle -size 1.0  -linecolor black -linewidth 0.25




# and finally, render it all
PsRender






