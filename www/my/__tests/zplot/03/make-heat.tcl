# source the library
source libs.tcl
namespace import Zplot::*

# get the table
TableLoad -table "heat" -file "x.dat.processed"

# define the canvas
PsCanvas -title "heat.eps" -width 3.75 -height 3 -units inches

# make a drawable
Drawable -xrange 0,17 -yrange 2,12 -xoff 50

# plot something
PlotHeat -table heat -divisor 470.0 -label f

# axes 
Axis -axis x; Axis -axis y 

# minor and major tics for xaxis, just major for yaxis
TicMarks -axis x -range 0,17 -step 2
TicMarks -axis y -range 2,12 -step 1
# labels for the tic marks
TicLabels -axis x -label "0,0 : 2,0.2 : 4,0.4 : 6,0.6 : 8,0.8 : 10,1.0 : 12,1.2 : 14,1.4 : 16,1.6"
TicLabels -axis y -label "2,open-R : 3,open-C : 4,open-A : 5,open : 6,read : 7,write : 8,access : 9,close : 10,fstat : 11,unlink " -yshift 10 -fontsize 8

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "System Call Density during PostMark"
Label -drawable canvas -coord [Location -type "ylabel"] -text "System Call" -rotate 90 
Label -drawable canvas -coord [Location -type "xlabel"] -text "Time (s)" -yshift -5

# and finally, render it all
PsRender






