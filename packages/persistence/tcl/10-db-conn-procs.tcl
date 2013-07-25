
# AOLServer has a rule that you can only allocated a handle once per pool, through thread. Unless you explictly release the handles from a pool, you won't be able to call ns_db gethandle again.

# The mechanism is based on the fact that commands are executed sequentially within a thread.

my::Class DB_Connection -parameter {
    {pool "[::xo::db::defaultpool]"}
    {timeout 10}
}


DB_Connection instproc init {} {

    my instvar pool dbhandle timeout

    if { ![info exists pool] } {
	ns_log notice "[my info class] [self] : no pool error"
	set pool [::xo::db::defaultpool]
    }

    set dbhandle [::xo::db::gethandle $pool]

}



DB_Connection instproc destroy {} {

    my instvar pool dbhandle

    if { ![info exists pool] } {
	ns_log notice "[my info class] [self] : no pool error"
	set pool [::xo::db::defaultpool]
    }

    ::xo::db::releasehandle $dbhandle $pool

    next
}





DB_Connection instproc exists {sql} {

    my instvar dbhandle

    set setId [ns_db 0or1row ${dbhandle} ${sql}]
   
    if { ${setId} ne {} } {
	set result 1
	ns_set free ${setId}
    } else {
	set result 0
    }

    ns_db flush ${dbhandle}

    return ${result}
}


DB_Connection instproc beginTransaction {} {

    my instvar dbhandle

    ns_db dml ${dbhandle} "begin transaction;"
}

DB_Connection instproc abortTransaction {} {

    my instvar dbhandle

    ns_db dml ${dbhandle} "abort transaction;"
}

DB_Connection instproc commitTransaction {} {

    my instvar dbhandle

    ns_db dml ${dbhandle} "commit transaction;"
}

DB_Connection instproc endTransaction {} {

    my instvar dbhandle

    ns_db dml ${dbhandle} "end transaction;"
}

if { [::xo::kit::performance_mode_p] } {
    DB_Connection instproc do {sql} {
	my instvar dbhandle
	if {[catch {ns_db dml ${dbhandle} ${sql}} errMsg]} {
	    ns_log error "sql=$sql"
	    error $errMsg
	}
    }
} else {
    DB_Connection instproc do {sql} {
	ns_log notice "(dbconn) do sql=$sql"
	my instvar dbhandle
	if {[catch {ns_db dml ${dbhandle} ${sql}} errMsg]} {
	    ns_log error "sql=$sql"
	    error $errMsg
	}
    }
}


DB_Connection instproc queryDict {sql} {
    my instvar dbhandle
    if { [catch {set setId [ns_db select ${dbhandle} ${sql}]} errMsg] } {
	ns_log error "sql=$sql"
	error $errMsg
    }
    if {[string equal ${setId} ""]} { return "" }

    set result {}
    set names {}
    set count 0
    while {[ns_db getrow ${dbhandle} ${setId}]} {
	set row {}
	set maplist [ns_set array ${setId}]
	if { ${names} eq {} } {
	    foreach {key value} $maplist {
		lappend names $key
	    }
	}
	foreach {key value} $maplist {
	    lappend row ${value}
	}
	lappend result ${row}
	incr count
    }
    ns_set free ${setId}
    ns_db flush ${dbhandle}
    return [dict create count ${count} names ${names} rows ${result}]
}

proc rows_to_objs {mydict  {Class "my::Object"}} {
    set result {}
    dict with mydict {
	if { [info exists rows] } {
	    foreach row ${rows} {
		set obj [${Class} new]
		lappend result ${obj}
		foreach key ${names} value ${row} {
		    ${obj} set ${key} ${value}
		}
	    }
	}
    }
    return ${result}    
}

DB_Connection instproc query {sql {Class "my::Object"}} {
    set mydict [my queryDict ${sql}]
    return [rows_to_objs $mydict]
}

DB_Connection instproc old_query {sql {Class "my::Object"}} {
    my instvar dbhandle
    set setId [ns_db select ${dbhandle} ${sql}]
    if {[string equal ${setId} ""]} { return "" }
    set result {}
    while {[ns_db getrow ${dbhandle} ${setId}]} {
	set obj [${Class} new]
	lappend result ${obj}
	for { set i 0 } { ${i} < [ns_set size ${setId}] } { incr i } {
	    ${obj} set [ns_set key ${setId} ${i}] [ns_set value ${setId} ${i}]
	}
    }
    ns_set free ${setId}
    ns_db flush ${dbhandle}
    return ${result}
}




DB_Connection instproc 0or1row {sql {o ""}} {

    if { ${o} eq {} } {
	set o [my::Object new]
    }

    my instvar dbhandle

    set row [ns_db 0or1row ${dbhandle} ${sql}]
    if { $row eq {} } {
	return
    }
    for { set i 0 } { ${i} < [ns_set size ${row}] } { incr i } {
	set varname [ns_set key ${row} ${i}]
	if {![${o} exists ${varname}]} {
	    ${o} set ${varname} [ns_set value ${row} ${i}]
	}
    }
    ns_set free ${row}
    ns_db flush ${dbhandle}

    return ${o}
}


DB_Connection instproc 1row {sql {o}} {

    my instvar dbhandle

    set setId [ns_db 1row ${dbhandle} ${sql}]
    if {[info exists o]} {
	for { set i 0 } { ${i} < [ns_set size ${setId}] } { incr i } {
	    set varname [ns_set key ${setId} ${i}]
	    if {![${o} exists ${varname}]} {
		${o} set ${varname} [ns_set value ${setId} ${i}]
	    }
	}
	set result ${o}
    } else {
	set result [list]
	for { set i 0 } { ${i} < [ns_set size ${setId}] } { incr i } {
	    lappend result [ns_set key ${setId} ${i}] [ns_set value ${setId} ${i}]
	}
    }

    ns_set free ${setId}
    ns_db flush ${dbhandle}

    return ${result}
}

DB_Connection instproc getvalue {sql} {
    my instvar dbhandle

    set result ""
    set setId [ns_db 0or1row ${dbhandle} ${sql}]
    if { ${setId} ne {} } {
	set result [ns_set value ${setId} 0]
	ns_set free ${setId}
    }
    ns_db flush ${dbhandle}
    return ${result}

}

# plsql/plpgsql exec command
DB_Connection instproc pl {sql} {
    my instvar dbhandle

    set setId [ns_db 1row ${dbhandle} ${sql}]
    set result [ns_set value ${setId} 0]
    ns_set free ${setId}
    ns_db flush ${dbhandle}

    return ${result}
      
}

DB_Connection instproc check_src_list {list} {

    set new_list ""
    foreach {obj src} ${list} {
	lassign [split [string trim ${src}] .] ns name
	lappend new_list [list ${obj} ${src} [my exists "SELECT 1 FROM pg_namespace ns join pg_class c on (ns.oid=c.relnamespace) WHERE ns.nspname='${ns}' and c.relname='${name}' LIMIT 1"]]
    }
    return [join ${new_list}]
}
