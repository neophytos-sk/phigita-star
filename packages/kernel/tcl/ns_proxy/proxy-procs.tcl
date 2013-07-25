namespace eval ::xo::ns::proxy {;}

ad_after_server_initialization init_exec_proxy {
    ns_proxy configure exec_proxy -maxslaves 10 -maxruns 1000
}

proc ::xo::ns::proxy::exec {call} {
    set handle [ns_proxy get exec_proxy]
    set result ""
    if { [catch { set result [$handle "exec {*}${call}"] } errmsg] } {
	ns_log notice "::xo::ns::proxy::exec errmsg=$errmsg"
    }
    ns_proxy release $handle
    return $result
}



# Now rename exec
if { [::info command ::exec] ne {} } {
    ns_log notice "rename exec real_exec: using _rename, see initfile"
    #_rename ::exec ::real_exec
    rename ::exec ::real_exec
}

if { [::info command ::real_exec] ne {} } {
    proc exec {args} {::xo::ns::proxy::exec $args}
}
