#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot-import.tcl

Table -file "data.table" -table all -separator ":"
Table -table title -columns c0,c1,c2,c3
Table -table data  -columns c0,c1,c2,c3
TableSelect -from all -to title -where "\[StringEqual \$c3 bold]"
TableSelect -from all -to data  -where "\[StringEqual \$c3 normal]"
PsCanvas -width 80 -height 44
Drawable -xrange -0.75,1.45 -yrange 0,5.5 -xoff 0 -yoff 0 -width 80 -height 44
# PlotPoints -table "data" -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h
PlotPoints -table title -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h -labelfont Helvetica-Bold
PlotPoints -table data  -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h
Line -coord "-0.7,4.15 : 1.4,4.15" -linewidth 0.25
Line -coord "0.7,0.2 : 0.7,5.2" -linewidth 0.25
PsRender -file "table.eps"



