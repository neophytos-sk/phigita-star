namespace eval ::xo::lib {;}
proc ::xo::lib::require {module_name} {
    source [acs_root_dir]/lib/${module_name}/pkgIndex.tcl
    package require $module_name
}


namespace eval ::xo::kit {;}
proc ::xo::kit::performance_mode_p {} { 
    return 0 
}
proc ::xo::kit::debug_mode_p {} {
    return [expr {![::xo::kit::performance_mode_p]}]
}
proc ::xo::kit::production_mode_p {} { 
    return 0 
}


proc acs_root_dir {} "return [file normalize [file join [file dirname [info script]] ../../..]]"

#puts [acs_root_dir]

proc ns_log {level args} {
    puts stderr "${level}: {*}$args"
}

# netinet
source [file join [acs_root_dir] packages/kernel/tcl/20-xo/ip/ip-procs.tcl]
