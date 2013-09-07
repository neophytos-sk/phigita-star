package provide critcl 2.1

set dir [file dirname [info script]]
set package_dir [file dirname ${dir}]

namespace eval ::critcl {;}

proc ::critcl::get_package_dir {} "return [list ${package_dir}]"

source [file join ${dir} platform.tcl]
source [file join ${dir} critcl.tcl]
