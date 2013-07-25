source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require tchart


# "png", "X", "Xdrawable", "pnm", "gif", "ai", "ps", "fig", "pcl", "hpgl", "tek", or "meta"
set display_type [lindex $argv 0]
set chart_type [lindex $argv 1]
set title [lindex $argv 2]
set xtext [lindex $argv 3]
set ytext [lindex $argv 4]

set startTime [clock clicks -milliseconds]
::tchart::plot $display_type $chart_type $title $xtext $ytext
set endTime [clock clicks -milliseconds]

puts stderr "Time Taken: [expr { $endTime - $startTime }]ms"