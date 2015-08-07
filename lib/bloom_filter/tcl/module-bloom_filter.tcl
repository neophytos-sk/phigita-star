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

    // Tcl_RegisterObjType(&bloom_filter_type);

    Tcl_CreateObjCommand(ip, "::bloom_filter::create", bf_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::bloom_filter::destroy", bf_DestroyCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::bloom_filter::insert", bf_InsertCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::bloom_filter::may_contain", bf_MayContainCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::bloom_filter::get_bytes", bf_GetBytesCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::bloom_filter::set_bytes", bf_SetBytesCmd, NULL, NULL);
}

set ccode_filename [file normalize [file join $module_dir c/tclmodule.c]]
# log ccode_filename=$ccode_filename
set conf(ccode) [::util::readfile $ccode_filename]

::critcl::ext::cbuild_module $module_filename conf
