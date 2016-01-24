#include "tcl.h"

#if 0
#include "ns.h"
#endif 

#define TDP_ERROR TCL_ERROR
#define TDP_OK    TCL_OK
#define TDP_ABORT TCL_RETURN

#define BOOL_LITERAL_false 0
#define BOOL_LITERAL_true  1
#define BOOL_LITERAL_off   0
#define BOOL_LITERAL_on    1


/*----------------------------------------------------------------------------
  |   Debug Macros
  |
  \---------------------------------------------------------------------------*/
#ifdef DEBUG
# define DBG(x) x
#else
# define DBG(x) 
#endif

#ifdef REUSE_DSTRING
# define DSTRING_FREE(x)
#else
# define DSTRING_FREE(x) Tcl_DStringFree((x))
#endif


static void tdp_cleanup(Tcl_Interp *interp);

// static 
#ifdef __USE_NS__
inline int tdp_ReturnBlank() {
    Ns_Conn *connPtr = (Ns_Conn *) Ns_GetConn();
    if (connPtr->flags & NS_CONN_CLOSED) {
        DBG(fprintf(stderr,"NS_CONN_CLOSED, likely a redirect, do nothing\n"));
        return TCL_OK;
    } else {
        return Ns_ConnReturnNotice(connPtr, 204, "No Content", NULL);
    }
}
#else
inline int tdp_ReturnBlank() {
    return TCL_OK;
}
#endif

inline int
tdp_Result(Tcl_Interp *interp, int result)
{
    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(result == TCL_OK ? 1 : 0));
    return TCL_OK;
}



static void
tdp_ExitHandler(ClientData clientData) {
    Tcl_Interp *interp = (Tcl_Interp *) clientData;
    tdp_cleanup(interp);
    Tcl_Release(interp);
}

static void
tdp_ThreadExitProc(ClientData clientData) {
    void tdp_ExitProc(ClientData clientData);
    Tcl_DeleteExitHandler(tdp_ExitProc, clientData);
    tdp_ExitHandler(clientData);
}

void
tdp_ExitProc(ClientData clientData) {
    Tcl_DeleteThreadExitHandler(tdp_ThreadExitProc, clientData);
    tdp_ExitHandler(clientData);
}

static void
tdp_RegisterExitHandlers(ClientData clientData) {
    Tcl_Preserve(clientData);
    Tcl_CreateThreadExitHandler(tdp_ThreadExitProc, clientData);
    Tcl_CreateExitHandler(tdp_ExitProc,clientData);
}

// ----------------------------------- auxiliary ----------------------------------------


inline int strcmp_eq(const char *s1, const char *s2) {
    return 0 == strcmp(s1,s2);
}

inline int strcmp_ne(const char *s1, const char *s2) {
    return 0 != strcmp(s1,s2);
}

inline int intcmp_eq(int x, int y) {
    return x==y;
}

inline int intcmp_ne(int x, int y) {
    return x!=y;
}

inline const char *getstr(Tcl_Obj *objPtr) {
    return Tcl_GetString(objPtr);
}


/* fetch value from "::__data__" array */
// static
Tcl_Obj *getvar_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr, Tcl_Obj *const objPtr2) {
    return Tcl_ObjGetVar2(interp,objPtr,objPtr2,TCL_GLOBAL_ONLY);
}


#ifdef USE_NSF
/* fetch value from xotcl object */
// static
Tcl_Obj *getvar_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr1, Tcl_Obj *const objPtr2) {

    Tcl_IncrRefCount(objPtr1);
    Tcl_IncrRefCount(objPtr2);

    Tcl_Obj *const objv[] = { 
        global_objects[OBJECT_NSF_VAR_SET], 
        objPtr1, 
        objPtr2 
    };

    if ( TCL_ERROR == Tcl_EvalObjv(interp, 3, objv, TCL_EVAL_GLOBAL) ) {
        Tcl_DecrRefCount(objPtr1);
        Tcl_DecrRefCount(objPtr2);
        return NULL;
    }

    Tcl_DecrRefCount(objPtr1);
    Tcl_DecrRefCount(objPtr2);

    return Tcl_DuplicateObj(Tcl_GetObjResult(interp));
}
#else
/* fetch value from TCL dictionary */
//static
Tcl_Obj *getvar_1 /* dict_elem_var */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const dictPtr, Tcl_Obj *const keyPtr) {

    Tcl_Obj *valuePtr;
    if (TCL_ERROR == Tcl_DictObjGet(interp,dictPtr,keyPtr,&valuePtr)) {
        DBG(fprintf(stderr,"DictObjGet error"));
        return NULL;
    }
    return valuePtr;
}
#endif


