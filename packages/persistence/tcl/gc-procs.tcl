namespace eval gc {;}

proc gc::gc { why } {
    global t__xotcl_object
    if {[info exists t__xotcl_object]} {
 	foreach {o} [array names t__xotcl_object] {
	    # Check if it still exists
	    if {[Object isobject ${o}]} {
		${o} destroy
	    }
	}
    }
    return filter_ok
}
