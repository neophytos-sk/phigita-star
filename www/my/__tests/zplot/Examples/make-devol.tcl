#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

PsCanvas -title "devol.eps" -width 400 -height 320

Table -file "data.devol"
TableAddColumns -columns mdate; TableMap -from date -to mdate

Drawable -xrange "-1,[expr [TableGetMax -column mdate] + 3]" -yrange 0,2000 \
    -coord ,40 -dimensions [expr [PsCanvasInfo -info width] - 15],
Grid -ystep 200 -xstep 1 -linecolor lightgray

# axes (no need to separate?)
AxesTicsLabels -style y -yauto ,,200 
AxesTicsLabels -style x -xmanual [TableMakeAxisLabels -name date -number mdate] -xlabelrotate 90 -xlabelanchor r,c 

# plot the darn data
PlotLines -xfield mdate -yfield value -stairstep true -linecolor purple \
    -labelfield value -labelsize 7 -labelcolor purple -labelshift 6,0 -labelrotate 90 -labelanchor l,c 

# embellishments
Circle -coord 10,463 -radius 20 -linecolor red 
Circle -coord 10,463 -radius 1 -linecolor red 

# all done
PsRender -file "devol.eps"
