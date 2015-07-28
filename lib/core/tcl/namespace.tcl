
proc ::tcl::namespace::__mixin {imported_nsp} {
    
    set nsp [uplevel {namespace current}]
    set exported_procs [namespace eval $imported_nsp { namespace export }]
    foreach exported_proc $exported_procs {
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

set __config_map [namespace ensemble configure namespace -map]
lappend __config_map "__mixin" "::tcl::namespace::__mixin"
lappend __config_map "__this" "::tcl::namespace::__this"
namespace ensemble configure namespace -map $__config_map
unset __config_map

