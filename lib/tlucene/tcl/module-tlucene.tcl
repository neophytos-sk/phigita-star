package provide tlucene 0.1

set dir [file dirname [info script]]
source [file join $dir tlucene.tcl]


::xo::lib::require critcl

::critcl::reset
::critcl::config language c++
::critcl::clibraries \
    -lclucene-core \
    -lclucene-shared \
    -L/opt/naviserver/lib \
    -L/opt/clucene/lib

::critcl::config I \
    /opt/naviserver/include \
    /opt/clucene/include \
    /usr/include \
    [file join $dir ../cc]

#::critcl::csources [file join $dir ../cc/tlucene.h]
::critcl::csources [file join $dir ../cc/tlucene.cc]


::critcl::cinit {
    // init_text
    Tcl_CreateObjCommand(ip, "::tlucene::parse_query", tlucene_ParseQueryCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::tlucene::tokenize", tlucene_TokenizeCmd, NULL, NULL);
} {
    // init_exts
}


critcl::ccode {

    #include "tlucene.h"

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }




    static int 
    tlucene_ParseQueryCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(2,2,1,"query");

	const char *utf8_query_string = Tcl_GetString(objv[1]);
	char result[MAX_QUERY_BYTELEN] = { '\0' };
	tlucene_ParseQuery(utf8_query_string,result);

	Tcl_SetObjResult(interp, Tcl_NewStringObj(result,-1));
	return TCL_OK;
    }


    static int 
    tlucene_TokenizeCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        CheckArgs(2,2,1,"textVar htmlVar");

	int charlength=0;
	char *text = Tcl_GetStringFromObj(objv[1],&charlength);
	std::map<std::string, std::list<int> > tokenmap;
	tlucene_Tokenize(text,tokenmap);

	Tcl_Obj *dictPtr = Tcl_NewDictObj();
	for(typeof(tokenmap.begin()) it=tokenmap.begin();
	    it != tokenmap.end();
	    ++it) 
	{

	 Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
	 for(typeof((it->second).begin()) it2 = (it->second).begin();
	     it2 != (it->second).end();
	     ++it2) 
	 {

	  Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewIntObj(*it2));

         }

	 Tcl_Obj *keyPtr = Tcl_NewStringObj((it->first).c_str(),-1);
	 Tcl_DictObjPut(interp,dictPtr,keyPtr,listPtr);

     }


	Tcl_SetObjResult(interp, dictPtr);

	return TCL_OK;

    }

}


::critcl::cbuild [file normalize [info script]]

