
package require critcl

set module_filename [file normalize [info script]]
set current_dir [file normalize [file dirname [info script]]]
set module_dir [file normalize [file join $current_dir ..]]

array set conf [list]
array set conf {
    includedirs {../c/ ../../core/c}
    clibraries {}
    csources {../c/murmur_hash2.c}
    cheaders {}
    cflags ""
    cinit ""
    ccode ""
}

set conf(cinit) {
    Tcl_CreateObjCommand(ip, "::murmur_hash::murmur_hash", murmur_hashCmd, NULL, NULL);
}

set ccode_filename [file normalize [file join $module_dir c/tclmodule.c]]
# log ccode_filename=$ccode_filename
set conf(ccode) [::util::readfile $ccode_filename]

::critcl::ext::cbuild_module $module_filename conf

