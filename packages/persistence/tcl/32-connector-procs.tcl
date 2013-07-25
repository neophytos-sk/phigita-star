Class Connector -parameter {
    {name         "[string tolower [namespace tail [self]]]"}
    {referrer       ""}
    {referrer_fkey  ""}
    {transformation ""}
    {sortDir        "ASC"}
    {columnTarget   ""}
}

Connector instproc getSelectExpression {{-conn ""} {-op "="} pathexp referenced_id} {
    my instvar name referrer referrer_fkey sortDir
    ### name || '|'
    set table [pathexp_to_key $pathexp $referrer]
    if { [::xo::db::table_exists_p main.${table}] } {
	set selectList [list]
	foreach att [$referrer attributes] {
	    lappend selectList " '[$att dbname] \{' || [$att dbname] || '\} ' "
	}
	set criteria [::xo::db::qualifier $referrer_fkey ${op} $referenced_id]
	#GROUP BY $referrer_fkey ORDER BY $referrer_fkey $sortDir
	return "(SELECT xo__concatenate_aggregate('{' || [join ${selectList} { || }] ||'} ') FROM ${table} WHERE ${criteria}) AS $name"
    } else {
	return "NULL AS $name"
    }
}

Connector instproc transform {objs} {
    my instvar transformation name
    if { $transformation ne {} } {
	foreach o $objs {
	    lassign $transformation varList script
	    $o set $name [::xo::fun::map ${varList} [$o set $name] $script]
	}
    }
}

Connector instproc get_raw_value {o} {
    my instvar name
    if { [$o exists $name] } {
	return [$o set $name]
    }
}

Connector instproc dbname {} {
    my instvar name
    return $name
}
