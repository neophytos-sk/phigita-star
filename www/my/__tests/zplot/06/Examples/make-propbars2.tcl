#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot.tcl; namespace import Zplot::*

Table -table propbars -file "data.propbars2"

# build a stacked bar from non-stacked data
TableAddColumns -table propbars -columns Britain2,USSR2,France2,Other2
TableMath -table propbars -expression {$USA      + $Britain} -destcol Britain2
TableMath -table propbars -expression {$Britain2 +    $USSR} -destcol USSR2
TableMath -table propbars -expression {$USSR2    +  $France} -destcol France2
TableMath -table propbars -expression {$France2  +   $Other} -destcol Other2

PsCanvas -width 100 -height 200 -title "propbars2.eps" 
Drawable -xrange -0.6,0.6 -yrange 0,100 -xoff 4 -yoff 4 -width 92 -height 180

PlotVerticalBars -table propbars -xfield rownumber -yfield Other2   -linewidth 0 -fill t -fillcolor mediumpurple \
    -labelfield Other   -labelplace i -labelformat "Other %s%%"
PlotVerticalBars -table propbars -xfield rownumber -yfield France2  -linewidth 0 -fill t -fillcolor pink         \
    -labelfield France  -labelplace i -labelformat "France %s%%"
PlotVerticalBars -table propbars -xfield rownumber -yfield USSR2    -linewidth 0 -fill t -fillcolor salmon       \
    -labelfield USSR    -labelplace i -labelformat "USSR %s%%"
PlotVerticalBars -table propbars -xfield rownumber -yfield Britain2 -linewidth 0 -fill t -fillcolor yellowgreen  \
    -labelfield Britain -labelplace i -labelformat "Britain %s%%"
PlotVerticalBars -table propbars -xfield rownumber -yfield USA      -linewidth 0 -fill t -fillcolor lightblue    \
    -labelfield USA     -labelplace i -labelformat "USA %s%%"

Label -coord 0,102 -text "Arms Exporters" -font Courier-Bold 

PsRender -file "propbars2.eps"



