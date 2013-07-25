
proc parse_cstruct {struct} {

    # extract metadata and then remove comments

    set struct [string map {"/*" "\x00" "*/" "\x01"} $struct]
    set pattern {\x00\s*((?:@[a-zA-Z0-9_()]+\s+[^@\x01]+\s*)+)\s*\x01}
    set struct [regsub -all -- $pattern $struct "\x02\\1"]

    set pattern {\x00[^\x01]*\x01}
    set struct [regsub -all -- $pattern $struct ""]
    set struct [string map {"\x00" "/*" "\x01" "*/"} $struct]

    # remove spaces, semicolons, and newlines from the end of the string to avoid having an empty element when we split
    set struct [string trim $struct " ;\n"]

    # defs as a list of lists
    set struct [::xo::fun::map declaration [split $struct ";"] {
	lassign [split $declaration "\x02"] x metadata

	# for pointers, attach the asterisk to the name of the type
	set pattern {\s*([*]+)\s*}
	set x [regsub -all -- $pattern $x "\\1 "]

	# remove extra spaces
	set pattern {\s+}
	set x [regsub -all -- $pattern $x " "]

	list [string trim [lrange $x 0 end-1]] [string trim [lindex $x end]] [string trim $metadata]
    }]

    return $struct
}

proc ctype_template {name cTypeName struct spec codeVar init_textVar init_extsVar} {

    upvar $codeVar code
    upvar $init_textVar init_text
    upvar $init_extsVar init_exts

    #ns_log notice "******************************** name=$name"
    set template ""

    if { $cTypeName eq {} } {
	set cTypeName ${name}_t
	append template {

	    typedef struct ${name} { 
		$spec 
	    } ${cTypeName};
	}
    }

    set ::__CTYPE($cTypeName) $name

    # Data Manipulation Commands
    set DataType              ${cTypeName}
    set HashTable             ${name}_HashTable
    set HashTableMutex        ${name}_HashTableMutex
    set ModuleInitialized     ${name}_ModuleInitialized

    set HandlePrefix          __${name}__              ;# TODO: pass a shorter name as prefix for handles

    set PROC_InitModule       ${name}_InitModule
    set PROC_ModuleFinalize   ${name}_ExitHandler      ;# Exit Handler
    set PROC_AllocData        ${name}_AllocData        ;# AUTO-GENERATED: critbit0_tree *tree = (critbit0_tree *)Tcl_Alloc(sizeof(critbit0_tree));
    set PROC_InitData         ${name}_InitData         ;# USER-SPECIFIED: INIT {treePtr} {treePtr->root = 0;}
    set PROC_CopyData         ${name}_CopyData         ;# USER-SPECIFIED: COPY {treePtr newTreePtr} {critbit0_allprefixed(treePtr,"",allprefixed_cb,newTreePtr); }
    set PROC_CopyDataArea     ${name}_CopyData_Area    ;# A collection of items
    set PROC_ClearData        ${name}_ClearData        ;# USER-SPECIFIED: CLEAR {treePtr} {critbit0_clear(treePtr);}
    set PROC_NewObjFromData   ${name}_Tcl_Obj       ;# USER-SPECIFIED: GET  {treePtr listPtr} {critbit0_allprefixed(treePtr,"",allprefixed_TclObj_cb,listPtr); }
    set PROC_GetDataFromObj   ${name}_GetDataFromObj   ;# USER-SPECIFIED: PUT  {treePtr objPtr2} { critbit0_insert(treePtr,Tcl_GetString(objPtr2)); }
    set PROC_AllocObj         ${name}_AllocObj
    set PROC_RegisterShared   ${name}_RegisterShared
    set PROC_ReturnHandle     ${name}_ReturnHandle
    set PROC_CreateCmd        ${name}_CreateCmd
    set PROC_SetCmd           ${name}_SetCmd
    set PROC_GetObjFromHandle ${name}_GetObjFromHandle
    set PROC_InfoCmd           ${name}_InfoCmd

    set struct_defs [parse_cstruct $struct]

    #ns_log notice "struct_defs = $struct_defs"

    set InitData_CODE       "" ; set INIT_varName1  "dataPtr"
    set ClearData_CODE      "" ; set CLEAR_varName1 "dataPtr" 
    set NewObjFromData_CODE "" ; set GET_varName1   "dataPtr" ; set GET_varName2  "listPtr"
    set GetDataFromObj_CODE "" ; set PUT_varName1   "listPtr" ; set PUT_varName2  "dataPtr"
    set CopyData_CODE       "" ; set COPY_varName1  "dataPtr" ; set COPY_varName2 "copyPtr"
    set CopyDataArea_CODE   "" ; set COPY_AreaSize_varName "n"

    foreach {blockName varList blockCode} $spec {
	set i -1
	foreach varName $varList {
	    set ${blockName}_varName[incr i] $varName
	}
	set ${blockName}_CODE $blockCode
    }
    set InitData_CODE       [::util::coalesce $InitData_CODE       [ccode_struct_InitData       $struct_defs ${DataType} "${INIT_varName1}"]]
    set ClearData_CODE      [::util::coalesce $ClearData_CODE      [ccode_struct_ClearData      $struct_defs "${CLEAR_varName1}->"]]
    set NewObjFromData_CODE [::util::coalesce $NewObjFromData_CODE [ccode_struct_NewObjFromData $struct_defs "${GET_varName1}" "${GET_varName2}"]]
    set GetDataFromObj_CODE [::util::coalesce $GetDataFromObj_CODE [ccode_struct_GetDataFromObj $struct_defs "${PUT_varName1}" "${PUT_varName2}"]]
    set CopyData_CODE       [::util::coalesce $CopyData_CODE       [ccode_struct_CopyData       $struct_defs "${COPY_varName1}" "${COPY_varName2}"]]
    set CopyDataArea_CODE   [::util::coalesce $CopyDataArea_CODE   [ccode_struct_CopyDataArea   $struct_defs ${DataType} "${COPY_varName1}" "${COPY_varName2}" "${PROC_CopyData}" "${COPY_AreaSize_varName}"]]


    #set GetAtDataProc      ${name}_GetAtDataProc ;# use indices in InternalType
    #set SetAtDataProc      ${name}_SetAtDataProc ;# use indices in InternalType

    # Manage Tcl Object Types
    #
    #   Register new object types, look up types, and 
    #   force conversions from one type to another.
    #
    set InternalStruct      ${name}_InternalStruct
    set InternalType        ${name}_InternalType
    set ObjType             ${name}_ObjType
    set FreeInternalRepProc ${name}_FreeInternalRepProc
    set DupInternalRepProc  ${name}_DupInternalRepProc
    set UpdateStringProc    ${name}_UpdateStringProc
    set SetFromAnyProc      ${name}_SetFromAnyProc


    # Code Generation Template
    append template {
	#define __MIN__(x,y) ((x)<(y)?(x):(y))

	/* Data Manipulation Commands */
	static ${DataType}* ${PROC_AllocData}();
	static void         ${PROC_CopyDataArea}(${DataType} *${COPY_varName2}, ${DataType} *${COPY_varName1}, int ${COPY_AreaSize_varName});
	static void         ${PROC_CopyData}(${DataType} *${COPY_varName2}, ${DataType} *${COPY_varName1});
	static void         ${PROC_InitData}(${DataType} *${INIT_varName1});
	static void         ${PROC_ClearData}(${DataType} *${CLEAR_varName1});
	static Tcl_Obj*     ${PROC_NewObjFromData}(${DataType} *${GET_varName1});
	static int          ${PROC_GetDataFromObj}(Tcl_Interp *interp, Tcl_Obj *${PUT_varName1}, ${DataType} *${PUT_varName2});
	static Tcl_Obj*     ${PROC_AllocObj}(Tcl_Interp *interp);

	/* Manage Tcl Object Types */
	static void ${FreeInternalRepProc}(Tcl_Obj *objPtr);
	static void ${DupInternalRepProc}(Tcl_Obj *srcPtr, Tcl_Obj *dupPtr);
	static void ${UpdateStringProc}(Tcl_Obj *objPtr);
	static int  ${SetFromAnyProc}(Tcl_Interp *interp, Tcl_Obj *objPtr);

	/* Create our Tcl hash table to store our handle look-ups.
	 * We keep track of all of our handles in a hash table so that
	 * we can always go back to something and look up our data should
	 * we lose the pointer to our struct.
	 */

	static Tcl_HashTable ${HashTable};   /* TODO: Replace with critbit tree.  */
	static Tcl_Mutex     ${HashTableMutex};
	static int           ${ModuleInitialized};

	/* Now, we want to define a struct that will hold our data.  The first
	 * three fields are Tcl-related and make it really easy for us to circle
	 * back and find our related pieces.
	 */

	typedef struct ${InternalStruct} {
	    Tcl_Interp    *interp;  /* The Tcl interpreter where we were created.  */
	    Tcl_Obj       *objPtr;  /*   The object that contains our string rep.  */
	    Tcl_HashEntry *hashPtr; /* The pointer to our entry in the hash table. */
	    ${DataType}   *dataPtr; /* Our native data.                            */

	    int epoch;
	    int refCount;

	} ${InternalType};

	static char ${name}_name[] = "${name}";

	static Tcl_ObjType ${ObjType} = {
	    ${name}_name,                          /* name */
	    ${FreeInternalRepProc},                  /* freeIntRepProc */
	    ${DupInternalRepProc},                   /* dupIntRepProc */
	    ${UpdateStringProc},                     /* updateStringProc */
	    ${SetFromAnyProc}                        /* setFromAnyProc */
	};


	static void ${PROC_InitData}(${DataType} *${INIT_varName1}) {
	    /* Init Data Code */
	    ${InitData_CODE}
	}

	static ${DataType} *${PROC_AllocData}() {
	    ${DataType} *${INIT_varName1} /* dataPtr */ = (${DataType} *)Tcl_Alloc(sizeof(${DataType}));
	    ${PROC_InitData}(${INIT_varName1});
	    return  ${INIT_varName1} /* dataPtr */  ;
	}

	static void ${PROC_CopyDataArea}(${DataType} *${COPY_varName2} /* copyPtr */, ${DataType} *${COPY_varName1} /* dataPtr */, int  ${COPY_AreaSize_varName} /* n */ ) {
	    ${CopyDataArea_CODE}
	}

	static void ${PROC_CopyData}(${DataType} *${COPY_varName2} /* copyPtr */, ${DataType} *${COPY_varName1} /* dataPtr */ ) {

	    /* Copy Data Code */
	    ${CopyData_CODE}

	    // Ns_Log(Notice,"data ${COPY_varName1}=%s",Tcl_GetString(${PROC_NewObjFromData}(${COPY_varName2})));
	    // Ns_Log(Notice,"target ${COPY_varName2}=%s",Tcl_GetString(${PROC_NewObjFromData}(${COPY_varName1})));
	}

	static void ${PROC_ClearData}(${DataType} *${CLEAR_varName1} /* dataPtr */) {
	    /* Clear Data Code */
	    ${ClearData_CODE}
	    Tcl_Free((char *) ${CLEAR_varName1} /* dataPtr */)  ;
	}

	/* Get Tcl_Obj From Data */
	static Tcl_Obj* /* listPtr */ ${PROC_NewObjFromData}(${DataType} *${GET_varName1} /* dataPtr */) {
	    /* New Tcl Object From Data */
	    ${NewObjFromData_CODE}
	}

	static int ${PROC_GetDataFromObj}(Tcl_Interp *interp, Tcl_Obj *${PUT_varName1} /* listPtr */, ${DataType} *${PUT_varName2} /* dataPtr */) {
	    /* Get Data From Tcl Obj */
	    ${GetDataFromObj_CODE}
	    return TCL_OK;
	}

	static Tcl_Obj *${PROC_AllocObj}(Tcl_Interp *interp) {

	    Tcl_Obj *objPtr = Tcl_NewObj();

	    /* TODO: Check why SetFromAnyProc is called whenever we invoke ${PROC_AllocObj} 
 	     * Perhaps, we should just call SetFromAnyProc here and get over with it;
	     */

	    ${InternalType} *internal = (${InternalType} *)Tcl_Alloc(sizeof(${InternalType}));
	    internal->interp = interp;
	    internal->dataPtr = (${DataType} *)${PROC_AllocData}();
	    internal->objPtr = objPtr;
	    internal->hashPtr = NULL;
	    internal->refCount = 0;

	    objPtr->bytes = NULL;
	    objPtr->internalRep.otherValuePtr = internal;
	    objPtr->typePtr = &${ObjType};

	    return objPtr;

	}

	static void ${FreeInternalRepProc}(Tcl_Obj *objPtr)
	{
	    ${InternalType} *internal = (${InternalType} *)objPtr->internalRep.otherValuePtr;
	    ${PROC_ClearData}((${DataType} *)internal->dataPtr);
	    Tcl_Free((char *)internal);
	    objPtr->typePtr = NULL;
	}

	static void ${DupInternalRepProc}(Tcl_Obj *srcPtr, Tcl_Obj *dupPtr)
	{
	    ${InternalType} *internal = (${InternalType} *)srcPtr->internalRep.otherValuePtr;
	    dupPtr->internalRep.otherValuePtr = Tcl_Alloc(sizeof(${InternalType}));
	    ${InternalType} *internal2 = (${InternalType} *)dupPtr->internalRep.otherValuePtr;
	    ${PROC_CopyData}((${DataType} *) internal2->dataPtr,(${DataType} *)internal->dataPtr);
	    dupPtr->typePtr = &${ObjType};
	}

	static void ${UpdateStringProc}(Tcl_Obj *objPtr)
	{
	    char *str;
	    Tcl_Obj *listPtr;
	    ${InternalType} *internal = (${InternalType} *) objPtr->internalRep.otherValuePtr;
	    listPtr = ${PROC_NewObjFromData}(internal->dataPtr);
	    str = Tcl_GetStringFromObj(listPtr, &objPtr->length);
	    objPtr->bytes = Tcl_Alloc(objPtr->length+1);
	    memcpy(objPtr->bytes, str, objPtr->length+1);
	    Tcl_IncrRefCount(listPtr);
	    Tcl_DecrRefCount(listPtr);
	}

	static int  ${SetFromAnyProc}(Tcl_Interp *interp, Tcl_Obj *objPtr)
	{

	    /* TODO: Make sure this works without causing any unwanted side-effects. */
	    /* TODO: this is not quite right - revisit
	     * if (objPtr->typePtr == &${ObjType}) {
	     *	 return TCL_OK;
	     * }
	     */

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

	    ${InternalType} *internal;
	    internal = (${InternalType} *)Tcl_Alloc(sizeof(${InternalType}));
	    internal->interp = interp;
	    internal->dataPtr = ${PROC_AllocData}();

	    objPtr->internalRep.otherValuePtr = internal;
	    objPtr->typePtr = &${ObjType};
	    return ${PROC_GetDataFromObj}(interp,listPtr,internal->dataPtr);

	}


	/***********************************************************************/

	static int ${PROC_RegisterShared} (const char *key, Tcl_Obj *objPtr)
	{
	    Tcl_HashEntry *entryPtr;
	    int refCount, newEntry;

	    Tcl_MutexLock(&${HashTableMutex});
	    refCount = ++objPtr->refCount;
	    entryPtr = Tcl_CreateHashEntry(&${HashTable}, (char*)key /* internal */, &newEntry);
	    if (newEntry) {
		Tcl_SetHashValue(entryPtr, (ClientData)objPtr);
		//internal->hashPtr = entryPtr;
	    }
	    Tcl_MutexUnlock(&${HashTableMutex});

	    /*
	    * DBG(fprintf(stderr, "--> ${PROC_RegisterShared}: ${name} data %p %s "
	     *		"shared table now with refcount of %d\n", objPtr,
	     *		newEntry ? "entered into" : "already in", refCount));
	     */
	    return 0;
	}


	/* see tDOM's tcldom_returnDocumentObj for more details */

	int ${PROC_ReturnHandle} (Tcl_Interp  *interp, Tcl_Obj *objPtr, int setVariable, Tcl_Obj *varNameObj)
	{
	    char        objCmdName[80], *varName;
	    Tcl_CmdInfo cmdInfo;
	    //${InternalType} *internal = (${InternalType} *) objPtr->internalRep.otherValuePtr;

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

	    sprintf((objCmdName), "${HandlePrefix}%p", (objPtr));

	    if (setVariable) {
		varName = Tcl_GetString(varNameObj);
		Tcl_SetVar(interp, varName, objCmdName, 0);
	    }

	    // HERE - FIX: 
	    ${PROC_RegisterShared}(objCmdName,objPtr);



	    /* Set Result */
	    Tcl_ResetResult(interp);
	    Tcl_SetStringObj(Tcl_GetObjResult(interp), (objCmdName), -1);
	    return TCL_OK;
	}

	/***********************************************************************/

	static
	int ${PROC_CreateCmd} (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
	{
	    int         setVariable = 0;
	    Tcl_Obj     *objPtr;
	    Tcl_Obj     *newObjName = NULL;


	    //CheckArgs(2,3,1,"?newObjVar?");

	    if (objc == 2) {
		newObjName = objv[1];
		setVariable = 1;
	    }

	    objPtr = ${PROC_AllocObj}(interp);
	    if (objPtr == NULL) {
		return TCL_ERROR;
	    }

	    return ${PROC_ReturnHandle}(interp, objPtr, setVariable, newObjName);
	}

	static Tcl_Obj *${PROC_GetObjFromHandle}(Tcl_Interp *interp, Tcl_HashTable *ht, Tcl_Obj *objVar)
	{

	    Tcl_Obj *handle = Tcl_ObjGetVar2(interp, objVar, NULL, TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1);
	    Tcl_HashEntry *entryPtr = Tcl_FindHashEntry(ht,(char *)Tcl_GetString(handle));
	    if (entryPtr == NULL) {
		//Tcl_AddErrorInfo(interp,"no such handle");
		return NULL;
	    }
	    return /* Tcl_Obj *objPtr = */ (Tcl_Obj *) Tcl_GetHashValue(entryPtr);

	}

	static
	int ${PROC_SetCmd} (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] )
	{


	    //CheckArgs(2,3,1,"docElemName ?newObjVar?");

	    if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "varName list");
		return TCL_ERROR;
	    }

	    Tcl_Obj *objPtr = (Tcl_Obj *) ${PROC_GetObjFromHandle}(interp, &${HashTable},objv[1]);
	    if (objPtr==NULL) {
		Tcl_AddErrorInfo(interp,"no such handle");
		return TCL_ERROR;
	    }

	    ${InternalType} *internal = (${InternalType} *) objPtr->internalRep.otherValuePtr;

	    if ( objPtr == NULL ) {
		Tcl_AddErrorInfo(interp,"no such object found (objPtr is NULL)");
		return TCL_ERROR;
	    }

	    ${PROC_GetDataFromObj}(interp,objv[2],internal->dataPtr);
	    Tcl_SetObjResult(interp,objPtr);
	    return TCL_OK;

	}

	/*----------------------------------------------------------------------------
	|   Exit Handler: ${PROC_ModuleFinalize}
	|
	|   Activated in application exit handler to delete shared document table
	|   Table entries are deleted by the object command deletion callbacks,
	|   so at this time, table should be empty. If not, we will leave some
	|   memory leaks. This is not fatal, though: we're exiting the app anyway.
	|   This is a private function to this file. 
	\---------------------------------------------------------------------------*/

	static void ${PROC_ModuleFinalize}(ClientData unused)
	{
	    Tcl_MutexLock(&${HashTableMutex});
	    Tcl_DeleteHashTable(&${HashTable});
	    Tcl_MutexUnlock(&${HashTableMutex});
	}

	/*----------------------------------------------------------------------------
	|   Initialize Module
	|   Activated at module load to initialize shared object handles table.
	|   This is exported since we need it in HERE: tdominit.c.
	\---------------------------------------------------------------------------*/


	void ${PROC_InitModule}()
	{
	    Tcl_MutexLock(&${HashTableMutex});
	    if (!${ModuleInitialized}) {
		//Tcl_InitHashTable(&${HashTable}, TCL_ONE_WORD_KEYS);
		Tcl_InitHashTable(&${HashTable}, TCL_STRING_KEYS);
		Tcl_CreateExitHandler(${PROC_ModuleFinalize}, NULL);
		${ModuleInitialized} = 1;
	    }
	    Tcl_MutexUnlock(&${HashTableMutex});
	}


    }



    set init_text [subst -nocommands -nobackslashes {
	${PROC_InitModule}();
	Tcl_CreateObjCommand(ip, "::${name}::create", ${PROC_CreateCmd}, NULL, NULL);
	Tcl_CreateObjCommand(ip, "::${name}::set", ${PROC_SetCmd}, NULL, NULL);
	//Tcl_CreateObjCommand(ip, "::${name}::info", ${PROC_InfoCmd}, NULL, NULL);
	Tcl_RegisterObjType(&${ObjType}); 
    }]
    set init_exts "" ;# externs: see app-critcl/critcl.tcl

    set code [subst -nocommands -nobackslashes $template]
}

