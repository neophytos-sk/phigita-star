# isMultivalued -- Either an array or a set. In the latter case what is really stored in the attribute is the OID of a tuple in the xo_proc catalog. The xo_proc tuple contains the query string that defines this set - i.e., the query to run to get the set. So the type (see above) refers to the type returned by this query, but the actual length of this attribute is the length (size) of an oid. --- At least this is the theory. All this is probably quite broken these days.

# isLocal -- This attribute is defined locally in the object. Note that an attribute may be locally defined and inherited simultaneously.

namespace eval ::xo {;}
namespace eval ::xo::base {;}

Class create ::xo::base::Attribute -parameter {
    {name            "[namespace tail [self]]"}
    {dbname          "[string tolower [string map {: _} [namespace tail [self]]]]"}
    {dom             "[[my info parent] info parent]"}
    {isHidden        "no"}
    {isUnique        "no"}
    {isStored        "yes"}
    {isProxy         "no"}
    {label           ""}
    {default         ""}
    {acc_method      "BTREE"}
    {datatype        "[string toupper [string trimleft [my info class] :]]"}

    {type            ""}
    {isNullable      "no"}
    {isMultiple      "no"}
    {isMultivalued   "no"}
    {isLocal         "yes"}

    {priority        "0"}
}

::xo::base::Attribute instproc get_sql {sql_name args} {
    return [my get_sql=$sql_name {*}${args}]
}

::xo::base::Attribute instproc get_sql=before_not_null {tablename} {
    # override in one of the derived classes
    # ns_log notice "get_sql=before_not_null o=[self] cl=[my info class] procs=[my info procs]"
}

::xo::base::Attribute instproc get_sql=add_column {tablename} {
    my instvar dbname isNullable datatype

    set sql ""
    if { ![::xo::pg::column_exists $tablename $dbname] } {
	append sql "\n ALTER TABLE $tablename ADD COLUMN $dbname $datatype;"
    }


    append sql [my get_sql "before_not_null" $tablename]
    if { !$isNullable } {
	append sql "\n ALTER TABLE $tablename ALTER COLUMN $dbname SET NOT NULL;"
    }

    set default_value [my set default]
    if { $default_value ne {} } {
	append sql "\n ALTER TABLE $tablename ALTER COLUMN $dbname SET DEFAULT $default_value;"
    }


    #set column_definition [my get_column_def {}]
    #ns_log notice "METADATA - ALTER SQL: \n\t[join $sql "\n\t"]"
    return $sql
}

::xo::base::Attribute instproc get_conf {} {
    my instvar name
    set result "[my info class] ${name}"
    foreach varname {isNullable isUnique default acc_method} {
	my instvar ${varname}
	if {[info exists ${varname}]} {
	    append result " -${varname} \{[set ${varname}]\}"
	}
    }
    return ${result}

}

::xo::base::Attribute instproc asNULL {} {
    return "NULL::[my datatype] as [my dbname]"
}

::xo::base::Attribute instproc autovalue {pathexp} {
    return [my default]
}


::xo::base::Attribute instproc default_value {o} {
    my instvar default
    if {[exists_and_not_null default]} {
	return ${default}
    } else {
	return NULL
    }
}


::xo::base::Attribute instproc getDQValue {o} {
    return [ns_dbquotevalue [my getValue $o]]
}

::xo::base::Attribute instproc getQuotedValue {value} {
    return [ns_dbquotevalue $value]
}


::xo::base::Attribute instproc get_raw_value {o} {
    my instvar name
    if { [${o} exists ${name}] } {
	return [${o} set ${name}]
    } else {
	return
    }
}

::xo::base::Attribute instproc getValue {o} {

    my instvar name

    set value [my get_raw_value ${o}]
    if { ${value} ne {} } {
	set result [my getQuotedValue ${value}]
    } elseif { [${o} exists db(${name})] } {
	return [${o} set db(${name})]
    } else {
	set result [my default_value ${o}]
    }
    
    ## Why not 'regsub -all {\\} ${str} {\\\\} str' ?
    # Michael Cleverly wrote: In Tcl 8.4+ 'string map' is faster 
    # (because, iirc, 'string map' now gets byte-code compiled).  
    # On the other hand, in Tcl 8.3 & earlier 'regsub'
    # (for this type of case) is quicker.
   
    return [string map {\\ \\\\} ${result}]

}

::xo::base::Attribute instproc get_column_def { ns } {
    return "[my dbname] [my datatype] [aux::decode [my isNullable] yes {} no { NOT NULL}]"

    set comment {[aux::decode [my isUnique] no {} yes { UNIQUE}]}
}

