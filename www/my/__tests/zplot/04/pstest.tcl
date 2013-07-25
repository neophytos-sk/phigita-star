#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# debugging
Debug 1 ps 
Debug 1 table

# define the canvas
PsCanvas -title "line.eps" -width 300 -height 240

PsPolygon -coord "100,100 : 100,200 : 150,220 : 200,200 : 200,100" -background lgray -fill t -fillstyle diaglines -fillcolor dred

PsCircle -coord 150,150 -radius 30 -background white -fill t -fillstyle diaglines2 -fillcolor orange 

# all done
PsRender


