
proc ccode_struct_NewObjFromData_OLD {defs objName1 objName2} {
    set elemName ${objName1}_elem
    set elemName2 ${objName1}_elem2

    append code "\n\t    Tcl_Obj *${elemName};"
    append code "\n\t    Tcl_Obj *${elemName2};"
    append code "\n\t    Tcl_Obj *${objName2} = Tcl_NewListObj(0,NULL);"
    set prefix "${objName1}->"

    set maxIteratorCount 0
    foreach def $defs {
	set dereference ""
	set iteratorCount 0
	set clear_code ""
	lassign $def cTypeName varName metadata
	array unset MD
	array set MD $metadata

	append code "\n\t    /* $cTypeName $varName */"
	switch -exact -- $cTypeName {
	    long    { append code "\n\t    ${elemName}=Tcl_NewLongObj(${prefix}${varName});" } 
	    short -
	    int     { append code "\n\t    ${elemName}=Tcl_NewIntObj(${prefix}${varName});" }
	    float -
	    double  { append code "\n\t    ${elemName}=Tcl_NewDoubleObj(${prefix}${varName});" }
	    default {


		if { [info exists ::__CTYPE([string trimright $cTypeName {*}])] } {
		    set ObjType $::__CTYPE([string trimright $cTypeName {*}])
		    set Tcl_NewObjProc    "${ObjType}_Tcl_NewObj"
		    set GetDataTemplate "%s%s=${Tcl_NewObjProc}(&(%s));"
		} else {
		    set Tcl_NewObjProc "Tcl_New[string totitle [string trimright ${cTypeName} {*}]]Obj" ;# might give us trouble
		    set GetDataTemplate "%s%s=${Tcl_NewObjProc}(%s);"
		}


		set numAsterisks [expr { [string length ${cTypeName}] - [string length [string trimright ${cTypeName} {*}]] }]
		if { ${numAsterisks} > 0 } {
		    if { [info exists MD(@size)] } {
			set indexListT1 [list]
			set indexListT2 [list]
			set tabs "\t"
			set before_code "\n\t    ${elemName} = Tcl_NewListObj(0,NULL);"
			set after_code ""
			foreach dimension $MD(@size) {
			    set iVar [format "%c" [expr { 104+[incr iteratorCount] }]]
			    append tabs "    "
			    lappend indexListT1 "${iVar}"
			    #lappend indexListT2 "${iVar}*${prefix}${dimension}"
			    lappend indexListT2 "${prefix}${dimension}"



			    ###
			    set allocType ""
			    set allocIf   ""

			    lassign [array get MD @allocType($dimension)] __key__ allocType
			    lassign [array get MD @allocIf($dimension)] __key__ allocIf
			    ###

			    if { ${allocType} eq {sparse} && ${allocIf} ne {} } {
				set srcName ${objName1}
				set allocCond [format ${allocIf} "${srcName}->${varName}${dereference}\[${iVar}\]"]  ;# HERE: to dot or not to dot (i.e. use ->), not sure yet 
				set loopTerminateTest " (${iVar} < ${prefix}${dimension}) && ( ${allocCond} )"
			    } else {
				set loopTerminateTest " ${iVar} < ${prefix}${dimension} "
			    }

			    append before_code "\n${tabs}for( ${iVar}=0; ${loopTerminateTest}; ${iVar}++) \{"
			    set after_code "\n${tabs}\}${after_code}"
			    append dereference "\[${iVar}\]"

			}
			append tabs "    "
			if { 1 == ${numAsterisks} } {

			    set indexList ""
			    set llen [llength $indexListT1]
			    for {set k 0} {$k < [expr { $llen - 1 }] } {incr k} {
				set multiplier [lindex $indexListT1 $k]
				for { set l [expr {1+$k}] } { $l < $llen } {incr l} {
				    lappend multiplier "( [lindex $indexListT2 $l] )"
				}
				lappend indexList "( [join $multiplier " * "] )"
			    }
			    set index [join [concat $indexList $iVar] " + "]

			    #lset indexListT2 end $iVar
			    #set index [join $indexListT2 " + "]
			} else {
			    set index [join $indexListT1 "\]\["]
			}
			append code "${before_code}"
			append code [format ${GetDataTemplate} "\n${tabs}" "${elemName2}" "${prefix}${varName}\[${index}\]"]
			append code "\n${tabs}Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${elemName}, ${elemName2});"
			append code ${after_code}
		    } else {
			append code [format $GetDataTemplate "\n\t    " ${elemName} ${prefix}${varName}]
		    }
		} else {
		    append code [format $GetDataTemplate "\n\t    " ${elemName} ${prefix}${varName}]
		}

	    }
	}
	if { $maxIteratorCount < $iteratorCount } {
	    set maxIteratorCount $iteratorCount
	}

	append code "\n\t    Tcl_ListObjAppendElement(NULL, (Tcl_Obj *) ${objName2}, ${elemName});\n"
    }
    append code "\n\t    return ${objName2}; /* listPtr */"

    set iteratorVars ""
    while { $maxIteratorCount > 0 } {
	append iteratorVars "\n\t    int [format "%c" [expr { 104 + ${maxIteratorCount} }]];"
	incr maxIteratorCount -1
    }

    return "${iteratorVars}\n\t    ${code}"

}


