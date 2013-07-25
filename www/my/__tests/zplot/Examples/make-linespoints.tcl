#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "linespoints.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar1
Table -table t -file "data.linespoints"

# this defines one particular drawing area
Drawable -xrange 0,5 -yrange 0,20 

set styles {
    {orange         square    t}
    {lightblue      circle    t}
    {darkblue       triangle  t}
    {olivedrab      utriangle t}
    {mediumpurple   diamond   t}
    {lightsalmon    xline     f}
    {rosybrown      plusline  f}
    {mistyrose      hline     f}
    {slateblue      vline     f}
    {lightcoral     asterisk  f}
    {red            square    f}
    {green          circle    f}
    {brown          triangle  f}
    {black          utriangle f}
    {gray           diamond   f}
    {darkcyan       dline1    f}
    {darkgoldenrod  dline2    f}
}

# axes
AxesTicsLabels -xtitle "X Title" -ytitle "Y Title" -title "Lots of Point Types (with Lines)" \
    -titleplace c -yauto 0,20,4

# now plot the data
set tables 17
for {set t 0} {$t < $tables} {incr t} {
    set line  [lindex $styles $t]
    set color [lindex $line 0]
    set style [lindex $line 1]
    set fill  [lindex $line 2]
    PlotLines -table t -xfield x -yfield y -linecolor $color -linewidth 0.5
    if {[string compare $fill t] == 0} {
	PlotPoints -table t -xfield x -yfield y -linecolor $color -style $style -linewidth 0.5 \
	    -fill t -fillcolor $color -legend ${style}:fill
    } else {
	PlotPoints -table t -xfield x -yfield y -linecolor $color -style $style -linewidth 0.5 -legend $style
    }
    TableMath -table t -expression {$y+0.75} -destcol y
}

# legend
Legend -coord 0.2,19 -width 5 -height 5 -fontsize 8 -skipnext 5 -skipspace 55

# all done
PsRender -file linespoints.eps



