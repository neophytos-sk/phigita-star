package provide json 0.1

set dir [file dirname [info script]]

::xo::lib::require critcl

::critcl::reset
::critcl::clibraries -L/usr/lib/ -lm
::critcl::config I /opt/naviserver/include [file join $dir ../c/]
::critcl::cfile $dir {cJSON.h cJSON.c}

::critcl::cinit {
    // init_text

    Tcl_CreateObjCommand(ip, "::json::parse_json", json_ParseCmd, NULL, NULL);

} {
    // init_exts
}

critcl::ccode {

    #include <float.h>  // DBL_EPILON
    #include <limits.h> // INT_MAX, INT_MIN
    #include <math.h>   // fabs
    #include "cJSON.h"

    #ifdef DEBUG
    # define DBG(x) x
    #else
    # define DBG(x)
    #endif

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }


		     

    static int json_ModuleInitialized;



Tcl_Obj *json_JsonToValue(Tcl_Interp *interp, cJSON *item);



Tcl_Obj *json_JsonToNumber(Tcl_Interp *interp, cJSON *item) {

    Tcl_Obj *valuePtr;
    double d = item->valuedouble;
    if (fabs(((double)item->valueint) - d) <= DBL_EPSILON && d<=INT_MAX && d>=INT_MIN) {
	valuePtr = Tcl_NewIntObj(item->valueint);
    } else {
	valuePtr = Tcl_NewDoubleObj(item->valuedouble);
    }
    return valuePtr;

}


Tcl_Obj *json_JsonToList(Tcl_Interp *interp, cJSON *item) {

    Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
    cJSON *child = item->child;
    while (child) {
	Tcl_Obj *elemPtr = json_JsonToValue(interp,child);
	Tcl_ListObjAppendElement(interp,listPtr,elemPtr);
	child=child->next;
    }
    return listPtr;

}


Tcl_Obj *json_JsonToDict(Tcl_Interp *interp, cJSON *item) {

    if (!item) return 0;

    Tcl_Obj *dictPtr = Tcl_NewDictObj();
    Tcl_Obj *keyPtr;
    Tcl_Obj *valuePtr;

    cJSON *child = item->child;
    while (child) {
	keyPtr = Tcl_NewStringObj(child->string,-1);
	valuePtr = json_JsonToValue(interp, child);
	Tcl_DictObjPut(interp,dictPtr, keyPtr, valuePtr);
	child = child->next;
    }
    return dictPtr;
}

Tcl_Obj *json_JsonToValue(Tcl_Interp *interp, cJSON *item) {


    if(!item) return 0;

    // DBG(fprintf(stderr,"type=%d\n",item->type));

    Tcl_Obj *valuePtr;
    switch((item->type)&255)
    {
	case cJSON_NULL:   valuePtr = Tcl_NewListObj(0,NULL); break;
	case cJSON_False:  valuePtr = Tcl_NewBooleanObj(0); break;
	case cJSON_True:   valuePtr = Tcl_NewBooleanObj(1); break;
	case cJSON_Number: valuePtr = json_JsonToNumber(interp,item); break;
	case cJSON_String: valuePtr = Tcl_NewStringObj(item->valuestring,-1); break;
	case cJSON_Array:  valuePtr = json_JsonToList(interp,item); break;
	case cJSON_Object: valuePtr = json_JsonToDict(interp,item); break;
	default:
	/* error */
	break;
    }
    return valuePtr;

}






    /*
    *----------------------------------------------------------------------
    *
    * json_ParseCmd --
    *
    *      Parse JSON and convert to TCL dict.
    *
    * Results:
    *      TCL_OK or TCL_ERROR
    *
    * Side effects:
    *
    *
    *----------------------------------------------------------------------
    */

    int json_ParseCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
	CheckArgs(2,3,1,"jsonVar");
	
	const char *varName = Tcl_GetString(objv[1]);
	const char *text = Tcl_GetVar(interp, varName, 0);


	cJSON *json;
	
	json=cJSON_Parse(text);
	if (!json) {
	    DBG(printf("Error before: [%s]\n",cJSON_GetErrorPtr()));
	    Tcl_AddErrorInfo(interp,cJSON_GetErrorPtr());
	    return TCL_ERROR;
	} else {
	    Tcl_Obj *objPtr = json_JsonToValue(interp,json);
	    Tcl_SetObjResult(interp,objPtr);
	    cJSON_Delete(json);
	}
	return TCL_OK;

    }


    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void json_InitModule() 
    {
        //Tcl_MutexLock(&json_Mutex);
        if (!json_ModuleInitialized) {
            json_ModuleInitialized = 1;
        }
        //Tcl_MutexUnlock(&json_Mutex);
    }


}

::critcl::cbuild [file normalize [info script]]
