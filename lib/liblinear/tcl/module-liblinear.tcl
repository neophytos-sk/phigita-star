package provide liblinear 0.1

::xo::lib::require critcl

::critcl::reset

::critcl::config language c++
::critcl::clibraries -lstdc++ -lblas

set dir [file dirname [info script]]
::critcl::config I /opt/naviserver/include [file join $dir ../c/]

#  blas/blas.h  blas/blasp.h blas/daxpy.c blas/ddot.c blas/dnrm2.c blas/dscal.c
::critcl::cfile $dir {linear.cpp tron.cpp linear.h tron.h}


# TODO
# - Rename ::ll_model::set to ::ll::set_model and so forth

::critcl::cinit {
    // init_text

    ll_parameter_InitModule();
    Tcl_CreateObjCommand(ip, "::ll_parameter::create", ll_parameter_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_parameter::set", ll_parameter_SetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_parameter::get", ll_parameter_GetCmd, NULL, NULL);
    Tcl_RegisterObjType(&ll_parameter_ObjType); 

    ll_problem_InitModule();
    Tcl_CreateObjCommand(ip, "::ll_problem::create", ll_problem_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_problem::set", ll_problem_SetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_problem::get", ll_problem_GetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_problem::load", ll_problem_LoadCmd, NULL, NULL);
    Tcl_RegisterObjType(&ll_problem_ObjType); 

    ll_model_InitModule();
    Tcl_CreateObjCommand(ip, "::ll_model::create", ll_model_CreateCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_model::set", ll_model_SetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_model::get", ll_model_GetCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_model::load", ll_model_LoadCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_model::save", ll_model_SaveCmd, NULL, NULL);
    Tcl_RegisterObjType(&ll_model_ObjType);

    Tcl_CreateObjCommand(ip, "::ll_train", ll_TrainCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::ll_cross_validation", ll_CrossValidationCmd, NULL, NULL);
    
} {
    // init_exts
}


critcl::ccode {
    #include "linear.h"
    #include <string.h>
    #include <stdlib.h>  // strtol - see ll_problem_LoadCmd and ll_readline

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

    #define ll_Malloc(type,n) (type *)Tcl_Alloc((n)*sizeof(type))
    #define ll_Free(x) Tcl_Free((char *) (x))

    #define ll_isspace(x)  ((x)==' ' || (x)=='\f' || (x)=='\n' || (x)=='\r' || (x)=='\t' || (x)=='\v')

    static Tcl_Obj*     ll_feature_node_List_Obj(Tcl_Interp *interp, struct feature_node *dataPtr);
    static int          ll_feature_node_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct feature_node *dataPtr);


    static Tcl_Obj* ll_feature_node_List_Obj(Tcl_Interp *interp, struct feature_node *dataPtr) {
	/* New Tcl List From Data */
            
        Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);

	/* int index */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->index));

	/* double value */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewDoubleObj(dataPtr->value));

	return listPtr;
    }


    static int ll_feature_node_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct feature_node *dataPtr) {
	/* Get List From Tcl Obj */

        Tcl_Obj *listPtr_Elem_L0;
        int listPtr_LLength;

	listPtr_LLength=0;
	if (Tcl_ListObjLength(interp, listPtr, &listPtr_LLength) != TCL_OK) { return TCL_ERROR; }
	if ( listPtr_LLength != 2 ) { return TCL_ERROR; }

	/* int index */
	Tcl_ListObjIndex(interp, listPtr, 0, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->index));

	/* double value */
	Tcl_ListObjIndex(interp, listPtr, 1, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetDoubleFromObj(interp,listPtr_Elem_L0,&(dataPtr->value));
	return TCL_OK;
    }



    /* ----------------------------------------------------------------------- */

    /* Data Manipulation Commands */
    static struct parameter* ll_parameter_AllocData();
    static void         ll_parameter_InitData(struct parameter *dataPtr);
    static void         ll_parameter_ClearData(struct parameter *dataPtr);
    static void         ll_parameter_CopyData(struct parameter *copyPtr, struct parameter *dataPtr);
    static Tcl_Obj*     ll_parameter_Tcl_Obj(Tcl_Interp *interp, struct parameter *dataPtr);
    static Tcl_Obj*     ll_parameter_List_Obj(Tcl_Interp *interp, struct parameter *dataPtr);
    static void         ll_parameter_FreeInternalRepProc(Tcl_Obj *objPtr);

    /* Create our Tcl hash table to store our handle look-ups.
     * We keep track of all of our handles in a hash table so that
     * we can always go back to something and look up our data should
     * we lose the pointer to our struct.
     */

    static Tcl_HashTable ll_parameter_HashTable;   /* TODO: Replace with critbit tree.  */
    static Tcl_Mutex     ll_parameter_HashTableMutex;
    static int           ll_parameter_ModuleInitialized;

    /* Now, we want to define a struct that will hold our data.  The first
     * three fields are Tcl-related and make it really easy for us to circle
     * back and find our related pieces.
     */

    typedef struct ll_parameter_InternalStruct {
	Tcl_Interp    *interp;  /* The Tcl interpreter where we were created.  */
	Tcl_Obj       *objPtr;  /*   The object that contains our string rep.  */
	Tcl_HashEntry *hashPtr; /* The pointer to our entry in the hash table. */
	struct parameter   *dataPtr; /* Our native data.                            */
	
	int epoch;
	int refCount;

    } ll_parameter_InternalType;

    static char ll_parameter_name[] = "ll_parameter";

    static Tcl_ObjType ll_parameter_ObjType = {
	ll_parameter_name,                          /* name */
	ll_parameter_FreeInternalRepProc,           /* freeIntRepProc */
	NULL,                                       /* dupIntRepProc */
	NULL,                                       /* updateStringProc */
	NULL                                        /* setFromAnyProc */
    };

    static void ll_parameter_FreeInternalRepProc(Tcl_Obj *objPtr)
    {
	ll_parameter_InternalType *internal = (ll_parameter_InternalType *)objPtr->internalRep.otherValuePtr;
	ll_parameter_ClearData((struct parameter *)internal->dataPtr);
	Tcl_Free((char *)internal);
	objPtr->typePtr = NULL;
    }


       static int ll_parameter_RegisterShared (const char *key, Tcl_Obj *objPtr)
        {
            Tcl_HashEntry *entryPtr;
            int refCount, newEntry;

            Tcl_MutexLock(&ll_parameter_HashTableMutex);
            refCount = ++objPtr->refCount;
            entryPtr = Tcl_CreateHashEntry(&ll_parameter_HashTable, (char*)key /* internal */, &newEntry);
            if (newEntry) {
                Tcl_SetHashValue(entryPtr, (ClientData)objPtr);
                //internal->hashPtr = entryPtr;
            }
            Tcl_MutexUnlock(&ll_parameter_HashTableMutex);

            /*
            * DBG(fprintf(stderr, "--> ll_parameter_RegisterShared: ll_parameter data %p %s "
             *          "shared table now with refcount of %d\n", objPtr,
             *          newEntry ? "entered into" : "already in", refCount));
             */
            return 0;
        }

        int ll_parameter_ReturnHandle (Tcl_Interp  *interp, Tcl_Obj *objPtr, int setVariable, Tcl_Obj *varNameObj)
        {
            char        objCmdName[80], *varName;
            Tcl_CmdInfo cmdInfo;
            //ll_parameter_InternalType *internal = (ll_parameter_InternalType *) objPtr->internalRep.otherValuePtr;

            if (objPtr /* internal->dataPtr */ == NULL) {
                if (setVariable) {
                    varName = Tcl_GetString(varNameObj);
                    Tcl_UnsetVar(interp, varName, 0);
                    Tcl_SetVar  (interp, varName, "", 0);
                }
                Tcl_ResetResult(interp);
                Tcl_SetStringObj(Tcl_GetObjResult(interp), (""), -1);
                return TCL_OK;
            }

            sprintf((objCmdName), "__ll_parameter__%p", (objPtr));

            if (setVariable) {
                varName = Tcl_GetString(varNameObj);
                Tcl_SetVar(interp, varName, objCmdName, 0);
            }

            // HERE - FIX: 
            ll_parameter_RegisterShared(objCmdName,objPtr);



            /* Set Result */
            Tcl_ResetResult(interp);
            Tcl_SetStringObj(Tcl_GetObjResult(interp), (objCmdName), -1);
            return TCL_OK;
        }

       static Tcl_Obj *ll_parameter_GetObjFromHandle(Tcl_Interp *interp, Tcl_HashTable *ht, Tcl_Obj *objVar)
        {

            Tcl_Obj *handle = Tcl_ObjGetVar2(interp, objVar, NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);
	    if (handle == NULL) {
		return NULL;
	    }
            Tcl_HashEntry *entryPtr = Tcl_FindHashEntry(ht,(char *)Tcl_GetString(handle));
            if (entryPtr == NULL) {
                //Tcl_AddErrorInfo(interp,"no such handle");
                return NULL;
            }
            return (Tcl_Obj *) Tcl_GetHashValue(entryPtr);

        }

        static void ll_parameter_InitData(struct parameter *dataPtr) {
            /* Init Data Code */
            memset(dataPtr,0,sizeof(struct parameter));
        }

        static struct parameter *ll_parameter_AllocData() {
            struct parameter *dataPtr = (struct parameter *)Tcl_Alloc(sizeof(struct parameter));
            ll_parameter_InitData(dataPtr);
            return  dataPtr;
        }


    static void ll_parameter_ClearData(struct parameter *dataPtr ) {
	destroy_param(dataPtr);
    }

        static Tcl_Obj *ll_parameter_AllocObj(Tcl_Interp *interp) {

            Tcl_Obj *objPtr = Tcl_NewObj();

            /* TODO: Check why SetFromAnyProc is called whenever we invoke ll_parameter_AllocObj 
             * Perhaps, we should just call SetFromAnyProc here and get over with it;
             */

            ll_parameter_InternalType *internal = (ll_parameter_InternalType *)Tcl_Alloc(sizeof(ll_parameter_InternalType));
            internal->interp = interp;
            internal->dataPtr = (struct parameter *)ll_parameter_AllocData();
            internal->objPtr = objPtr;
            internal->hashPtr = NULL;
            internal->refCount = 0;

            objPtr->bytes = NULL;
            objPtr->internalRep.otherValuePtr = internal;
            objPtr->typePtr = &ll_parameter_ObjType;

            return objPtr;

        }

    static void ll_parameter_CopyData(struct parameter *copyPtr /* copyPtr */, struct parameter *dataPtr /* dataPtr */ ) {

	/* Copy Data Code */
        
	copyPtr->solver_type=dataPtr->solver_type;
	copyPtr->eps=dataPtr->eps;
	copyPtr->C=dataPtr->C;
	copyPtr->nr_weight=dataPtr->nr_weight;
	copyPtr->weight_label = (int*) Tcl_Alloc(dataPtr->nr_weight * sizeof(int));
	memcpy(copyPtr->weight_label, dataPtr->weight_label, dataPtr->nr_weight * sizeof(int));
	copyPtr->weight = (double*) Tcl_Alloc(dataPtr->nr_weight * sizeof(double));
	memcpy(copyPtr->weight, dataPtr->weight, dataPtr->nr_weight * sizeof(double));

    }


    static int ll_parameter_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr /* listPtr */, struct parameter *dataPtr /* dataPtr */) {
	/* Get Data From Tcl Obj */
            
        Tcl_Obj *listPtr_Elem_L0;
        Tcl_Obj *listPtr_Elem_L1;
        int i;
        int listPtr_LLength;
        int llength_i;

	listPtr_LLength=0;
	if (Tcl_ListObjLength(interp, listPtr, &listPtr_LLength) != TCL_OK) { return TCL_ERROR; }
	if ( listPtr_LLength != 6 ) { return TCL_ERROR; }

	/* int solver_type */
	Tcl_ListObjIndex(interp, listPtr, 0, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->solver_type));

	/* double eps */
	Tcl_ListObjIndex(interp, listPtr, 1, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetDoubleFromObj(interp,listPtr_Elem_L0,&(dataPtr->eps));

	/* double C */
	Tcl_ListObjIndex(interp, listPtr, 2, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetDoubleFromObj(interp,listPtr_Elem_L0,&(dataPtr->C));

	/* int nr_weight */
	Tcl_ListObjIndex(interp, listPtr, 3, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->nr_weight));

	/* int* weight_label */
	Tcl_ListObjIndex(interp, listPtr, 4, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->weight_label = (int*) Tcl_Alloc(dataPtr->nr_weight * sizeof(int));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
	for(i=0; i < dataPtr->nr_weight; i++) {
	    Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
	    Tcl_GetIntFromObj(interp,listPtr_Elem_L1,&(dataPtr->weight_label[i]));
        }

	/* double* weight */
	Tcl_ListObjIndex(interp, listPtr, 5, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->weight = (double*) Tcl_Alloc(dataPtr->nr_weight * sizeof(double));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
	for(i=0; i < dataPtr->nr_weight; i++) {
                 Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
                 Tcl_GetDoubleFromObj(interp,listPtr_Elem_L1,&(dataPtr->weight[i]));
        }
	return TCL_OK;
    }



    static Tcl_Obj* ll_parameter_Tcl_Obj(Tcl_Interp *interp, struct parameter *dataPtr) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check if/why SetFromAnyProc is called whenever we invoke ll_parameter_AllocObj 
	 * Perhaps, we should just call SetFromAnyProc here and get over with it;
	 */

	ll_parameter_InternalType *internal = (ll_parameter_InternalType *)Tcl_Alloc(sizeof(ll_parameter_InternalType));
	internal->interp = interp;
	internal->dataPtr = (struct parameter *)dataPtr;

	internal->objPtr = objPtr;
	internal->hashPtr = NULL;
	internal->refCount = 0;

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &ll_parameter_ObjType;

	return objPtr;

    };


    static Tcl_Obj* ll_parameter_List_Obj(Tcl_Interp *interp, struct parameter *dataPtr) {
	/* New List From Data */
            
        Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
        Tcl_Obj *listPtr_L0;
        int i;
        int llength_i;


	/* int solver_type */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->solver_type));

	/* double eps */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewDoubleObj(dataPtr->eps));

	/* double C */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewDoubleObj(dataPtr->C));

	/* int nr_weight */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->nr_weight));

	/* int* weight_label */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->nr_weight; i++) {
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, Tcl_NewIntObj(dataPtr->weight_label[i]));
	}
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	/* double* weight */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->nr_weight; i++) {
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, Tcl_NewDoubleObj(dataPtr->weight[i]));
        }
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	return listPtr;
    }


    static
    int ll_parameter_CreateCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {
            int         setVariable = 0;
            Tcl_Obj     *objPtr;
            Tcl_Obj     *newObjName = NULL;


            //CheckArgs(2,3,1,"?newObjVar?");

            if (objc == 2) {
                newObjName = objv[1];
                setVariable = 1;
            }

            objPtr = ll_parameter_AllocObj(interp);
            if (objPtr == NULL) {
                return TCL_ERROR;
            }

            return ll_parameter_ReturnHandle(interp, objPtr, setVariable, newObjName);
        }

        static
        int ll_parameter_SetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {

            if (objc != 3) {
                Tcl_WrongNumArgs(interp, 1, objv, "varName list");
                return TCL_ERROR;
            }

            Tcl_Obj *objPtr = (Tcl_Obj *) ll_parameter_GetObjFromHandle(interp, &ll_parameter_HashTable,objv[1]);
            if (objPtr==NULL) {
                // Tcl_AddErrorInfo(interp,"no such handle");
                return TCL_ERROR;
            }

            ll_parameter_InternalType *internal = (ll_parameter_InternalType *) objPtr->internalRep.otherValuePtr;

            if ( internal == NULL ) {
                Tcl_AddErrorInfo(interp,"no such object found (internal is NULL)");
                return TCL_ERROR;
            }

            ll_parameter_GetDataFromObj(interp,objv[2],internal->dataPtr);

	    /* The following requires/invokes UpdateStringProc:
	     *     Tcl_SetObjResult(interp,objPtr);
	     *
	     * The following is better:
	     *     Tcl_SetObjResult(interp,ll_parameter_List_Obj(interp, internal->dataPtr));
	     *
	     * But, in this case, we do not want to return the string we used.	    
	     *
	     */

            return TCL_OK;

        }


        int ll_parameter_GetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {

            if (objc != 2) {
                Tcl_WrongNumArgs(interp, 1, objv, "varName");
                return TCL_ERROR;
            }

            Tcl_Obj *objPtr = (Tcl_Obj *) ll_parameter_GetObjFromHandle(interp, &ll_parameter_HashTable,objv[1]);
            if (objPtr==NULL) {
                // Tcl_AddErrorInfo(interp,"no such handle");
                return TCL_ERROR;
            }

            ll_parameter_InternalType *internal = (ll_parameter_InternalType *) objPtr->internalRep.otherValuePtr;

            if ( internal == NULL ) {
                Tcl_AddErrorInfo(interp,"no such object found (internal is NULL)");
                return TCL_ERROR;
            }

	    Tcl_SetObjResult(interp,ll_parameter_List_Obj(interp, internal->dataPtr));
            return TCL_OK;

        }


        /*----------------------------------------------------------------------------
        |   Exit Handler: ll_parameter_ExitHandler
        |
        |   Activated in application exit handler to delete shared document table
        |   Table entries are deleted by the object command deletion callbacks,
        |   so at this time, table should be empty. If not, we will leave some
        |   memory leaks. This is not fatal, though: we're exiting the app anyway.
        |   This is a private function to this file. 
        \---------------------------------------------------------------------------*/

        static void ll_parameter_ExitHandler(ClientData unused)
        {
            Tcl_MutexLock(&ll_parameter_HashTableMutex);
            Tcl_DeleteHashTable(&ll_parameter_HashTable);
            Tcl_MutexUnlock(&ll_parameter_HashTableMutex);
        }

        /*----------------------------------------------------------------------------
        |   Initialize Module
        |   Activated at module load to initialize shared object handles table.
        |   This is exported since we need it in HERE: tdominit.c.
        \---------------------------------------------------------------------------*/


        void ll_parameter_InitModule()
        {
            Tcl_MutexLock(&ll_parameter_HashTableMutex);
            if (!ll_parameter_ModuleInitialized) {
                //Tcl_InitHashTable(&ll_parameter_HashTable, TCL_ONE_WORD_KEYS);
                Tcl_InitHashTable(&ll_parameter_HashTable, TCL_STRING_KEYS);
                Tcl_CreateExitHandler(ll_parameter_ExitHandler, NULL);
                ll_parameter_ModuleInitialized = 1;
            }
            Tcl_MutexUnlock(&ll_parameter_HashTableMutex);
        }



    /* ----------------------------------------------------------------------- */

    /* Data Manipulation Commands */
    static struct problem* ll_problem_AllocData();
    static void         ll_problem_InitData(struct problem *dataPtr);
    static void         ll_problem_ClearData(struct problem *dataPtr);
    static Tcl_Obj*     ll_problem_AllocObj(Tcl_Interp *interp);
    static Tcl_Obj*     ll_problem_Tcl_Obj(Tcl_Interp *interp, struct problem *dataPtr);
    static Tcl_Obj*     ll_problem_List_Obj(Tcl_Interp *interp, struct problem *dataPtr);
    static int          ll_problem_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct problem *dataPtr);
    static void         ll_problem_FreeInternalRepProc(Tcl_Obj *objPtr);

    /* Create our Tcl hash table to store our handle look-ups.
     * We keep track of all of our handles in a hash table so that
     * we can always go back to something and look up our data should
     * we lose the pointer to our struct.
     */

    static Tcl_HashTable ll_problem_HashTable;   /* TODO: Replace with critbit tree.  */
    static Tcl_Mutex     ll_problem_HashTableMutex;
    static int           ll_problem_ModuleInitialized;

    /* Now, we want to define a struct that will hold our data.  The first
     * three fields are Tcl-related and make it really easy for us to circle
     * back and find our related pieces.
     */

    typedef struct ll_problem_InternalStruct {
	Tcl_Interp    *interp;  /* The Tcl interpreter where we were created.  */
	Tcl_Obj       *objPtr;  /*   The object that contains our string rep.  */
	Tcl_HashEntry *hashPtr; /* The pointer to our entry in the hash table. */
	struct problem   *dataPtr; /* Our native data.                            */

	int epoch;
	int refCount;

    } ll_problem_InternalType;

    static char ll_problem_name[] = "ll_problem";

    static Tcl_ObjType ll_problem_ObjType = {
	ll_problem_name,                          /* name */
	ll_problem_FreeInternalRepProc,                  /* freeIntRepProc */
	NULL,                                     /* dupIntRepProc */
	NULL,                                     /* updateStringProc */
	NULL                                      /* setFromAnyProc */
    };

        static void ll_problem_FreeInternalRepProc(Tcl_Obj *objPtr)
        {
            ll_problem_InternalType *internal = (ll_problem_InternalType *)objPtr->internalRep.otherValuePtr;
            ll_problem_ClearData((struct problem *)internal->dataPtr);
            Tcl_Free((char *)internal);
            objPtr->typePtr = NULL;
        }



    static void ll_problem_InitData(struct problem *dataPtr) {
	/* Init Data Code */
	memset(dataPtr,0,sizeof(struct problem));
    }

    static struct problem *ll_problem_AllocData() {
	struct problem *dataPtr = (struct problem *)Tcl_Alloc(sizeof(struct problem));
	ll_problem_InitData(dataPtr);
	return  dataPtr;
    }

    static void ll_problem_ClearData(struct problem *paramPtr) {
	if(paramPtr->y != NULL)
	    Tcl_Free((char *) paramPtr->y);
        if(paramPtr->x != NULL)
                Tcl_Free((char *) paramPtr->x);

    }


    static Tcl_Obj* ll_problem_Tcl_Obj(Tcl_Interp *interp, struct problem *dataPtr) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check if/why SetFromAnyProc is called whenever we invoke ll_problem_AllocObj 
	 * Perhaps, we should just call SetFromAnyProc here and get over with it;
	 */

	ll_problem_InternalType *internal = (ll_problem_InternalType *)Tcl_Alloc(sizeof(ll_problem_InternalType));
	internal->interp = interp;
	internal->dataPtr = (struct problem *)dataPtr;

	internal->objPtr = objPtr;
	internal->hashPtr = NULL;
	internal->refCount = 0;

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &ll_problem_ObjType;

	return objPtr;

    };



    static Tcl_Obj* ll_problem_List_Obj(Tcl_Interp *interp, struct problem *dataPtr) {
	/* New Tcl List From Data */
            
        Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
        Tcl_Obj *listPtr_L0;
        Tcl_Obj *listPtr_L1;
        int i;
        int j;
        int llength_i;
        int llength_j;


	/* int l */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->l));

	/* int n */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->n));

	/* int* y */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->l; i++) {
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, Tcl_NewIntObj(dataPtr->y[i]));
        }
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	// l is the number of training data
	// n is the number of features
	// y is an array containing the target values
	// x is a sparse array of feature nodes
	DBG(fprintf(stderr,"l=%d n=%d\n",dataPtr->l, dataPtr->n));

	
	/* struct feature_node** x */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->l; i++) {
                 listPtr_L1 = Tcl_NewListObj(0,NULL);
		 struct feature_node *x_space = dataPtr->x[i];
                 for(j=0; j < dataPtr->n; j++) {
                         Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L1, ll_feature_node_List_Obj(interp, &(x_space[j])));
			 if ( x_space[j].index == -1 ) break;
                 }
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, listPtr_L1); 
        }
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	/* double bias */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewDoubleObj(dataPtr->bias));

	return listPtr;
    }


    static int ll_problem_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct problem *dataPtr) {
	/* Get Data From Tcl List */

        Tcl_Obj *listPtr_Elem_L0;
        Tcl_Obj *listPtr_Elem_L1;
        Tcl_Obj *listPtr_Elem_L2;
        int i;
        int j;
        int listPtr_LLength;
        int llength_i;
        int llength_j;

	listPtr_LLength=0;
	if (Tcl_ListObjLength(interp, listPtr, &listPtr_LLength) != TCL_OK) { return TCL_ERROR; }
	if ( listPtr_LLength != 5 ) { return TCL_ERROR; }

	/* int l */
	Tcl_ListObjIndex(interp, listPtr, 0, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->l));

	/* int n */
	Tcl_ListObjIndex(interp, listPtr, 1, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->n));

	/* int* y */
	Tcl_ListObjIndex(interp, listPtr, 2, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->y = (int*) Tcl_Alloc(dataPtr->l * sizeof(int));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
	for(i=0; i < dataPtr->l; i++) {
                 Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
                 Tcl_GetIntFromObj(interp,listPtr_Elem_L1,&(dataPtr->y[i]));
         }


	/* struct feature_node** x */
	Tcl_ListObjIndex(interp, listPtr, 3, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->x = (struct feature_node**) Tcl_Alloc(dataPtr->l * sizeof(struct feature_node*));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
	for(i=0; i < dataPtr->l; i++) {
                 Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
                 dataPtr->x[i] = (struct feature_node*) Tcl_Alloc(dataPtr->n * sizeof(struct feature_node));
                 if (Tcl_ListObjLength(interp, listPtr_Elem_L1, &llength_j) != TCL_OK) { return TCL_ERROR; }
                 for(j=0; j < llength_j; j++) {
                         Tcl_ListObjIndex(interp, listPtr_Elem_L1, j, (Tcl_Obj **)&listPtr_Elem_L2);
                         ll_feature_node_GetDataFromObj(interp,listPtr_Elem_L2,&(dataPtr->x[i][j]));
                 } 
         }

	/* double bias */
	Tcl_ListObjIndex(interp, listPtr, 4, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetDoubleFromObj(interp,listPtr_Elem_L0,&(dataPtr->bias));
	return TCL_OK;
    }

    static Tcl_Obj *ll_problem_AllocObj(Tcl_Interp *interp) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check why SetFromAnyProc is called whenever we invoke ll_problem_AllocObj 
	 * Perhaps, we should just call SetFromAnyProc here and get over with it;
	 */

	ll_problem_InternalType *internal = (ll_problem_InternalType *)Tcl_Alloc(sizeof(ll_problem_InternalType));
	internal->interp = interp;
	internal->dataPtr = (struct problem *)ll_problem_AllocData();
	internal->objPtr = objPtr;
	internal->hashPtr = NULL;
	internal->refCount = 0;

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &ll_problem_ObjType;

	return objPtr;

    }


    static int ll_problem_RegisterShared (const char *key, Tcl_Obj *objPtr)
    {
	Tcl_HashEntry *entryPtr;
	int refCount, newEntry;

	Tcl_MutexLock(&ll_problem_HashTableMutex);
	refCount = ++objPtr->refCount;
	entryPtr = Tcl_CreateHashEntry(&ll_problem_HashTable, (char*)key /* internal */, &newEntry);
	if (newEntry) {
	    Tcl_SetHashValue(entryPtr, (ClientData)objPtr);
	    //internal->hashPtr = entryPtr;
	}
	Tcl_MutexUnlock(&ll_problem_HashTableMutex);

            /*
            * DBG(fprintf(stderr, "--> ll_problem_RegisterShared: ll_problem data %p %s "
             *          "shared table now with refcount of %d\n", objPtr,
             *          newEntry ? "entered into" : "already in", refCount));
             */
	return 0;
    }

    int ll_problem_ReturnHandle (Tcl_Interp  *interp, Tcl_Obj *objPtr, int setVariable, Tcl_Obj *varNameObj)
    {
	char        objCmdName[80], *varName;
	Tcl_CmdInfo cmdInfo;
	//ll_problem_InternalType *internal = (ll_problem_InternalType *) objPtr->internalRep.otherValuePtr;

	if (objPtr /* internal->dataPtr */ == NULL) {
	    if (setVariable) {
		varName = Tcl_GetString(varNameObj);
		Tcl_UnsetVar(interp, varName, 0);
		Tcl_SetVar  (interp, varName, "", 0);
	    }
	    Tcl_ResetResult(interp);
	    Tcl_SetStringObj(Tcl_GetObjResult(interp), (""), -1);
	    return TCL_OK;
	}

	sprintf((objCmdName), "__ll_problem__%p", (objPtr));

	if (setVariable) {
	    varName = Tcl_GetString(varNameObj);
	    Tcl_SetVar(interp, varName, objCmdName, 0);
	}

	// HERE - FIX: 
	ll_problem_RegisterShared(objCmdName,objPtr);



	/* Set Result */
	Tcl_ResetResult(interp);
	Tcl_SetStringObj(Tcl_GetObjResult(interp), (objCmdName), -1);
	return TCL_OK;
    }

    static Tcl_Obj *ll_problem_GetObjFromHandle(Tcl_Interp *interp, Tcl_HashTable *ht, Tcl_Obj *objVar)
    {
	
	Tcl_Obj *handle = Tcl_ObjGetVar2(interp, objVar, NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);
	if (handle == NULL) {
	    return NULL;
	}
	Tcl_HashEntry *entryPtr = Tcl_FindHashEntry(ht,(char *)Tcl_GetString(handle));
	if (entryPtr == NULL) {
	    //Tcl_AddErrorInfo(interp,"no such handle");
	    return NULL;
	}
	return (Tcl_Obj *) Tcl_GetHashValue(entryPtr);
	
    }

    static
    int ll_problem_CreateCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
    {
	int         setVariable = 0;
	Tcl_Obj     *objPtr;
	Tcl_Obj     *newObjName = NULL;


	//CheckArgs(2,3,1,"?newObjVar?");

	if (objc == 2) {
	    newObjName = objv[1];
	    setVariable = 1;
	}

	objPtr = ll_problem_AllocObj(interp);
	if (objPtr == NULL) {
	    return TCL_ERROR;
	}

	return ll_problem_ReturnHandle(interp, objPtr, setVariable, newObjName);
    }


    static
    int ll_problem_SetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
    {


	//CheckArgs(2,3,1,"docElemName ?newObjVar?");

	if (objc != 3) {
	    Tcl_WrongNumArgs(interp, 1, objv, "varName list");
	    return TCL_ERROR;
	}

	Tcl_Obj *objPtr = (Tcl_Obj *) ll_problem_GetObjFromHandle(interp, &ll_problem_HashTable,objv[1]);
	if (objPtr==NULL) {
	    Tcl_AddErrorInfo(interp,"no such handle");
	    return TCL_ERROR;
	}

	ll_problem_InternalType *internal = (ll_problem_InternalType *) objPtr->internalRep.otherValuePtr;

	if ( objPtr == NULL ) {
	    Tcl_AddErrorInfo(interp,"no such object found (objPtr is NULL)");
	    return TCL_ERROR;
	}

	ll_problem_GetDataFromObj(interp,objv[2],internal->dataPtr);

	/* The following requires/invokes UpdateStringProc:
	 *     Tcl_SetObjResult(interp,objPtr);
	 *
	 * The following is better:
	 *     Tcl_SetObjResult(interp,ll_problem_List_Obj(interp, internal->dataPtr));
	 *
	 * But, in this case, we do not want to return the string we used.	    
	 *
	 */

	return TCL_OK;

    }


    int ll_problem_GetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
    {

	if (objc != 2) {
	    Tcl_WrongNumArgs(interp, 1, objv, "varName");
	    return TCL_ERROR;
	}

	Tcl_Obj *objPtr = (Tcl_Obj *) ll_problem_GetObjFromHandle(interp, &ll_problem_HashTable,objv[1]);
	if (objPtr==NULL) {
	    // Tcl_AddErrorInfo(interp,"no such handle");
	    return TCL_ERROR;
	}

	ll_problem_InternalType *internal = (ll_problem_InternalType *) objPtr->internalRep.otherValuePtr;

	if ( internal == NULL ) {
	    Tcl_AddErrorInfo(interp,"no such object found (internal is NULL)");
	    return TCL_ERROR;
	}

	Tcl_SetObjResult(interp,ll_problem_List_Obj(interp, internal->dataPtr));
	return TCL_OK;

    }



        /*----------------------------------------------------------------------------
        |   Exit Handler: ll_problem_ExitHandler
        |
        |   Activated in application exit handler to delete shared document table
        |   Table entries are deleted by the object command deletion callbacks,
        |   so at this time, table should be empty. If not, we will leave some
        |   memory leaks. This is not fatal, though: we're exiting the app anyway.
        |   This is a private function to this file. 
        \---------------------------------------------------------------------------*/

        static void ll_problem_ExitHandler(ClientData unused)
        {
            Tcl_MutexLock(&ll_problem_HashTableMutex);
            Tcl_DeleteHashTable(&ll_problem_HashTable);
            Tcl_MutexUnlock(&ll_problem_HashTableMutex);
        }

        /*----------------------------------------------------------------------------
        |   Initialize Module
        |   Activated at module load to initialize shared object handles table.
        |   This is exported since we need it in HERE: tdominit.c.
        \---------------------------------------------------------------------------*/


        void ll_problem_InitModule()
        {
            Tcl_MutexLock(&ll_problem_HashTableMutex);
            if (!ll_problem_ModuleInitialized) {
                //Tcl_InitHashTable(&ll_problem_HashTable, TCL_ONE_WORD_KEYS);
                Tcl_InitHashTable(&ll_problem_HashTable, TCL_STRING_KEYS);
                Tcl_CreateExitHandler(ll_problem_ExitHandler, NULL);
                ll_problem_ModuleInitialized = 1;
            }
            Tcl_MutexUnlock(&ll_problem_HashTableMutex);
        }



    /* ----------------------------------------------------------------------- */

    /* Data Manipulation Commands */
    static struct model* ll_model_AllocData();
    static void         ll_model_InitData(struct model *dataPtr);
    static void         ll_model_ClearData(struct model *dataPtr);
    static Tcl_Obj*     ll_model_AllocObj(Tcl_Interp *interp);
    static Tcl_Obj*     ll_model_Tcl_Obj(Tcl_Interp *interp, struct model *dataPtr);
    static Tcl_Obj*     ll_model_List_Obj(Tcl_Interp *interp, struct model *dataPtr);
    static int          ll_model_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct model *dataPtr);
    static void         ll_model_FreeInternalRepProc(Tcl_Obj *objPtr);


    /* Create our Tcl hash table to store our handle look-ups.
     * We keep track of all of our handles in a hash table so that
     * we can always go back to something and look up our data should
     * we lose the pointer to our struct.
     */

    static Tcl_HashTable ll_model_HashTable;   /* TODO: Replace with critbit tree.  */
    static Tcl_Mutex     ll_model_HashTableMutex;
    static int           ll_model_ModuleInitialized;

    /* Now, we want to define a struct that will hold our data.  The first
     * three fields are Tcl-related and make it really easy for us to circle
     * back and find our related pieces.
     */

    typedef struct ll_model_InternalStruct {
	Tcl_Interp    *interp;  /* The Tcl interpreter where we were created.  */
	Tcl_Obj       *objPtr;  /*   The object that contains our string rep.  */
	Tcl_HashEntry *hashPtr; /* The pointer to our entry in the hash table. */
	struct model   *dataPtr; /* Our native data.                            */

	int epoch;
	int refCount;

    } ll_model_InternalType;

    static char ll_model_name[] = "ll_model";

    static Tcl_ObjType ll_model_ObjType = {
	ll_model_name,                          /* name */
	ll_model_FreeInternalRepProc,                  /* freeIntRepProc */
	NULL,                                   /* dupIntRepProc */
	NULL,                                   /* updateStringProc */
	NULL                                    /* setFromAnyProc */
    };

        static void ll_model_FreeInternalRepProc(Tcl_Obj *objPtr)
        {
	    DBG(fprintf(stderr,"ll_model_FreeInternalRepProc called"));

            ll_model_InternalType *internal = (ll_model_InternalType *)objPtr->internalRep.otherValuePtr;
            ll_model_ClearData((struct model *)internal->dataPtr);
            Tcl_Free((char *)internal);
            objPtr->typePtr = NULL;
        }



        static int ll_model_RegisterShared (const char *key, Tcl_Obj *objPtr)
        {
            Tcl_HashEntry *entryPtr;
            int refCount, newEntry;

            Tcl_MutexLock(&ll_model_HashTableMutex);
            refCount = ++objPtr->refCount;
            entryPtr = Tcl_CreateHashEntry(&ll_model_HashTable, (char*)key /* internal */, &newEntry);
            if (newEntry) {
                Tcl_SetHashValue(entryPtr, (ClientData)objPtr);
                //internal->hashPtr = entryPtr;
            }
            Tcl_MutexUnlock(&ll_model_HashTableMutex);

            DBG(fprintf(stderr, "--> ll_model_RegisterShared: ll_model data %p %s "
			        "shared table now with refcount of %d\n", objPtr,
			        newEntry ? "entered into" : "already in", refCount));

            return 0;
        }


        int ll_model_ReturnHandle (Tcl_Interp  *interp, Tcl_Obj *objPtr, int setVariable, Tcl_Obj *varNameObj)
        {
            char        objCmdName[80], *varName;
            Tcl_CmdInfo cmdInfo;
            //ll_model_InternalType *internal = (ll_model_InternalType *) objPtr->internalRep.otherValuePtr;

            if (objPtr /* internal->dataPtr */ == NULL) {
                if (setVariable) {
                    varName = Tcl_GetString(varNameObj);
                    Tcl_UnsetVar(interp, varName, 0);
                    Tcl_SetVar  (interp, varName, "", 0);
                }
                Tcl_ResetResult(interp);
                Tcl_SetStringObj(Tcl_GetObjResult(interp), (""), -1);
                return TCL_OK;
            }

            sprintf((objCmdName), "__ll_model__%p", (objPtr));

	    DBG(fprintf(stderr,"objCmdName=%s\n",objCmdName));

            if (setVariable) {
                varName = Tcl_GetString(varNameObj);
                Tcl_SetVar(interp, varName, objCmdName, 0);
            }

            // HERE - FIX: 
            ll_model_RegisterShared(objCmdName,objPtr);



            /* Set Result */
            Tcl_ResetResult(interp);
            Tcl_SetStringObj(Tcl_GetObjResult(interp), (objCmdName), -1);
            return TCL_OK;
        }


        static Tcl_Obj *ll_model_GetObjFromHandle(Tcl_Interp *interp, Tcl_HashTable *ht, Tcl_Obj *objVar)
        {

            Tcl_Obj *handle = Tcl_ObjGetVar2(interp, objVar, NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);
	    if (handle == NULL) {
		return NULL;
	    }
            Tcl_HashEntry *entryPtr = Tcl_FindHashEntry(ht,(char *)Tcl_GetString(handle));
            if (entryPtr == NULL) {
                //Tcl_AddErrorInfo(interp,"no such handle");
                return NULL;
            }
            return (Tcl_Obj *) Tcl_GetHashValue(entryPtr);

        }


    static void ll_model_InitData(struct model *dataPtr) {
	/* Init Data Code */
	memset(dataPtr,0,sizeof(struct model));
    }

    static struct model *ll_model_AllocData() {
	struct model *dataPtr = (struct model *)Tcl_Alloc(sizeof(struct model));
	ll_model_InitData(dataPtr);
	return  dataPtr ;
    }

    static void ll_model_ClearData(struct model *modelPtr) {
        if(modelPtr->w != NULL)
                Tcl_Free((char *) modelPtr->w);
        if(modelPtr->label != NULL)
                Tcl_Free((char *) modelPtr->label);

    }

    static Tcl_Obj *ll_model_AllocObj(Tcl_Interp *interp) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check why SetFromAnyProc is called whenever we invoke ll_model_AllocObj 
	* Perhaps, we should just call SetFromAnyProc here and get over with it;
	*/

	ll_model_InternalType *internal = (ll_model_InternalType *)Tcl_Alloc(sizeof(ll_model_InternalType));
	internal->interp = interp;
	internal->dataPtr = (struct model *)ll_model_AllocData();
	internal->objPtr = objPtr;
	internal->hashPtr = NULL;
	internal->refCount = 0;

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &ll_model_ObjType;

	return objPtr;

    }


    static int ll_model_GetDataFromObj(Tcl_Interp *interp, Tcl_Obj *listPtr, struct model *dataPtr) {
	/* Get Data From List Obj */
            
        Tcl_Obj *listPtr_Elem_L0;
        Tcl_Obj *listPtr_Elem_L1;
        Tcl_Obj *listPtr_Elem_L2;
        Tcl_Obj *tmpObjPtr;
        int i;
        int j;
        int listPtr_LLength;
        int llength_i;
        int llength_j;

	listPtr_LLength=0;
	if (Tcl_ListObjLength(interp, listPtr, &listPtr_LLength) != TCL_OK) { return TCL_ERROR; }
	if ( listPtr_LLength != 6 ) { return TCL_ERROR; }

	/* struct parameter param */
	Tcl_ListObjIndex(interp, listPtr, 0, (Tcl_Obj **)&listPtr_Elem_L0);
	tmpObjPtr = ll_parameter_GetObjFromHandle(interp,&ll_parameter_HashTable,listPtr_Elem_L0);
	ll_parameter_InternalType *internal = (ll_parameter_InternalType *) tmpObjPtr->internalRep.otherValuePtr;
	/*
	 * Consider the following (also increment refCount of internal):
	 *     dataPtr->param = internal->dataPtr
	 *
	 */
	ll_parameter_CopyData(&(dataPtr->param),internal->dataPtr);

	/* int nr_class */
	Tcl_ListObjIndex(interp, listPtr, 1, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->nr_class));

	/* int nr_feature */
	Tcl_ListObjIndex(interp, listPtr, 2, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetIntFromObj(interp,listPtr_Elem_L0,&(dataPtr->nr_feature));

	/* double* w */
	Tcl_ListObjIndex(interp, listPtr, 3, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->w = (double*) Tcl_Alloc(dataPtr->nr_feature * dataPtr->nr_class * sizeof(double));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
        for(i=0; i < dataPtr->nr_feature; i++) {
                 Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
                 if (Tcl_ListObjLength(interp, listPtr_Elem_L1, &llength_j) != TCL_OK) { return TCL_ERROR; }
                 for(j=0; j < dataPtr->nr_class; j++) {
                         Tcl_ListObjIndex(interp, listPtr_Elem_L1, j, (Tcl_Obj **)&listPtr_Elem_L2);
                         Tcl_GetDoubleFromObj(interp,listPtr_Elem_L2,&(dataPtr->w[(i * (dataPtr->nr_class)) + j]));
                 } 
         }

	/* int* label */
	Tcl_ListObjIndex(interp, listPtr, 4, (Tcl_Obj **)&listPtr_Elem_L0);
	dataPtr->label = (int*) Tcl_Alloc(dataPtr->nr_class * sizeof(int));
	if (Tcl_ListObjLength(interp, listPtr_Elem_L0, &llength_i) != TCL_OK) { return TCL_ERROR; }
	for(i=0; i < dataPtr->nr_class; i++) {
                 Tcl_ListObjIndex(interp, listPtr_Elem_L0, i, (Tcl_Obj **)&listPtr_Elem_L1);
                 Tcl_GetIntFromObj(interp,listPtr_Elem_L1,&(dataPtr->label[i]));
         }

	/* double bias */
	Tcl_ListObjIndex(interp, listPtr, 5, (Tcl_Obj **)&listPtr_Elem_L0);
	Tcl_GetDoubleFromObj(interp,listPtr_Elem_L0,&(dataPtr->bias));
	return TCL_OK;
    }


    static Tcl_Obj* ll_model_Tcl_Obj(Tcl_Interp *interp, struct model *dataPtr) {

	Tcl_Obj *objPtr = Tcl_NewObj();

	/* TODO: Check if/why SetFromAnyProc is called whenever we invoke ll_model_AllocObj 
	 * Perhaps, we should just call SetFromAnyProc here and get over with it;
	 */

	ll_model_InternalType *internal = (ll_model_InternalType *)Tcl_Alloc(sizeof(ll_model_InternalType));
	internal->interp = interp;
	internal->dataPtr = (struct model *)dataPtr;

	internal->objPtr = objPtr;
	internal->hashPtr = NULL;
	internal->refCount = 0;

	objPtr->bytes = NULL;
	objPtr->internalRep.otherValuePtr = internal;
	objPtr->typePtr = &ll_model_ObjType;

	return objPtr;

    };


    static Tcl_Obj* ll_model_List_Obj(Tcl_Interp *interp, struct model *dataPtr) {
	/* New Tcl List From Data */
            
        Tcl_Obj *listPtr = Tcl_NewListObj(0,NULL);
        Tcl_Obj *listPtr_L0;
        Tcl_Obj *listPtr_L1;
        int i;
        int j;
        int llength_i;
        int llength_j;
	

	/* struct parameter param */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, ll_parameter_List_Obj(interp, &(dataPtr->param)));

	/* int nr_class */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->nr_class));

	/* int nr_feature */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewIntObj(dataPtr->nr_feature));

	/* double* w */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->nr_feature; i++) {
                 listPtr_L1 = Tcl_NewListObj(0,NULL);
                 for(j=0; j < dataPtr->nr_class; j++) {
                         Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L1, Tcl_NewDoubleObj(dataPtr->w[(i * (dataPtr->nr_class)) + j]));
                 }
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, listPtr_L1); 
	}
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	/* int* label */
	listPtr_L0 = Tcl_NewListObj(0,NULL);
	for(i=0; i < dataPtr->nr_class; i++) {
                 Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr_L0, Tcl_NewIntObj(dataPtr->label[i]));
        }
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, listPtr_L0);

	/* double bias */
	Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) listPtr, Tcl_NewDoubleObj(dataPtr->bias));
	return listPtr;
    }


        int ll_model_CreateCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {
            int         setVariable = 0;
            Tcl_Obj     *objPtr;
            Tcl_Obj     *newObjName = NULL;


            //CheckArgs(2,3,1,"?newObjVar?");

            if (objc == 2) {
                newObjName = objv[1];
                setVariable = 1;
            }

            objPtr = ll_model_AllocObj(interp);
            if (objPtr == NULL) {
                return TCL_ERROR;
            }

            return ll_model_ReturnHandle(interp, objPtr, setVariable, newObjName);
        }


        int ll_model_SetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {


            //CheckArgs(2,3,1,"docElemName ?newObjVar?");

            if (objc != 3) {
                Tcl_WrongNumArgs(interp, 1, objv, "varName list");
                return TCL_ERROR;
            }

            Tcl_Obj *objPtr = (Tcl_Obj *) ll_model_GetObjFromHandle(interp, &ll_model_HashTable,objv[1]);
            if (objPtr==NULL) {
                // Tcl_AddErrorInfo(interp,"no such handle");
                return TCL_ERROR;
            }

            ll_model_InternalType *internal = (ll_model_InternalType *) objPtr->internalRep.otherValuePtr;

            if ( internal == NULL ) {
                Tcl_AddErrorInfo(interp,"no such object found (internal is NULL)");
                return TCL_ERROR;
            }

            ll_model_GetDataFromObj(interp,objv[2],internal->dataPtr);

	    /* The following requires/invokes UpdateStringProc:
	     *     Tcl_SetObjResult(interp,objPtr);
	     *
	     * The following is better:
	     *     Tcl_SetObjResult(interp,ll_model_List_Obj(interp, internal->dataPtr));
	     *
	     * But, in this case, we do not want to return the string we used.	    
	     *
	     */

            return TCL_OK;

        }

        int ll_model_GetCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
        {

            if (objc != 2) {
                Tcl_WrongNumArgs(interp, 1, objv, "varName");
                return TCL_ERROR;
            }

            Tcl_Obj *objPtr = (Tcl_Obj *) ll_model_GetObjFromHandle(interp, &ll_model_HashTable,objv[1]);
            if (objPtr==NULL) {
                // Tcl_AddErrorInfo(interp,"no such handle");
                return TCL_ERROR;
            }

            ll_model_InternalType *internal = (ll_model_InternalType *) objPtr->internalRep.otherValuePtr;

            if ( internal == NULL ) {
                Tcl_AddErrorInfo(interp,"no such object found (internal is NULL)");
                return TCL_ERROR;
            }

	    Tcl_SetObjResult(interp,ll_model_List_Obj(interp, internal->dataPtr));
            return TCL_OK;

        }


        /*----------------------------------------------------------------------------
        |   Exit Handler: ll_model_ExitHandler
        |
        |   Activated in application exit handler to delete shared document table
        |   Table entries are deleted by the object command deletion callbacks,
        |   so at this time, table should be empty. If not, we will leave some
        |   memory leaks. This is not fatal, though: we're exiting the app anyway.
        |   This is a private function to this file. 
        \---------------------------------------------------------------------------*/

        static void ll_model_ExitHandler(ClientData unused)
        {
            Tcl_MutexLock(&ll_model_HashTableMutex);
            Tcl_DeleteHashTable(&ll_model_HashTable);
            Tcl_MutexUnlock(&ll_model_HashTableMutex);
        }

        /*----------------------------------------------------------------------------
        |   Initialize Module
        |   Activated at module load to initialize shared object handles table.
        |   This is exported since we need it in HERE: tdominit.c.
        \---------------------------------------------------------------------------*/


        void ll_model_InitModule()
        {
            Tcl_MutexLock(&ll_model_HashTableMutex);
            if (!ll_model_ModuleInitialized) {
                //Tcl_InitHashTable(&ll_model_HashTable, TCL_ONE_WORD_KEYS);
                Tcl_InitHashTable(&ll_model_HashTable, TCL_STRING_KEYS);
                Tcl_CreateExitHandler(ll_model_ExitHandler, NULL);
                ll_model_ModuleInitialized = 1;
            }
            Tcl_MutexUnlock(&ll_model_HashTableMutex);
        }


    static char* ll_readline(FILE *input, char **line, int *max_line_len)
    {
        int len;

        if(fgets(*line,*max_line_len,input) == NULL)
                return NULL;

        while(strrchr(*line,'\n') == NULL)
        {
	    *max_line_len *= 2;
	    *line = (char *) Tcl_Realloc(*line,*max_line_len);
	    len = (int) strlen(*line);
	    if(fgets((*line)+len,(*max_line_len)-len,input) == NULL)
	        break;
        }
        return *line;
    }



    struct problem *load_problem(const char *filename, double bias)
    {
        int max_index, inst_max_index, i;
        long int elements, j;
        FILE *fp = fopen(filename,"r");


        if(fp==NULL) return NULL;
	struct problem *prob = (struct problem *) ll_problem_AllocData();
	struct feature_node *x_space;
	int errno;

        char *endptr;
        char *idx, *val, *label;

        prob->l = 0;
        elements = 0;
        int max_line_len = 1024;

	char *saveptr1, *saveptr2;

        char *line = ll_Malloc(char,max_line_len); 
        while(ll_readline(fp,&line,&max_line_len)!=NULL)
        {
                char *p = strtok_r(line," \t", &saveptr1); // label

                // features
                while(1)
                {
                        p = strtok_r(NULL," \t", &saveptr1);
                        if(p == NULL || *p == '\n') // check '\n' as ' ' may be after the last feature
                                break;
                        elements++;
                }
                elements++; // for bias term
                prob->l++;
        }
        rewind(fp);

        prob->bias=bias;
	// DBG(fprintf(stderr,"prob->l=%d bias=%.2f elements=%d\n",prob->l,prob->bias,elements));

        prob->y = ll_Malloc(int,prob->l);
        prob->x = ll_Malloc(struct feature_node *,prob->l);
        x_space = ll_Malloc(struct feature_node,elements+prob->l);

        max_index = 0;
        j=0;
        for(i=0;i<prob->l;i++)
        {

	 // DBG(fprintf(stderr,"load_problem ---> i=%d max_line_len=%d offset=%d line=%p\n",i,max_line_len,ftell(fp),line));

	 inst_max_index = 0; // strtol gives 0 if wrong format
	 ll_readline(fp,&line,&max_line_len);

                prob->x[i] = &x_space[j];
                label = strtok_r(line," \t\n",&saveptr2);
                if(label == NULL) // empty line
		{
		    return NULL;
		    //exit_input_error(i+1);
		}

                prob->y[i] = (int) strtol(label,&endptr,10);
                if(endptr == label || *endptr != '\0')
		{
		    return NULL;
		    // exit_input_error(i+1);
		}

                while(1)
                {
		    idx = strtok_r(NULL,":",&saveptr2);
		    val = strtok_r(NULL," \t",&saveptr2);
		    
		    if(val == NULL) break;

		    errno = 0;
		    x_space[j].index = (int) strtol(idx,&endptr,10);
		    if(endptr == idx || errno != 0 || *endptr != '\0' || x_space[j].index <= inst_max_index) {
			return NULL;
			// exit_input_error(i+1);
		    } else {
			inst_max_index = x_space[j].index;
		    }
		    
		    errno = 0;
		    x_space[j].value = strtod(val,&endptr);
		    if(endptr == val || errno != 0 || (*endptr != '\0' && !ll_isspace(*endptr))) {
			return NULL;
			// exit_input_error(i+1);
		    }

		    ++j;
                }
                if(inst_max_index > max_index) {
                        max_index = inst_max_index;
		}

                if(prob->bias >= 0) {
                        x_space[j++].value = prob->bias;
		}

                x_space[j++].index = -1;
        }

	// DBG(fprintf(stderr,"load_problem j=%d\n",j));

        if(prob->bias >= 0) {
	    prob->n=max_index+1;
	    for(i=1; i < prob->l; i++) {
	        (prob->x[i]-2)->index = prob->n;
	    }
	    x_space[j-2].index = prob->n;

        } else {
	    prob->n=max_index;
	}


	if (ferror(fp) != 0 || fclose(fp) != 0) return NULL;
	return prob;
    }


    static 
    int ll_problem_LoadCmd (ClientData cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	if (objc != 3 && objc !=4) {
	    Tcl_WrongNumArgs(interp, 1, objv, "newObjName filenameObj ?bias?");
	    return TCL_ERROR;
	}

	Tcl_Obj* newObjName = objv[1];
	Tcl_Obj* filenameObj = objv[2];
	double bias = -1;
	if (objc==4) {
	    Tcl_GetDoubleFromObj(interp,objv[3],&bias);
	}

	const char *problem_file_name = Tcl_GetString(filenameObj);
	struct problem *problem = (struct problem *) load_problem(problem_file_name,bias);
	if (!problem) {
	    Tcl_AddErrorInfo(interp,"load_problem failed");
	    return TCL_ERROR;
	}

	Tcl_Obj* problemObj = ll_problem_Tcl_Obj(interp,problem);

	if (problemObj == NULL) {
	    return TCL_ERROR;
	}
	return ll_problem_ReturnHandle(interp, problemObj, /* setVariable */ 1, newObjName);

    }

    static 
    int ll_model_LoadCmd (ClientData cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	if (objc != 3) {
	    Tcl_WrongNumArgs(interp, 1, objv, "newObjName filenameObj");
	    return TCL_ERROR;
	}

	Tcl_Obj* newObjName = objv[1];
	Tcl_Obj* filenameObj = objv[2];

	const char *model_file_name = Tcl_GetString(filenameObj);
	struct model *model = (struct model *) load_model(model_file_name);

	DBG(fprintf(stderr,"nr_class=%d nr_feature=%d\n",get_nr_class(model), get_nr_feature(model)));
	
	Tcl_Obj* modelObj = ll_model_Tcl_Obj(interp,model);

	if (modelObj == NULL) {
	    return TCL_ERROR;
	}
	return ll_model_ReturnHandle(interp, modelObj, /* setVariable */ 1, newObjName);
    }


    static 
    int ll_TrainCmd (ClientData cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	// TODO: add model varname as objv[1]

	if (objc != 4) {
	    Tcl_WrongNumArgs(interp, 1, objv, "model(out) problem(in) param(in)");
	    return TCL_ERROR;
	}

	Tcl_Obj *newObjName = objv[1];
	Tcl_Obj* objPtr1 = objv[2];
	Tcl_Obj* objPtr2 = objv[3];

	Tcl_Obj* problemObj = ll_problem_GetObjFromHandle(interp,&ll_problem_HashTable,objPtr1);
	Tcl_Obj* paramObj = ll_parameter_GetObjFromHandle(interp,&ll_parameter_HashTable,objPtr2);

	if (!problemObj || !paramObj) {
	    return TCL_ERROR;
	}

	ll_problem_InternalType *internal1 = (ll_problem_InternalType *) problemObj->internalRep.otherValuePtr;
	struct problem* problem = (struct problem *) internal1->dataPtr;

	ll_parameter_InternalType *internal2 = (ll_parameter_InternalType *) paramObj->internalRep.otherValuePtr;
	struct parameter* param = (struct parameter *) internal2->dataPtr;

	if (!problem || !param) {
	    Tcl_AddErrorInfo(interp,"problem or param pointers are null");
	    return TCL_ERROR;
	}

	const char *errMsg = check_parameter(problem,param);
	if (errMsg) {
	    Tcl_AddErrorInfo(interp,errMsg);
	    return TCL_ERROR;
	}

	struct model *model = train(problem,param);


	Tcl_Obj* modelObj = ll_model_Tcl_Obj(interp,model);
	if (modelObj == NULL) {
	    return TCL_ERROR;
	}

	return ll_model_ReturnHandle(interp, modelObj, /* setVariable */ 1, newObjName);

	// OLD: the following line is just temporary - better return a model handle
	// Tcl_SetObjResult(interp,ll_model_List_Obj(interp, model));
	// return TCL_OK;

    }



    int ll_model_SaveCmd (ClientData cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	// TODO: add model varname as objv[1]

	if (objc != 3) {
	    Tcl_WrongNumArgs(interp, 1, objv, "model filename");
	    return TCL_ERROR;
	}

	Tcl_Obj *objPtr = objv[1];
	Tcl_Obj *filenameObj  = objv[2];

	Tcl_Obj* modelObj = ll_model_GetObjFromHandle(interp,&ll_model_HashTable,objPtr);
	if (!modelObj) {
	    return TCL_ERROR;
	}

	ll_model_InternalType *internal = (ll_model_InternalType *) modelObj->internalRep.otherValuePtr;
	if (!internal) {
	    return TCL_ERROR;
	}
	struct model *model = (struct model *) internal->dataPtr;
	
	const char *model_file_name = Tcl_GetString(filenameObj);
	save_model(model_file_name,model);

	// Tcl_SetObjResult(interp,modelObj);
	return TCL_OK;
    }



    static 
    int ll_CrossValidationCmd (ClientData cd, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

	CheckArgs(3,4,1,"prob param nr_fold ?target?");


	Tcl_Obj* probObj = ll_model_GetObjFromHandle(interp,&ll_problem_HashTable,objv[1]);
	if (!probObj) { return TCL_ERROR; }

	Tcl_Obj* paramObj = ll_model_GetObjFromHandle(interp,&ll_parameter_HashTable,objv[2]);
	if (!paramObj) { return TCL_ERROR; }

	int nr_fold;
	Tcl_GetIntFromObj(interp, objv[3],&nr_fold);


	ll_problem_InternalType *prob_internal = (ll_problem_InternalType *) probObj->internalRep.otherValuePtr;
	if (!prob_internal) { return TCL_ERROR; }

	struct problem *prob = (struct problem *) prob_internal->dataPtr;
	if (!prob) { return TCL_ERROR; }

	ll_parameter_InternalType *param_internal = (ll_parameter_InternalType *) paramObj->internalRep.otherValuePtr;
	if (!param_internal) { return TCL_ERROR; }

	struct parameter *param = (struct parameter *) param_internal->dataPtr;
	if (!prob) { return TCL_ERROR; }


	int i;
        int total_correct = 0;
        int *target = ll_Malloc(int, prob->l);

        cross_validation(prob,param,nr_fold,target);

        for(i=0;i<prob->l;i++)
                if(target[i] == prob->y[i])
                        ++total_correct;

	double accuracy = 100.0 * total_correct / prob->l;

        //printf("Cross Validation Accuracy = %g%%\n",100.0*total_correct/prob->l);

        ll_Free(target);

	Tcl_SetObjResult(interp, Tcl_NewDoubleObj(accuracy));
	return TCL_OK;

    }




}



