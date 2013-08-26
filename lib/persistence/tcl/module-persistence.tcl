package provide persistence 0.1

set dir [file dirname [info script]]
set package_dir [file normalize [file join ${dir} ..]]

namespace eval ::persistence {;}

proc ::feed_reader::get_package_dir {} "return ${package_dir}"

proc ::feed_reader::get_conf_dir {} "return ${package_dir}/conf"

source [file join $dir data_procs.tcl]

