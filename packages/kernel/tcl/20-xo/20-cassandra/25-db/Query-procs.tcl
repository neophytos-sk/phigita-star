package require crc16

namespace eval ::xo::db {;}
namespace eval ::xo::db::md {;}


proc ::xo::db::md::list_aggtables {} {
    return [nsv_array names AGGTABLE]
}
proc ::xo::db::md::describe_aggtable {{pattern ""}} {
    return [nsv_array get AGGTABLE {*}$pattern]
}

proc ::xo::db::md::list_memtables {} {
    return [nsv_array names MEMTABLE]
}
proc ::xo::db::md::describe_memtable {{pattern ""}} {
    return [nsv_array get MEMTABLE {*}$pattern]
}

proc ::xo::db::list_elements {memtable} {
    return [nsv_array names $memtable]
}

### 300000 ms = 300 s = 5 minutes
proc ::xo::db::list_expired_memtables {pattern {threshold_ms "300000"}} {
    set current_ts [clock milliseconds]
    set result ""
    foreach {name mydict} [::xo::db::md::describe_memtable {*}$pattern] {
	set loaded_ts [dict get $mydict loaded_ts]
	if { $current_ts - $loaded_ts > $threshold_ms } {
	    lappend result $name
	}
    }
    return $result
}

proc ::xo::db::flush_memtable {arrayName} {
    ns_log notice "flushing $arrayName"
    foreach aggtable [nsv_array names AGGTABLE "${arrayName}*"] {
	nsv_unset AGGTABLE $aggtable
    }
    nsv_unset MEMTABLE $arrayName
    nsv_unset $arrayName
}


proc ::xo::db::flush_expired_memtables {{threshold_ms "300000"}} {
    foreach memtable [::xo::db::list_expired_memtables "*" $threshold_ms] {
	::xo::db::flush_memtable $memtable
    }
}

### not used at the moment
proc ::xo::db::parseCoordinates {coords} {
    lassign [lreverse [split ${coords} {,}]] y x
    lassign [split ${x} {!}] keyspace key
    lassign [split ${y} {!}] cf column_path
    return [list $keyspace $key $cf $column_path]
}

proc ::xo::db::get_count {x y_parent {predicate ""}} {
    lassign [split ${x} {!}] keyspace key
    lassign [split ${y_parent} {.}] cf y_path    

    set pathexp ""
    if { $keyspace ne {} } {
	set pathexp [list "$keyspace $key"]
    }
    set ds [::db::Set new \
		  -pathexp ${pathexp} \
		  -select {{count(1) as cnt_items}} \
		  -type $cf \
		  -limit 1 \
		  -noinit]

    if { $predicate ne {} } {
	$ds set where [${cf} predicate_to_sql ${predicate}]
    }

    # aggregate
    set arrayName "DATA:${x}:${cf}.COUNT.[$cf predicate_to_hash ${predicate}]"
    ###set arrayName "TOP(${limit}).${x}.${cf}"
    set loaded_p [nsv_exists AGGTABLE $arrayName]
    set refresh_p 0
    if { $loaded_p } {
	set mydict [nsv_get AGGTABLE $arrayName]
	set vc0 [dict get $mydict vector_clock]
	set vc1 [$ds getVectorClock]
	if { $vc0 ne $vc1 } {
	    set refresh_p 1
	    ns_log notice "AGGTABLE $arrayName needs to refresh..."
	}
    }
    if { !$loaded_p || $refresh_p } {
	###ns_log notice "AGGTABLE $arrayName loaded_p=$loaded_p refresh_p=$refresh_p"
	set mydict [$ds loadRows]
	#$ds debug
	# change me to any field, indexed by any sortField
	dict with mydict {
	    # it contains a single value, the count
	    set result $rows
	    nsv_set AGGTABLE $arrayName [list vector_clock [$ds getVectorClock] count $result loaded_ts [clock milliseconds]]
	}
    } else {
	set result [dict get $mydict count]
    }
    return $result
}