proc define_ctype {name cTypeName struct {spec ""}} {

    ctype_template $name $cTypeName $struct $spec code init_text init_exts
    ### START TEST
    #if { ${name} eq {ll_problem} } {
    #return
    #}
    ### END TEST


    ::critcl::cinit $init_text $init_exts
    ::critcl::ccode $code

    #ns_log notice "define_ctype $name: done"
    #ns_log notice "define_ctype $name: done init_text=$init_text code=$code"
    #doc_return 200 text/plain $code
    #return
}





####################


proc ccode_struct_InitData {defs DataType dataPtrName} {
    return "memset(${dataPtrName},0,sizeof(${DataType}));"
}

proc ccode_struct_isIncomplete {defs DataType} {
    #ns_log notice "Checking if DataType=$DataType is incomplete"
    foreach def $defs {
	lassign $def cTypeName varName metadata
	set cTypeNA [string trimright ${cTypeName} {*}]
	if { ${cTypeName} ne ${cTypeNA} } {
	    set ::__INCOMPLETE_STRUCT($DataType) 1
	    return 1
	}
	if { [info exists ::__INCOMPLETE_STRUCT($cTypeNA)] } {
	    set ::__INCOMPLETE_STRUCT($DataType) 1
	    return 1
	}
    }
    return 0
}

