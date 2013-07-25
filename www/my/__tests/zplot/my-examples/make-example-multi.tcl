set inputDirectory [acs_root_dir]/www/my/__tests/zplot/my-examples
set outputDirectory /web/data/Zplot
set inputFile1 ${inputDirectory}/file.data
set inputFile2 ${inputDirectory}/file2.data
set inputFile3 ${inputDirectory}/file.heat
set epsFile ${outputDirectory}/bar.eps
set jpgFile ${outputDirectory}/bar.jpg

# describe the drawing surface
::Zplot::PsCanvas -title "example-multi.eps" -width 300 -height 205

::Zplot::Table -table t -file $inputFile1
::Zplot::TableAddColumns -table t -columns ylower,yhigher
::Zplot::TableMath -table t -expression {$ylo-1} -destcol ylower
::Zplot::TableMath -table t -expression {$yhi+1} -destcol yhigher

# lines
::Zplot::Drawable -drawable d1 -xrange 0,11 -yrange 0,10 -coord 10,10 -dimensions 60,40
::Zplot::AxesTicsLabels -title Lines -drawable d1 -majortics f -labels f
::Zplot::PlotLines -table t -drawable d1 -xfield x -yfield y -linewidth 0.5

# points
::Zplot::Drawable -drawable d23 -xrange 0,11 -yrange 0,10 -coord 80,10 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Points" -drawable d23 -majortics f -labels f
::Zplot::PlotPoints -table t -drawable d23 -xfield x -yfield y -style xline -linewidth 0.5

# linespoints
::Zplot::Drawable -drawable d2 -xrange 0,11 -yrange 0,10 -coord 150,10 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Lines & Points" -drawable d2 -majortics f -labels f
::Zplot::PlotLines -table t -drawable d2 -xfield x -yfield y -linewidth 0.5
::Zplot::PlotPoints -table t -drawable d2 -xfield x -yfield y -style xline -linewidth 0.5

# filled 
::Zplot::Drawable -drawable d3 -xrange 0,11 -yrange 0,10 -coord 220,10 -dimensions 60,40
::Zplot::PlotVerticalFill -table t -drawable d3 -xfield x -yfield y 
::Zplot::PlotLines -table t -drawable d3 -xfield x -yfield y -linewidth 0.5
::Zplot::AxesTicsLabels -title "Filled" -drawable d3 -majortics f -labels f

# error bars
::Zplot::Drawable -drawable da -xrange 0,11 -yrange 0,10 -coord 10,80 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Error Bars" -drawable da -majortics f -labels f
::Zplot::PlotVerticalIntervals -table t -drawable da -xfield x -ylofield ylo -yhifield yhi 
::Zplot::PlotPoints -table t -drawable da -xfield x -yfield y -style circle -linewidth 0.5 -size 0.5

# box plots
::Zplot::Drawable -drawable db -xrange 0,11 -yrange 0,10 -coord 80,80 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Box Plots" -drawable db -majortics f -labels f
::Zplot::PlotVerticalIntervals -table t -drawable db -xfield x -ylofield ylower -yhifield yhigher -linewidth 0.5
::Zplot::PlotVerticalBars -table t -drawable db -xfield x -ylofield ylo -yfield yhi -fill t -fillcolor gray -linewidth 0.5 -barwidth 0.8
::Zplot::PlotPoints -table t -drawable db -xfield x -yfield y -style circle -linewidth 0.5 -size 0.5 

# hintervals
::Zplot::Drawable -drawable dc -xrange 0,10 -yrange 0,11 -coord 150,80 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Intervals" -drawable dc -majortics f -labels f
::Zplot::PlotHorizontalIntervals -table t -drawable dc -yfield x -xlofield ylo -xhifield yhi -linewidth 0.5

# functions
::Zplot::Drawable -drawable dd -xrange 0,10 -yrange 0,11 -coord 220,80 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Functions" -drawable dd -majortics f -labels f
::Zplot::PlotFunction -drawable dd -func {$x} -range 0,10 -step 0.1 -linewidth 0.5
::Zplot::PlotFunction -drawable dd -func {2*$x} -range 0,5 -step 0.1 -linewidth 0.5
::Zplot::PlotFunction -drawable dd -func {$x*$x} -range 0,3.3 -step 0.1 -linewidth 0.5
::Zplot::Label -drawable dd -coord 1.5,9 -text "y=x*x" -fontsize 6
::Zplot::Label -drawable dd -coord 5.5,8 -text "y=x" -fontsize 6
::Zplot::Label -drawable dd -coord 7.5,5 -text "y=2x" -fontsize 6

# bars
::Zplot::Drawable -drawable d5 -xrange 0,11 -yrange 0,10 -coord 10,150 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Vertical Bars" -drawable d5 -majortics f -labels f
::Zplot::PlotVerticalBars -table t -drawable d5 -xfield x -yfield y -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t

# stacked bars
::Zplot::Drawable -drawable d55 -xrange 0,11 -yrange 0,10 -coord 80,150 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Stacked Bars" -drawable d55 -majortics f -labels f
::Zplot::PlotVerticalBars -table t -drawable d55 -xfield x -yfield y -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t
::Zplot::Table -table t2 -file $inputFile2
::Zplot::PlotVerticalBars -table t2 -drawable d55 -xfield x -yfield y -barwidth 0.8 -fillcolor black -linewidth 0 -fill t

# bars
::Zplot::Drawable -drawable d6 -xrange 0,10 -yrange 0,11 -coord 150,150 -dimensions 60,40
::Zplot::AxesTicsLabels -title "Horizontal Bars" -drawable d6 -majortics f -labels f
::Zplot::PlotHorizontalBars -table t -drawable d6 -xfield y -yfield x -barwidth 0.8 -fillcolor gray -linewidth 0 -fill t

# heat
::Zplot::Table -table h -file $inputFile3
::Zplot::Drawable -drawable d7 -xrange 0,6 -yrange 0,6 -coord 220,150 -dimensions 60,40
::Zplot::PlotHeat -table h -drawable d7 -xfield c0 -yfield c1 -hfield c2 -divisor 4.0
::Zplot::AxesTicsLabels -title "Heat" -drawable d7 -majortics f -labels f

# finally, output the graph to a file
::Zplot::PsRender -file $epsFile


exec -- /bin/sh -c "/usr/bin/convert eps:${epsFile} jpg:${jpgFile} || exit 0" 2> /dev/null

ns_returnfile 200 image/jpeg ${jpgFile}
