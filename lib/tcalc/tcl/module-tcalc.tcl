package provide tcalc 0.1

set dir [file dirname [info script]]

#package require critcl
::xo::lib::require critcl

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
::critcl::clibraries -L/opt/naviserver/lib -lm

::critcl::config I /usr/include
::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../c]

foreach file {eval.c eval.h token.c token.h} {
    set extension [file extension $file]
    set filename  [file join $dir ../c/ $file]
    if { $extension eq {.h} } {
	::critcl::cheaders $filename
    } else {
	::critcl::csources $filename
    }
}


if { [::xo::kit::debug_mode_p] } {
    ::critcl::cflags -DDEBUG
}



::critcl::cinit {
    // init_text
    tcalc_InitModule();
    Tcl_CreateObjCommand(ip, "::tcalc::eval", tcalc_EvalCmd, NULL, NULL);
    // Tcl_CreateThreadExitHandler(tcalc_ExitHandler,NULL);

} {
    // init_exts
}

critcl::ccode {

    #include "eval.h"

    /*----------------------------------------------------------------------------
    |   Module Globals
    |
    \---------------------------------------------------------------------------*/

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }


    static int tcalc_ModuleInitialized;


    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void tcalc_InitModule() 
    {
	//Tcl_MutexLock(&tcalc__Mutex);
	if (!tcalc_ModuleInitialized) {
	    // tcalc_init();
	    tcalc_ModuleInitialized = 1;
	}
	//Tcl_MutexUnlock(&calc_Mutex);
    }


    static int 
    tcalc_EvalCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) 
    {
        //DBG(fprintf(stderr,"tcalc_EvalCmd\n"));

        CheckArgs(2,2,1,"expression");

	const char *input = Tcl_GetString(objv[1]);
        Tcl_SetObjResult(interp, Tcl_NewDoubleObj(evaluate(input)));
        return TCL_OK;

    }

    /*----------------------------------------------------------------------------
     |   Exit Handler: cbt_ExitHandler
     |
     |   Activated in application exit handler to delete shared document table
     |   Table entries are deleted by the object command deletion callbacks,
     |   so at this time, table should be empty. If not, we will leave some
     |   memory leaks. This is not fatal, though: we're exiting the app anyway.
     |   This is a private function to this file. 
     \---------------------------------------------------------------------------*/

    static void tcalc_ExitHandler(ClientData unused)
    {
	// tcalc_cleanup();
    }


}


::critcl::cbuild [file normalize [info script]]
