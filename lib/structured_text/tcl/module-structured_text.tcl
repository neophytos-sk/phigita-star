package provide structured_text 0.1

set dir [file dirname [info script]]
source [file join $dir structured_text.tcl]

#ns_log notice "module-structured_text.tcl: dir=$dir"

::xo::lib::require critcl

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
::critcl::clibraries -L/opt/naviserver/lib
::critcl::clibraries -ltcl

::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../c]

::critcl::csources [file join $dir ../c/structured_text.c]
#::critcl::cheaders [file join $dir ../c/structured_text.h]

::critcl::cinit {
    // init_text
    Tcl_CreateObjCommand(ip, "::xo::structured_text::__stx_to_html", stx_TextToHtmlCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::xo::structured_text::__mtx_to_html", stx_MiniToHtmlCmd, NULL, NULL);
} {
    // init_exts
}


critcl::ccode {
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


::critcl::cbuild [file normalize [info script]]

