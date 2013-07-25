namespace eval ::xo::db {;}

proc ::xo::db::defaultpool {} "return [ns_config ns/server/[ns_info server]/db defaultpool main]"

ns_log notice "defaultpool proc body = [info body ::xo::db::defaultpool]"

proc ::xo::db::gethandle {{pool ""}} {

    global t__db_pool_handle t__db_pool_handle_count

    if { ${pool} eq {} } {
	set pool [::xo::db::defaultpool]
    }

    if {[info exists t__db_pool_handle(${pool})]} {
	set dbhandle $t__db_pool_handle(${pool})
	incr t__db_pool_handle_count(${pool},${dbhandle})
    } else {
	###  -timeout $timeout
	set dbhandle  [ns_db gethandle ${pool}]
	set t__db_pool_handle(${pool}) ${dbhandle}
	set t__db_pool_handle_count(${pool},${dbhandle}) 1
	# scheduled procs do not have an ad_conn set by preferences::handler
#	set tz Europe/Athens
#	catch {	set tz [ClockMgr getLocalTZ] }
	#set tz "UTC"
	#ns_db dml ${dbhandle} "set time zone '${tz}';"
    }

    #ns_atclose "::xo::db::releasehandle $dbhandle $pool"
    return $dbhandle

}

proc ::xo::db::releasehandle {dbhandle {pool ""}} {
    global t__db_pool_handle t__db_pool_handle_count

    if { ${pool} eq {} } {
	set pool [::xo::db::defaultpool]
    }

    if {[info exists t__db_pool_handle(${pool})]} {
	incr t__db_pool_handle_count(${pool},${dbhandle}) -1
	if {$t__db_pool_handle_count(${pool},${dbhandle})} {
	    # do nothing
	} else {
	    ns_db releasehandle ${dbhandle}
	    catch "unset t__db_pool_handle(${pool})"
	    catch "unset t__db_pool_handle_count(${pool},${dbhandle})"
	    catch "unset dbhandle"
	}
    }

}

proc ::xo::db::withhandle {dbVar code_block {pool ""}} {
    upvar $dbVar db
    set db [::xo::db::gethandle ${pool}]
    set errno [catch { uplevel 1 $code_block } error]
    ::xo::db::releasehandle $db ${pool}

    # Unset dbh, so any subsequence use of this variable will bomb.
    if { [info exists db] } {
	unset db
    }
    
    # If errno is 1, it's an error, so return errorCode and errorInfo;
    # if errno = 2, it's a return, so don't try to return errorCode/errorInfo
    # errno = 3 or 4 give undefined results
    
    if { $errno == 1 } {
	
	# A real error occurred
	global errorInfo errorCode
	return -code $errno -errorcode $errorCode -errorinfo $errorInfo $error
    }
    
    if { $errno == 2 } {
	
	# The code block called a "return", so pass the message through but don't try
	# to return errorCode or errorInfo since they may not exist
	
	return -code $errno $error
    }
}

ad_proc ::xo::db::value {{-pool ""} {-cache ""} -default:optional -statement_name:optional sql} {

    if { ${cache} ne {} } {
	set found_p [nsv_exists __db_value ${cache}]
	if { $found_p } {
	    set value [nsv_get __db_value ${cache}]
	    return $value
	}
    }

    ::xo::db::withhandle db {
	set row [ns_db 0or1row $db $sql]
    } ${pool}

    if { $row eq {} } {
	if { [info exists default] } {
	    return $default
	}
	error "Selection did not return a value, and no default was provided"
    }
    set value [ns_set value $row 0]

    if { ${cache} ne {} } {
	nsv_set __db_value ${cache} ${value}
    }

    return ${value}

}

ad_proc ::xo::db::0or1row {-statement_name:optional -rowVar:optional -column_arrayVar sql} {

    if { [info exists column_arrayVar] && [info exists rowVar] } {
	return -code error "Can't specify both column_array and column_set"
    }

    if { [info exists column_arrayVar] } {
	upvar $column_arrayVar column_array
	if { [info exists column_array] } {
	    unset column_array
	}
    }

    if { [info exists rowVar] } {
	upvar $rowVar row
    }

    ::xo::db::withhandle db {
	set row [ns_db 0or1row $db $sql]
    }
    
    if { ${row} eq {} } {
	return 0
    }

    if { [info exists column_arrayVar] } {
	for { set i 0 } { $i < [ns_set size $row] } { incr i } {
	    set column_array([ns_set key $row $i]) [ns_set value $row $i]
	}
    } elseif { ![info exists rowVar] } {
	for { set i 0 } { $i < [ns_set size $row] } { incr i } {
	    upvar [ns_set key $row $i] value
	    set value [ns_set value $row $i]
	}
    }

    return 1
}

# ::xo::db::value "select nextval('t_${sequence}')"
proc ::xo::db::nextval {sequence} {

    ::xo::db::withhandle db {
	set row [ns_db 1row $db "select nextval('t_${sequence}')"]
    }
    return [ns_set value $row 0]
}


# table must be given in a fully qualified form,
# i.e. {pool}.{schema}.{tablename}
proc ::xo::db::touch {table} {
    return [nsv_incr __db_table ${table}]
}






proc ::xo::db::table_exists_p {table} {

    lassign [split ${table} {.}] pool schema tablename

    set exists_p [::xo::db::value -pool ${pool} -default 0 [subst -nocommands {
	SELECT 1 
	FROM pg_namespace ns JOIN pg_class c on (ns.oid=c.relnamespace)
	WHERE ns.oid=c.relnamespace 
	AND ns.nspname='${schema}'
	AND c.relname='${tablename}'
	LIMIT 1
    }]]

    return ${exists_p}

}



    proc ::xo::db::get_table_version {table} {

	set found_p [nsv_exists __db_table ${table}]

    if { ${found_p} } {	
	set version [nsv_get __db_table ${table}]
	return ${version} 
    }

    # checking whether the table exists
    # if it exists, it returns 1, otherwise 0
    set exists_p [::xo::db::table_exists_p ${table}]
    if { ${exists_p} } {
	return [::xo::db::touch ${table}]
    } else {
	return 0
    }

}