Class Boolean  -superclass "::xo::base::Attribute"
Class Integer  -superclass "::xo::base::Attribute"
Class Intarray  -superclass "::xo::base::Attribute" -parameter {{datatype {integer\[\]}} {acc_method {gist}}}
Class Decimal -superclass "::xo::base::Attribute"
Class Double -superclass "::xo::base::Attribute" -parameter {{datatype {double precision}}}
Class Numeric -superclass "::xo::base::Attribute" -parameter {{datatype {numeric}}}
Class Smallint -superclass "Integer"
Class Bigint   -superclass "Integer"
Class String   -superclass "::xo::base::Attribute" -parameter {{maxlen ""}}
Class TSearch2_Vector -superclass "::xo::base::Attribute" -parameter {
    {datatype {tsvector}} 
    {acc_method {gist}}
    {priority "1"}
}
Class Geometry -superclass "::xo::base::Attribute" -parameter {{datatype {geometry}} {acc_method {gist}}}
Class TclDict -superclass "::xo::base::Attribute" -parameter {{datatype "text"}}
Class ValueList -superclass "::xo::base::Attribute" -parameter {{datatype "text"} {values ""} {labels ""}}


TclDict instproc get_raw_value {o} {
    my instvar name
    if { [${o} exists ${name}] } {
	return [${o} set ${name}]
    } else {
	set index [string length "${name}."]
	set mydict [dict create]
	foreach varName [$o info vars ${name}.*] {
	    dict set mydict [string range $varName $index end] [$o set $varName]
	}
	$o set $name $mydict
	return $mydict
    }
}

String instproc init {} {
    my instvar maxlen
    # || $maxlen > 1000
    if { $maxlen eq {} } { 
	my datatype "VARCHAR" 
    } else { 
	my datatype "VARCHAR($maxlen)"
    }
}

String instproc getQuotedValue {value} {
    return E[ns_dbquotevalue $value]
}

Class Timestamptz -superclass ::xo::base::Attribute -parameter {
    {default "timestamp 'now'"}
    {datatype "timestamp with time zone"}
}





Class Timestamp -superclass ::xo::base::Attribute -parameter {
    {default "timestamp 'now'"}
    {datatype "timestamp without time zone"}
}

Class Interval -superclass ::xo::base::Attribute -parameter {
    {datatype "INTERVAL"}
}

Class LTree -superclass ::xo::base::Attribute -parameter {
    {acc_method "GIST"}
}

Class BLOB -superclass "::xo::base::Attribute"

Class Image -superclass "BLOB"


Class Serial -superclass "::xo::base::Attribute"

Class OID -superclass "Integer" -parameter {
    {isNullable "no"}
    {isUnique "yes"}
    {isHidden "yes"}
    {datatype "INTEGER"}
}

OID instproc init {} {

    [my dom] key [my name]

    set sequence_spec "Sequence [my name]"
    [my dom] sequence [list $sequence_spec]

}

OID instproc default_value {o} {
    return "xo__nextval([ns_dbquotevalue [${o} info.db.sequence]])"
}

OID instproc autovalue {pathexp} {

    set ns [my dbNamespace ${pathexp}]

    set pool [my dbPool ${ns}]

    set conn [DB_Connection new -volatile -pool ${pool}]

    if {![${conn} exists [my pdl.schema.exists ${ns}]]} {
        catch { ${conn} do [my pdl.schema.create ${ns}] }
    }

    if {![${conn} exists [my pdl.sequence.exists ${ns}]]} {
        catch { ${conn} do [my pdl.sequence.create ${ns}] }
    }

    return [${conn} getvalue [my pdl.sequence.nextvalue ${ns}]]
}




Class FKey -superclass "::xo::base::Attribute" -parameter {
    {ref ""}
    {refkey ""}
    {onUpdateAction ""}
    {onDeleteAction ""}
}


FKey instproc init {} {    
    if { [string equal [my refkey] ""] } {
	my refkey [[my ref] key]
    }
    my datatype "[[my ref]::attribute::[my refkey] datatype]"
}

FKey instproc get_column_def { ns } {
    return "[next] references ${ns}.xo__[string map {: _} [string trimleft [my ref] {:}]]([my refkey]) [ad_decode [my onDeleteAction] "" "" "on delete [my onDeleteAction]"]"
}

FKey instproc relmap {} {
    if { [[self] isMultiple] } {
	set table [my ref]
    } else {
	set table [[my info parent] name]
    }
    return [list ${table}]
}


## Relation Key
Class RelKey -superclass "::xo::base::Attribute" -parameter {
    {ref ""}
    {refkey ""}
    {onUpdateAction ""}
    {onDeleteAction ""}
    {datatype ""}
}

RelKey instproc init {} {    
    my instvar datatype

    if { [string equal [my refkey] ""] } {
	my refkey [[my ref] key]
    }
    if { $datatype eq {} } {
	my datatype "[[my ref]::attribute::[my refkey] datatype]"
    }
}



Class SK



Class Hoard -superclass {::xo::base::Attribute ::db::Set} -parameter {
}

Hoard instproc getValue {o} {
    $o eval {my load}
    return [my toDict]
}

#Hoard new -subject "creation_user" -select "user_id screen_name first_names last_name" -pool main -srcType ::CC_Users -restrictClause [list "creation_user skolem:eq creation_user"]

#get_column_by_names -pool main -cf CC_Users {user_id screen_name first_names last_name}

# ColumnFamily User -slots {}
