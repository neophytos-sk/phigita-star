namespace eval ::templating::data {;}

if { [::templating::config::get_option "data_object_type"] eq {DICT} } {

    # for TCL dictionaries
    proc ::templating::data::datadict_to_objs {datadictVar} {
	upvar $datadictVar datadict
	set names [dict get $datadict names]
	set rows [dict get $datadict rows]
	set result [list]
	foreach row ${rows} {
	    set rowdict [dict create]
	    foreach key ${names} value ${row} {
		dict set rowdict ${key} ${value}
	    }
	    lappend result ${rowdict}
	}
	return ${result}
    }

} elseif { [::templating::config::get_option "data_object_type"] eq {NSF} } {

    # for NSF objects
    proc ::templating::data::datadict_to_objs {datadictVar} {
	upvar $datadictVar datadict
	return [::rows_to_objs $datadict "::my::Object"]
    }

} else {

    error "unknown config option value for 'data_object_type': must be 'NSF' or 'DICT'"
}

proc data_from_sql_script {storeId pool sql_script {cache_expr ""}} {

    #::xo::kit::log --->>> (before) storeId=$storeId: sql_script=$sql_script

    # Note:
    # 1. sql at this point contains tcl variables to ::__data__
    #    and calls to ad_conn 
    # 2. get the vector clock, db::get_sql_table appends
    #    an element to __vc every time it is called
    set __vc [list] 
    set sql [subst -nobackslashes $sql_script]
    set vector_clock_now [join $__vc {.}]

    set cache ""
    set timeout ""
    if { $cache_expr ne {} } {
	set num_of_refs 0
	lassign $cache_expr cache num_of_refs timeout
	if { $num_of_refs } {
	    set cache [subst -nobackslashes -nocommands $cache_expr]
	}
    }

    if { $cache ne {} && $vector_clock_now eq {} } {
	error "you cannot have an empty vector_clock_now when using the cache"
    }

    #::xo::kit::log cache_expr=$cache_expr
    if { $cache ne {} } {

	# used to check if data in cache is still valid
	# but also to set the cache timestamp 
	set clock_seconds_now [clock seconds]

	set found_p [nsv_exists __datastore ${cache}]
	if { $found_p } {
	    set rows [nsv_get __datastore ${cache}]
	    set valid_cache_p 1

	    # check clock_seconds_now Vs clock_seconds_cache + timeout
	    if { $timeout ne {} } {

		set clock_seconds_cache [dict get $rows clock_seconds]
		if { ${clock_seconds_now} > ${clock_seconds_cache} + ${timeout} } {
		    set valid_cache_p 0
		}

	    }

	    # check vector_clock_now Vs vector_clock_cache
	    if { ${valid_cache_p} } {
		set vector_clock_cache [dict get $rows vector_clock]
		if { $vector_clock_now eq $vector_clock_cache } {
		    set rowcount [dict get $rows count]
		    set ::__data__(${storeId},rowcount) ${rowcount}
		    return [::templating::data::datadict_to_objs rows]
		}
	    }
	}
    }

    # Execute SQL query
    set rows ""
    if { [catch {
	set conn [DB_Connection new -pool $pool]
	set rows [${conn} queryDict ${sql}]

	if { $cache ne {} } {
	    dict set rows vector_clock $vector_clock_now
	    dict set rows clock_seconds $clock_seconds_now
	}

	$conn destroy
	if { $cache ne {} } {
	    nsv_set __datastore ${cache} $rows
	}
    } errMsg] } {
	error "Failed to load data (vector_clock_now=${vector_clock_now}) errMsg=$errMsg sql=${sql}"
    } 

    set rowcount [dict get $rows count]
    set ::__data__(${storeId},rowcount) ${rowcount}

    return [::templating::data::datadict_to_objs rows]
}
