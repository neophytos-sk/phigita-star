# TODO:
# * Consider sv_new, sv_create, sv_extend, sv_insert, sv_contains, and so on
# * Difference between sv_new and sv_create is that the sv_create associates a name with the handle

package provide critbit_tree 0.1

set dir [file dirname [info script]]

#package require critcl
::xo::lib::require critcl

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
::critcl::clibraries -L/opt/naviserver/lib

#::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../c]

::critcl::csources [file join $dir ../c/critbit.c]
::critcl::cheaders [file join $dir ../c/critbit.h]

if { [::xo::kit::debug_mode_p] } {
    ::critcl::cflags -DDEBUG
}

## TODO: Rename CreateCmd to OpenCmd (??) and DestroyCmd (??) to CloseCmd
## or Rename CreateCmd to ConnectCmd/LinkCmd and DestroyCmd to DisconnectCmd/UnlinkCmd

::critcl::cinit {
    // init_text
    cbt_InitModule();
    Tcl_CreateObjCommand(ip, "::cbt::create", cbt_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::extend", cbt_ExtendCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::insert", cbt_InsertCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::delete", cbt_DeleteCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::get", cbt_GetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::exists", cbt_PrefixExistsCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::prefix_match", cbt_PrefixMatchCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::segment_match", cbt_SegmentMatchCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::id", cbt_GetIdCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::size", cbt_SizeCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::dump", cbt_DumpCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::restore", cbt_RestoreCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::cbt::destroy", cbt_DestroyCmd, NULL, NULL);
    //Tcl_CreateObjCommand(ip, "::cbt::info", cbt_InfoCmd, NULL, NULL);
    Tcl_RegisterObjType(&cbt_ObjType); 
} {
    // init_exts
}

