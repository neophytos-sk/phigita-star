
proc define_cproc {name argv} {

    set tclPreProcess   ""
    set tclPostProcess  ""
    set tclProcArgs [list]
    set cCallArgs [list]
    foreach {argType argName} $argv {

	if { [string index $argName end] eq {*} } {
	    lappend tclProcArgs ${argName}Var
	    lappend cCallArgs c_$argname

	    append tclPreProcess   "\n\tupvar ${argName}Var $argName"
	    append tclPreProcess   "\n\tset c_${argName} [${argType}sToByteArray \$\{argName\}]"
	    append tclPostProcess  "\n\tset ${argName} [byteArrayTo[string totitle ${argName}]s \$\{c_${argName}\}]"

	} else {
	    lappend tclProcArgs $argName
	    lappend cCallArgs $argName
	}


	set body     "${name}([join ${cCallArgs} {,}]); return TCL_OK"

    critcl::cproc ${name}_ ${argv} ok ${body}

    proc ${name} $callargs

}