proc ccode_struct_GetDataFromObj {defs objName dataName} {

    set prefix "${dataName}->"
    set elemName "${objName}_Elem"
    set elemName2 "${objName}_Elem2"
    set elemNameCount "${elemName}_Count"
    set objNameCount "${objName}_Count"

    set declarations [list]
    lappend declarations "Tcl_Obj *${elemName};"
    lappend declarations "Tcl_Obj *${elemName2};"

    set numDefs [llength $defs]
    append code [ccode_llength_check declarations ${objName} ${numDefs}]


    set __CODE__ ""
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

	append code "\n\n\t    /* $cTypeName $varName */"
	append code "\n\t    Tcl_ListObjIndex(interp, ${objName}, $i, (Tcl_Obj **)&${elemName});"

	switch -exact -- $cTypeName {
	    long    { append code "\n\t    Tcl_GetLongFromObj(interp,${elemName},&(${prefix}${varName}));" } 
	    short -
	    int     { append code "\n\t    Tcl_GetIntFromObj(interp,${elemName},&(${prefix}${varName}));" }
	    float -
	    double  { append code "\n\t    Tcl_GetDoubleFromObj(interp,${elemName},&(${prefix}${varName}));" }
	    string -
	    char*   { append code "\n\t    ${prefix}${varName}=Tcl_GetString(${elemName});" }
	    default {

		ccode_struct_GetDataFromObj_Template __CODE__ declarations metadata $cTypeName $varName $elemName $dataName


		if { [info exists ::__CTYPE([string trimright $cTypeName {*}])] } {
		    set ObjType $::__CTYPE([string trimright $cTypeName {*}])
		    set HashTable "${ObjType}_HashTable"
		    set PROC_GetObjFromHandle "${ObjType}_GetObjFromHandle"
		    set PROC_GetDataFromObj "${ObjType}_GetObjFromHandle"
		    #set PutDataTemplate "\n\t    %s \n\t    ${elemName2} = ${ObjType}_GetObjFromHandle(interp,&${HashTable},%s);\n\t    ${ObjType}_GetDataFromObj(interp, ${elemName2}, /* ([string trimright ${cTypeName} {*}] *) */ %s);"
		    # THIS WORKS BUT THIS IS NOT WHAT WE WANT HERE, SEE COMMENT IN ccode_llength_check
		    #set PutDataTemplate "\n\t    %s \n\t    ${elemName2} = ${ObjType}_GetObjFromHandle(interp,&${HashTable},%s);\n\t    ${ObjType}_GetDataFromObj(interp, Tcl_NewStringObj(Tcl_GetString(${elemName2}),-1), /* ([string trimright ${cTypeName} {*}] *) */ %s);Ns_Log(Notice,\"structure copied\");"


		    set preStrFmt {%1$s}
		    set handleFmt {%2$s}
		    set copyPtrFmt {%3$s}

		    set PutDataTemplate ""

		    append PutDataTemplate "\n\t    ${preStrFmt} \n\t    ${elemName2} = ${ObjType}_GetObjFromHandle(interp,&${HashTable},${handleFmt});"
		    #append PutDataTemplate "\n\t    ${ObjType}_GetDataFromObj(interp, ${elemName2}, %s);"
		    # THE FOLLOWING WORKS BUT THIS IS NOT WHAT WE WANT HERE - this comment refers to the param in the model structure
		    #append PutDataTemplate "\n\t    ${ObjType}_GetDataFromObj(interp, Tcl_NewStringObj(Tcl_GetString(${elemName2}),-1), %s);"
		    #append PutDataTemplate "Ns_Log(Notice,\"structure copied ok\");"
		    append PutDataTemplate {Ns_Log(Notice,"before internal");}
		    append PutDataTemplate "\n\t    ${ObjType}_InternalType *internal = (${ObjType}_InternalType *) ${elemName2}->internalRep.otherValuePtr;"
		    append PutDataTemplate {Ns_Log(Notice,"after internal and before copy data:");}
		    append PutDataTemplate "\n\t    ${ObjType}_CopyData(${copyPtrFmt},internal->dataPtr);"
		    append PutDataTemplate {Ns_Log(Notice,"after copy data - HERE TODO FIX:");}
		} else {
		    set PutDataTemplate "%sTcl_Get[string totitle [string trimright ${cTypeName} {*}]]FromObj(interp,%s,%s);" ;# might give us trouble
		    #set PutDataTemplate "%s /*%s*/ %s = 1234;"
		}

		set numAsterisks [expr { [string length ${cTypeName}] - [string length [string trimright ${cTypeName} {*}]] }]
		if { ${numAsterisks} > 0 } {

		    if { [info exists MD(@size)] } {
			set indexListT1 [list]
			set indexListT2 [list]
			set tabs "\t"
			set before_code ""
			set after_code ""

			foreach dimension $MD(@size) {
			    set iVar [format "%c" [expr { 104+[incr iteratorCount] }]]
			    append tabs "    "
			    lappend indexListT1 "${iVar}"
			    #lappend indexListT2 "${iVar}*(${prefix}${dimension} - 1)"
			    lappend indexListT2 "${prefix}${dimension}"

			    append before_code "\n${tabs}for(${iVar}=0; ${iVar} < ${prefix}${dimension}; ${iVar}++) \{"
			    set after_code "\n${tabs}\}${after_code}"
			}
			append tabs "    "
			if { 1 == ${numAsterisks} } {
			    set indexList ""
			    set llen [llength $indexListT1]
			    for {set k 0} {$k < [expr { $llen - 1 }] } {incr k} {
				set multiplier [lindex $indexListT1 $k]
				for { set l [expr {1+$k}] } { $l < $llen } {incr l} {
				    lappend multiplier "( [lindex $indexListT2 $l] )"
				}
				lappend indexList "( [join $multiplier " * "] )"
			    }
			    set index "[join $indexList " + "] + $iVar"
			    #lset indexListT2 end $iVar
			    #set index [join $indexListT2 " + "]
			} else {
			    set index [join $indexListT1 "\]\["]
			}

			set numElements [get_array_max_dim $MD(@size) $prefix]

			append before_code "\n${tabs}Tcl_ListObjIndex(interp, ${elemName}, ${index}, &${elemName2});"
			append code "\n"
			append code [ccode_llength_check declarations ${elemName} $numElements]
			append code "\n\t    ${prefix}${varName} = (${cTypeName})Tcl_Alloc((${numElements})*sizeof([string trimright ${cTypeName} {*}]));"
			append code ${before_code}
			append code "\n\t    [subst {Ns_Log(Notice,"index=%d <- [string repeat { %d } [llength $indexListT1]]",${index},[join ${indexListT1} {,}]);}]"
			append code [format ${PutDataTemplate} "\n${tabs}" "${elemName2}" "&(${prefix}${varName})\[${index}\]"]
			append code ${after_code}

		    } else {
			append code "\n\t    [format ${PutDataTemplate} "" "${elemName}" "${prefix}${varName}"]"
		    }
		} else {
		    append code "\n\t    [format ${PutDataTemplate} "" "${elemName}" "&(${prefix}${varName})"]"
		    #if { $ObjType eq {ll_parameter}} {
		    #	append code "Ns_Log(Notice,\"%s eps=%f\",Tcl_GetString(${ObjType}_Tcl_NewObj(& ${prefix}${varName})),(&${prefix}${varName})->eps);"
		    #}
		}
	    }



	}
	if { $maxIteratorCount < $iteratorCount } {
	    set maxIteratorCount $iteratorCount
	}

    }

    while { $maxIteratorCount > 0 } {
	#iteratorVars
	lappend declarations "int [format "%c" [expr { 104 + ${maxIteratorCount} }]];"
	incr maxIteratorCount -1
    }

    set result ""
    append result "\n\t"
    append result [join [lsort -unique ${declarations}] "\n\t"]
    append result "\n"
    append result ${code}

    ns_log notice "\n\n GetDataFromObj __CODE__ = \n $__CODE__ \n\n"
    return ${result}

}

