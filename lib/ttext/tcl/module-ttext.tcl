package provide ttext 0.1

set dir [file dirname [info script]]

source [file join $dir ttext-langclass.tcl]

::xo::lib::require critcl

set prefix "/opt/tcl"

array set conf [list]
set conf(clibraries) "-L${prefix}/lib -lunac -lexttextcat"
set conf(includedirs) [list ${prefix}/include]


if { [::xo::kit::debug_mode_p] } {
    set conf(cflags) -DDEBUG
}

set conf(cinit) {
    // init_text
    RegisterExitHandlers(ip);
    ttext_InitModule(ip);


}

set conf(ccode) [subst -nocommands -nobackslashes {
    const char ttext_LangClass_prefix[] = "${prefix}/share/libexttextcat/";
    const char ttext_LangClass_conf[] = "${prefix}/share/libexttextcat/fpdb.conf";
}]

append conf(ccode) {
    #include <string.h>
    #include <stdlib.h>
    #include "unac.h"
    #include "libexttextcat/textcat.h"

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }

    #define ASSOC_DATA_KEY_LangClass "ttext_LangClass"

    // static int ttext_ModuleInitialized;
    // static void *ttext_LangClass_handle;


    /*
    *----------------------------------------------------------------------
    *
    * ttext_UnaccentCmd --
    *
    *    http://home.gna.org/unac/  
    *
    * Results:
    *      TCL_OK or TCL_ERROR
    *
    * Side effects:
    *      
    *
    *----------------------------------------------------------------------
    */


    int ttext_UnaccentCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
	CheckArgs(3,3,1,"charset text");	
	
	int len;
	const char* charset = Tcl_GetString(objv[1]);
	const char* text = Tcl_GetStringFromObj(objv[2],&len);

	char* unaccented = 0;
	size_t unaccented_length = 0;
	
	if(unac_string(charset, text, len, &unaccented, &unaccented_length) < 0) {
	    Tcl_AddErrorInfo(interp,"unaccent: attempt to unaccent with the specified charset failed");
	    return TCL_ERROR;
	}

	Tcl_SetObjResult(interp,Tcl_NewStringObj(unaccented,unaccented_length));

	free(unaccented);

	return TCL_OK;
    }


    /*
    *----------------------------------------------------------------------
    *
    * ttext_LangClassCmd --
    *
    *    DESCRIPTION="Library implementing N-gram-based text categorization"
    *    HOMEPAGE="http://software.wise-guys.nl/libtextcat/"
    *    SRC_URI="http://dev-www.libreoffice.org/src/${PN}/${P}.tar.xz"
    *
    * Results:
    *      TCL_OK or TCL_ERROR
    *
    * Side effects:
    *      
    *
    *----------------------------------------------------------------------
    */

    int ttext_LangClassCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {

        CheckArgs(2,2,1,"string");

        void *ttext_LangClass_handle = 
        Tcl_GetAssocData(interp,
        ASSOC_DATA_KEY_LangClass,
        NULL);

        if (!ttext_LangClass_handle) {
            Tcl_AddErrorInfo(interp,"ttext_LangClass_handle is null, exiting...\n");
            return TCL_ERROR;
        }

        const char *buf = Tcl_GetString(objv[1]);
        char *result = textcat_Classify(ttext_LangClass_handle, buf, strlen(buf) + 1);
        Tcl_AppendResult(interp,result,NULL);


        return TCL_OK;
    }


    void ttext_LangClass_init(Tcl_Interp *interp) {
        // prefix is the directory path where fingerprints are stored
        void *ttext_LangClass_handle = special_textcat_Init(ttext_LangClass_conf, ttext_LangClass_prefix);

        if (!ttext_LangClass_handle) { 
            fprintf(stderr,"Unable to init using '%s'.",ttext_LangClass_conf);
            // exit
            // return TCL_ERROR;
        } 

        Tcl_SetAssocData(
            interp,
            ASSOC_DATA_KEY_LangClass,
            NULL,
            ttext_LangClass_handle);

    }

    void ttext_LangClass_cleanup(Tcl_Interp *interp) {

	void *ttext_LangClass_handle = 
	    Tcl_GetAssocData(interp,
			     ASSOC_DATA_KEY_LangClass,
			     NULL);

	textcat_Done(ttext_LangClass_handle);
	Tcl_DeleteAssocData(interp,ASSOC_DATA_KEY_LangClass);
    }

    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void ttext_InitModule(Tcl_Interp *interp) 
    {

	ttext_LangClass_init(interp);

	Tcl_CreateObjCommand(interp, "::ttext::__langclass", ttext_LangClassCmd, NULL, NULL);

	Tcl_CreateObjCommand(interp, "::ttext::unaccent", ttext_UnaccentCmd, NULL, NULL);
    }


    static void
    ExitHandler(ClientData clientData) {

	Tcl_Interp *interp = (Tcl_Interp *) clientData;
        ttext_LangClass_cleanup(clientData);
	Tcl_Release(interp);
    }

    static void ttext_ThreadExitProc(ClientData clientData)
    {
        void ttext_ExitProc(ClientData clientData);
	Tcl_DeleteExitHandler(ttext_ExitProc, clientData);
	ExitHandler(clientData);
    }

	void
        ttext_ExitProc(ClientData clientData) {
            Tcl_DeleteThreadExitHandler(ttext_ThreadExitProc, clientData);
            ExitHandler(clientData);
        }

	static void
        RegisterExitHandlers(ClientData clientData) {
            Tcl_Preserve(clientData);
            Tcl_CreateThreadExitHandler(ttext_ThreadExitProc, clientData);
            Tcl_CreateExitHandler(ttext_ExitProc,clientData);
        }


}

::critcl::ext::cbuild_module [info script] conf
