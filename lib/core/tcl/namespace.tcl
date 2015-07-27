
proc ::tcl::namespace::__mixin {imported_nsp} {
    
    set nsp [uplevel {namespace current}]
    set exported_procs [namespace eval $imported_nsp { namespace export }]
    foreach exported_proc $exported_procs {
        interp alias \
            {} ${nsp}::$exported_proc \
            {} ::runtime::stack_with __nsp ${nsp} ${imported_nsp}::${exported_proc}
    }

}

proc ::tcl::namespace::__this {} {
    return [::runtime::stack_top __nsp]
}

array set __config [namespace ensemble configure namespace]
lappend __config(-map) "__mixin" "::tcl::namespace::__mixin"
lappend __config(-map) "__this" "::tcl::namespace::__this"
namespace ensemble configure namespace -map $__config(-map)
unset __config

