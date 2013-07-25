Class Index -parameter {
    {name         "[string tolower [namespace tail [self]]]"}
    {subject      "[string tolower [namespace tail [self]]]"}
    {isUnique     "no"}
    {cluster_p    "no"}
    {suffix "idx"}
    {acc_method "BTREE"}
    {on_copy_include_p     "no"}
    {on_inherit_include_p  "no"}
    {dom "[[my info parent] info parent]"}
}


Index instproc init {args} {
    my instvar acc_method
    if { [Object isobject [my dom]::attribute::[lindex [my subject] 0]] } {
	set acc_method [[my dom]::attribute::[lindex [my subject] 0] acc_method]
    }
}


Index instproc get_conf_for_copy {} {

    if {![my on_copy_include_p]} {
	return ""
    }

    my instvar name
    set result "[my info class] ${name}"
    foreach varname {subject isUnique cluster_p suffix acc_method on_copy_include_p on_inherit_include_p} {
        my instvar ${varname}
        if {[info exists ${varname}]} {
            append result " -${varname} [set ${varname}]"
        }
    }
    return ${result}
}

Index instproc indexmap {schemaname tablename} {

    my instvar cluster_p

    set acc_method [[my dom]::attribute::[lindex [my subject] 0] acc_method]

    append sql "CREATE [aux::decode [my isUnique] yes {UNIQUE } no {}]INDEX \"[my name]\" ON ${schemaname}.${tablename} USING ${acc_method} ([join [my subject] {,}]);"

    if { ${cluster_p} } {
	append sql "CLUSTER [my name] ON ${schemaname}.${tablename}"
    }
    return ${sql}

}

Index instproc get_db_def { schema tablename indexspace } {

    my instvar name isUnique acc_method

    return "CREATE [aux::decode ${isUnique} yes {UNIQUE} no {}] INDEX \"${tablename}__${name}\" ON ${schema}.${tablename} USING ${acc_method} ([join [my subject] {,}]) TABLESPACE ${indexspace};"

}
