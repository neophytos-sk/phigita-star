proc log {args} {
    puts stderr [::join $args]
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
