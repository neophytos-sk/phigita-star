package provide utilities 0.1

set dir [file dirname [info script]]

::xo::lib::require critcl

::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
::critcl::clibraries -L/opt/naviserver/lib

::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../c]

#::critcl::csources [file join $dir ../c/structured_text.cc]
#::critcl::cheaders [file join $dir ../c/structured_text.h]

::critcl::cinit {
    // init_text
} {
    // init_exts
}


critcl::ccode {

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }



}

## C
namespace eval ::util {
    #critcl::cproc map2keyl_new { char* text } char* {}
}


## TCL
namespace eval ::util {;}
proc ::util::uint32_to_bin {val} {
    return [binary format I* $val]
}

# expr {$val & 0xFFFFFFFF} to produce an unsinged value (see "man n binary")
proc ::util::bin_to_uint32 {binary_value} {
    binary scan $binary_value I* val
    set val [expr {$val & 0xFFFFFFFF}]
    return $val
}



::critcl::cbuild [file normalize [info script]]