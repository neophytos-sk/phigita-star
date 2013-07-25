#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs-import.tcl

# define the canvas
PsCanvas -title "labels.eps" -width 500 -height 500 

# make a drawable
Drawable -xrange 0,20 -yrange 0,20 -xoff 120

set letter [lindex $argv 0]

set letterStr "${letter}"
for {set i 1} {$i < 10} {incr i} {
    set letterStr "${letterStr}${letter}"
}

set ystr "1,$letterStr"
for {set i 2} {$i <= 20} {incr i} {
    set ystr "$ystr : $i,$letterStr"
}

AxesTicsLabels -xauto 0,20,2 -ymanual $ystr -fontsize 10 -ytitle "test"

for {set i 1} {$i <= 20} {incr i} {
    set value [expr 0.50 + (($i-1)*0.02)]
    Label -coord 0.1,$i -anchor l,c -text $value
}


PsRender -file "Output/labels.eps"


