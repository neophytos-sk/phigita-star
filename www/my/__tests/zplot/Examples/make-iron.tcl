#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# read in data
Table -table iron -file "data.iron"

# move all values over a bit, to place point markers right in the middle of each square
TableMath -table iron -expression {$x + 0.5} -destcol x
TableMath -table iron -expression {$y + 0.5} -destcol y

# select different values to plot different points
foreach t {zero stop retry propagate redundancy} {
    Table -table $t -columns x,y,action
    # note how '-where' clause is formed: backslash before left-bracket prevents StringEqual
    # from being called right now, and backslash before $action prevents it from being evaluated
    # right now. In contrast, $t is evaluated right now as desired, to zero, stop, ..., etc.
    # simple quotations around the entire thing make sure it is passed as a single arg to -where
    TableSelect -from iron -to $t -where " \[ StringEqual \$action $t ] " 
}

set cols   20
set rows   12
set size   10.0
set hsize  5.0
set width  [expr $cols * $size]
set height [expr $rows * $size]

# canvas, drawable
PsCanvas -title "iron.eps" -width [expr $width+50.0] -height [expr $height+40.0+15.0]
Drawable -xrange "0,$cols" -yrange "0,$rows" -coord 50,40 -dimensions $width,$height \
    -fill t -fillcolor lightgray

# make all points white
PlotPoints -table iron -style square -size $hsize -fill t -fillcolor white -linewidth 0.0

# stop, retry, propagate, zero, redundancy
PlotPoints -table stop       -style vline  -size $hsize -linewidth 0.5
PlotPoints -table retry      -style dline1 -size $hsize -linewidth 0.5 -linecolor green
PlotPoints -table propagate  -style hline  -size $hsize -linewidth 0.5
PlotPoints -table zero       -style circle -size $hsize -linewidth 0.5 -linecolor red
PlotPoints -table redundancy -style dline2 -size $hsize -linewidth 0.5 

# overlay a grid
Grid -xstep 1 -ystep 1 -linecolor black -linewidth 0.25

# some axis labels
AxesTicsLabels -style x -xmanual "0,path : 1,open* : 2,chmod* : 3,read : 4,readlink : 5,getdir : 6,creat : 7,link : 8,mkdir : 9,rename : 10,symlink : 11,write : 12,trunc : 13,rmdir : 14,unlink : 15,mount : 16,fsync* : 17,umount : 18,logwrite : 19,recovery " -fontsize 8 -majortics f -axis f -xlabelrotate 90 -xlabelanchor r,c -xlabelshift 5,0
AxesTicsLabels -style y -ymanual "0,imap-cntl : 1,bmap-desc : 2,aggr-inode : 3,j-data : 4,j-super : 5,super : 6,data : 7,internal : 8,imap : 9,bmap : 10,dir : 11,inode " -fontsize 8 -majortics f -axis f -ylabelshift 0,5 -ylabelanchor r,c

# finally, a title
Label -drawable default -text "JFS Fault Behavior: Write Faults" -fontsize 8 -coord "10,12.4" -font "Helvetica-Bold"

# all done
PsRender -file iron.eps

