#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

# define the canvas
PsCanvas -title "pattern-example.eps" -width 300 -height 40

set x 15
set y 15

set w 20
set s 10

foreach t {solid hline vline dline1 dline2 circle} {
    puts "PLOTTING $t"
    PsText -coord $x,[expr $y-4] -text "$t" -size 8 -anchor c,h
    PsBox -coord [expr $x-$w/2.0],$y:[expr $x+$w/2.0],[expr $y+$w] -fill t -fillstyle $t -linewidth 0.25 
    set x [expr $x + $w + $s]
}

foreach t {square triangle utriangle star} {
    puts "PLOTTING $t"
    PsText -coord $x,[expr $y-4] -text "$t" -size 8 -anchor c,h
    PsBox -coord [expr $x-$w/2.0],$y:[expr $x+$w/2.0],[expr $y+$w] -fill t -fillstyle $t -linewidth 0.25 -fillparams 4,2
    set x [expr $x + $w + $s]
}

# all done
PsRender -file "pattern-example.eps"




