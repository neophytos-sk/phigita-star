source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require templating

set filename [lindex $argv 0] ;# "somepage.tdp"

set doc [source_tdom $filename ::templating::lang html]
puts [$doc asHTML]
$doc delete
