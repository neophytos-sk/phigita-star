package provide persistence 0.1

set dir [file dirname [info script]]
set package_dir [file normalize [file join ${dir} ..]]

namespace eval ::persistence {;}

proc ::persistence::get_package_dir {} "return ${package_dir}"

proc ::persistence::get_conf_dir {} "return ${package_dir}/conf"

source [file join $dir data_procs.tcl]
source [file join $dir orm_procs.tcl]

