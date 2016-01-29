proc log {args} {
    set level [info level]
    set level_info [info level [expr { $level - 1 }]]

    set caller_info [lindex $level_info 0]
    if { [namespace exists ::tcl::${caller_info}] } {
        lappend caller_info [lindex ${level_info} 1]
    }
    puts stderr "(${caller_info}) [::join ${args}]"
}


proc printvars {args} {
    set vars [list]
    foreach varname [uplevel {info vars}] {
        upvar $varname localCopy
        if { [array exists localCopy] } {
            lappend vars "$varname = [array get localCopy]"
        } else {
            lappend vars "$varname = $localCopy"
        }
    }
    log [join $vars "\n"]
    return $vars
}
