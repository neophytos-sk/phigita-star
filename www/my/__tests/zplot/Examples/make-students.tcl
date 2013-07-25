#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

source zplot.tcl; namespace import Zplot::*

# first, just get the data
Table -table students -file data.students

# find the number of columns, compute from this the number of exams
set columns  [TableGetColNames -table students]
set ncolumns [llength $columns]
set nexams   [expr $ncolumns - 2]
set rows     [TableGetNumRows -table students]

# make the canvas's width data dependent
PsCanvas -title students.eps -width [expr 10 * ($nexams+1) * $rows] -height 140
Drawable -xrange 0.5,[expr $rows+.5] -yrange 0,100 -coord 45,45

# plot clusters, one per student
set colors "yellowgreen lightgreen forestgreen darkolivegreen"
for {set e 0} {$e < $nexams} {incr e} {
    set colName  [lindex $columns [expr $e+2]]
    set examName [string map {_ " "} $colName]
    PlotVerticalBars -table students -xfield id -yfield $colName \
	-fill t -fillcolor [lindex $colors $e] -linewidth 0.2 -barwidth 0.8 \
	-cluster $e,$nexams -legend "$examName" 
}

# labels and decor
AxesTicsLabels -yauto 0,100,25 -xauto 1,5,1 -xlabelformat "%s" -ylabelformat "%s%%" \
    -xtitle "Student ID" -ytitle "Exam Score" -title "Student Exam Scores" 
Legend -coord 0.5,-43 -width 7 -height 7 -fontsize 8 -skipnext 1 -skipspace 50
PsRender -file "students.eps"