::critcl::cproc ll_predict {Tcl_Interp* interp Tcl_Obj* objPtr Tcl_Obj* listPtr} ok {
    Tcl_Obj* modelObj = ll_model_GetObjFromHandle(interp,&ll_model_HashTable,objPtr);

    ll_model_InternalType *internal = (ll_model_InternalType *) modelObj->internalRep.otherValuePtr;
    struct model *model = (struct model *) internal->dataPtr;

    // predict

    int nr_class=get_nr_class(model);
    double *prob_estimates=NULL;
    int nr_feature=get_nr_feature(model);
    int n;

    if(model->bias>=0) {
	n=nr_feature+1;
    } else {
	n=nr_feature;
    }
    
    DBG(fprintf(stderr,"nr_class=%d nr_feature=%d bias=%.2f\n",nr_class, nr_feature,model->bias));

    // TODO: flag_predict_probability

    int i=0, j=0, listLength=0, inst_max_index=0;
    Tcl_Obj *elemListPtr, *indexPtr, *valuePtr;
    Tcl_ListObjLength(interp,listPtr,&listLength);
    struct feature_node *x = (struct feature_node *) Tcl_Alloc((listLength+2)*sizeof(struct feature_node));
    for(i=0;i<listLength;++i) {

     Tcl_ListObjIndex(interp,listPtr,i,&elemListPtr);
     Tcl_ListObjIndex(interp,elemListPtr,0,&indexPtr);
     Tcl_ListObjIndex(interp,elemListPtr,1,&valuePtr);

     Tcl_GetIntFromObj(interp,indexPtr,&(x[j].index));
     Tcl_GetDoubleFromObj(interp,valuePtr,&(x[j].value));


     /* DBG(fprintf(stderr,"index=%d value=%.2f\n",x[j].index,x[j].value)); */

     if (x[j].index <= inst_max_index) {
	 Tcl_AddErrorInfo(interp,"x[j].index <= inst_max_index");
	 return TCL_ERROR;
     } else {
	 inst_max_index = x[j].index;
     }

     // feature indices larger than those in training are not used
     if(x[i].index <= nr_feature) {
	 ++j;
     }

    }
    
    if(model->bias>=0)
    {
	x[j].index = n;
	x[j].value = model->bias;
	j++;
    }
    x[j].index = -1;

    int predict_label = predict(model,x);
    
    DBG(fprintf(stderr,"predict_label=%d\n",predict_label));

    Tcl_Free((char *) x);

    Tcl_SetObjResult(interp,Tcl_NewIntObj(predict_label));
    return TCL_OK;
}


::critcl::cbuild [file normalize [info script]]
