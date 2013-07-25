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

# this defines one particular drawing area (default name: "root")
Drawable -xrange 0,6 -yrange -10,25 -yoff 15

# plot some data, for goodness sake
PlotVerticalBars -table gt -xfield x -yfield y -ylofield ylo \
    -barwidth 0.9 -fill t -fillcolor dred -fillstyle /line -fillparams 0.5,3.5 \
    -legend "Widgets"
PlotVerticalBars -table lt -xfield x -ylofield y -ylofield ylo \
    -barwidth 0.9 -fill t -fillcolor dblue -fillstyle hline -fillparams .5,2.5 \
    -legend "Gidgets"
PlotVerticalIntervals -table bar1devs -xfield count -ylofield devlo -yhifield devhi -align r -linewidth 0.5

# draw a legend
Legend -coord 50,20 -height 10 -width 10 -vskip 2 -fontsize 10.0 

# old style axis
Axis -axis x -location 0.0
Axis -axis y -range -10,20 

# minor and major tics for xaxis, just major for yaxis
TicMarks -axis x -range 1,6 -step 1 -location 0
TicMarks -axis x -range 1,5 -step 0.25 -ticsize 2 -location 0
TicMarks -axis y -range -10,25 -step 5 

# labels for the tic marks
TicLabels -axis x -label "1,1 : 2,2 : 4,3 : 5,hello" -location 0
TicLabels -axis y -range -10,25 -step 5 
# TicLabels -axis y -label "-10,-10 : 0,0 : 10,10 : 20, 20" 

# test out circles
PsCircle -coord 240,180 -radius 10 -fill t -fillcolor dred -fillstyle square -fillparams 2,2 -linewidth 0.25

Label -coord 1,6 -text "5"

# so easy you can even draw your own darn labels (if you like)
for {set i 1} {$i < 6} {incr i} { 
    Label -coord $i,-10 -text $i -anchor r -rotate 90 -fontsize 6.0
}

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "A Good Example"
Label -drawable canvas -coord [Location -type "ylabel"] -text "Height (cm)" -rotate 90 -xshift 5
Label -drawable canvas -coord [Location -type "xlabel"] -text "Measured Thing"
# PsRaw "gsave newpath cpx cpy moveto 2 0 mr (Helvetica) findfont 10.0 scalefont setfont (Thang) lshow stroke grestore"

# make little tiny version of graph too (and show how easy this is)
Table -table hbars -file "data.hbars"
Drawable -name tiny -xoff 50 -yoff 120 -width 50 -height 40 -xrange 0,15 -yrange 0,5
Label -drawable canvas -coord [Location -drawable tiny -type "title"]  -text "Tiny Title" -fontsize 6.0
# so easy just to draw your own axes
Line -drawable tiny -coord "0,5 : 0,0 : 15,0" -linewidth 0.5

# Axis -drawable tiny -axis x -linewidth 0.5 ; Axis -drawable tiny -axis y -linewidth 0.5 
PlotHorizontalBars -drawable tiny -table hbars -xfield x -yfield y \
    -barwidth 0.9 -fill t -fillcolor orange -linewidth 0 -xlofield xlo

# points
Table -table points -file "data.pts"
Drawable -name pts -xoff 105 -yoff 120 -width 50 -height 40 -xrange 0,11 -yrange 0,15
Axis -drawable pts -axis x; Axis -drawable pts -axis y 
PlotPoints -drawable pts -table points -xfield x -yfield y -style square -size 2.0 \
    -linecolor orange -linewidth 0.25
PlotPoints -drawable pts -table points -xfield x -yfield y -style xline  -size 0.5 \
    -linecolor yellow -linewidth 0.25
PlotPoints -drawable pts -table points -xfield x -yfield y -style circle -size 1.0 \
    -linecolor black -linewidth 0.25

# and finally, render it all
PsRender






