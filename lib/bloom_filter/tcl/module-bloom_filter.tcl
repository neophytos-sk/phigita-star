package require murmur_hash

package require critcl

set module_filename [file normalize [info script]]
set current_dir [file normalize [file dirname [info script]]]
set module_dir [file normalize [file join $current_dir ..]]

array set conf [list]
array set conf {
    includedirs {../c/ ../../core/c ../../murmur_hash/c }
    clibraries {-lm}
    csources {../c/bloom.c ../../murmur_hash/c/murmur_hash2.c}
    cheaders {}
    cflags ""
    cinit ""
    ccode ""
}

set conf(cinit) {
    Tcl_CreateObjCommand(ip, "::bloom_filter::create", bf_CreateCmd, NULL, NULL);
}

set ccode_filename [file normalize [file join $module_dir c/tclmodule.c]]
puts ccode_filename=$ccode_filename
set conf(ccode) [::util::readfile $ccode_filename]

::critcl::ext::cbuild_module $module_filename conf