### ::xo::db::get_cell User:814 Blog_Item:123
proc ::xo::db::get_cell {x y {pk "id"} {consistency_level "1"}} {
    lassign [split ${x} {!}] keyspace key
    lassign [split ${y} {!}] cf column_path

    set pathexp ""
    if { $keyspace ne {} } {
	set pathexp [list "$keyspace $key"]
    }
    set data [::db::Set new \
		  -pathexp ${pathexp} \
		  -type $cf \
		  -noinit]

    set arrayName "DATA:${x}:${cf}"
    set loaded_p [nsv_exists MEMTABLE $arrayName]

    ### TEST TEST TEST
    set refresh_p 0
    if { $loaded_p } {
	set mydict [nsv_get MEMTABLE $arrayName]
	set vc0 [dict get $mydict vector_clock]
	set vc1 [$data getVectorClock]
	if { $vc0 ne $vc1 } {
	    set refresh_p 1
	    ns_log notice "$arrayName needs to refresh..."
	}
    }
    ### TEST TEST TEST
    if { !$loaded_p || $refresh_p } {
	set data [::xo::db::get_slice ${x} ${cf} {*}${pk}]
	array set map [$data getIndexMapBy $pk]
    }

    set rows [list]
    set record_found_p [nsv_exists ${arrayName} ${column_path}]
    if { !${record_found_p} }  {
	rp_returnnotfound
	return
    } else {
	set record [nsv_get ${arrayName} ${column_path}]
	lappend rows $record
    }

    set names [::xo::fun::map x [$cf getDBSlots] {$x dbname}]
    dict set mydict names $names
    dict set mydict rows $rows
    set o [rows_to_objs $mydict $cf]

    return $o

    if {[info exists map($column_path)]} {
	return $map($column_path)
    } else {
	rp_returnnotfound
	ns_log notice "x=$x y=$y map->names=[array names map]"
	return
    }
}


proc ::xo::db::get_slice_top {x y_parent limit sortField {sortDir "increasing"} {pk "id"} {predicate ""} {consistency_level "1"}} {
    lassign [split ${x} {!}] keyspace key
    lassign [split ${y_parent} {.}] cf y_path

    set pathexp ""
    if { $keyspace ne {} } {
	set pathexp [list "$keyspace $key"]
    }

    set arrayName "DATA:${x}:${cf}.TOP:${limit}.BY:${sortField}-${sortDir}.PRED:[crc::crc16 -format %X ${predicate}]"

    set ds [::db::Set new \
		-cache $arrayName \
		-pathexp ${pathexp} \
		-type $cf \
		-limit $limit \
		-order "${sortField} [::util::decode $sortDir "increasing" "asc" "decreasing" "desc" "__INVALID__"]" \
		-where [${cf} predicate_to_sql ${predicate}] \
		-noinit]


    $ds load
    #ns_log notice sql=[$ds set sql],result=[$ds set result]
    return $ds

    ### TODO: load an index into memory


    # aggregate

    ###set arrayName "TOP(${limit}).${x}.${cf}"
    set loaded_p [nsv_exists AGGTABLE $arrayName]
    set refresh_p 0
    if { $loaded_p } {
	set mydict [nsv_get AGGTABLE $arrayName]
	set vc0 [dict get $mydict vector_clock]
	set vc1 [$ds getVectorClock]
	if { $vc0 ne $vc1 } {
	    set refresh_p 1
	    ns_log notice "AGGTABLE $arrayName needs to refresh..."
	}
    }
    if { !$loaded_p || $refresh_p } {
	###ns_log notice "AGGTABLE $arrayName loaded_p=$loaded_p refresh_p=$refresh_p"
	set ds [::xo::db::get_slice $x $y_parent $pk $predicate]
	# change me to any field, indexed by any sortField
	set sortedList [$ds sort $sortField $sortDir]
	$ds set result [lrange $sortedList 0 [expr {${limit}-1}]]
	nsv_set AGGTABLE $arrayName [list vector_clock [$ds getVectorClock] indexlist [::xo::fun::map x [$ds set result] {$x set $pk}] names [::xo::fun::map obj [$cf getDBSlots] {$obj dbname}] loaded_ts [clock milliseconds]]
    } else {
	set rows ""
	foreach id [dict get $mydict indexlist] {
	    lappend rows [nsv_get DATA:${x}:${cf} ${id}]
	}
	dict set mydict rows $rows
	$ds set result [rows_to_objs $mydict $cf]
    }
    return $ds
}

