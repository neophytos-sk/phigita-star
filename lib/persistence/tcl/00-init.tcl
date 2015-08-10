package require core
package require util_procs

proc is_server_p {} {
    return [info exists ::__is_server_p]
}

