
	int ${PROC_SetCmd} (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
	{

	    //CheckArgs(2,3,1,"docElemName ?newObjVar?");

	    if (objc != 2) {
		Tcl_WrongNumArgs(interp, 2, objv, "varName list");
		return TCL_ERROR;
	    }

	    Tcl_Obj *objPtr;
	    objPtr= Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);

	    if ( objPtr == NULL ) {
		return TCL_ERROR;
	    }

	    /* Get the data from the given object and then copy it into the object corresponding to objv[1] */
	    ${DataType} *dataPtr;
	    ${PROC_GetDataFromObj}(interp,objv[2],dataPtr);

	    ${InternalType} *internal = (${InternalType} *)objPtr->internalRep.otherValuePtr;
	    ${PROC_CopyData}(internal->dataPtr,dataPtr);


	    Tcl_ResetResult(interp);
	    Tcl_SetObjResult(interp, objPtr);

	    return TCL_OK;
	}
/**********************
	static
	int ${PROC_SetCmd} (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
	{


	    //CheckArgs(2,3,1,"docElemName ?newObjVar?");

	    if (objc != 2) {
		Tcl_WrongNumArgs(interp, 2, objv, "varName list");
		return TCL_ERROR;
	    }

	    Tcl_Obj *objPtr;
	    //objPtr= Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);

	    if ( objPtr == NULL ) {
		return TCL_ERROR;
	    }

	    /* Get the data from the given object and then copy it into the object corresponding to objv[1] */
	    //${DataType} *dataPtr;
	    //${PROC_GetDataFromObj}(interp,objv[2],dataPtr);

	    //${InternalType} *internal = (${InternalType} *)objPtr->internalRep.otherValuePtr;
	    //${PROC_CopyData}(internal->dataPtr,dataPtr);

	    Tcl_SetObjResult(interp,objv[1]);
	    return TCL_OK;
	}
*************************/


/********************
	static
	int tcldom_UnregisterDocShared (
					Tcl_Interp  * interp,
					domDocument * doc
					)
	{
	    int deleted;

	    Tcl_MutexLock(&tableMutex);
	    if (doc->refCount > 1) {
		tcldom_deleteNode(doc->rootNode, interp);
		domFreeNode(doc->rootNode, tcldom_deleteNode, interp, 1);
		doc->refCount--;
		deleted = 0;
	    } else {
		Tcl_HashEntry *entryPtr = Tcl_FindHashEntry(&sharedDocs, (char*)doc);
		if (entryPtr) {
		    Tcl_DeleteHashEntry(entryPtr);
		    deleted = 1;
		} else {
		    deleted = 0;
		}
	    }
	    Tcl_MutexUnlock(&tableMutex);

	    DBG(fprintf(stderr, "--> tcldom_UnregisterDocShared: doc %p %s "
			"shared table\n", doc, deleted ? "deleted from" : "left in"));

	    return deleted;
	}

	static
	int tcldom_CheckDocShared (
				   domDocument * doc
				   )
	{
	    Tcl_HashEntry *entryPtr;
	    domDocument *tabDoc = NULL;
	    int found = 0;

	    Tcl_MutexLock(&tableMutex);
	    entryPtr = Tcl_FindHashEntry(&sharedDocs, (char*)doc);
	    if (entryPtr == NULL) {
		found = 0;
	    } else {
		tabDoc = (domDocument*)Tcl_GetHashValue(entryPtr);
		found  = tabDoc ? 1 : 0;
	    }
	    Tcl_MutexUnlock(&tableMutex);

	    if (found && doc != tabDoc) {
		Tcl_Panic("document mismatch; doc=%p, in table=%p\n", doc, tabDoc);
	    }

	    return found;
	}


	void tcldom_initialize()
	{
	    if (!tcldomInitialized) {
		Tcl_MutexLock(&tableMutex);
		Tcl_InitHashTable(&sharedDocs, TCL_ONE_WORD_KEYS);
		Tcl_CreateExitHandler(tcldom_Finalize, NULL);
		tcldomInitialized = 1;
		Tcl_MutexUnlock(&tableMutex);
	    }
	}


****************************/
