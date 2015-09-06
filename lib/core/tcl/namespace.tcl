
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
lappend __config_map "__mixin" "::tcl::${ensemble}::__mixin"
lappend __config_map "__this" "::tcl::${ensemble}::__this"
lappend __config_map "__next" "::tcl::${ensemble}::__next"
namespace ensemble configure ${ensemble} -map $__config_map
unset __config_map

