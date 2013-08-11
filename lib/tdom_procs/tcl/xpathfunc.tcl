namespace eval ::dom::xpathFunc {;}
proc ::dom::xpathFunc::names { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'names'"
    }
    foreach { type value } $args break
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "names only applicable for node or attribute nodelists!"
    }
    set n {}
    if {$type == "nodes"} {
	foreach node $value { lappend n [$node nodeName] }
    } else {
	foreach {attrName attrValue} $value { lappend n $attrName }
    }
    return [list string $n]
}
proc ::dom::xpathFunc::values { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'values'"
    }
    foreach { type value } $args break
    if {${type} == "empty"} {
	return [list string ""]
    }
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "values only applicable for node or attribute nodelists!"
    }
    set result {}
    if {$type == "nodes"} {
	foreach node $value { lappend result [$node nodeValue] }
    } else {
	foreach attrNode ${value} {
	    foreach {attrName attrValue} ${attrNode} { lappend result ${attrValue} }
	}
    }
    return [list string ${result}]
}

proc ::dom::xpathFunc::returnstring {ctxNode pos nodeListNode nodeList args} {
    if {[llength $args] != 2} {
        error "returnstring(): wrong # of args!"
    }
    foreach {arg1Typ arg1Value} $args break
    set result [::dom::xpathFuncHelper::coerce2string $arg1Typ $arg1Value]
    return [list string $result]
}



proc ::dom::xpathFunc::textvalues { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'values'"
    }
    foreach { type value } $args break
    if {${type} == "empty"} {
	return [list string ""]
    }
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "values only applicable for node or attribute nodelists!"
    }
    set result {}
    if {$type == "nodes"} {
	foreach node $value { lappend result [$node text] }
    } else {
	foreach attrNode ${value} {
	    foreach {attrName attrValue} ${attrNode} { lappend result ${attrValue} }
	}
    }
    return [list string ${result}]
}

proc ::dom::xpathFunc::match_attribute {ctxNode pos nodeListType nodeList args} {
    if {[llength $args] != 6} {
        error "match_attribute(): wrong # of args! Usage: match_attribute(nodes,attribute,pattern)"
    }
    foreach {arg1Typ arg1Value arg2Typ arg2Value arg3Typ arg3Value} $args break
    if { $arg1Typ ne {nodes} } {
	error "match_attribute(nodes,attribute,pattern)"
    }
    set nodes $arg1Value
    set attrname [::dom::xpathFuncHelper::coerce2string $arg2Typ $arg2Value]
    set pattern [::dom::xpathFuncHelper::coerce2string $arg3Typ $arg3Value]

    ns_log notice "attrname=$attrname pattern=$pattern"

    set result_nodes [list]
    foreach node $nodes {
	if { [string match -nocase $pattern [$node getAttribute $attrname ""]] } {
	    lappend result_nodes $node
	}
    }

    return [list nodes $result_nodes]
}
