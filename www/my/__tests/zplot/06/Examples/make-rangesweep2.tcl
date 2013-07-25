#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "rangesweep2.eps" -width 300 -height 240

# read in the data
Table -table all -file "data.rangesweep2"
Table -table a -columns c0,c1,c2,c3,c4,c5
Table -table b -columns c0,c1,c2,c3,c4,c5
TableSelect -from all -to a -where {[StringEqual $c1 a]} -fcolumns c0,c1,c2,c3,c4,c5 -tcolumns c0,c1,c2,c3,c4,c5
TableSelect -from all -to b -where {[StringEqual $c1 b]} -fcolumns c0,c1,c2,c3,c4,c5 -tcolumns c0,c1,c2,c3,c4,c5

# make a drawable 
Drawable -xrange "0,120" -yrange "0,100" -xoff 40 -width 250

# now plot the data
PlotVerticalFill -table a -xfield c0 -yfield c5 -ylofield c4 -fillcolor blue -legend "Treatment A"
PlotVerticalFill -table b -xfield c0 -yfield c5 -ylofield c4 -fillcolor red  -legend "Treatment B"
PlotLines -table a -xfield c0 -yfield c2 -linewidth 0.5
PlotLines -table b -xfield c0 -yfield c2 -linewidth 0.5 -linedash 4,2
PlotPoints -table a -xfield c0 -yfield c2 -style circle -fill t -fillcolor black -linewidth 0.25
PlotPoints -table b -xfield c0 -yfield c2 -style circle -linewidth 0.25

# axes
AxesTicsLabels -yauto ,,10 -xauto ,,12 -xtitle "Follow-up Time (months)" -ytitle "Average Night Driving Score" 
Legend -coord 6,15 

# labels
Label -coord 60,104 -text "Average Night Driving Score" -fontsize 6
Label -coord 60,99  -text "With Missing Values Imputed Using Approximate Bayesian Bootstrap" -fontsize 6
Label -coord 60,94  -text "and 10% Lower on Average than Observed Values" -fontsize 6

# all done
PsRender -file rangesweep2.eps



