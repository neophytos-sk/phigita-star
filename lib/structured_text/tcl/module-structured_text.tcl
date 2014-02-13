package provide structured_text 0.1

set dir [file dirname [info script]]
source [file join $dir structured_text.tcl]

#ns_log notice "module-structured_text.tcl: dir=$dir"

::xo::lib::require critcl

array set conf [list]

set conf(debug_mode_p) [::xo::kit::debug_mode_p]

if { [info commands ns_info] ne {} && [ns_info name] eq {NaviServer} } {
    set conf(clibraries) "-L/opt/naviserver/lib"
} else {
    set conf(clibraries) "-L/opt/naviserver/lib -ltcl"
}


set conf(includedirs) [list \
    "/opt/naviserver/include" \
    [file join $dir ../c/] \
    [file join $dir ../../struct/include]]


set conf(csources) [file join $dir ../c/structured_text.c]
set conf(cheaders) [file join $dir ../c/structured_text.h]

set conf(cinit) {
    // init_text
    Tcl_CreateObjCommand(ip, "::xo::structured_text::__stx_to_html", stx_TextToHtmlCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::xo::structured_text::__mtx_to_html", stx_MiniToHtmlCmd, NULL, NULL);
}

set conf(ccode) {
    #include "structured_text.h"

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }



    static int 
    stx_TextToHtmlCmd (ClientData  cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(3,3,1,"textVar htmlVar");

        const char *textVar = Tcl_GetString(objv[1]);
        const char *text = Tcl_GetVar(interp, textVar, TCL_LEAVE_ERR_MSG);
        if (!text) {
            return TCL_ERROR;
        }

        int outflags = 0;
        Tcl_DString ds;
        Tcl_DStringInit(&ds);
        StxToHtml(&ds, &outflags, text);
        Tcl_Obj *newValuePtr = Tcl_NewStringObj(Tcl_DStringValue(&ds),Tcl_DStringLength(&ds));
        Tcl_DStringFree(&ds);

        Tcl_ObjSetVar2(interp, objv[2], NULL, newValuePtr, TCL_LEAVE_ERR_MSG);
        Tcl_SetObjResult(interp,Tcl_NewIntObj(outflags));

        return TCL_OK;
    }


    static int 
    stx_MiniToHtmlCmd (ClientData  cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(3,3,1,"textVar htmlVar");

        const char *textVar = Tcl_GetString(objv[1]);

        const char *text = Tcl_GetVar(interp, textVar, TCL_LEAVE_ERR_MSG);

        int outflags = 0;
        Tcl_DString ds;
        Tcl_DStringInit(&ds);
        MinitextToHtml(&ds, &outflags, text);
        Tcl_Obj *newValuePtr = Tcl_NewStringObj(Tcl_DStringValue(&ds),Tcl_DStringLength(&ds));
        Tcl_DStringFree(&ds);

        Tcl_ObjSetVar2(interp, objv[2], NULL, newValuePtr, TCL_LEAVE_ERR_MSG);
        Tcl_SetObjResult(interp,Tcl_NewIntObj(outflags));
        return TCL_OK;
    }

}

::critcl::ext::cbuild_module [info script] conf

