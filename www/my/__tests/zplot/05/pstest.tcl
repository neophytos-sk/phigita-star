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

# PsPolygon -coord "100,100 : 100,200 : 150,220 : 200,200 : 200,100" -background lgray -fill t -fillstyle /line -fillcolor dred

# PsCircle -coord 150,150 -radius 30 -background white -fill t -fillstyle \line -fillcolor orange 

PsLine -coord "100 10 : 200 10" -arrow t 
PsLine -coord "100 10 : 100 110" -arrow t 
PsLine -coord "10 10 : 60 60" -arrow t -arrowfillcolor lgray

# PsText -coord "100 10" -anchor l -yanchor c -text "Text 33" -color red -font Courier

# all done
PsRender


