#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# read in data
Table -table iron -file "data.iron"
TableMath -table iron -expression {$x + 0.5} -destcol x
TableMath -table iron -expression {$y + 0.5} -destcol y

# select different values to plot different points
foreach t {zero stop retry propagate redundancy} {
    Table -table $t -columns x,y,action
    TableSelect -from iron -to $t -where "\[StringEqual \$action $t\]" \
	-fcolumns x,y,action -tcolumns x,y,action
}

set cols   20
set rows   12
set size   10.0
set hsize  5.0
set width  [expr $cols * $size]
set height [expr $rows * $size]

# canvas, drawable
PsCanvas -title "iron.eps" -width $width -height [expr $height + 40.0]
Drawable -xrange "0 $cols" -yrange "0 $rows" -xoff 0 -yoff 40.0 -width $width -height $height \
    -fill t -fillcolor lgray

# make all points white
PlotPoints -table iron -style square -size $hsize -fill t -fillcolor white -linewidth 0.0

# stop, retry, propagate, zero, redundancy
PlotPoints -table stop       -style vline  -size $hsize -linewidth 0.5
PlotPoints -table retry      -style /line  -size $hsize -linewidth 0.5
PlotPoints -table propagate  -style hline  -size $hsize -linewidth 0.5
PlotPoints -table zero       -style circle -size $hsize -linewidth 0.5 
PlotPoints -table redundancy -style \line  -size $hsize -linewidth 0.5 

# overlay a grid
for {set r 0} {$r < $rows} {incr r} {
    Line -coord "0 $r : $cols $r" -linewidth 0.25
}
for {set c 0} {$c < $cols} {incr c} {
    Line -coord "$c 0 : $c $rows" -linewidth 0.25
}

# some axis labels
TicLabels -axis x -label "0,open : 1,close : 2,read : 3,x : 4,x : 5,x : 6,x : 7,x : 8,x : 9,x : 10,x : 11,x : 12,x : 13,x : 14,x : 15,x : 16,x : 17,x : 18,x : 19,x " -rotate 90 -xshift 4.0 -fontsize 8.0

# all done
PsRender -file Output/iron.eps

