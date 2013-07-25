package provide critcl-ext 0.1

set dir [file dirname [info script]]
source [file join $dir ccode-args.tcl]
source [file join $dir ccode-struct.tcl]



proc ccode_struct_ClearData {defs {prefix ""}} {

    set code ""
    set maxIteratorCount 0
    foreach def $defs {
	set iteratorCount 0
	set clear_code ""
	lassign $def cTypeName varName metadata
	array unset MD
	array set MD $metadata

	switch -exact -- $cTypeName {
	    short -
	    long -
	    int -
	    float -
	    double  { append code "\n\t    /* No clear needed for ${varName} */" }
	    default {

		if { [info exists ::__CTYPE([string trimright $cTypeName {*}])] } {
		    set ObjType $::__CTYPE([string trimright $cTypeName {*}])
		    set ClearDataProc    "${ObjType}_ClearData"
		    set ClearDataTemplate "${ClearDataProc}(%s);"
		} else {
		    set ClearDataProc "Tcl_Free" ;# might give us trouble
		    set ClearDataTemplate "${ClearDataProc}((char *) &%s); /* HERE - HERE - HERE - HERE - HERE - HERE: clear_from_defs proc*/"
		}

		set numAsterisks [expr { [string length ${cTypeName}] - [string length [string trimright ${cTypeName} {*}]] }]
		if { ${numAsterisks} > 0 } {
		    if { [info exists MD(@size)] } {
			set indexListT1 [list]
			set indexListT2 [list]
			set tabs "\t"
			set before_clear_code ""
			set after_clear_code ""
			foreach iteratorVarName $MD(@size) {
			    set iVarName [format "%c" [expr { 104+[incr iteratorCount] }]]
			    append tabs "    "
			    lappend indexListT1 "${iVarName}"
			    lappend indexListT2 "${iVarName}*${prefix}${iteratorVarName}"
			    append before_clear_code "\n${tabs}for(${iVarName}=${prefix}${iteratorVarName} - 1; ${iVarName}>=0; ${iVarName}--) \{"
			    set after_clear_code "\n${tabs}\}${after_clear_code}"
			}
			append tabs "    "
			if { 1 } {   ;# TODO: consider the @allocation type in the future
			    lset indexListT2 end $iVarName
			    set index [join $indexListT2 " + "]
			} else {
			    set index [join $indexListT1 "\]\["]
			}
			append code "${before_clear_code}\n${tabs}"
			append code [format ${ClearDataTemplate} ${prefix}${varName}\[${index}\]]
			append code ${after_clear_code}
		    } else {
			append code [format ${ClearDataTemplate} ${prefix}${varName}]
		    }
		} else {
		    append code "\n\n\t    [format ${ClearDataTemplate} "&${prefix}${varName}"];"
		}

	    }
	}
	if { $maxIteratorCount < $iteratorCount } {
	    set maxIteratorCount $iteratorCount
	}
    }

    set iteratorVars ""
    while { $maxIteratorCount > 0 } {
	append iteratorVars "\n\t    int [format "%c" [expr { 104 + ${maxIteratorCount} }]];"
	incr maxIteratorCount -1
    }

    return "${iteratorVars}$code"

}




proc get_array_max_dim {dimensions {prefix ""}} {
    return [join [::xo::fun::map dimVarName $dimensions { set _ ${prefix}${dimVarName} }] { * }] ;# multiply all dimensions to figure out how much memory we need
}

proc ccode_llength_check {declarationsVar objName count {objNameCount ""} {indentation "\n"}} {
    upvar $declarationsVar declarations

    if { ${objNameCount} eq {} } {
	set objNameCount ${objName}_LLength
    }
    lappend declarations "int ${objNameCount};"
    # TODO - FIX: Changing ${objName} to Tcl_NewStringObj(Tcl_GetString(${objName}),-1) works 
    # but this is not what we want for structures embedded in other structures. We will attempt
    # to use GopyData or just assign the internal value of the object to the structure in GetDataFromObj.
    # Should we increment the reference counter, most likely.
    append __CODE__ "${indentation} ${objNameCount}=0;"
    append __CODE__ "${indentation} if (Tcl_ListObjLength(interp, ${objName}, &${objNameCount}) != TCL_OK) { return TCL_ERROR; }"
    append __CODE__ "${indentation} if ( ${objNameCount} != ${count} ) { return TCL_ERROR; }"

    return ${__CODE__}
}


proc ccode_foldl_llength { declarationsVar iVar objName indentation} {
    upvar ${declarationsVar} declarations

    set iDimVar "size_${iVar}"       ;# total size of all sublists of the input list
    set iLLenVar "llength_${iVar}"   ;# length of the input list (of lists)
    set iSubLenVar "sublist_llength" ;# length of a given sublist
    set iIndexVar "sublist_index"    ;# index of a sublist
    set iSubVar "${objName}_SL"

    lappend declarations "int ${iDimVar};"
    lappend declarations "int ${iLLenVar};"
    lappend declarations "int ${iSubLenVar};"
    lappend declarations "int ${iIndexVar};"
    lappend declarations "Tcl_Obj *${iSubVar};"

    append __CODE__ "${indentation} ${iDimVar} = 0;"
    append __CODE__ "${indentation} if (Tcl_ListObjLength(interp, ${objName}, &${iLLenVar}) != TCL_OK) { return TCL_ERROR; }"
    append __CODE__ "${indentation} for(${iIndexVar}=0; ${iIndexVar}<${iLLenVar}; ${iIndexVar}++) \{"
    append __code__ "${indentation} \t if (Tcl_ListObjIndex(interp, ${objName}, ${iIndexVar}, &${iSubVar}) != TCL_OK) { return TCL_ERROR; }"
    append __CODE__ "${indentation} \t if (Tcl_ListObjLength(interp, ${iSubVar}, &${iSubLenVar}) != TCL_OK) { return TCL_ERROR; }"
    append __CODE__ "${indentation} \t ${iDimVar} += ${iSubLenVar};"
    append __CODE__ "${indentation} \}"

    return ${__CODE__}
}




proc ccode_ctype_ObjType {cTypeNoAsterisks} {
    set ObjType ""
    if { [info exists ::__CTYPE($cTypeNoAsterisks)] } {
	set ObjType $::__CTYPE($cTypeNoAsterisks)
    }
    return ${ObjType}
}






#################

proc args_from_dict {callArgsVar procName argsDict {otherVarList ""}} {
    upvar $callArgsVar callArgs

    set numOtherVars [llength $otherVarList]
    set indexOtherVar 0

    set result ""
    set procArgs [info args ${procName}]
    set callArgs [list]
    array set argv $argsDict
    foreach argName ${procArgs} {
	if { [info exists argv(${argName})] } {
	    lappend callArgs $argv(${argName})
	} else {
	    if { [string match "*Var" ${argName}] } {
		if { $indexOtherVar < $numOtherVars } {
		    set varName [lindex $otherVarList $indexOtherVar]
		} else {
		    set varName __BYREF(${procName},$indexOtherVar,[string range ${argName} 0 end-3])
		    lappend result $varName
		}
		lappend callArgs $varName
		incr indexOtherVar
	    } else {
		lappend callArgs ""
	    }
	}
    }
    return $result
}