proc ccode_struct_CopyDataArea {defs DataType srcName destName PROC_CopyData COPY_AreaSize_varName} {
    # YES - if it contains a pointer or an incomplete struct
    if { [ccode_struct_isIncomplete ${defs} ${DataType}] } {
	return [subst -nocommands -nobackslashes {
	    int i;
	    for(i=0; i<${COPY_AreaSize_varName}; i++) {
		${PROC_CopyData}(&(${destName}[i]), &(${srcName}[i]));
	    }
	}]
    } else {
	return [subst -nocommands -nobackslashes {
	    memcpy(${destName},${srcName}, ${COPY_AreaSize_varName} * sizeof(${DataType}));
	}]
    }
}


proc ccode_struct_CopyData_ByRef {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName srcName destName} {
    upvar ${codeVar} code
    upvar ${templateVar} template
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    array set MD $metadata

    set dimensions [list]
    set left_part  [list]
    set right_part [list]
    lassign [array get MD @size] __key__ dimensions
    #lassign [split [linsert $dimensions $numAsterisks {|}] {|}] left_part right_part
    lassign [split [linsert $dimensions [expr { $numAsterisks - 1}] {|}] {|}] left_part right_part

    #ns_log notice "cTypeNA=$cTypeNA varName=${varName} asterisks=$numAsterisks left_part=$left_part right_part=$right_part"

 
    set indentation "\n"
    set rowIndex "xxx"
    set code_before ""
    set code_after_list [list]
    set dereference ""
    set prevDereference ""
    set dimExpr ""
    set asterisks ""
    set declaration ""

    set iVarList [list]
    set i 0

    foreach dimension [concat $left_part [list [string trim $right_part]]] {
	incr numAsterisks -1 
	set asterisks [string repeat "*" $numAsterisks]

	append indentation "\t"

	set iVar      [format "%c" [expr { 104 + [incr itCount] }]] ;# 105 is the char code for the letter i
	lappend iVarList ${iVar}
	lappend declarations $declaration
	set declaration "int ${iVar};"
 
	set allocType ""
	set allocIf   ""

	lassign [array get MD @allocType($dimension)] __key__ allocType
	lassign [array get MD @allocIf($dimension)] __key__ allocIf

	set dimExprList [::xo::fun::map x ${dimension} { set _ ${srcName}->${x} }]
	set dimExpr [join $dimExprList " * "]
	if { ${allocType} eq {sparse} && ${allocIf} ne {} } {
	    set iMaxVar "${iVar}_max"
	    set allocCond [format ${allocIf} "${srcName}->${varName}${dereference}\[${iMaxVar}\]"]  ;# HERE: to dot or not to dot (i.e. use ->), not sure yet 
	    set dimExpr "(__MIN__(${dimExpr},1+${iMaxVar}))" ;# +1 in order to include the mark node, e.g. (-1,?) for feature nodes
 
	    lappend declarations "int ${iMaxVar};"
	    append code_before "${indentation} ${iMaxVar}=0; while (${allocCond}) { ${iMaxVar}++; };"
	    lappend code_after_list $code_after
	}



	append code ${code_before}
	append code "${indentation} ${destName}->${varName}${dereference} = (${cTypeNA}*${asterisks}) Tcl_Alloc(${dimExpr} * sizeof(${cTypeNA}${asterisks}));"
	set prevDereference $dereference
	append dereference "\[${iVar}\]"
	set code_before "${indentation} for(${iVar}=0; ${iVar} < ${dimExpr}; ${iVar}++) \{"
	set code_after "${indentation} \}" 
	incr i 
    }

    set srcPtr  "${srcName}->${varName}${prevDereference}"
    set destPtr "${destName}->${varName}${prevDereference}"

    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} ${dereference} ${asterisks}] 
    append code [join [lreverse $code_after_list]]


}

