proc wrap_proc {procname procargs procbody} {
    set nsp [namespace qualifiers $procname]
    set name [namespace tail $procname]
    set shadow ${nsp}::__${name}
    uplevel [list rename $procname $shadow]
    uplevel [list proc $procname $procargs $procbody]
}

proc call_orig {args} {
    set caller [info frame -1]
    set type [dict get $caller type]
    if { $type ne {proc} } {
        error "call_shadow: must be called inside a wrap_proc"
    }
    set procname [dict get $caller proc]
    uplevel [list call_orig_of $procname {*}$args]
}

proc call_orig_of {procname args} {
    set nsp [namespace qualifiers $procname]
    set name [namespace tail $procname]
    set shadow ${nsp}::__${name}
    uplevel [list $shadow {*}$args]
}
