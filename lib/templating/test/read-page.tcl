source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require templating

if { [llength $argv] } {
    set filename [lindex $argv 0]
} else {
    set filename "somepage.tdp"
}

set doc [source_tdom $filename ::templating::lang html]
puts [$doc asHTML]
$doc delete