proc ccode_struct_CopyData_ByVal {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName srcName destName} {
    upvar ${codeVar} code
    upvar ${templateVar} template

    set indentation "\n\t"
    set srcPtr  "&(${srcName}->${varName})"
    set destPtr "&(${destName}->${varName})"
    set dimExpr "1"
    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} "/* no dereference */" "/* no asterisks */"] 
}

proc ccode_struct_CopyData_Template {codeVar declarationsVar metadataVar cTypeName varName srcName destName} {
    upvar ${codeVar} code
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    set cTypeNA [string trimright ${cTypeName} {*}]
    set numAsterisks [expr { [string length ${cTypeName}] - [string length ${cTypeNA}] }]

    set ObjType [ccode_ctype_ObjType ${cTypeNA}]

    set indentFmt {%1$s}
    set commentFmt {%2$-20s}
    set objTypeFmt {%3$s}
    set cTypeNAFmt {%4$s}
    set varNameFmt {%5$-12s}
    set srcFmt {%6$s}
    set destFmt {%7$s}
    set dimExprFmt {%8$s}
    set dereferenceFmt {%9$s}
    set asterisksFmt {%10$s}
    set iVarFmt {%11$s}


    set template ""
    if { ${ObjType} ne {} } {
	#append template "${indentFmt} Ns_Log(Notice,\"calling ${ObjType}_CopyData\");"
	append template "${indentFmt} ${ObjType}_CopyData_Area(${destFmt},${srcFmt},${dimExprFmt});"
    } else {
	#append template "${indentFmt} Ns_Log(Notice,\"memcpy from ${srcFmt} to ${destFmt} \");"
	append template "${indentFmt} memcpy(${destFmt}, ${srcFmt}, ${dimExprFmt} * sizeof(${cTypeNA}${asterisksFmt}));" ;# might give us trouble
    }
 
    if { ${numAsterisks} > 0 } {
	ccode_struct_CopyData_ByRef code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${srcName} ${destName}
    } else {
	ccode_struct_CopyData_ByVal code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${srcName} ${destName}
    }
}

