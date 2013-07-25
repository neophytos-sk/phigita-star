#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

PsCanvas -title "example-psline.eps" -width 200 -height 35

set r 0.25
set ccolor black

set ylo 5
set yhi 10
PsLine -coord "5,$ylo : 10,$ylo : 10,$yhi : 15,$yhi : 15,$ylo : 20,$ylo : 20,$yhi : 25,$yhi : 25,$ylo : 30,$ylo" -linecolor gray
PsCircle -coord 5,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 30,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor

set ylo 15
set yhi 20
PsLine -coord "5,$ylo : 10,$ylo : 10,$yhi : 15,$yhi : 15,$ylo : 20,$ylo : 20,$yhi : 25,$yhi : 25,$ylo : 30,$ylo" -linecap 1 -linecolor gray
PsCircle -coord 5,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 30,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor

set ylo 25
set yhi 30
PsLine -coord "5,$ylo : 10,$ylo : 10,$yhi : 15,$yhi : 15,$ylo : 20,$ylo : 20,$yhi : 25,$yhi : 25,$ylo : 30,$ylo"  -linecap 2 -linecolor gray
PsCircle -coord 5,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 30,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor


set ylo 5
set yhi 10
PsLine -coord "40,$ylo : 45,$ylo : 45,$yhi : 50,$yhi : 50,$ylo : 55,$ylo : 55,$yhi : 60,$yhi : 60,$ylo : 65,$ylo" -linecolor gray
PsCircle -coord 40,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 65,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor

set ylo 15
set yhi 20
PsLine -coord "40,$ylo : 45,$ylo : 45,$yhi : 50,$yhi : 50,$ylo : 55,$ylo : 55,$yhi : 60,$yhi : 60,$ylo : 65,$ylo" -linecolor gray -linejoin 1
PsCircle -coord 40,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 65,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor

set ylo 25
set yhi 30
PsLine -coord "40,$ylo : 45,$ylo : 45,$yhi : 50,$yhi : 50,$ylo : 55,$ylo : 55,$yhi : 60,$yhi : 60,$ylo : 65,$ylo" -linecolor gray -linejoin 2
PsCircle -coord 40,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor
PsCircle -coord 65,$ylo -radius $r -linewidth 0.1 -linecolor $ccolor





PsRender -file example-psline.eps




