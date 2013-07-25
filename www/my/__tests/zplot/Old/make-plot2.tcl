# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "zplot.eps" -width 3.5 -height 2.75 -units inches

# read in the file into a table called bar1
Table -table bar1devs -file "data.devs"
Table -table bar1 -file "data.bar"
# TableDump bar1

# new table, to fill with selected values
Table -table gt -columns x,y,ylo
Table -table lt -columns x,y,ylo
TableSelect -from bar1 -fcolumns c0,c1,c2 -where {$c1 > 0} -to gt -tcolumns x,y,ylo
TableSelect -from bar1 -fcolumns c0,c1,c2 -where {$c1 <= 0} -to lt -tcolumns x,y,ylo
# TableDump gt
# TableDump lt

# this defines one particular drawing area (default name: "root")
Drawable -xrange 0,6 -yrange -10,25 -yoff 15

# plot some data, for goodness sake
PlotVerticalBars -table gt -x x -y y -ylo ylo \
    -barwidth 0.9 -fill t -fillcolor darkred -fillstyle /line -fillparams 0.5,3.5 \
    -legend "Widgets"
PlotVerticalBars -table lt -x x -y y -ylo ylo \
    -barwidth 0.9 -fill t -fillcolor darkblue -fillstyle hlines -fillparams .5,2.5 \
    -legend "Gidgets"
PlotVerticalIntervals -table bar1devs -x count -ylo devlo -yhi devhi -align b -linewidth 0.5 

# draw a legend
Legend -coord 50,20 -height 10 -width 10 -fontsize 10.0 

# old style axis
AxisTicsLabels -xlocation 0.0 -xlabellocation 0 -yrange -10,20 -ylocation 0 -yticstep 5 -xlabel "1,1 : 2,2: 4,4: 5,5: 6,6"

# minor and major tics for xaxis, just major for yaxis
# TicMarks -axis x -range 1,6 -step 1 -offset 10
# TicMarks -axis x -range 1,5 -step 0.25 -ticsize 2 -offset 10
# TicMarks -axis y -range -10,25 -step 5 

# labels for the tic marks
# TicLabels -axis x -label "1,1 : 2,2 : 4,3 : 5,hello" -offset 10
# TicLabels -axis y -range -10,25 -step 5 
# TicLabels -axis y -label "-10,-10 : 0,0 : 10,10 : 20, 20" 

# test out circles
PsCircle -coord 240,180 -radius 10 -fill t -fillcolor darkred -fillstyle squares -fillparams 2,2 -linewidth 0.25

Label -coord 1,6 -text "5"

# so easy to draw your own darn labels (if you like)
for {set i 1} {$i <= 6} {incr i} { 
    Label -coord $i,-10 -text $i -anchor r -rotate 90 -fontsize 6.0
}

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "A Good Example"
Label -drawable canvas -coord [Location -type "ylabel"] -text "Height (cm)" -rotate 90 
Label -drawable canvas -coord [Location -type "xlabel"] -text "Measured Thing"
# PsRaw "gsave newpath cpx cpy moveto 2 0 mr (Helvetica) findfont 10.0 scalefont setfont (Thang) lshow stroke grestore"

# make little tiny version of graph too (and show how easy this is)
Table -table hbars -file "hbars.data"
Drawable -drawable tiny -xoff 42 -yoff 120 -width 50 -height 40 -xrange 0,15 -yrange 0,5
Label -drawable canvas -coord [Location -drawable tiny -type "title"]  -text "Tiny Title" -fontsize 6.0
# so easy just to draw your own axes
Line -drawable tiny -coord "0,5 : 0,0 : 15,0" -linewidth 0.5

# Axis -drawable tiny -axis x -linewidth 0.5 ; Axis -drawable tiny -axis y -linewidth 0.5 
PlotHorizontalBars -drawable tiny -table hbars -x x -y y \
    -barwidth 0.9 -fill t -fillcolor orange -linewidth 0 -xlo xlo

# points
Table -table points -file "data.pts"
Drawable -drawable pts -xoff 105 -yoff 120 -width 50 -height 40 -xrange 0,11 -yrange 0,15
AxisTicsLabels -drawable pts -ylabel "0,0 : 5,5: 10,10: 15,15" -fontsize 6.0 -yticrange "0,15" -yticstep 5 -linewidth 0.5 
PlotPoints -drawable pts -table points -x x -y y -style box    -size 2.0 -linecolor orange -linewidth 0.25
PlotPoints -drawable pts -table points -x x -y y -style x      -size 0.5 -linecolor yellow -linewidth 0.25
PlotPoints -drawable pts -table points -x x -y y -style circle -size 1.0 -linecolor black -linewidth 0.25

# and finally, render it all
PsRender