critcl::ccode {
    #include "critbit.h"
    #include <stdio.h>
    #include <string.h>


    /*----------------------------------------------------------------------------
    |   Module Globals
    |
    \---------------------------------------------------------------------------*/

    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }


    #ifndef TCL_THREADS
    static int nada_for_now = 0;
    #define TSD(x)     x
    #define GET_TSD()
    #else
    typedef struct cbt_ThreadSpecificData_s {
	int nada_for_now;
    } cbt_ThreadSpecificData;
    static Tcl_ThreadDataKey cbt_TSD_Key;
    #define GET_TSD()  cbt_ThreadSpecificData *tsdPtr = (cbt_ThreadSpecificData*) Tcl_GetThreadData(&cbt_TSD_Key, sizeof(cbt_ThreadSpecificData));
    #define TSD(x)     tsdPtr->x
    #endif /* TCL_THREADS */

    #ifdef DEBUG
    # define DBG(x) x
    #else
    # define DBG(x) 
    #endif

    #define CBT_CMD(s,internal)      sprintf((s), "_CBT%p", (internal))
    #define CBT_THREADED(x)          x



    /* Data Manipulation Commands */
    static critbit0_tree* cbt_AllocData();
    static void               cbt_CopyData(critbit0_tree *copyPtr, critbit0_tree *dataPtr);
    static void               cbt_InitData(critbit0_tree *dataPtr);
    static void               cbt_ClearData(critbit0_tree *dataPtr);
    static void               cbt_Tcl_Obj(critbit0_tree *dataPtr, Tcl_Obj *listPtr);
    static int                cbt_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, critbit0_tree *dataPtr);
    static Tcl_Obj*           cbt_AllocObj(Tcl_Interp *interp);

    /* Manage Tcl Object Types */
    static void cbt_FreeInternalRepProc(Tcl_Obj *objPtr);
    static void cbt_DupInternalRepProc(Tcl_Obj *srcPtr, Tcl_Obj *dupPtr);
    static void cbt_UpdateStringProc(Tcl_Obj *objPtr);
    static int  cbt_SetFromAnyProc(Tcl_Interp *interp, Tcl_Obj *objPtr);


    /* Create our Tcl hash table to store our handle look-ups.
    * We keep track of all of our handles in a hash table so that
    * we can always go back to something and look up our data should
    * we lose the pointer to our struct.
    */

    static Tcl_HashTable cbt_HandleToInternal_HT;          /* (char*)internal to (cbt_InternalType*)internal   */
    static Tcl_Mutex     cbt_HandleToInternal_HT_Mutex;

    static Tcl_HashTable cbt_NameToInternal_HT;  /* (char*)name to (cbt_InternalType*)internal */
    static Tcl_Mutex     cbt_NameToInternal_HT_Mutex;

    static int           cbt_ModuleInitialized;

    /* Now, we want to define a struct that will hold our data.  The first
    * three fields are Tcl-related and make it really easy for us to circle
    * back and find our related pieces.
    */

    typedef struct cbt_InternalStruct {
	Tcl_Interp    *interp;            /* The Tcl interpreter where we were created. */
	Tcl_Obj       *objPtr;            /* The object that contains our string rep. */
	Tcl_HashEntry *entryPtr;          /* Entry in the <(char*) handle,internal> hash table (cbt_HandleToInternal_HT). */
	Tcl_HashEntry *entryPtr2;         /* Entry in the <(char*) name,internal> hash table (cbt_NameToInternal_HT). */
	critbit0_tree *dataPtr;           /* Our native data. */

	int epoch;                        /* Track object changes */
	int refCount;

    } cbt_InternalType;

    static char cbt_name[] = "cbt";
    static Tcl_ObjType cbt_ObjType = {
	cbt_name,                          /* name */
	cbt_FreeInternalRepProc,                  /* freeIntRepProc */
	cbt_DupInternalRepProc,                   /* dupIntRepProc */
	cbt_UpdateStringProc,                     /* updateStringProc */
	cbt_SetFromAnyProc                        /* setFromAnyProc */
    };


    /* Auxiliary Functions */

    static int allprefixed_TclObj_cb(const critbit0_tree*const t,const char *elem, void *arg) {
	//DBG(fprintf(stderr,"allprefixed_TclObj_cb\n"));
	int ulen = critbit0_bytelen(t,elem);
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) arg, Tcl_NewByteArrayObj(elem,ulen));
	return 1;
    }


    static int prefix_match_TclObj_cb(const critbit0_tree*const t,const char *elem, int *remaining, void *arg) {

	if (*remaining) {
	    int ulen = critbit0_bytelen(t,elem);
	    Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) arg, Tcl_NewByteArrayObj(elem,ulen));
	    --(*remaining);
	    return 1;
	} else {
	    return 0;
	}
    }


    /* Custom-User Code */
    static void cbt_InitData(critbit0_tree *dataPtr) {
	dataPtr->root= 0;
	dataPtr->size=0;
	dataPtr->keylen= 0;
    }

    static critbit0_tree *cbt_AllocData() {
	critbit0_tree *dataPtr= (critbit0_tree *)Tcl_Alloc(sizeof(critbit0_tree));
	cbt_InitData(dataPtr);
	return  dataPtr;
    }

    static void cbt_ClearData(critbit0_tree *dataPtr) {
	critbit0_clear(dataPtr);
	Tcl_Free((char *) dataPtr)  ;
    }

    static void cbt_CopyData(critbit0_tree *copyPtr, critbit0_tree *dataPtr) {
       copyPtr = cbt_AllocData();
       critbit0_allprefixed(dataPtr,"", allprefixed_cb, copyPtr);

    }

    static void cbt_Tcl_Obj(critbit0_tree *dataPtr, Tcl_Obj *listPtr) {
	//DBG(fprintf(stderr,"cbt_Tcl_Obj\n"));
	critbit0_allprefixed(dataPtr,"",allprefixed_TclObj_cb,listPtr);
    }

    static int cbt_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, critbit0_tree *dataPtr) {
        Tcl_Obj *listPtr_Elem_L0;
        int listPtr_LLength;

	listPtr_LLength=0;
	if (Tcl_ListObjLength(interp, listPtr, &listPtr_LLength) != TCL_OK) { return TCL_ERROR; }

	//Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	int i;
	for(i=0; i<listPtr_LLength; ++i) {
	    Tcl_ListObjIndex(interp, listPtr, i, (Tcl_Obj **)&listPtr_Elem_L0);
	    int ulen= 0;
	    const unsigned char *u= Tcl_GetByteArrayFromObj(listPtr_Elem_L0,&ulen);
	    //const unsigned char *u= Tcl_GetStringFromObj(listPtr_Elem_L0,&ulen);
	    critbit0_insert(dataPtr,u,ulen);
	}
	//Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	return TCL_OK;
    }

    // inline
    static char* cbt_GetByteArrayFromObj(Tcl_Interp *interp,const critbit0_tree*const dataPtr, Tcl_Obj *objPtr, int*const dstWrotePtr) {
	const char *dst;
	dst = Tcl_GetByteArrayFromObj(objPtr,dstWrotePtr);
	return dst;

	if (dataPtr->keylen) {
	    dst = Tcl_GetByteArrayFromObj(objPtr,dstWrotePtr);
	    //const char *u = objv[2]->bytes?objv[2]->bytes:Tcl_GetString(objv[2]);
	    //ulen= (objv[2])->length;
	} else {
	    // we need this for utf-8

	    dst = Tcl_GetStringFromObj(objPtr,dstWrotePtr);
	    return dst;
	    
	}
	return dst;
    }




    /* Machine Generated Code */

    static void 
    cbt_FreeInternalRepProc(Tcl_Obj *objPtr) {
	DBG(fprintf(stderr,"cbt_FreeInternalRepProc\n"));
	cbt_InternalType *internal = (cbt_InternalType *)objPtr->internalRep.otherValuePtr;
	cbt_ClearData((critbit0_tree *)internal->dataPtr);
	Tcl_Free((char *)internal);
	objPtr->typePtr = NULL;
    }

    static void 
    cbt_DupInternalRepProc(Tcl_Obj *srcPtr, Tcl_Obj *dupPtr) {
	DBG(fprintf(stderr,"DupInternalRepProc\n"));
	cbt_InternalType *internal = (cbt_InternalType *)srcPtr->internalRep.otherValuePtr;
	dupPtr->internalRep.otherValuePtr = Tcl_Alloc(sizeof(cbt_InternalType));
	cbt_InternalType *internal2 = (cbt_InternalType *)dupPtr->internalRep.otherValuePtr;
	cbt_CopyData((critbit0_tree *) internal2->dataPtr,(critbit0_tree *)internal->dataPtr);
	dupPtr->typePtr = &cbt_ObjType;
    }

    static void 
    cbt_UpdateStringProc(Tcl_Obj *objPtr) {
	DBG(fprintf(stderr,"UpdateStringProc\n"));
	char *str;
	cbt_InternalType *internal = (cbt_InternalType *) objPtr->internalRep.otherValuePtr;
	Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
	cbt_Tcl_Obj((critbit0_tree *)internal->dataPtr,listPtr);
	str = Tcl_GetByteArrayFromObj(listPtr, &objPtr->length);
	objPtr->bytes = Tcl_Alloc(objPtr->length+1);
	memcpy(objPtr->bytes, str, objPtr->length+1);
	Tcl_IncrRefCount(listPtr);
	Tcl_DecrRefCount(listPtr);
    }

    static int
    cbt_SetFromAnyProc(Tcl_Interp *interp, Tcl_Obj *objPtr) {

	DBG(fprintf(stderr,"SetFromAnyProc\n"));

	Tcl_Obj *listPtr = Tcl_DuplicateObj(objPtr);
	int count;
	int i;


	Tcl_IncrRefCount(listPtr);
	if (Tcl_ListObjLength(interp, listPtr, &count) != TCL_OK)
	{
	    Tcl_DecrRefCount(listPtr);
	    return TCL_ERROR;
	}


	if (objPtr->typePtr && objPtr->typePtr->freeIntRepProc) 
	{
	    objPtr->typePtr->freeIntRepProc(objPtr);
	}

	cbt_InternalType *internal;
	internal = (cbt_InternalType *)Tcl_Alloc(sizeof(cbt_InternalType));
	internal->interp = interp;
	internal->dataPtr = cbt_AllocData();

	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &cbt_ObjType;
	return cbt_GetDataFromObj(interp,listPtr,internal->dataPtr);

    }

    static cbt_InternalType *
    cbt_AllocInternal(Tcl_Interp *interp) {
	cbt_InternalType *internal = (cbt_InternalType *)Tcl_Alloc(sizeof(cbt_InternalType));
	internal->interp     = interp;
	internal->dataPtr    = (critbit0_tree *)cbt_AllocData();
	internal->objPtr     = NULL;
	internal->entryPtr   = NULL;
	internal->entryPtr2  = NULL;
	internal->refCount   = 0;
	return internal;
    }

    static Tcl_Obj *
    cbt_AllocObj(Tcl_Interp *interp) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check why SetFromAnyProc is called whenever we invoke cbt_AllocObj 
	* Perhaps, we should just call SetFromAnyProc here and get over with it;
	*/

	cbt_InternalType *internal = cbt_AllocInternal(interp);

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &cbt_ObjType;

	return objPtr;

    }


    /* ================================================== */

    static int 
    cbt_RegisterName(const char *name, cbt_InternalType *internal) {

	Tcl_HashEntry *entryPtr;
	int refCount, newEntry;

	Tcl_MutexLock(&cbt_NameToInternal_HT_Mutex);
	refCount = ++internal->refCount;
	entryPtr = Tcl_CreateHashEntry(&cbt_NameToInternal_HT, (char*) name, &newEntry);
	if (newEntry) {
	    Tcl_SetHashValue(entryPtr, (ClientData)internal);
	    internal->entryPtr2 = entryPtr;
	}
	Tcl_MutexUnlock(&cbt_NameToInternal_HT_Mutex);

	DBG(fprintf(stderr, "--> RegisterName: name=%s cbt data internal=%p %s shared table now with refcount of %d\n", name, entryPtr, newEntry ? "entered into" : "already in", refCount));

	return 0;
    }

    static int 
    cbt_RegisterShared(cbt_InternalType *internal) {

	// TODO: UnregisterShared (see tcldom.c)

	Tcl_HashEntry *entryPtr;
	int refCount, newEntry;

	Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	refCount = ++internal->refCount;
	entryPtr = Tcl_CreateHashEntry(&cbt_HandleToInternal_HT, (char*) internal, &newEntry);
	if (newEntry) {
	    Tcl_SetHashValue(entryPtr, (ClientData)internal);
	    internal->entryPtr = entryPtr;
	}
	Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	DBG(fprintf(stderr, "--> RegisterShared: cbt data %p %s shared table now with refcount of %d\n", entryPtr, newEntry ? "entered into" : "already in", refCount));
             
	return 0;
    }

    static int
    cbt_RegisterHandle(const char *name, const char *handle, cbt_InternalType *internal) {
	DBG(fprintf(stderr,"RegisterHandle: handle=%s internal=%p\n",handle,internal));

	CBT_THREADED(cbt_RegisterShared(internal));

	if (name) CBT_THREADED(cbt_RegisterName(name,internal));
             
	return 0;

    }

    /* see tDOM's tcldom_returnDocumentObj for more details */

    static int 
    cbt_ReturnHandle (Tcl_Interp  *interp, cbt_InternalType *internal, int setVariable, Tcl_Obj *varNameObj) {
	char        handle[80], *varName = NULL;
	//Tcl_CmdInfo cmdInfo;

	DBG(fprintf(stderr,"cbt_ReturnHandle\n"));

	// CBT_GET_TSD()

	if (internal == NULL) {
	    if (setVariable) {
		varName = Tcl_GetString(varNameObj);
		Tcl_UnsetVar(interp, varName, 0);
		Tcl_SetVar  (interp, varName, "", 0);
	    }
	    Tcl_ResetResult(interp);
	    Tcl_SetStringObj(Tcl_GetObjResult(interp), "", -1);
	    return TCL_OK;
	}

	CBT_CMD(handle,internal);
	DBG(fprintf(stderr,"cbt_ReturnHandle: create handle => %s\n",handle));

	// TSD(dontCreateObjCommands)
	if (setVariable) {
	    varName = Tcl_GetString(varNameObj);
	    Tcl_SetVar(interp, varName, handle, 0);
	    DBG(fprintf(stderr,"cbt_ReturnHandle: set %s %s\n",varName,handle));
	}

	cbt_RegisterHandle(varName, handle,internal);

	/* Set Result */
	Tcl_ResetResult(interp);
	Tcl_SetStringObj(Tcl_GetObjResult(interp), (handle), -1);
	return TCL_OK;
    }

    static int 
    cbt_CheckInternalShared (cbt_InternalType *internal) {
	Tcl_HashEntry *entryPtr;
	cbt_InternalType *tabInternal = NULL;
	int found = 0;
	
	Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	entryPtr = Tcl_FindHashEntry(&cbt_HandleToInternal_HT, (char*)internal);
	if (entryPtr == NULL) {
	    found = 0;
	} else {
	    tabInternal = (cbt_InternalType *)Tcl_GetHashValue(entryPtr);
	    found  = tabInternal ? 1 : 0;
	}
	Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	if (found && internal != tabInternal) {
	    Tcl_Panic("critbit tree mismatch; given(cbt)=%p, in hashtable(cbt)=%p\n", internal, tabInternal);
	}

	return found;
    }



    static cbt_InternalType *
    cbt_GetInternalFromHandle(Tcl_Interp *interp, const char *handle, char **errMsg) {

	cbt_InternalType *internal = NULL;
	int shared = 1;
	
	if (strncmp(handle, "_CBT", 4)) {
	    *errMsg = "parameter not a critbit tree handle!";
	    return NULL;
	}
	if (sscanf(&handle[4], "%p", &internal) != 1) {
	    *errMsg = "parameter not a critbit tree handle!";
	    return NULL;
	}

	CBT_THREADED(shared = cbt_CheckInternalShared(internal));
	if (!shared) {
	    *errMsg = "parameter not a shared critbit tree handle!";
	    return NULL;
	}

	return internal;
	
    }


    static cbt_InternalType *
    cbt_GetInternalFromName(Tcl_Interp *interp, const char *name, char **errMsg) {
	cbt_InternalType *internal = NULL;
	Tcl_HashEntry *entryPtr;

	Tcl_MutexLock(&cbt_NameToInternal_HT_Mutex);
	entryPtr = Tcl_FindHashEntry(&cbt_NameToInternal_HT, (char*)name);
	if (entryPtr == NULL) {
	    *errMsg = "parameter not the name of a cribit tree!";
	} else {
	    internal = (cbt_InternalType *)Tcl_GetHashValue(entryPtr);
	}
	Tcl_MutexUnlock(&cbt_NameToInternal_HT_Mutex);

	return internal;
    }


    /* -------------------------------------------------- */


    static int 
    cbt_CreateCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
      DBG(fprintf(stderr,"CreateCmd\n"));

	int         setVariable = 0;
	Tcl_Obj     *newObjName = NULL;


	CheckArgs(2,3,1,"record_type ?newObjVar?");

	if (objc == 3) {
	    newObjName = objv[2];
	    setVariable = 1;
	}

	cbt_InternalType *internal = cbt_AllocInternal(interp);
	if (internal == NULL) {
	    return TCL_ERROR;
	}

	Tcl_GetIntFromObj(interp,objv[1],&(internal->dataPtr->keylen));
	DBG(fprintf(stderr,"keylen=%d\n",internal->dataPtr->keylen));
	return cbt_ReturnHandle(interp,  internal, setVariable, newObjName);
    }

    static int 
    cbt_ExtendCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"ExtendCmd\n"));

	CheckArgs(3,3,1,"handle list");

	char *errMsg;
	char *handle = Tcl_GetString(objv[1]);
	cbt_InternalType *internal = cbt_GetInternalFromHandle(interp, handle, &errMsg);
	if (internal==NULL) {
	    DBG(fprintf(stderr,"ExtendCmd: errMsg=%s \n",errMsg));
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	cbt_GetDataFromObj(interp,objv[2],internal->dataPtr);
	Tcl_SetObjResult(interp,objv[1]);
	return TCL_OK;

    }

    static int 
    cbt_GetIdCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"GetIdCmd\n"));

	CheckArgs(2,2,1,"handle");

	char *errMsg;
	cbt_InternalType *internal = cbt_GetInternalFromName(interp, Tcl_GetString(objv[1]), &errMsg);
	if (internal==NULL) {
	    //Tcl_AddErrorInfo(interp,errMsg);
	    //return TCL_ERROR;
	    return TCL_OK;
	}

	char handle[80];
	CBT_CMD(handle,internal);
	Tcl_SetStringObj(Tcl_GetObjResult(interp), (handle), -1);
	return TCL_OK;
    }


    static int 
    cbt_DestroyCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"DestroyCmd\n"));

	CheckArgs(2,2,1,"handle");

	char *errMsg;
	char *handle = Tcl_GetString(objv[1]);
	cbt_InternalType *internal = cbt_GetInternalFromHandle(interp, handle, &errMsg);
	if (internal==NULL) {
	    DBG(fprintf(stderr,"DestroyCmd: errMsg=%s \n",errMsg));
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	DBG(fprintf(stderr,"size of tree: %d\n",internal->dataPtr->size));

	if (internal->entryPtr2) {
	    Tcl_MutexLock(&cbt_NameToInternal_HT_Mutex);
	    Tcl_DeleteHashEntry(internal->entryPtr2);
	    Tcl_MutexUnlock(&cbt_NameToInternal_HT_Mutex);
	}

	Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	Tcl_DeleteHashEntry(internal->entryPtr);
	Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	cbt_ClearData((critbit0_tree *)internal->dataPtr);
	Tcl_Free((char *)internal);


	return TCL_OK;
    }


    static int 
    cbt_InsertCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	CheckArgs(3,3,1,"handle key=value");
	//CheckArgs(4,4,1,"handle key value");

	char *errMsg;
	const char *handle= Tcl_GetString(objv[1]);
	cbt_InternalType *internal =  cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	const char *elem = Tcl_GetByteArrayFromObj(objv[2],&ulen);

	// Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	int result= critbit0_insert(internal->dataPtr,elem,ulen);
	// Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	Tcl_SetObjResult(interp, Tcl_NewIntObj(result));    
	return TCL_OK;
    }


    static int 
    cbt_DeleteCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	CheckArgs(3,3,1,"handle data\n\t data := key=value or what have you");

	char *errMsg;
	const char *handle= Tcl_GetString(objv[1]);
	cbt_InternalType *internal =  cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	// TODO - HERE (2011-09-24 - change required for delete to work - simplex ): when you process the result from prefix_match - there is no byte array
	// const char *elem = Tcl_GetByteArrayFromObj(objv[2],&ulen);
	const char *elem = Tcl_GetStringFromObj(objv[2],&ulen);

	DBG(fprintf(stderr,"ulen=%d elem=%*.s\n",ulen,ulen,elem));

	// Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	int result= critbit0_delete(internal->dataPtr,elem,ulen);
	// Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	Tcl_SetObjResult(interp, Tcl_NewIntObj(result));    
	return TCL_OK;
    }


    // TODO (2010-11-11):
    // * unify prefix_match and allprefixed
    // * add orderby option: direction=0 direction=1
    // * add limit clause: special value -1=all
    // * use a critbit_tree* for the result only if limit>1 OR limit==-1 (all)
    // * else if limit==1 use char* just like the PrefixMatchCmd does
    // * name the new command prefix_match
    // * exact OR longest match
    static int 
    cbt_PrefixMatchCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	CheckArgs(3,6,1,"handle prefix ?direction? ?limit? ?exact?\n\tdirection := <0=asc (default) | 1=desc>\n\tlimit := <-1=all (default)>\n\texact := 1=exact prefix match | 0=longest prefix match");

	char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	cbt_InternalType *inInternal= cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!inInternal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	const char *u = cbt_GetByteArrayFromObj(interp,inInternal->dataPtr,objv[2],&ulen);
	//const char *u = Tcl_GetByteArrayFromObj(objv[2],&ulen);

	DBG(fprintf(stderr,"ulen=%d u=%*.s\n",ulen,ulen,u));

	int direction = 0;  //  0=ascending | 1=descending
	int limit = -1;     // -1=all
	int exact = 1;      //  1=exact prefix match | 0=longest prefix match
	if (objc>=4) Tcl_GetIntFromObj(interp,objv[3],&direction);
	if (objc>=5) Tcl_GetIntFromObj(interp,objv[4],&limit);
	if (objc>=6) Tcl_GetIntFromObj(interp,objv[5],&exact);

	DBG(fprintf(stderr,"direction=%d limit=%d exact=%d\n",direction,limit,exact));

	Tcl_Obj *listPtr= Tcl_NewListObj(0,NULL);
	critbit0_prefix_match(inInternal->dataPtr,u,ulen,direction,limit,exact,prefix_match_TclObj_cb,listPtr);

	// critbit0_tree *outTree = cbt_AllocData(interp);
	// critbit0_prefix_match(inInternal->dataPtr,u,ulen,direction,limit,exact,prefix_match_cb,outTree);
	//cbt_Tcl_Obj(outTree,listPtr);
	//critbit0_clear(outTree);

	Tcl_SetObjResult(interp, listPtr);
	return TCL_OK;
    }



    static int 
    cbt_SegmentMatchCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {


	CheckArgs(3,3,1,"handle key");


	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	const char *u = Tcl_GetByteArrayFromObj(objv[2],&ulen);

	const critbit0_tree* t  = (const critbit0_tree *)internal->dataPtr;
	const char* elem = NULL;

	// HERE: Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
	size_t match = critbit0_segment_match(internal->dataPtr,u,ulen,(void**)&elem);

	// HERE: Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

	//DBG(fprintf(stderr,"different at byte %zd\n",match));
	if (!match) {
	    return TCL_OK;
	}

	const size_t keylen = internal->dataPtr->keylen;
	const size_t half_keylen = keylen/2;

	Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
	Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewByteArrayObj(&elem[0],half_keylen));
	Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewByteArrayObj(&elem[half_keylen],half_keylen));
	Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewStringObj(&elem[keylen],-1));

	//const char *p= rawmemchr(&elem[keylen],'\0');
	//if (p) Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewByteArrayObj(&elem[keylen],p-&elem[keylen]));

	Tcl_SetObjResult(interp, listPtr);
	return TCL_OK;
    }


    static int 
    cbt_SizeCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"SizeCmd\n"));

	CheckArgs(2,2,1,"handle");

	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}
	Tcl_SetObjResult(interp,Tcl_NewIntObj(internal->dataPtr->size));
	return TCL_OK;
    }


    static int 
    cbt_PrefixExistsCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	//DBG(fprintf(stderr,"ExistsCmd\n"));

	CheckArgs(3,3,1,"handle prefix");

	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	const char *u = cbt_GetByteArrayFromObj(interp,internal->dataPtr,objv[2],&ulen);

	Tcl_SetObjResult(interp,Tcl_NewIntObj(critbit0_prefix_exists(internal->dataPtr,u,ulen)));
	return TCL_OK;
    }



    static int 
    cbt_GetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"GetCmd\n"));

	CheckArgs(3,3,1,"handle key");

	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	int ulen= 0;
	const char *u = cbt_GetByteArrayFromObj(interp,internal->dataPtr,objv[2],&ulen);

	// check that tree has unique keys
	// check that key is a key, e.g. ending in =

	char *elem;
	if (!critbit0_get(internal->dataPtr,u,ulen,&elem)) {
	    const char errMsg2[] = "key not found";
	    Tcl_AddErrorInfo(interp,errMsg2);
	    return TCL_ERROR;
	}
	int elemLen = critbit0_bytelen(internal->dataPtr,&elem);

	//fprintf(stderr,"elemLen=%d elem=%s\n",elemLen,elem);

	Tcl_SetObjResult(interp,Tcl_NewStringObj(elem,-1));
	//Tcl_SetObjResult(interp,Tcl_NewByteArrayObj(elem,-1));
	return TCL_OK;
    }


    static int 
    cbt_DumpCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"DumpCmd\n"));

	CheckArgs(3,3,1,"handle filename");

	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}
	const char * filename = Tcl_GetString(objv[2]);
	if (!critbit0_dump(internal->dataPtr,filename)) {
	    fprintf(stderr,"failed to dump file");
	    return TCL_ERROR;
	}
	return TCL_OK;
    }

    // Restore

    static int 
    cbt_RestoreCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
	DBG(fprintf(stderr,"RestoreCmd\n"));

	CheckArgs(3,3,1,"handle filename");

	const char *handle = Tcl_GetString(objv[1]);

	char *errMsg;
	const cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);

	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}
	const char * filename = Tcl_GetString(objv[2]);
	if (!critbit0_restore(internal->dataPtr,filename)) {
	    fprintf(stderr,"failed to dump file");
	    return TCL_ERROR;
	}
	return TCL_OK;
    }



   /*----------------------------------------------------------------------------
     | 
     | FIX: Thread Exit Handler (2011-12-25)
     |
     |   Exit Handler: cbt_ExitHandler
     |
     |   Activated in application exit handler to delete shared document table
     |   Table entries are deleted by the object command deletion callbacks,
     |   so at this time, table should be empty. If not, we will leave some
     |   memory leaks. This is not fatal, though: we're exiting the app anyway.
     |   This is a private function to this file. 
     \---------------------------------------------------------------------------*/

   static void cbt_ExitHandler(ClientData unused)
   {
       // Internal To Internal Hash Table
       Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
       Tcl_DeleteHashTable(&cbt_HandleToInternal_HT);
       Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);

       // Name To Internal Hash Table
       Tcl_MutexLock(&cbt_NameToInternal_HT_Mutex);
       Tcl_DeleteHashTable(&cbt_NameToInternal_HT);
       Tcl_MutexUnlock(&cbt_NameToInternal_HT_Mutex);

   }

   /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


   void cbt_InitModule() {
     Tcl_MutexLock(&cbt_HandleToInternal_HT_Mutex);
     if (!cbt_ModuleInitialized) {
       Tcl_InitHashTable(&cbt_HandleToInternal_HT, TCL_ONE_WORD_KEYS);
       Tcl_InitHashTable(&cbt_NameToInternal_HT, TCL_STRING_KEYS);
       Tcl_CreateThreadExitHandler(cbt_ExitHandler, NULL);
       cbt_ModuleInitialized = 1;
     }
     Tcl_MutexUnlock(&cbt_HandleToInternal_HT_Mutex);
   }


}


