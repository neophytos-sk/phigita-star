#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot-import.tcl

PsCanvas -title "bars2.eps" -width 300 -height 140
Drawable -xrange 89,102 -yrange -15,30 -coord 0,25 -dimensions 300,100
Box -drawable canvas -coord 0,0:300,140 -fill t -fillcolor darkgreen -linewidth 0

Table -table bars2 -file data.bars2

# select the columns into two groups: y value > zero, and <= zero
Table -table gt -columns x,y
Table -table lt -columns x,y
TableSelect -from bars2 -fcolumns c0,c1 -where {$c1 > 0} -to gt -tcolumns x,y
TableSelect -from bars2 -fcolumns c0,c1 -where {$c1 <= 0} -to lt -tcolumns x,y

Grid -y f -xrange 90,101 -xstep 1 -linecolor yellow -linedash 2,2

PlotVerticalBars -table gt -xfield x -yfield y -fill t -fillcolor yellow -barwidth 0.7 -linewidth 0 -yloval 0 \
    -labelfield y -labelcolor white -labelfont Helvetica-Bold -labelsize 7.0
PlotVerticalBars -table lt -xfield x -yfield y -fill t -fillcolor    red -barwidth 0.7 -linewidth 0 -yloval 0 \
    -labelfield y -labelplace o -labelanchor c,h -labelcolor white -labelfont Helvetica-Bold -labelsize 7.0 

# a bit of a hack to get around that we don't support date fields (yet)
AxesTicsLabels -style x -xauto 90,99,1 -majortics f -xaxisposition 0 -linewidth 0.5 \
    -fontsize 8.0 -xlabelformat "'%s" -xlabelshift 0,-30 -linecolor white -fontcolor white
AxesTicsLabels -style x -xmanual "100,'00 : 101,'01" -majortics f -xaxisposition 0 \
    -linewidth 0.5 -fontsize 8.0 -xlabelshift 0,-30 -axis f -fontcolor white

# label positioning always a pain on these bad boys that take up too much of the canvas
Label -text "Emerging growth fund annual return (%)" -coord 89.5,32 -anchor l -fontsize 8.0 -font "Courier-Bold" -color white
Label -text "Calendar Year" -coord 95.5,-24 -fontsize 8.0 -color white 

PsRender -file "bars2.eps"