// static
void append_quoted_html(Tcl_DString *dsPtr, const char *string, int length) {
    while (length--) {
        switch (*string) {
            case '<':
                Tcl_DStringAppend(dsPtr, "&lt;",4);
                break;

            case '>':
                Tcl_DStringAppend(dsPtr, "&gt;",4);
                break;

            case '&':
                Tcl_DStringAppend(dsPtr, "&amp;",5);
                break;

            case '\'':
                Tcl_DStringAppend(dsPtr, "&#39;",5);
                break;

            case '"': /* '" */
                Tcl_DStringAppend(dsPtr, "&#34;",5);
                break;

            default:
                Tcl_DStringAppend(dsPtr, string, 1);
                break;
        }
        ++string;
    }
}

/* append value from "::__data__" array */
// static
void append_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *objPtr1, Tcl_Obj *objPtr2, Tcl_DString *dsPtr, int noquote) {

    if (!objPtr1 || !objPtr2)  return;

    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,objPtr1,objPtr2,TCL_GLOBAL_ONLY);
    if (!objPtr) {
        DBG(fprintf(stderr,"append_0: objPtr is null"));
        Tcl_DStringAppend(dsPtr,"-ERROR-",7);
        return;
    }
    
    int length;
    const char *bytes = Tcl_GetStringFromObj(objPtr,&length);
    if (noquote) 
        Tcl_DStringAppend(dsPtr,bytes,length);
    else
        append_quoted_html(dsPtr,bytes,length);

}

#ifdef USE_NSF
/* append value from xotcl object to dsPtr */
// static
void append_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr1, Tcl_Obj *const objPtr2, Tcl_DString *const dsPtr, int noquote) {
    Tcl_IncrRefCount(objPtr1);
    Tcl_IncrRefCount(objPtr2);

    Tcl_Obj *const objv[] = { global_objects[OBJECT_NSF_VAR_SET], objPtr1, objPtr2 };

    if ( TCL_ERROR == Tcl_EvalObjv(interp, 3, objv, TCL_EVAL_GLOBAL) ) {
        Tcl_DecrRefCount(objPtr1);
        Tcl_DecrRefCount(objPtr2);
        return;
    }

    int length;
    const char *bytes = Tcl_GetStringFromObj(Tcl_GetObjResult(interp),&length);
    if (noquote) 
        Tcl_DStringAppend(dsPtr,bytes,length);
    else
        append_quoted_html(dsPtr,bytes,length);


    Tcl_DecrRefCount(objPtr1);
    Tcl_DecrRefCount(objPtr2);
}
#else
/* append value from TCL dictionary to dsPtr */
// static
void append_1 /* dict_elem_var */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const dictPtr, Tcl_Obj *const keyPtr, Tcl_DString *const dsPtr, int noquote) {

    Tcl_Obj *valuePtr;
    if (TCL_ERROR == Tcl_DictObjGet(interp,dictPtr,keyPtr,&valuePtr)) {
        DBG(fprintf(stderr,"DictObjGet error in append_1"));
        return /* NULL */;
    }

    int length;
    const char *bytes = Tcl_GetStringFromObj(valuePtr,&length);
    if (noquote) 
        Tcl_DStringAppend(dsPtr,bytes,length);
    else
        append_quoted_html(dsPtr,bytes,length);

}
#endif


// static
void append_obj(Tcl_Obj *objPtr, Tcl_DString *dsPtr, int noquote) {
    int length;
    const char *bytes = Tcl_GetStringFromObj(objPtr,&length);
    if (noquote) 
        Tcl_DStringAppend(dsPtr,bytes,length);
    else
        append_quoted_html(dsPtr,bytes,length);
}

// static
void append_obj_element(Tcl_Interp *interp,Tcl_Obj *objPtr, int index, Tcl_DString *dsPtr, int noquote) {
    Tcl_Obj *elemPtr;
    Tcl_ListObjIndex(interp,objPtr,index,&elemPtr);
    if (!elemPtr) {
        // TODO: possibly raise error
        return;
    }
    int length;
    const char *bytes = Tcl_GetStringFromObj(elemPtr,&length);
    if (noquote) 
        Tcl_DStringAppend(dsPtr,bytes,length);
    else
        append_quoted_html(dsPtr,bytes,length);
}

// static
Tcl_Obj *getvar_obj_element(Tcl_Interp *interp,Tcl_Obj *objPtr, int index) {
    Tcl_Obj *elemPtr;
    Tcl_ListObjIndex(interp,objPtr,index,&elemPtr);
    if (!elemPtr) {
        // TODO: possibly raise error
        return;
    }
    return elemPtr;
}

