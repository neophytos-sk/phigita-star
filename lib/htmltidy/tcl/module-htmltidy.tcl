package provide htmltidy 0.1

set dir [file dirname [info script]]

::xo::lib::require critcl

array set conf [list]
set conf(clibraries) "-L/opt/naviserver/lib -ltidy"
set conf(includedirs) [list "/opt/naviserver/include"]

set conf(cinit) {
    // init_text

    Tcl_CreateObjCommand(ip, "::htmltidy::tidy", htmltidy_TidyCmd, NULL, NULL);

}

set conf(ccode) {

    #undef panic
    /*
     * the location of the definition of panic is here:
     * /web/local-data/critcl/cache/tcl.h:2373 
     *
     */

    #include "tidy/tidy.h"
    #include "tidy/buffio.h"

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }

    static int htmltidy_ModuleInitialized;



    /*
    *----------------------------------------------------------------------
    *
    * ttext_TidyCmd --
    *
    *
    *
    * Results:
    *      TCL_OK or TCL_ERROR
    *
    * Side effects:
    *      
    *
    *----------------------------------------------------------------------
    */

    int htmltidy_TidyCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
	CheckArgs(2,3,1,"html ?options?");
	
	const char* html = Tcl_GetString(objv[1]);

	TidyBuffer output; /* = {0}; */
	TidyBuffer errbuf; /* = {0}; */
	int status = 0;

	uint contentErrors = 0;
	uint contentWarnings = 0;
	uint accessWarnings = 0;

	TidyDoc tdoc = tidyCreate();
	tidyBufInit( &output );
	tidyBufInit( &errbuf );

	tidyOptSetBool( tdoc, TidyForceOutput, yes );
	tidyOptSetBool( tdoc, TidyQuiet, yes );
	tidyOptSetBool( tdoc, TidyMark, no);
	tidyOptSetBool( tdoc, TidyXhtmlOut, yes );  // Convert to XHTML
	tidyOptSetBool( tdoc, TidyNumEntities, yes );
	tidyOptSetBool( tdoc, TidyAsciiChars, yes ); 
	tidyOptSetBool( tdoc, TidyHideEndTags, yes );
	tidyOptSetBool( tdoc, TidyFixBackslash, yes );
	tidyOptSetBool( tdoc, TidyHideComments, yes );
	tidyOptSetBool( tdoc, TidyFixComments, yes );
	tidyOptSetBool( tdoc, TidyFixUri, yes );
	tidyOptSetBool( tdoc, TidyShowWarnings, yes ); 


	tidyOptSetInt( tdoc, TidyShowErrors, 0); 
	tidyOptSetInt( tdoc, TidyWrapLen, 0); 
	tidyOptSetInt( tdoc, TidyIndentContent, 0 );

	tidyOptSetValue( tdoc, TidyInCharEncoding, "utf8");
	tidyOptSetValue( tdoc, TidyOutCharEncoding, "utf8");

	/*
	int i;
	for(i=2;i<objc;++i) {
	 Tcl_Obj *elemListPtr;
	 Tcl_Obj *keyPtr;
	 Tcl_Obj *valuePtr;

	 Tcl_ListObjIndex(interp,objv[2],i,&elemListPtr);
	 Tcl_ListObjIndex(interp,elemListPtr,0,&keyPtr);
	 Tcl_ListObjIndex(interp,elemListPtr,1,&valuePtr);
	 tidyOptParseValue(tdoc, Tcl_GetString(keyPtr), Tcl_GetString(valuePtr));
        }
	*/

	if (status >= 0) { status = tidySetErrorBuffer( tdoc, &errbuf ); }
        if (status >= 0) { status = tidyParseString( tdoc, html); }
        if (status >= 0) { status = tidyCleanAndRepair( tdoc );	}
        if (status >= 0) { status = tidyRunDiagnostics( tdoc );	}

        if (status > 1) {

	    /* If errors, do we want to force output? */
	    status = ( tidyOptGetBool(tdoc, TidyForceOutput) ? status : -1 );
	    
	}

        contentErrors   += tidyErrorCount( tdoc );
        contentWarnings += tidyWarningCount( tdoc );
        accessWarnings  += tidyAccessWarningCount( tdoc );

	if (status >= 0) { status = tidySaveBuffer( tdoc, &output ); }
	if (status >= 0) { Tcl_AppendResult(interp,output.bp,NULL); }

	/* called to free hash tables etc. */
	tidyBufFree( &output );
	tidyBufFree( &errbuf );
	tidyRelease( tdoc );
	
	return TCL_OK;
    }


    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void htmltidy_InitModule() 
    {
        //Tcl_MutexLock(&htmltidy_Mutex);
        if (!htmltidy_ModuleInitialized) {
            htmltidy_ModuleInitialized = 1;
        }
        //Tcl_MutexUnlock(&htmltidy_Mutex);
    }


}

::critcl::ext::cbuild_module [info script] conf
