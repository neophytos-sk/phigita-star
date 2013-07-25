#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# get the data in, do something to it
Table -table rangebar -file data.rangebar1.zplot 

# make a new table for all the values
Table -table average -columns x,yavg,ylo,yhi,ymin,ymax

# compute means and other fun things 
TableComputeMeanEtc -from rangebar -to average \
    -fcolumns c0,c1 -tcolumns "mean,yavg:meanminusdev,ylo:meanplusdev,yhi:min,ymin:max,ymax"
TableStore -table average -file /tmp/data.average

# make the entire canvas usable by the default drawable
PsCanvas -title "rangebar1.eps" -width 240 -height 100 
Drawable -xrange 0.5,5.5 -yrange 0,5.0 -xoff 0 -yoff 0 -width 240 -height 100

# plot a boxplot: first vertical intervals (5%,95%), 
# then vertical bars on top (deviations), the a point (mean)
PlotVerticalIntervals -table average -xfield x -ylofield ymin -yhifield ymax -linewidth 0.25
PlotVerticalBars -table average -xfield x -yfield yhi -ylofield ylo \
    -barwidth 0.4 -linewidth 0.25 -fill t -fillcolor white
PlotPoints -table average -xfield x -yfield yavg -linewidth 0.0 \
    -style circle -fill t -fillstyle solid -fillcolor lblue -size 1.0

# now, scatter all the data on top of it
PlotPoints -table rangebar -style circle -linewidth 0.0 \
    -fill t -fillcolor orange -size 0.50 -xfield c0 -yfield c1

# AxisTicsLabels
PsRender -file Output/rangebar1.eps
