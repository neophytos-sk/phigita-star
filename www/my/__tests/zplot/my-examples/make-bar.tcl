ad_conn_set user_id 814

ad_page_contract {
    @author Neophytos Demetriou
} {
    {chs:trim,notnull "300x250"}
    {chd:trim,notnull ""}
    {cht:trim,notnull ""}
}


lassign [split $chs x] width height


set inputDirectory [acs_root_dir]/www/my/__tests/zplot/my-examples
set outputDirectory /web/data/Zplot
set inputFile ${outputDirectory}/data-[ns_sha1 $chd].${cht}
set epsFile ${outputDirectory}/bar-${width}x${height}.eps
set jpgFile ${outputDirectory}/bar.jpg

set fp [open $inputFile w]
foreach line [split $chd {|}] {
    puts $fp [string map {, :} $line]
}
close $fp


# define the canvas
::Zplot::PsCanvas -title "bar.eps" -width ${width} -height ${height}

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
::Zplot::Table -table bar -file $inputFile -separator ":"

# this defines one particular drawing area
set xmin [::Zplot::TableGetMin -column c0 -table bar]
set xmax [::Zplot::TableGetMax -column c0 -table bar]
set ymax [::Zplot::TableGetMax -column c1 -table bar]
::Zplot::Drawable -xrange "[expr { ${xmin}-1 }],[expr $xmax+1]" -yrange "-6,[expr $ymax+2]" -coord 30,

# plot some data, for goodness sake
::Zplot::PlotVerticalBars -table bar -xfield c0 -yfield c1 -barwidth 0.9 -labelfield c1 -yloval 0 \
    -fill t -fillcolor darkred -fillstyle solid -fillsize 4 -fillskip 4 -legend "Widgets" 

# axis
::Zplot::AxesTicsLabels -xaxisposition 0 -xauto ${xmin},${xmax},1 -xlabelbgcolor white \
    -title "Bar Plot ${width}x${height}" \
    -titleplace c -xtitleplace c -ytitleplace c 
::Zplot::Label -coord 3,-6.5 -anchor c,h -text "Measured Thing"

# draw a legend
::Zplot::Legend -coord 190,170 -height 10 -width 10 -fontsize 10.0 


# and finally, render it all
::Zplot::PsRender -file ${epsFile}

exec -- /bin/sh -c "/usr/bin/convert eps:${epsFile} jpg:${jpgFile} || exit 0" 2> /dev/null

ns_returnfile 200 image/jpeg ${jpgFile}