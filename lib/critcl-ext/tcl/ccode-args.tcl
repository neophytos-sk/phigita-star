


 #
 # Generic routine to convert a list into a bytearray
 #
 proc ::listToByteArray { valuetype list {elemsize 0} } {
    if { $valuetype == "i" || $valuetype == "I" } {
       if { $::tcl_platform(byteOrder) == "littleEndian" } {
          set valuetype "i"
       } else {
          set valuetype "I"
       }
    }

    switch -- $valuetype {
    f - d - i - I {
       set result [binary format ${valuetype}* $list]
    }
    s {
       set result {}
       foreach elem $list {
          append result [binary format a$elemsize $elem]
       }
    }
    default {
       error "Unknown value type: $valuetype"
    }
    }

    return $result
 }

 interp alias {} stringsToByteArray {} ::listToByteArray s
 interp alias {} intsToByteArray    {} ::listToByteArray i
 interp alias {} floatsToByteArray  {} ::listToByteArray f
 interp alias {} doublesToByteArray {} ::listToByteArray d

 #
 # Generic routine to convert a bytearray into a list
 #
 proc ::byteArrayToList { valuetype bytearray {elemsize 0} } {
    if { $valuetype == "i" || $valuetype == "I" } {
       if { $::tcl_platform(byteOrder) == "littleEndian" } {
          set valuetype "i"
       } else {
          set valuetype "I"
       }
    }

    switch -- $valuetype {
    f - d - i - I {
       binary scan $bytearray ${valuetype}* result
    }
    s {
       set result  {}
       set length  [string length $bytearray]
       set noelems [expr {$length/$elemsize}]
       for { set i 0 } { $i < $noelems } { incr i } {
          set elem    [string range $bytearray \
                         [expr {$i*$elemsize}] [expr {($i+1)*$elemsize-1}]]
          set posnull [string first "\000" $elem]
          if { $posnull != -1 } {
             set elem [string range $elem 0 [expr {$posnull-1}]]
          }
          lappend result $elem
       }
    }
    default {
       error "Unknown value type: $valuetype"
    }
    }
    return $result
 }

 interp alias {} byteArrayToStrings {} ::byteArrayToList s
 interp alias {} byteArrayToInts    {} ::byteArrayToList i
 interp alias {} byteArrayToFloats  {} ::byteArrayToList f
 interp alias {} byteArrayToDoubles {} ::byteArrayToList d





proc define_cproc {name argv {tclInit ""} {cBody ""}} {

    set tclDeclarations ""
    set tclPreProcess ""
    set tclPostProcess  ""
    set tclProcArgs [list]
    set tclCallArgs [list]
    set cCallArgs [list]
    foreach {argType argName} $argv {

	if { [string index $argType end] eq {*} } {
	    set argTypeOnly [string trimright $argType {*}]
	    lappend tclProcArgs ${argName}Var
	    lappend tclCallArgs \$\{c_$argName\}

	    append tclDeclarations "\n\tupvar \$${argName}Var $argName"
	    append tclPreProcess   "\n\tset c_${argName} \[${argTypeOnly}sToByteArray \$\{${argName}\}\]"

	    if { [string match "out*" $argName] } {
		append tclPostProcess  "\n\tset ${argName} \[byteArrayTo[string totitle ${argTypeOnly}]s \$\{c_${argName}\}\]"
	    }

	    #append tclPostProcess "\n\tns_log notice $argName=\[set $argName\]"

	} else {
	    lappend tclProcArgs $argName
	    lappend tclCallArgs "\$$argName"
	}
	lappend cCallArgs $argName

    }

    if { $cBody eq {} } {
	set cBody    "\n"
	append cBody "\n\t${name}([join ${cCallArgs} {, }]);"
	append cBody "\n\treturn TCL_OK;"
	append cBody "\n"
    }
    ::critcl::cproc ${name}_ ${argv} ok ${cBody}



    set tclBody ""
    append tclBody "\n\t$tclDeclarations"
    append tclBody "\n\t$tclInit"
    append tclBody "\n\t$tclPreProcess"
    append tclBody "\n\tset error \[${name}_ [join $tclCallArgs]\]"
    #append tclBody "\n\tns_log notice error=\$error"
    append tclBody "\n\t$tclPostProcess"
    append tclBody "\n"
    append tclBody "\n\treturn\n"

    proc ${name} $tclProcArgs $tclBody

    #ns_log notice "critcl::cproc ${name}_ [list ${argv}] ok [list ${body}] \n\nproc $name [list $tclProcArgs] [list [info body $name]]"
}
