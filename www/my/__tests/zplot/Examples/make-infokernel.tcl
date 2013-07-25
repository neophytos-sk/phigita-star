#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# define the canvas
PsCanvas -title "infokernel.eps" -width 2in -height 3.4in

set stacks {misc  sim       refresh check}
set colors {black lightgray white   darkgray}

# make two drawables, one for the upper graph, one for the lower
Drawable -drawable lo -xrange "-0.5,3.5" -yrange "0,5" \
    -coord .4in,0.4in -dimensions 1.4in,1.375in
Drawable -drawable hi -xrange "-0.5,3.5" -yrange "96,101" \
    -coord 0.4in,1.775in -dimensions 1.4in,1.375in

# load data and plot the graphs (on both drawables)
for {set i 0} {$i < [llength $stacks]} {incr i} {
    set t [lindex $stacks $i]
    set c [lindex $colors $i]
    Table -table $t -file "infokernel/times.$t" 
    PlotVerticalBars -drawable hi -table $t -xfield c0 -yfield c1 \
	-barwidth 0.7 -yloval 0 -fill t -fillcolor $c -fillstyle solid 
    PlotVerticalBars -drawable lo -table $t -xfield c0 -yfield c1 \
	-barwidth 0.7 -yloval 0 -fill t -fillcolor $c -fillstyle solid \
	-legend [string toupper $t 0 0]
}

# axes (again, one for each drawable)
AxesTicsLabels -drawable lo -xaxisposition 0 -yauto 0,4,2 \
    -xmanual "0,FIFO : 1,LRU : 2,MRU : 3,LFU " \
    -xtitle "Target Replacement Algorithm" \
    -ytitle "Time per Read (us)" -fontsize 8.0 \
    -ytitleshift -5,50 -xtitleshift -5,0
AxesTicsLabels -drawable hi -style y -fontsize 8.0 \
    -title "InfoReplace Overheads" -titleshift 0,5 -yauto 97,101,2

# draw some breaks on the graph
GraphBreak -drawable lo -coord -0.5,5 -elements 6 -linewidth 0.5
GraphBreak -drawable lo -coord    3,5 -elements 8 -linewidth 0.5

# draw a legend
Legend -drawable canvas -coord 65,215 -height 10 -width 10 -fontsize 8.0 -style left

# and finally, render it all
PsRender -file "infokernel.eps"