proc ccode_struct_CopyData {defs srcName destName} {

    set itCount 0
    set declarations ""

    set __CODE__ ""
    ####

    set prefix1 "${srcName}->"
    set prefix2 "${destName}->"

    set i -1
    foreach def $defs {
	incr i
	lassign $def cTypeName varName metadata
	array unset MD
	array set MD $metadata

	switch -exact -- $cTypeName {
	    long   -
	    short  -
	    int    -
	    float  -
	    double  { append __CODE__ "\n\t ${destName}->${varName}=${srcName}->${varName};" }
	    string -
	    char*   { 
		# HERE: we need to memcpy here, the line below is WRONG
		append __CODE__ "\n\t ${prefix2}${varName}=${prefix1}${varName};" 
		####append __CODE__ "\n\t memcpy(${destName}->${varName},${srcName}->${varName},-1);
	    }
	    default {

		ccode_struct_CopyData_Template __CODE__ declarations metadata $cTypeName $varName $srcName $destName

	    }
	}

	if {0} {
	    if { [string index $cTypeName end] ne {*} && ![string match "struct*" $cTypeName] } {
		append code "\n\t    [subst {Ns_Log(Notice,"copy data %d: %s (from)",$i,Tcl_GetString(Tcl_NewDoubleObj(${prefix1}${varName})));}]"
		append code "\n\t    [subst {Ns_Log(Notice,"copy data %d: %s (to)",$i,Tcl_GetString(Tcl_NewDoubleObj(${prefix2}${varName})));}]"
	    } else {
		append code "\n\t    [subst {Ns_Log(Notice,"copy data %d",$i);}]"
	    }
	}

    }

    # HERE: ns_log notice "\n\n CopyData __CODE__ =\n\t[join [lsort -unique $declarations] \n\t]\n${__CODE__} \n\n"

    append code "[join [lsort -unique $declarations] \n\t]"
    append code "\n\t${__CODE__}"

    return ${code}

}



####################### GetDataFromObj