namespace eval ::cbt {

    variable STRING_KEYS 0
    variable UINT32_KEYS 4
    variable UINT64_KEYS 8

    variable STRING_VALS [expr { 256 + 0 }]
    variable UINT32_VALS [expr { 256 + 4 }]
    variable UINT64_VALS [expr { 256 + 8 }]

    variable STRING 0
    variable UINT32_STRING [expr { $UINT32_KEYS + $STRING_VALS }]
    variable UINT64_STRING [expr { $UINT64_KEYS + $STRING_VALS }]
    variable STRING_UINT32 [expr { $STRING_KEYS + $UINT32_VALS }]

    ::critcl::cproc contains {Tcl_Interp* interp char* handle char* elem} ok {
	char *errMsg;
	cbt_InternalType *internal = cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}
	int result= critbit0_contains(internal->dataPtr,elem);
	Tcl_SetObjResult(interp, Tcl_NewIntObj(result));    
	return TCL_OK;
    }


    ::critcl::cproc to_string {Tcl_Interp* interp char* handle} ok {
	char *errMsg;
	cbt_InternalType *internal= cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	Tcl_Obj *listPtr= Tcl_NewListObj(0,NULL);
	cbt_Tcl_Obj(internal->dataPtr,listPtr);
	Tcl_SetObjResult(interp, listPtr);
	return TCL_OK;
    }

    ::critcl::cproc bytes {Tcl_Interp* interp char* handle} ok {
	char *errMsg;
	cbt_InternalType *internal= cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	//WRONGDBG("---%s\n---",(char *)internal->dataPtr->root);
	
	//Tcl_SetObjResult(interp, listPtr);
	return TCL_OK;
    }

    ::critcl::cproc write_to_file {Tcl_Interp* interp char* handle char* filename} ok {
	DBG(fprintf(stderr,"WriteToFileCmd\n"));

	char *errMsg;
	cbt_InternalType *internal= cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	Tcl_Obj *listPtr= Tcl_NewListObj(0,NULL);
	cbt_Tcl_Obj(internal->dataPtr,listPtr);

	FILE *fp = fopen(filename,"wb");
	int bytelen= 0;
	unsigned char *bytes = Tcl_GetByteArrayFromObj(listPtr,&bytelen);
	if (!fwrite(bytes,bytelen,1,fp)) {
	    fprintf(stderr,"fwrite error");
	    fclose(fp);
	    return TCL_ERROR;
	}
	//fprintf(fp,"%s",bytes);

	fclose(fp);
	return TCL_OK;
    }

    ::critcl::cproc read_from_file {Tcl_Interp* interp char* handle char* filename} ok {

	FILE *file;
	char *buffer;
	unsigned long fileLen;

	//Open file
	file = fopen(filename, "rb");
	if (!file) {
	    fprintf(stderr, "Unable to open file %s", filename);
	    return;
	}
	
	//Get file length
	fseek(file, 0, SEEK_END);
	fileLen=ftell(file);
	fseek(file, 0, SEEK_SET);

	//Allocate memory
	buffer=(char *)Tcl_Alloc(fileLen+1);
	if (!buffer) {
	    fprintf(stderr, "Memory error!");
	    fclose(file);
	    return;
	}

	//Read file contents into buffer
	if (!fread(buffer, fileLen, 1, file)) {
	    fprintf(stderr, "fread error!");
	    fclose(file);
	    return;
	}
	fclose(file);
	

	Tcl_Obj *listPtr = Tcl_NewByteArrayObj(buffer,fileLen);
	Tcl_Free((char*) buffer);


	char *errMsg;
	cbt_InternalType *internal= cbt_GetInternalFromHandle(interp,handle,&errMsg);
	if (!internal) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}


	return cbt_GetDataFromObj(interp,listPtr,internal->dataPtr);
    }

}


::critcl::cbuild [file normalize [info script]]
