namespace eval ::xo::lib {;}
proc ::xo::lib::require {module_name} {
    source /web/servers/service-phigita/lib/${module_name}/pkgIndex.tcl
    package require $module_name
}


namespace eval ::xo::kit {;}
proc ::xo::kit::performance_mode_p {} { 
    return 0 
}
proc ::xo::kit::debug_mode_p {} {
    return [expr {![::xo::kit::performance_mode_p]}]
}


proc acs_root_dir {} {
    return /web/servers/service-phigita/
}

proc ns_log {level args} {
    puts "${level}: {*}$args"
}

# netinet
source [file join [acs_root_dir] packages/kernel/tcl/20-xo/ip/ip-procs.tcl]
