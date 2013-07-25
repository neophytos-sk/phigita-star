Class create Container \
    -proc add {container Class name args} {
	if {![my isobject $container]} {my create $container}
	eval $Class create ${container}::$name $args
    } \
    -proc list {container {pattern "*"}} {
	if {![my isobject $container]} {return [list]}
	lsort [$container info children $pattern]
    }
