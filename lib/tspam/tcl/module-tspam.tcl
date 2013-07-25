package provide tspam 0.1

set dir [file dirname [info script]]

#package require critcl
::xo::lib::require critcl

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
#::critcl::clibraries -L/opt/naviserver/lib -lplot -lm

::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../c]

foreach file {tspam.c dbh.c dbh.h dbtext.c dbtext.h filt.c filt.h lex.c lex.h str.c str.h vec.c vec.h} {
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

    RegisterExitHandlers(ip); // interp

    // init_text
    tspam_InitModule();
    Tcl_CreateObjCommand(ip, "::tspam::classify", tspam_ClassifyCmd, NULL, NULL);
    Tcl_CreateExitHandler(tspam_ExitHandler,NULL);

} {
    // init_exts
}

critcl::ccode {

	/*----------------------------------------------------------------------------
	|   Debug Macros
	|
	\---------------------------------------------------------------------------*/
	#ifdef DEBUG
	# define DBG(x) x
	#else
	# define DBG(x) 
	#endif


    /*----------------------------------------------------------------------------
    |   Module Globals
    |
    \---------------------------------------------------------------------------*/

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }


    static int tspam_ModuleInitialized;


    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void tspam_InitModule() 
    {
	//Tcl_MutexLock(&tspam__Mutex);
	if (!tspam_ModuleInitialized) {
	    tspam_init();
	    tspam_ModuleInitialized = 1;
	}
	//Tcl_MutexUnlock(&tspam_Mutex);
    }

	/*
	*  Exit Handler
	*/
	static void
	ExitHandler(ClientData clientData) {
	    DBG(fprintf(stderr,"--->>> tspam: ExitHandler\n"));

	    Tcl_Interp *interp = (Tcl_Interp *)clientData;

	    tspam_cleanup();

	    Tcl_Release(interp);
	}

	#if defined(TCL_THREADS)
	/*
	* Gets activated at thread-exit
	*/
	static void
	tspam_ThreadExitProc(ClientData clientData) {
	    DBG(fprintf(stderr,"+++ tspam: ThreadExitProc\n");)
	    
	    void tspam_ExitProc(ClientData clientData);
	    Tcl_DeleteExitHandler(tspam_ExitProc, clientData);
	    ExitHandler(clientData);
	}
	#endif

	/*
	* Gets activated at application-exit
	*/
	void
	tspam_ExitProc(ClientData clientData) {
	    DBG(fprintf(stderr,"+++ tspam: ExitProc\n");)
	    #if defined(TCL_THREADS)
	    Tcl_DeleteThreadExitHandler(tspam_ThreadExitProc, clientData);
	    #endif
	    ExitHandler(clientData);
	}

    /*
    * Registers thread/application exit handlers.
    */
    static void
    RegisterExitHandlers(ClientData clientData) {
	Tcl_Preserve(clientData);
	#if defined(TCL_THREADS)
	Tcl_CreateThreadExitHandler(tspam_ThreadExitProc, clientData);
	#endif
	Tcl_CreateExitHandler(tspam_ExitProc, clientData);
    }



    static int 
    tspam_ClassifyCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) 
    {
        //DBG(fprintf(stderr,"PlotCmd\n"));

        CheckArgs(2,2,1,"filename");

	const char *filename = Tcl_GetString(objv[1]);
	int is_spam = tspam_classify(filename);

        Tcl_SetObjResult(interp, Tcl_NewIntObj(is_spam));
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

    static void tspam_ExitHandler(ClientData unused)
    {
	tspam_cleanup();
    }


}


::critcl::cbuild [file normalize [info script]]