// static
int getint_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {


    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,part1Ptr,part2Ptr,TCL_GLOBAL_ONLY);
    // TODO: check if objPtr is null
    if (!objPtr) {
        DBG(fprintf(stderr,"getint_0 / tclvar / error\n"));
    }
    Tcl_IncrRefCount(objPtr);


    int intValue;
    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
        // return TCL_ERROR;
        Tcl_DecrRefCount(objPtr);
        return 0;
    }

    Tcl_DecrRefCount(objPtr);
    return intValue;
}

// static
int getint_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {

    Tcl_Obj *objPtr = getvar_1 /* nsfvar */ (interp,global_objects,part1Ptr,part2Ptr);
    // TODO: check if objPtr is null
    if (!objPtr) {
        DBG(fprintf(stderr,"getint_1 / nsfvar / error\n"));
    }
    Tcl_IncrRefCount(objPtr);

    int intValue;
    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
        // return TCL_ERROR;
        Tcl_DecrRefCount(objPtr);
        return 0;
    }

    Tcl_DecrRefCount(objPtr);
    return intValue;

}

// static
int getint_2 /* tclobj */ (Tcl_Interp *interp, Tcl_Obj *objPtr) {
    if (!objPtr) {
        // TODO: raise error somehow, use 'goto' perhaps?
        return 0;
    }

    int intValue;
    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
        // return TCL_ERROR;
        return 0;
    }
    return intValue;
}

// static
int getbool_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {


    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,part1Ptr,part2Ptr,TCL_GLOBAL_ONLY);
    // TODO: check if objPtr is null
    if (!objPtr) {
        DBG(fprintf(stderr,"getbool_0 / tclvar / error\n"));
    }
    Tcl_IncrRefCount(objPtr);

    int boolValue;
    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
        // return TCL_ERROR;
        Tcl_DecrRefCount(objPtr);
        return 0;
    }

    Tcl_DecrRefCount(objPtr);
    return boolValue;

}

// static
int getbool_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {

    Tcl_Obj *objPtr = getvar_1 /* nsfvar */ (interp,global_objects,part1Ptr,part2Ptr);
    // TODO: check if objPtr is null
    if (!objPtr) {
        DBG(fprintf(stderr,"getbool_1 / nsfvar / error\n"));
        return 0;
    }
    Tcl_IncrRefCount(objPtr);

    int boolValue;
    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
        // return TCL_ERROR;
        Tcl_DecrRefCount(objPtr);
        return 0;
    }

    Tcl_DecrRefCount(objPtr);
    return boolValue;

}

int getbool_2 /* tclobj */ (Tcl_Interp *interp, Tcl_Obj *objPtr) {
    if (!objPtr) {
        // TODO: raise error somehow, use 'goto' perhaps?
        return 0;
    }

    int boolValue;
    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
        // return TCL_ERROR;
        return 0;
    }
    return boolValue;
}


/*  --- widgets stuff --- */


// just set the data for other widgets to use
static
int tdp_val(Tcl_Interp *interp, Tcl_Obj **global_objects, int script_index, int var_index) {

    if ( TCL_ERROR == Tcl_EvalObjEx(interp, global_objects[script_index], TCL_EVAL_GLOBAL) ) {
        return TDP_ERROR;
    } else {
        Tcl_Obj *newValuePtr = Tcl_DuplicateObj(Tcl_GetObjResult(interp));
        if (!newValuePtr) {
            return TDP_ERROR;
        }

        Tcl_IncrRefCount(newValuePtr);
        Tcl_Obj *objPtr = Tcl_ObjSetVar2(interp,global_objects[OBJECT_DATA],global_objects[var_index],newValuePtr,TCL_GLOBAL_ONLY);
        if (!objPtr) {
            Tcl_DecrRefCount(newValuePtr);
            return TDP_ERROR;
        }
        Tcl_DecrRefCount(newValuePtr);
        return TDP_OK;
    }
}


static
int tdp_guard(Tcl_Interp *interp, Tcl_Obj **global_objects, int script_index) {
    if ( TCL_ERROR == Tcl_EvalObjEx(interp, global_objects[script_index], TCL_EVAL_GLOBAL) ) {
        return TDP_ERROR;
    } else {
        int boolValue;
        if (TCL_OK != Tcl_GetBooleanFromObj(interp,Tcl_GetObjResult(interp),&boolValue)) {
            return TDP_ERROR;
        }
        if (!boolValue) return TDP_ABORT;
        return TDP_OK;
    }
}
