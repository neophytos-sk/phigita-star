#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# define the canvas
PsCanvas -title "test.eps" -width 200 -height 60

set y 10
set s 20

set x 10
PsText -coord $x,$y  -anchor l,l -text "Anchor Is l,l" 
PsText -coord $x,[expr $y+$s]  -anchor l,c -text "Anchor Is l,c" 
PsText -coord $x,[expr $y+$s+$s] -anchor l,h -text "Anchor Is l,h" 

PsCircle -coord $x,$y -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s] -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s+$s] -linecolor red -fill t -fillcolor red

set x 100
PsText -coord $x,$y  -anchor c,l -text "Anchor Is c,l" 
PsText -coord $x,[expr $y+$s]  -anchor c,c -text "Anchor Is c,c" 
PsText -coord $x,[expr $y+$s+$s] -anchor c,h -text "Anchor Is c,h" 

PsCircle -coord $x,$y -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s] -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s+$s] -linecolor red -fill t -fillcolor red

set x 190
PsText -coord $x,$y  -anchor r,l -text "Anchor Is r,l" 
PsText -coord $x,[expr $y+$s]  -anchor r,c -text "Anchor Is r,c" 
PsText -coord $x,[expr $y+$s+$s] -anchor r,h -text "Anchor Is r,h" 

PsCircle -coord $x,$y -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s] -linecolor red -fill t -fillcolor red
PsCircle -coord $x,[expr $y+$s+$s] -linecolor red -fill t -fillcolor red

# all done
PsRender -file pstest.eps 




