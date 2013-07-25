source [acs_root_dir]/packages/kernel/tcl/Zplot/zplot-procs.tcl

set inputDirectory [acs_root_dir]/www/my/__tests/zplot/my-examples
set outputDirectory /web/data/Zplot
set inputFile ${inputDirectory}/data.table
set epsFile ${outputDirectory}/table.eps
set jpgFile ${outputDirectory}/table.jpg

ns_log notice "Zplot inputFile: $inputFile"

#set width 88;set height 44
set width 320;set height 176;set labelsize_header 16;set labelsize_data 14



::Zplot::Table -file ${inputFile} -table all -separator ":"


::Zplot::Table -table title -columns c0,c1,c2,c3
::Zplot::Table -table data  -columns c0,c1,c2,c3
::Zplot::TableSelect -from all -to title -where "\[StringEqual \$c3 bold]"
::Zplot::TableSelect -from all -to data  -where "\[StringEqual \$c3 normal]"
::Zplot::PsCanvas -width ${width} -height ${height}
::Zplot::Drawable -xrange -0.75,1.45 -yrange 0,5.5 -coord 0,0 -dimensions ${width},${height}
# PlotPoints -table "data" -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h
::Zplot::PlotPoints -table title -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h -labelfont Helvetica-Bold -labelsize $labelsize_header
::Zplot::PlotPoints -table data  -labelfield c2 -xfield c0 -yfield c1 -style label -labelanchor c,h -labelsize $labelsize_data
::Zplot::Line -coord "-0.7,4.15 : 1.4,4.15" -linewidth 0.25
::Zplot::Line -coord "0.7,0.2 : 0.7,5.2" -linewidth 0.25
::Zplot::PsRender -file ${epsFile}


exec -- /bin/sh -c "/usr/bin/convert eps:${epsFile} jpg:${jpgFile} || exit 0" 2> /dev/null

ns_returnfile 200 image/jpeg ${jpgFile}