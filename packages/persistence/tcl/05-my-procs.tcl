


namespace eval my {;}


Class ::my::Object -parameter volatile_p

::my::Object instproc lmap {fn list} {
    set result [list]
    foreach item ${list} {
	lappend result [my {*}${fn} {*}${item}]
    }
    return ${result}
}


::my::Object instproc variable {args} {
    foreach varlist ${args} {
	if {[llength ${varlist}] == 2} {
	    #foreach {myVar otherVar} ${varlist} break;
	    lassign $varlist myVar otherVar
	} else {
	    set myVar ${varlist}
	    set otherVar ${varlist}
	}
	upvar [self callinglevel] ${otherVar} test.${myVar}
	my instvar [list ${myVar} test.${myVar}]
	if {[info exists ${myVar}]} {
	    set test.${myVar} [set ${myVar}]
	}
    }
}


::my::Object proc alloc {o args} {
    global t__xotcl_object
    set t__xotcl_object(${o}) {}
    next
}

::my::Object instproc destroy {} {
    if { [catch {
	my instvar volatile_p
	if {[info exists volatile_p]} {
	    set destroy_p ${volatile_p}
	} else {
	    set destroy_p yes
	}

	if {${destroy_p}} {
	    global t__xotcl_object
	    #ns_log notice "HERE: destroy [self]"
	    catch "unset t__xotcl_object([self])"
	    # HERE: Check what happens if the conn is closed before next is called.
	    next
	}
    } errmsg] } {
	ns_log notice ${errmsg}
    }
}

::my::Object instproc quoted {__NAME__} {
    my instvar ${__NAME__}
    if {[info exists ${__NAME__}]} {
	return [ns_dbquotevalue [string map {\\ \\\\} [set ${__NAME__}]]]
    } else {
	return null
    }
}



Object ::XO

Class ::my::Class -superclass "Class" -instmixin ::my::Object -mixin ::my::Object -parameter {{volatile_p "no"}}


::my::Class instproc def {-objname args} { 
    if {![info exists objname]} {
	set objname [::XO autoname ::xo::__\#]
    }
    #ns_log notice "my create ${objname} {*}${args}"
    return [my create ${objname} {*}${args}] 
}
 
::my::Class instproc alloc {o args} {
    global t__xotcl_object
    set t__xotcl_object(${o}) {}
    set result [next]
    ${o} mixin add ::my::Object
    return ${result}
}


