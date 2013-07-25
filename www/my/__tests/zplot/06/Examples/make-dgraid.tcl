#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot-import.tcl

PsCanvas -title "dgraid.eps" -width 400 -height 290
Table -table copy   -file "data.dgraid-copy"
Table -table nocopy -file "data.dgraid-nocopy"

# do major copy graph
Drawable -drawable copy -xoff 35 -yoff 30 -height 110 -width 350 -xrange 0,4500 -yrange 0,8000
PlotPoints -drawable copy -table copy -xfield c0 -yfield c1 -style xline -linewidth 0.25
PlotLines -drawable copy -table copy -xfield c0 -yfield c1 -linewidth 0.25
AxesTicsLabels -drawable copy -xtitle "Time (s)" -xauto ,,500 -yauto ,,2000 -ylabeltimes 0.001 -ylabelformat "%d"

# do closeups of copy graph
Drawable -drawable copyc1 -xoff 135 -yoff 90 -height 40 -width 40 -xrange 700,720 -yrange 0,6000
Table -table copyc1 -columns c0,c1
TableSelect -from copy -to copyc1 -where {($c0>=700) && ($c0<=720)}
AxesTicsLabels -drawable copyc1 -ticmajorsize 2 -xauto ,,10 -yauto ,,2000 -ylabeltimes 0.001 -ylabelformat "%d" -linecolor gray -fontsize 6
PlotLines -drawable copyc1 -table copyc1 -xfield c0 -yfield c1 -linewidth 0.25

Drawable -drawable copyc2 -xoff 325 -yoff 70 -height 40 -width 60 -xrange 3280,3310 -yrange 0,6000
Table -table copyc2 -columns c0,c1
TableSelect -from copy -to copyc2 -where {($c0>=3280) && ($c0<=3310)}
AxesTicsLabels -drawable copyc2 -ticmajorsize 2 -xauto ,,10 -yauto ,,2000 -ylabeltimes 0.001 -ylabelformat "%d" -linecolor gray -fontsize 6
PlotLines -drawable copyc2 -table copyc2 -xfield c0 -yfield c1 -linewidth 0.25

# finally, do nocopy graph
Drawable -drawable nocopy -xoff 35 -yoff 160 -height 110 -width 350 -xrange 0,4500 -yrange 0,8000
PlotPoints -drawable nocopy -table nocopy -xfield c0 -yfield c1 -style plusline -linewidth 0.25 
PlotLines -drawable nocopy -table nocopy -xfield c0 -yfield c1 -linewidth 0.25 
AxesTicsLabels -drawable nocopy -xauto ,,500 -yauto ,,2000 -ylabeltimes 0.001 -ylabelformat "%d" 

# a few labels
Label -drawable nocopy -coord 2250,8300 -text "DGRAID: Measuring Imperfect Placement"
Label -drawable canvas -coord 13,150 -text "Number of Misplaced Blocks (Thousands)" -rotate 90 

# boxes around the closeup regions (though not really needed)
Box -drawable copy -coord "650,-400 : 770,6000 " -linedash 2,2 -linewidth 0.25 -linecolor gray
Box -drawable copy -coord "3200,-400 : 3400,1000 " -linedash 2,2 -linewidth 0.25 -linecolor gray
Line -drawable copy -coord 780,3000:1100,4000 -linedash 2,2 -linewidth 0.25 -linecolor gray
Line -drawable copy -coord 3400,1000:3600,2000 -linedash 2,2 -linewidth 0.25 -linecolor gray

PsRender -file "dgraid.eps"




