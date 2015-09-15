proc ::tcl::namespace::__copy {imported_nsp {pattern "*"}} {
    set nsp [uplevel {namespace current}]

    # copy imports
    set procnames [namespace eval ${imported_nsp} { namespace import }]
    foreach procname $procnames {
        set origin [namespace eval ${imported_nsp} "namespace origin $procname"]
        namespace eval ${nsp} "namespace import -force $origin"
    }

    # copy vars
    set varnames [info vars ${imported_nsp}::*]
    foreach varname $varnames {
        set name [namespace tail $varname]
        if { [array exists $varname] } {
            array set ${nsp}::${name} [array get $varname]
        } else {
            set ${nsp}::${name} [set $varname]
        }
    }

    # copy procs
    set procnames [info procs ${imported_nsp}::${pattern}]
    foreach procname $procnames {
        set procargnames [info args $procname]

        set procargs [list]
        foreach procarg $procargnames {
            set dval_p [info default $procname $procarg dval]
            if { $dval_p } {
                lappend procargs [list $procarg $dval]
            } else {
                lappend procargs $procarg
            }
        }

        set procbody [info body $procname]
        proc ${nsp}::[namespace tail $procname] $procargs $procbody
    }
}

proc ::tcl::namespace::__mixin {imported_nsp} {
    
    set nsp [uplevel {namespace current}]
    set exported_procs [namespace eval $imported_nsp { namespace export }]
    foreach exported_proc $exported_procs {
        if { [info proc ${nsp}::$exported_proc] ne {} } {
            rename ${nsp}::$exported_proc ${nsp}::__$exported_proc
        }

        # log "alias ${nsp}::$exported_proc"

        interp alias \
            {} ${nsp}::$exported_proc \
            {} ::runtime::stack_with __nsp ${nsp} ${imported_nsp}::${exported_proc}
    }

    namespace inscope ${nsp} [list \
        namespace ensemble create -subcommands $exported_procs]

}

proc ::tcl::namespace::__this {} {
    return [::runtime::stack_top __nsp]
}

# work in progress
proc ::tcl::namespace::__next {args} {
    set caller [info frame -1]

    set type [dict get $caller type]
    if { $type ne {proc} } {
        error "namespace __next must be called inside a proc"
    }
    set proc [dict get $caller proc]
    set nsp [namespace qualifier $proc]
    set procname [namespace tail $proc]
    set shadow_proc ${nsp}::__${procname}
    return [uplevel [list $shadow_proc {*}$args]]

}

set ensemble "namespace"
set __config_map [namespace ensemble configure ${ensemble} -map]
lappend __config_map "__copy" "::tcl::${ensemble}::__copy"
lappend __config_map "__mixin" "::tcl::${ensemble}::__mixin"
lappend __config_map "__this" "::tcl::${ensemble}::__this"
lappend __config_map "__next" "::tcl::${ensemble}::__next"
namespace ensemble configure ${ensemble} -map $__config_map
unset __config_map

