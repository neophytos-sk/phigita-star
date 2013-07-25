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
::critcl::config language c++
::critcl::clibraries -lstdc++
::critcl::clibraries -L/opt/naviserver/lib

::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../cc]

::critcl::csources [file join $dir ../cc/structured_text.cc]
::critcl::cheaders [file join $dir ../cc/structured_text.h]

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
    stx_TextToHtmlCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(3,3,1,"textVar htmlVar");

	const char *textVar = Tcl_GetString(objv[1]);
	const char *text = Tcl_GetVar(interp, textVar, TCL_LEAVE_ERR_MSG);
	if (!text) {
	    return TCL_ERROR;
	}

	structured_text doc(text);

	std::string html;
	int outflags = 0;
	doc.to_html(html,&outflags);

	Tcl_Obj *newValuePtr = Tcl_NewStringObj(html.c_str(),-1);

	//const char *data = html.c_str();
	//int length = html.size();
	//Tcl_Obj *newValuePtr = Tcl_NewByteArrayObj((unsigned char *)data,length);
	//Tcl_ConvertToType(interp,newValuePtr,Tcl_GetObjType("string"));

	Tcl_ObjSetVar2(interp, objv[2], NULL, newValuePtr, TCL_LEAVE_ERR_MSG);
	Tcl_SetObjResult(interp,Tcl_NewIntObj(outflags));
	return TCL_OK;
    }


    static int 
    stx_MiniToHtmlCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(3,3,1,"textVar htmlVar");

	const char *textVar = Tcl_GetString(objv[1]);

	int outflags = 0;
	const char *text = Tcl_GetVar(interp, textVar, TCL_LEAVE_ERR_MSG);
	structured_text doc(text);
	std::string html;
	doc.minitext_to_html(html,&outflags);

	Tcl_Obj *newValuePtr = Tcl_NewStringObj(html.c_str(),-1);

	Tcl_ObjSetVar2(interp, objv[2], NULL, newValuePtr, TCL_LEAVE_ERR_MSG);
	Tcl_SetObjResult(interp,Tcl_NewIntObj(outflags));
	return TCL_OK;
    }

}


::critcl::cbuild [file normalize [info script]]