proc ccode_struct_GetDataFromObj_ByRef {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName objName dataName} {

    upvar ${codeVar} code
    upvar ${templateVar} template
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    array set MD $metadata

    set dimensions [list]
    set left_part  [list]
    set right_part [list]
    lassign [array get MD @size] __key__ dimensions
    lassign [split [linsert $dimensions [expr { $numAsterisks - 1}] {|}] {|}] left_part right_part

    #ns_log notice "cTypeNA=$cTypeNA varName=${varName} asterisks=$numAsterisks left_part=$left_part right_part=$right_part"

 
    set indentation "\n"
    set code_before ""
    set code_after "\n\t \}"
    set code_after_list [list]
    set dereference ""
    set prevDereference ""
    set dimExpr ""
    set asterisks ""
    set declarationList ""

    set itCount 0
    set iNextObjName ${objName}_L${itCount}
    foreach dimensionList [concat $left_part [list [string trim $right_part]]] {
	incr numAsterisks -1 
	set asterisks [string repeat "*" $numAsterisks]

	set dimExprList [::xo::fun::map x ${dimensionList} { set _ ${dataName}->${x} }]
	set dimExpr [join $dimExprList " * "]

	#append code_before "${indentation}\t /* varName=${varName} dimensionList=$dimensionList */"
	append code_before "${indentation}\t ${dataName}->${varName}${dereference} = (${cTypeNA}*${asterisks}) Tcl_Alloc(${dimExpr} * sizeof(${cTypeNA}${asterisks}));"

	set i 0
	set iVarList [list]
	foreach dimension $dimensionList { 
	    
	    append indentation "\t"
	    lappend code_after_list $code_after ;# TODO: this is most likely need in CopyData too

	    set iObjName ${objName}_L${itCount}	    
	    set iVar      [format "%c" [expr { 104 + [incr itCount] }]] ;# 105 is the char code for the letter i
	    set iLLengthVar "llength_${iVar}"

	    set iNextObjName ${objName}_L${itCount}
	    lappend iVarList ${iVar}

	    lappend declarations "int ${iVar};" 
	    lappend declarations "Tcl_Obj *${iObjName};"
	    lappend declarations "Tcl_Obj *${iNextObjName};"
	    lappend declarations "int ${iLLengthVar};"

	    set allocType ""
	    set allocIf   ""

	    lassign [array get MD @allocType($dimension)] __key__ allocType
	    lassign [array get MD @allocIf($dimension)] __key__ allocIf

	    if { ${allocType} eq {sparse} && ${allocIf} ne {} } {
		# TODO: add mark node, e.g. for feature_node we would have an extra node of the form (-1,?)
		append code_before "${indentation} if (Tcl_ListObjLength(interp, ${iObjName}, &${iLLengthVar}) != TCL_OK) { return TCL_ERROR; }"
		set dimExpr ${iLLengthVar}

		#set loopTerminateTest "((${iVar} < ${dimExpr}) && (${dimExpr} >= ${iLLengthVar}))"
	    } else {
		set dimExpr [lindex $dimExprList $i]
		append code_before "${indentation} if (Tcl_ListObjLength(interp, ${iObjName}, &${iLLengthVar}) != TCL_OK) { return TCL_ERROR; }"

		#set loopTerminateTest "((${iVar} < ${dimExpr}) && (${dimExpr} == ${iLLengthVar}))"
	    }


	    append code ${code_before}

	    set prevDereference $dereference
	    set code_before ""
	    append code_before "${indentation} for(${iVar}=0; ${iVar} < ${dimExpr}; ${iVar}++) \{"

	    # debugging
	    append code_before "\n Ns_Log(Notice,\"$varName $iVar = %d ${dimExpr} = %d\",${iVar},${dimExpr});"

	    append code_before "${indentation}\t Tcl_ListObjIndex(interp, ${iObjName}, ${iVar}, (Tcl_Obj **)&${iNextObjName});"

	    append code_before "\n Ns_Log(Notice,\"${iNextObjName}=%s \", Tcl_GetString(${iNextObjName}));"

	    set code_after "${indentation}\t \}" 
	    incr i 
	}

	### Start of dereference code that generates an index from iVarList and dimExprList
	set indexList ""
	set llen [llength ${iVarList}]
	for {set k 0} {$k < [expr { $llen - 1 }] } {incr k} {
	    set multiplier [lindex ${iVarList} $k]
	    for { set l [expr {1+$k}] } { $l < $llen } {incr l} {
		lappend multiplier "([lindex ${dimExprList} $l])"
	    }
	    lappend indexList "([join ${multiplier} " * "])"
	}
	lappend indexList ${iVar}
	set index [join ${indexList} " + "]
	append dereference "\[${index}\]"
	### End of dereference code

    }

    set srcPtr  "${iNextObjName}"
    set destPtr "${dataName}->${varName}${dereference}"

    append indentation "\t"
    append code ${code_before}
    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} ${dereference} ${asterisks}] 
    append code [join [lreverse $code_after_list]]


}


proc ccode_struct_GetDataFromObj_ByVal {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName objName dataName} {
    upvar ${codeVar} code
    upvar ${templateVar} template

    set iNextObjName ${objName}_L0
    set indentation "\n\t"
    set srcPtr  "${iNextObjName}"
    set destPtr "${dataName}->${varName}"
    set dimExpr "1"
    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} "/* no dereference */" "/* no asterisks */"] 
}