proc ccode_struct_InitData {defs DataType dataPtrName} {

    return "memset(${dataPtrName},0,sizeof(${DataType}));"

    if {0} {
	set prefix "${dataPtrName}->"
	set code ""
	foreach def $defs {
	    set init_value ""
	    lassign $def cTypeName varName metadata
	    
	    switch -exact -- $cTypeName {
		
		short -
		long -
		int     { set init_value "0" }
		
		float -
		double  { set init_value "0.0" }
		
		default { set init_value "NULL" }
	    }
	    
	    if { [info exists ::__CTYPE([string trim $cTypeName {*}])] && [string index $cTypeName end] ne {*} } {
		set well_known_name $::__CTYPE([string trim $cTypeName {*}])
		set InitDataProc    "${well_known_name}_InitData"
		append code "\n\t    ${InitDataProc}(&${prefix}${varName});" ;# note the ambersand/address
	    } else {
		append code "\n\t    ${prefix}${varName} = ${init_value};          /* ${cTypeName} */"
	    }
	}
	return $code
    }
}

proc ccode_struct_CopyData {defs dataName1 dataName2} {
    set srcName $dataName1
    set destName $dataName2

    set itCount 0
    set declarations ""

    set TEST_code ""
    ####

    set prefix1 "${dataName1}->"
    set prefix2 "${dataName2}->"

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
	    double  { append code "\n\t    ${prefix2}${varName}=${prefix1}${varName};" }
	    string -
	    char*   { 
		# we need to memcpy here, the line below is WRONG
		append code "\n\t    ${prefix2}${varName}=${prefix1}${varName};" 
	    }
	    default {

		# TEST - TEST - TEST
		ccode_struct_CopyData_Template TEST_code declarations metadata $cTypeName $varName $srcName $destName
		#append code $TEST_code


		# $::__CTYPE([string trimright $cTypeName {*}])
		set ObjType [ccode_ctype_ObjType [string trimright $cTypeName {*}]]
		if { ${ObjType} ne {} } {
		    set CopyDataTemplate ""
		    append CopyDataTemplate "\n\t    Ns_Log(Notice,\"calling ${ObjType}_CopyData\");"
		    append CopyDataTemplate "\n\t    ${ObjType}_CopyData(%s,%s); /* %s */  /* TODO: NOT GOOD ENOUGH FOR POINTERS TO POINTERS, WE NEED TO ITERATE */ "
		} else {
		    set cTypeNoAsterisks [string trimright ${cTypeName} {*}]
		    set CopyDataTemplate ""
		    set destFmt {%1$s}
		    set srcFmt {%2$s}
		    set numSlotsFmt {%3$s}
		    append CopyDataTemplate "\n\t    $destFmt = (${cTypeName}) Tcl_Alloc($numSlotsFmt * sizeof($cTypeNoAsterisks));"
		    append CopyDataTemplate "\n\t    memcpy($destFmt,$srcFmt,$numSlotsFmt * sizeof($cTypeNoAsterisks));" ;# might give us trouble
		}

		set numAsterisks [expr { [string length ${cTypeName}] - [string length [string trimright ${cTypeName} {*}]] }]
		if { ${numAsterisks} > 0 } {
		    #byref
		    if { [info exists MD(@size)] } {
			set numSlots [join [::xo::fun::map x $MD(@size) { list ${prefix1}${x} }] {*}]
			append CopyDataTemplate "\n\t    Ns_Log(Notice,\"copy case 1: $varName\");"
			append code [format ${CopyDataTemplate} "${prefix2}${varName}" "${prefix1}${varName}" "$numSlots"] 
		    } else {
			append CopyDataTemplate "\n\t    Ns_Log(Notice,\"copy case 2: $varName \");"
			append code [format ${CopyDataTemplate} "${prefix2}${varName}" "${prefix1}${varName}" ""]
		    }
		} else {
		    append CopyDataTemplate "\n\t    Ns_Log(Notice,\"copy case 3: $varName\");"
		    append code [format ${CopyDataTemplate} "&${prefix2}${varName}" "&${prefix1}${varName}" ""]
		}

	    }
	}

	if { [string index $cTypeName end] ne {*} && ![string match "struct*" $cTypeName] } {
	    append code "\n\t    [subst {Ns_Log(Notice,"copy data %d: %s (from)",$i,Tcl_GetString(Tcl_NewDoubleObj(${prefix1}${varName})));}]"
	    append code "\n\t    [subst {Ns_Log(Notice,"copy data %d: %s (to)",$i,Tcl_GetString(Tcl_NewDoubleObj(${prefix2}${varName})));}]"
	} else {
	    append code "\n\t    [subst {Ns_Log(Notice,"copy data %d",$i);}]"
	}

    }

    ns_log notice "\n\n TEST_code=\n\t[join [lsort -unique $declarations] \n\t]\n\n$TEST_code \n\n"

    return ${code}

}

