#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot-import.tcl

PsCanvas -title tutorial.eps -dimensions 3in,2.4in

Table -file tutorial.data

Drawable -xrange 0,4 -yrange 0,4

AxesTicsLabels -title "Tutorial" -xtitle "X Axis" -ytitle "Y Axis"

PlotPoints 

PsRender -file tutorial.eps