proc ccode_struct_GetDataFromObj_Template {codeVar declarationsVar metadataVar cTypeName varName objName dataName} {
    upvar ${codeVar} code
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    set cTypeNA [string trimright ${cTypeName} {*}]
    set numAsterisks [expr { [string length ${cTypeName}] - [string length ${cTypeNA}] }]

    set ObjType [ccode_ctype_ObjType ${cTypeNA}]

    set indentFmt {%1$s}
    set listFmt {%2$s}
    set srcFmt {%6$s}
    set destFmt {%7$s}
    set tmpFmt {%10$s}

    set template ""
    if { ${ObjType} ne {} } {

	set HashTable             "${ObjType}_HashTable"
	set InternalType          "${ObjType}_InternalType"
	set PROC_CopyData         "${ObjType}_CopyData"
	set PROC_GetObjFromHandle "${ObjType}_GetObjFromHandle"
	set PROC_GetDataFromObj   "${ObjType}_GetDataFromObj"

	array set MD $metadata
	lassign [array get MD @input] __key__ input

	# check metadata to see whether we'll accept handles for this struct member
	if { ${input} eq {inline} } {
	    # get the data from listptr, ???
	    append template "${indentFmt} Ns_Log(Notice,\"${ObjType} inline=%%s\",Tcl_GetString(${srcFmt}));"
	    append template "${indentFmt} ${PROC_GetDataFromObj}(interp,${srcFmt},&(${destFmt}));" ;# HERE 
	} else {

	    # get object from handle, then get the data
	    lappend declarations "Tcl_Obj *tmpObjPtr;"
	    append template "${indentFmt} tmpObjPtr = ${PROC_GetObjFromHandle}(interp,&${HashTable},${srcFmt});"
	    append template "${indentFmt} ${InternalType} *internal = (${InternalType} *) tmpObjPtr->internalRep.otherValuePtr;"
	    append template "${indentFmt} ${PROC_CopyData}(&(${destFmt}),internal->dataPtr);"
	}





    } else {
	append template "${indentFmt} Tcl_Get[string totitle ${cTypeNA}]FromObj(interp,${srcFmt},&(${destFmt}));" ;# might give us trouble
    }
 
    if { ${numAsterisks} > 0 } {
	ccode_struct_GetDataFromObj_ByRef code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${objName} ${dataName}
    } else {
	#append code "/* $template */"
	ccode_struct_GetDataFromObj_ByVal code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${objName} ${dataName}
    }
}





proc ccode_struct_GetDataFromObj {defs objName dataName} {

    set code ""
    set objNamePrefix "${objName}_Elem"
    set declarations [list]
    lappend declarations "Tcl_Obj *${objNamePrefix}_L0;"

    set numDefs [llength $defs]
    append code [ccode_llength_check declarations ${objName} ${numDefs}] ;# rename this proc to CheckArgs

    set i -1
    set maxIteratorCount 0
    foreach def $defs {
	incr i
	set iteratorCount 0
	set clear_code ""
	set ObjType ""
	lassign $def cTypeName varName metadata


	append code "\n\n\t    /* $cTypeName $varName */"
	append code "\n\t    Ns_Log(Notice,\"getting $cTypeName $varName\");"
	append code "\n\t    Tcl_ListObjIndex(interp, ${objName}, $i, (Tcl_Obj **)&${objNamePrefix}_L0);"
	append code "\n\t    Ns_Log(Notice,\"${varName} ${objNamePrefix}_L0 = %s\", Tcl_GetString(${objNamePrefix}_L0));"

	switch -exact -- $cTypeName {
	    long    { append code "\n\t    Tcl_GetLongFromObj(interp,${objNamePrefix}_L0,&(${dataName}->${varName}));" } 
	    short -
	    int     { append code "\n\t    Tcl_GetIntFromObj(interp,${objNamePrefix}_L0,&(${dataName}->${varName}));" }
	    float -
	    double  { append code "\n\t    Tcl_GetDoubleFromObj(interp,${objNamePrefix}_L0,&(${dataName}->${varName}));" }
	    string -
	    char*   { append code "\n\t    ${dataName}->${varName}=Tcl_GetString(${objNamePrefix}_L0);" }
	    default {

		ccode_struct_GetDataFromObj_Template code declarations metadata $cTypeName $varName $objNamePrefix $dataName
	    }
	}
    }

    set result ""
    append result "\n\t"
    append result [join [lsort -unique ${declarations}] "\n\t"]
    append result "\n"
    append result ${code}

    #ns_log notice "\n\n GetDataFromObj code = \n $result \n\n"
    return ${result}

}






############################## NewObjFromData



proc ccode_struct_NewObjFromData_ByRef {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName objName dataName} {

    upvar ${codeVar} code
    upvar ${templateVar} template
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    array set MD $metadata

    set dimensions [list]
    set left_part  [list]
    set right_part [list]
    lassign [array get MD @size] __key__ dimensions
    lassign [split [linsert $dimensions [expr { $numAsterisks - 1}] {|}] {|}] left_part right_part

    #ns_log notice "cTypeNA=$cTypeNA varName=${varName} asterisks=$numAsterisks left_part=$left_part right_part=$right_part"

 
    set indentation "\n"
    set code_before ""
    set code_after "\n\t \}"
    set code_after_list [list]
    set dereference ""
    set prevDereference ""
    set dimExpr ""
    set asterisks ""
    set declarationList ""

    set itCount 0
    set iNextObjName ${objName}_L${itCount}
    append code_after "${indentation}\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName}, ${iNextObjName});"
    foreach dimensionList [concat $left_part [list [string trim $right_part]]] {
	incr numAsterisks -1 
	set asterisks [string repeat "*" $numAsterisks]

	set dimExprList [::xo::fun::map x ${dimensionList} { set _ ${dataName}->${x} }]
	set dimExpr [join $dimExprList " * "]

	#append code_before "${indentation}\t /* varName=${varName} dimensionList=$dimensionList */"
	#append code_before "${indentation}\t ${dataName}->${varName}${dereference} = (${cTypeNA}*${asterisks}) Tcl_Alloc(${dimExpr} * sizeof(${cTypeNA}${asterisks}));"

	set i 0
	set iVarList [list]
	foreach dimension $dimensionList { 
	    
	    append indentation "\t"
	    lappend code_after_list $code_after ;# TODO: this is most likely need in CopyData too

	    set iObjName ${objName}_L${itCount}	    
	    set iVar      [format "%c" [expr { 104 + [incr itCount] }]] ;# 105 is the char code for the letter i
	    set iLLengthVar "llength_${iVar}"

	    set iNextObjName ${objName}_L${itCount}
	    lappend iVarList ${iVar}

	    lappend declarations "int ${iVar};" 
	    lappend declarations "Tcl_Obj *${iObjName};"
	    #lappend declarations "Tcl_Obj *${iNextObjName};"
	    lappend declarations "int ${iLLengthVar};"

	    set allocType ""
	    set allocIf   ""

	    lassign [array get MD @allocType($dimension)] __key__ allocType
	    lassign [array get MD @allocIf($dimension)] __key__ allocIf

	    append code_before "${indentation} ${iObjName} = Tcl_NewListObj(0,NULL);"


	    if { ${allocType} eq {sparse} && ${allocIf} ne {} } {
		# TODO: add mark node, e.g. for feature_node we would have an extra node of the form (-1,?)
		#append code_before "${indentation} if (Tcl_ListObjLength(NULL, ${iObjName}, &${iLLengthVar}) != TCL_OK) { return TCL_ERROR; }"
		#set dimExpr ${iLLengthVar}

		# minus one because we want to keep the terminal node in our data
		set allocCond [format ${allocIf} "${dataName}->${varName}${dereference}\[${iVar} - 1 \]"]  ;# HERE: to dot or not to dot (i.e. use ->), not sure yet 
		#set dimExpr "(__MIN__(${dimExpr},1+${iMaxVar}))" ;# +1 in order to include the mark node, e.g. (-1,?) for feature nodes

		set loopTerminateTest " (${iVar} < ${dimExpr}) && ( ${allocCond} )"
	    } else {
		set dimExpr [lindex $dimExprList $i]
		set loopTerminateTest "${iVar} < ${dimExpr}"
	    }


	    append code ${code_before}

	    set prevDereference $dereference
	    set code_before "${indentation} for(${iVar}=0; ${loopTerminateTest}; ${iVar}++) \{"

	    # debugging
	    #append code_before "\n Ns_Log(Notice,\"$iVar = %d\",${iVar});"

	    #append code_before "${indentation}\t Tcl_ListObjIndex(NULL, ${iObjName}, ${iVar}, (Tcl_Obj **)&${iNextObjName});"

	    #append code_before "\n Ns_Log(Notice,\"${iObjName}=%s \", Tcl_GetString(${iObjName}));"

	    set code_after "${indentation}\t \}"
	    append code_after "${indentation}\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${iObjName}, ${iNextObjName});"

	    incr i 
	}

	### Start of dereference code that generates an index from iVarList and dimExprList
	set indexList ""
	set llen [llength ${iVarList}]
	for {set k 0} {$k < [expr { $llen - 1 }] } {incr k} {
	    set multiplier [lindex ${iVarList} $k]
	    for { set l [expr {1+$k}] } { $l < $llen } {incr l} {
		lappend multiplier "([lindex ${dimExprList} $l])"
	    }
	    lappend indexList "([join ${multiplier} " * "])"
	}
	lappend indexList ${iVar}
	set index [join ${indexList} " + "]
	append dereference "\[${index}\]"
	### End of dereference code

    }


    set srcPtr "${dataName}->${varName}${dereference}"
    set destPtr  "${iObjName}"

    append indentation "\t"
    append code ${code_before}
    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} ${dereference} ${asterisks}] 

    append code [join [lreverse $code_after_list]]


}