### ::xo::db::get_slice User:814 Blog_Item
### ::xo::db::get_slice User:814 Blog_Item.FTS:hello-world
### ::xo::db::get_slice User:814 Blog_Item_Label "id in {232 343 454 565 676 787}"
### ::xo::db::get_slice User:814 Blog_Item "since ts(1234567890)"
### ::xo::db::get_slice User:814 Blog_Item "offset 50 limit 10"
### ::xo::db::get_slice User:814 Blog_Item "range D..K"
proc ::xo::db::get_slice {x y_parent {pk "id"} {predicate ""} {consistency_level "1"}} {
    lassign [split ${x} {!}] keyspace key
    lassign [split ${y_parent} {.}] cf y_path

    ns_log notice "get_slice x=$x y_parent=$y_parent"

    set pathexp ""
    if { $keyspace ne {} } {
	set pathexp [list "$keyspace $key"]
    }
    set data [::db::Set new \
		  -pathexp ${pathexp} \
		  -type $cf \
		  -order "$pk" \
		  -noinit]
    
    set arrayName "DATA:${x}:${cf}"
    set loaded_p [nsv_exists MEMTABLE $arrayName]
    set refresh_p 0
    if { $loaded_p } {
	set mydict [nsv_get AGGTABLE $arrayName]
	set vc0 [dict get $mydict vector_clock]
	set vc1 [$data getVectorClock]
	if { $vc0 ne $vc1 } {
	    set refresh_p 1
	    ns_log notice "$arrayName needs to refresh..."
	}
    }
    if { !$loaded_p || $refresh_p } {
	
	##$data load_slice ${x} ${cf}
	foreach connector [$cf connectors] {
	    ns_log notice "connector tablename=[$cf getTableName]"
	    $data lappend select [$connector getSelectExpression -conn [$data getConn] -op eq-noquote ${pathexp} "[$cf getTableName].id"]
	}

	set mydict [$data loadRows]
	### rows_to_objs should use ::$cf but then we have trouble with ::db::View (s) such as CC_Users
	$data set result [rows_to_objs $mydict $cf]
	foreach connector [$cf connectors] {
	    $connector transform [$data set result]
	}


	dict with mydict {
	    #set index [lsearch -exact $names $pk]
	    #ns_log notice "index=$index names=$names pk=$pk"
	    foreach o [$data set result] {
		#dict set row ms [clock milliseconds]
		#dict set row size [string bytelength $row]
		
		#set myarray([lindex $row $index]) $row
		set myarray([$o set $pk]) [$o toRecord]
	    }
	    #ns_log notice myarray=[array names myarray]
	    set vector_clock [$data getVectorClock]
	    nsv_array set $arrayName [array get myarray]
	    nsv_set MEMTABLE $arrayName [list vector_clock $vector_clock size [array size myarray] names [::xo::fun::map obj [$cf getDBSlots] {$obj dbname}] loaded_ts [clock milliseconds]]
	}
	ns_log notice "loading... x=${x} cf=$cf arrayName=$arrayName"
    } else {
	set arraymap [nsv_array get $arrayName]
	#ns_log notice arraymap=$arraymap
	set rows ""
	foreach {id record} $arraymap {
	    lappend rows $record
	}
	#ns_log notice [dict get $mydict names]
	dict set mydict rows $rows
	$data set result [rows_to_objs $mydict $cf]
    }
    #ns_log notice mydict=$mydict
    #ns_log notice "$arrayName loaded_p=$loaded_p cf=$cf"

    if { $predicate ne {} } {
	$data set result [::xo::fun::filter [$data set result] x [join $predicate { && }]]
    }
    return $data
}

proc ::xo::db::insert {x y mydict timestamp {consistency_level "1"}} {
    lassign [split ${x} {:}] keyspace key
    lassign [split ${y} {.}] cf column_path
    
    set pathexp [list "$keyspace $key"]
    set o [$cf new -mixin ::db::Object -pathexp $pathexp]
    foreach {key value} $mydict {
	$o set $key $value
    }
    $o do self-insert
    ### bg_sendOneWay "insert $mydict"
}

array set ConsistencyLevel {
    ZERO 0
    ONE 1
    QUORUM 2
    DCQUORUM 3
    DCQUORUMSYNC 4
    ALL 5
}






ns_schedule_proc 60 ::xo::db::flush_expired_memtables


