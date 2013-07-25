#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

set number [lindex $argv 0]

source zplot-import.tcl

set tb [clock clicks -milliseconds]

# describe the drawing surface
PsCanvas -title "timing-example.eps" -width 300 -height 200

# load some data
set t0 [clock clicks -milliseconds]
Table -table t -file "data.$number"
set t1 [clock clicks -milliseconds]
puts "Table: [expr ($t1/1e3) - ($t0/1e3)]"

# make a drawable region for a graph
Drawable -xrange 0,$number -yrange 0,$number

# make some axes
AxesTicsLabels -title "A Sample Graph" -xtitle "The X-Axis" -ytitle "The Y-Axis"

# plot the points
set t0 [clock clicks -milliseconds]
PlotPoints -table t -xfield c0 -yfield c1 -style hline -size 1
set t1 [clock clicks -milliseconds]
puts "PlotPoints: [expr ($t1/1e3) - ($t0/1e3)]"

# finally, output the graph to a file
PsRender -file "timing-example.eps"

set te [clock clicks -milliseconds]
puts "Overall: [expr ($te/1e3) - ($tb/1e3)]"
