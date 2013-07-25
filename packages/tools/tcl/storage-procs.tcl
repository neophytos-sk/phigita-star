namespace eval ::xo::storage {;}


proc ::xo::storage::default_dbname {} {
    #  [ad_conn user_id]
    # FIX: this is called by dumpdb scheduled proc
    # 
    return "SIMPLEX-814"
}

proc ::xo::storage::filename {dbname} {
    return [file join /web/data/cbt_db/ ${dbname}.cbt_db]
}

proc ::xo::storage::systemdb {} {
    return "SYSTEM"
}

proc ::xo::storage::init {} {

    set dbname [::xo::storage::default_dbname]
    if { [::cbt::id ${dbname}.cbt_db] ne {} } return

    set db [::cbt::create $::cbt::STRING_KEYS "${dbname}.cbt_db"]

    set sysdb [::cbt::id [::xo::storage::systemdb]]
    if { $sysdb eq {} } {
	# TODO: make sure ::cbt::create handles concurrency (e.g. via a mutex lock)
	set sysdb [::cbt::create $::cbt::STRING_KEYS [::xo::storage::systemdb]]
    }

    set str "${dbname}=${db}"
    if { ![::cbt::exists $sysdb $str] } {
	::cbt::insert $sysdb $str
    }

    set filename [::xo::storage::filename ${dbname}]
    if { [file exists $filename] } {
	::xo::storage::restore $db $filename
	# file delete $filename
    }

}

proc ::xo::storage::dump {db filename} {

    set tmpfile ${filename}-[clock milliseconds]
    ::cbt::dump $db $tmpfile
    file rename -force -- $tmpfile $filename


}

proc ::xo::storage::dumpall {} {
    if { [catch {::xo::storage::__dumpall} errMsg] } {
	ns_log error $errMsg
    }
}

proc ::xo::storage::__dumpall {} {

    set sysdbname [::xo::storage::systemdb]
    set sysdb [::cbt::id $sysdbname]
    if { $sysdb eq {} } { return }

    # dump system database

    ::xo::storage::dump $sysdb [::xo::storage::filename $sysdbname]

    # dump all user databases

    ns_log notice "dumping all critbit tree databases..."

    set prefix ""
    set direction 0
    set limit ""
    set exact ""
    set dblist [::cbt::prefix_match $sysdb $prefix $direction $limit $exact]
    foreach str $dblist {
	lassign [split $str {=}] dbname db
	set filename [::xo::storage::filename $dbname]
	set db [::cbt::id ${dbname}.cbt_db]
	ns_log notice "dump $dbname to $filename (handle=$db)"

	# TODO: sync number of sessions
	set user_id "814"
	set num_sessions_key "STATE.${user_id}.num_sessions"
	# TODO: check nsv_set below, it used used to *get* the value
	::xo::storage::SET ${num_sessions_key} [nsv_set __api ${num_sessions_key}]


	::xo::storage::dump $db $filename
    }
}

proc ::xo::storage::restore {db filename} {
    ::cbt::restore $db $filename

    set user_id [ad_conn user_id]
    set key "STATE.${user_id}.num_sessions"
    set found_p [::cbt::exists $db "${key}="]
    if { $found_p } {
	set value [::cbt::get $db "${key}="]
	set index [expr {1+[string length ${key}]}]
	set value [string range $value $index end]
	nsv_set __api $key $value
    }

}

proc ::xo::storage::PUT {key value} {
    set dbname [::xo::storage::default_dbname]
    set db [::cbt::id "${dbname}.cbt_db"]
    set value [encoding convertto utf-8 $value]
    set result [::cbt::insert $db ${key}=${value}]
    return [::util::map2json id $key result $result]
}

proc ::xo::storage::GET {key} {
    set dbname [::xo::storage::default_dbname]
    set db [::cbt::id "${dbname}.cbt_db"]
    set found_p [::cbt::exists $db "${key}="]
    if { $found_p } {
	set index [expr {1+[string length ${key}]}]
	set value [::cbt::get $db ${key}=]
	#set value [encoding convertfrom utf-8 $value]
	set value [string range $value $index end]
    } else {
	set value ""
    }
    return [::util::map2json found_p $found_p id $key data $value]
}

proc ::xo::storage::prefix_match {prefix {direction ""} {limit ""} {exact "1"} {format "json"}} {
    set dbname [::xo::storage::default_dbname]
    set db [::cbt::id ${dbname}.cbt_db]	
    set elements [::cbt::prefix_match $db $prefix $direction $limit $exact]
    set elements [encoding convertfrom utf-8 $elements]
    set data [list]
    foreach el $elements {
	set index [expr { 1 + [string first {=} $el] }]
	if { $format eq {json} } {
	    lappend data \{[string range $el $index end]\}
	} else {
	    lappend data [string range $el $index end]
	}
    }
    return [::util::map2json prefix $prefix L:data $data]
}

proc ::xo::storage::prefix_delete {prefix} {
    set dbname [::xo::storage::default_dbname]
    set db [::cbt::id "${dbname}.cbt_db"]	
    set result [list]
    foreach item [::cbt::prefix_match $db $prefix] {
	set deleted [::cbt::delete $db [encoding convertfrom utf-8 $item]]
	lappend result $item-$deleted
    }
    # TODO: delete_one id so that id corresponds to the id in the response
    return [::util::map2json id $prefix result $result]
}

proc ::xo::storage::SET {key value} {
    ::xo::storage::prefix_delete "${key}="
    set json [::xo::storage::PUT $key $value]
}

proc ::xo::storage::INCR {key} {
    return [nsv_incr __api $key]
}

proc ::xo::storage::DECR {key} {
    # nsv_incr array key ?count?
    return [nsv_incr __api $key {-1}]
}