proc ccode_struct_NewObjFromData_ByVal {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName objName dataName} {
    upvar ${codeVar} code
    upvar ${templateVar} template

    set indentation "\n\t"
    set srcPtr "${dataName}->${varName}"
    set destPtr  "${objName}"
    set dimExpr "1"
    append code [format $template ${indentation} "/* no comment */" ${ObjType} ${cTypeNA} ${varName} ${srcPtr} ${destPtr} ${dimExpr} "/* no dereference */" "/* no asterisks */"] 
}



proc ccode_struct_NewObjFromData_Template {codeVar declarationsVar metadataVar cTypeName varName objName dataName} {
    upvar ${codeVar} code
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    set cTypeNA [string trimright ${cTypeName} {*}]
    set numAsterisks [expr { [string length ${cTypeName}] - [string length ${cTypeNA}] }]

    set ObjType [ccode_ctype_ObjType ${cTypeNA}]

    set indentFmt {%1$s}

    set srcFmt {%6$s}
    set destFmt {%7$s}
    set tmpFmt {%10$s}

    set template ""
    if { ${ObjType} ne {} } {
	set PROC_NewObjFromData   "${ObjType}_Tcl_Obj"
	append template "${indentFmt} Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${destFmt}, ${PROC_NewObjFromData}(&(${srcFmt})));"
    } else {
	set Tcl_ObjProc "Tcl_New[string totitle [string trimright ${cTypeName} {*}]]Obj" ;# might give us trouble
	append template "${indentFmt} Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${destFmt}, ${Tcl_ObjProc}(${srcFmt}));"
    }
 
    if { ${numAsterisks} > 0 } {
	ccode_struct_NewObjFromData_ByRef code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${objName} ${dataName}
    } else {
	#append code "/* $template */"
	ccode_struct_NewObjFromData_ByVal code template declarations metadata ${ObjType} ${cTypeNA} ${numAsterisks} ${varName} ${objName} ${dataName}
    }
}





proc ccode_struct_NewObjFromData {defs dataName objName} {

    set code ""
    set objNamePrefix "${objName}_Elem"
    set declarations [list]
    lappend declarations "Tcl_Obj *${objName} = Tcl_NewListObj(0,NULL);"

    set i -1
    set maxIteratorCount 0
    foreach def $defs {
	incr i
	set iteratorCount 0
	set clear_code ""
	set ObjType ""
	lassign $def cTypeName varName metadata
	array unset MD
	array set MD $metadata

	append code "\n\n\t /* $cTypeName $varName */"
	#append code "\n\t    Ns_Log(Notice,\"getting $cTypeName $varName\");"
	#append code "\n\t    Tcl_ListObjIndex(NULL, ${objName}, $i, (Tcl_Obj **)&${objNamePrefix}_L0);"

	switch -exact -- $cTypeName {
	    long    { append code "\n\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName}, Tcl_NewLongObj(${dataName}->${varName}));" } 
	    short -
	    int     { append code "\n\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName}, Tcl_NewIntObj(${dataName}->${varName}));" }
	    float -
	    double  { append code "\n\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName}, Tcl_NewDoubleObj(${dataName}->${varName}));" }
	    string -
	    char*   { append code "\n\t Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName}, Tcl_NewStringObj(${dataName}->${varName}));" }
	    default {

		ccode_struct_NewObjFromData_Template code declarations metadata $cTypeName $varName $objName $dataName

	    }
	}
    }

    set result ""
    append result "\n\t"
    append result [join [lsort -unique ${declarations}] "\n\t"]
    append result "\n"
    append result ${code}
    append result "\n\n\t return ${objName}; /* listPtr */"

    #ns_log notice "\n\n NewObjFromData code = \n $result \n\n"
    return ${result}

}


