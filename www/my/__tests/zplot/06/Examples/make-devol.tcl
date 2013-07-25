#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# do it
Table -table devol -file "data.devol"
# puts "unique: [TableGetUniqueValues -table devol -column date]"
PsCanvas -title "devol.eps" -width 400 -height 320
Drawable -xscale category -xrange "[TableGetUniqueValues -table devol -column date]" -yrange 0,2000 -yoff 40 -xmargin 15
Grid -ystep 200 -xstep 1 -linecolor lightgray
AxesTicsLabels -style y -yauto ,,200 
AxesTicsLabels -style x -xauto ,,1 -xlabelrotate 90 -xlabelanchor r,c 
DrawableSlide -slide .5,0
PlotLines -table devol -xfield date -yfield value -stairstep true -linecolor purple \
    -labelfield value -labelsize 7 -labelcolor purple -labelshift 4,0 -labelrotate 90 -labelanchor l,c 
Circle -coord 11/87,463 -radius 20 -linecolor red 
Circle -coord 11/87,463 -radius 1 -linecolor red 
# AxesTicsLabels
PsRender -file "devol.eps"
