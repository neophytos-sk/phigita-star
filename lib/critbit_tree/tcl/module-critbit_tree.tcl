# TODO:
# * Consider sv_new, sv_create, sv_extend, sv_insert, sv_contains, and so on
# * Difference between sv_new and sv_create is that the sv_create associates a name with the handle

package provide critbit_tree 0.1

package require critcl

set module_filename [file normalize [info script]]
set current_dir [file normalize [file dirname [info script]]]
set module_dir [file normalize [file join $current_dir ..]]

array set conf [list]
array set conf {
    includedirs {../c/ ../../core/c}
    clibraries {}
    csources {../c/critbit.c}
    cheaders {}
    cflags ""
    cinit ""
    ccode ""
}
set conf(debug_mode_p) [::xo::kit::debug_mode_p]
if { [::xo::kit::debug_mode_p] } {
    set conf(cflags) -DDEBUG
}

set conf(cinit) {
    // init_text
    cbt_InitModule();
    Tcl_CreateObjCommand(ip, "::cbt::create", cbt_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::extend", cbt_ExtendCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::insert", cbt_InsertCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::delete", cbt_DeleteCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::get", cbt_GetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::exists", cbt_PrefixExistsCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::prefix_match", cbt_PrefixMatchCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::segment_match", cbt_SegmentMatchCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::id", cbt_GetIdCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::size", cbt_SizeCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::dump", cbt_DumpCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::restore", cbt_RestoreCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::destroy", cbt_DestroyCmd, NULL, NULL);
    //Tcl_CreateObjCommand(ip, "::cbt::info", cbt_InfoCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::contains", cbt_ContainsCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::to_string", cbt_ToStringCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::get_bytes", cbt_GetBytesCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::set_bytes", cbt_SetBytesCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::write_to_file", cbt_WriteToFileCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::read_from_file", cbt_ReadFromFileCmd, NULL, NULL);
    Tcl_RegisterObjType(&cbt_ObjType); 
}


set ccode_filename [file normalize [file join $module_dir c/tclmodule.c]]
# log ccode_filename=$ccode_filename
set conf(ccode) [::util::readfile $ccode_filename]

::critcl::ext::cbuild_module $module_filename conf


namespace eval ::cbt {

    variable STRING_KEYS 0
    variable UINT32_KEYS 4
    variable UINT64_KEYS 8

    variable STRING_VALS [expr { 256 + 0 }]
    variable UINT32_VALS [expr { 256 + 4 }]
    variable UINT64_VALS [expr { 256 + 8 }]

    variable STRING 0
    variable UINT32_STRING [expr { $UINT32_KEYS + $STRING_VALS }]
    variable UINT64_STRING [expr { $UINT64_KEYS + $STRING_VALS }]
    variable STRING_UINT32 [expr { $STRING_KEYS + $UINT32_VALS }]
    variable STRING_UINT64 [expr { $STRING_KEYS + $UINT64_VALS }]
    variable STRING_STRING [expr { $STRING_KEYS + $STRING_VALS }]

    namespace ensemble create -subcommands {
        create destroy
        extend insert delete get exists prefix_match
        segment_match id size dump restore
        info extend
        contains to_string bytes
        write_to_file
        read_from_file
    }
}


