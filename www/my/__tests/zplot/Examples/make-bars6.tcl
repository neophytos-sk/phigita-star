#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot-import.tcl

Table -table bars -file "data.bars6"

PsCanvas -title "bars6.eps" -width 300 -height 140

Drawable -xrange -0.5,2.5 -yrange -5000,15000

# because tics and axes are different, call AxesTicsLabels twice, once to specify x-axis, other to specify y-axis
AxesTicsLabels -style y -yauto ,,5000 
AxesTicsLabels -style x -axis f -majortics f -xmanual "0,ABC Corp : 1,NetStuff : 2,MicroMason" -xaxisposition -5000
Grid -x false -ystep 5000 -linecolor salmon

PlotVerticalBars -table bars -xfield rownumber -yfield c0 -fill t -fillcolor salmon -barwidth 0.7 -yloval 0 -linewidth 0.5 \
    -labelfield c0 -labelformat "\$%s"

Label -text "Annual Revenues (thousands)" -coord -0.4,15500 -anchor l -font Courier-Bold -fontsize 9

PsRender -file "bars6.eps"