# cTypeNA = cTypeNoAsterisks
proc ccode_struct_CopyData_ByRef_OLD {codeVar templateVar declarationsVar metadataVar ObjType cTypeNA numAsterisks varName srcName destName} {
    upvar ${codeVar} code
    upvar ${templateVar} template
    upvar ${declarationsVar} declarations
    upvar ${metadataVar} metadata

    array set MD $metadata

    set dimensions [list]
    lassign [array get MD @size] __key__ dimensions

    set itCount 0
    set tabs ""
    set code_before ""
    set code_after ""
    set rowIndex "0"
    set indexList ""
    set rightBraces ""
    set dereference ""
    set dimExpr ""
    #while { $numAsterisks > 0 } 
    foreach dimension $dimensions {

	#append tabs "\t"

	set allocType ""
	set allocIf   ""
	set iVar      [format "%c" [expr { 104 + [incr itCount] }]] ;# 105 is the char code for the letter i

	lappend declarations "int ${iVar};"

	lassign [array get MD @allocType($dimension)] __key__ allocType
	lassign [array get MD @allocIf($dimension)] __key__ allocIf

	set extraTabs "\t"

	# Examples:
	#   destPtr->label = (int *) Tcl_Alloc(srcPtr->nr_class * sizeof(int));
	#   destPtr->x = (struct feature_node **) Tcl_Alloc(srcPtr->l * sizeof(struct feature_node *));         /* not sparse */
	#   destPtr->x[0] = (struct feature_node *) Tcl_Alloc(min(srcPtr->n,) * sizeof(struct feature_node));   /* sparse, thus varying alloc sizes for the srcPtr->l number of pointers*/
	#   destPtr->x[1] = (struct feature_node *) Tcl_Alloc(min(srcPtr->n,) * sizeof(struct feature_node));
	#   destPtr->x[srcPtr->l] = (struct feature_node *) Tcl_Alloc(min(srcPtr->n,) * sizeof(struct feature_node));
	#   destPtr->x = &(destPtr->x[0])

	if { ${allocType} eq {sparse} && ${allocIf} ne {} } {
	    set iMaxVar "${iVar}_max"
	    set allocCond [format ${allocIf} "${srcName}\[$rowIndex + ${iMaxVar}\]->"]  ;# HERE: dot or ->, not sure yet 
	    lappend dimExpr "(min(${srcName}->${dimension},1+${iMaxVar}))" ;# +1 in order to include the mark node, e.g. (-1,?) for feature nodes

	    lappend declarations "int ${iMaxVar}=0;"
	    append code_before "\n while (${allocCond}) { ${iMaxVar}++; };"
	} else {
	    lappend dimExpr "${srcName}->${dimension}"
	}

	if { $indexList ne {} } {
	    set rowIndex     "" ;# HERE
	    set dereference  "\[${rowIndex}\]"
	}

	set destPtr "${destName}->${varName}${dereference}"
	#set asterisks [string repeat "*" [expr { ${numAsterisks} - 1 }]] ;# HERE

	#append code_before  "\n ${tabs} ${destPtr} = (${cTypeNA}*${asterisks}) Tcl_Alloc(${dimExpr} * sizeof(${cTypeNA}${asterisks}));"
	#append code_before  "\n ${tabs} for(${iVar}=0; ${iVar} < ${dimExpr}; ${iVar}++) \{"
	#lappend rightBraces "\n ${tabs} \}"

	lappend indexList    "${iVar}"
	#incr numAsterisks -1
    }
    #append code_after [join [lreverse $rightBraces]]

    #set indentation "\n \t${tabs}"
    set indentation "\n "
    set innerSrcPtr  "$srcName->${varName}" ;# HERE - FIX - DEFINE
    set innerDestPtr "$destName->${varName}" ;# HERE - FIX - DEFINE
    set innerDereference "$dereference"

    append code "\n /* Dimensions: $dimensions */"
    append code "\n /* Asterisks:  $numAsterisks */"

    #append code $code_before
    set numAsterisks_tmp $numAsterisks
    set dereference ""
    set i 0
    while { [incr numAsterisks -1] >= 0 } {
	set asterisks [string repeat "*" $numAsterisks]
	set innerDimExpr [::util::coalesce [join [lrange $dimExpr $i end] " * "] "1"] ;# HERE - FIX - DEFIN

	# add for loop
	append code [format $template ${indentation} "${cTypeNA} [string repeat * $numAsterisks]${varName}" ${ObjType} ${cTypeNA} ${varName} ${innerSrcPtr} ${innerDestPtr}${dereference} ${innerDimExpr} ${innerDereference} ${asterisks}] 

	incr i 
	set dereference "\[i\]"
    }
    set numAsterisks $numAsterisks_tmp
    #append code $code_after

    ## TEST TEST TEST
    append code "\n/************* START ***************/"
    ccode_struct_CopyData_ByRef_MALLOC code template declarations metadata $ObjType $cTypeNA $numAsterisks $varName $srcName $destName
    append code "\n/************** END ***************/"



}
