# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here

namespace eval ::persistence::orm {
    namespace export \
        to_path \
        from_path \
        insert \
        init_type \
        find_by_id \
        find_by_axis \
        find \
        get \
        mtime

    #exists

}

proc ::persistence::orm::init_type {} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx

    # log "persistence (ORM): initializing [namespace __this] ensemble/type"

    assert { vcheck("ks","required notnull sysdb_slot_name") }
    assert { vcheck("cf","required notnull sysdb_slot_name") }
    assert { vcheck("pk","required notnull sysdb_slot_name") }

    set nsp [namespace __this]
    set oid [::sysdb::object_type_t find $nsp]

    if { 0 && $exists_p } {
        # TODO: integrity check
    } else {
        ::persistence::define_ks $ks
        foreach {index_name index_item} [array get idx] {
            set axis $index_name
            ::persistence::define_cf $ks $cf.$axis
        }

        array set item [list ks $ks cf $cf nsp $nsp]
        ::sysdb::object_type_t insert item
    }
}

proc ::persistence::orm::to_path_by {axis args} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf

    if {1} {
        # if datatype of first arg/attribute exceeds a certain threshold
        # then we map the attribute values to row keys
        set args [lassign $args row_key]
        #set column_path [::persistence::to_column_path $args]
        set column_path [join $args {/}]
    } else {
        # check that supercolumns are allowed for the given axis
        #set column_path [::persistence::to_column_path $args]
        set column_path [join $args {/}]
        set row_key "__default__"
    }

    set target "${ks}/${cf}.${axis}/${row_key}/+/${column_path}"

    #puts target=$target

    return $target
}

proc ::persistence::orm::to_path {id} {
    variable [namespace __this]::pk
    set axis "by_$pk"
    return [to_path_by $axis $id {*}$id]
    #return [to_path_by $axis $id "__data__"]
}

proc ::persistence::orm::from_path {path} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx

    set column_path [lassign [split ${path} {/}] _ks _cf_axis row_key __delimiter__]
    lassign [split $_cf_axis {.}] _cf axis

    assert { $ks eq ${_ks} }
    assert { $cf eq ${_cf} }
    assert { exists("idx($axis)") }

    # process index attributes
    set args [split $column_path {/}]
    if { $row_key ne {__default__} } {
        set args [concat [split ${row_key} { }] $args]
    }
    
    set result [list]
    array set idx $idx($axis)
    foreach attname $idx(atts) {
        set args [lassign $args attvalue]
        lappend result $attname $attvalue
    }

    # TODO: case when (#args > 1), process supercolumns

    assert { [llength $args] == 1 }

    set args [lassign $args last_arg]

    #if { $last_arg ne {__data__} } {
        # a link, the pk
        lappend result $pk $last_arg
    #}

    return $result
}

proc ::persistence::orm::insert {itemVar {optionsVar ""}} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx
    variable [namespace __this]::att

    upvar $itemVar item

    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    set attributes [array names att]

    # compute derived attributes
    set derived_attributes [list]
    foreach attname $attributes {
        array set attinfo $att($attname)
        if { [info exists attinfo(func)] && ![info exists item($attname)] } {
            # log $attinfo(func)
            set item($attname) [apply $attinfo(func) item]
        }
        array unset attinfo
    }


    # validate attribute values
    set option_validate_p [get_value_if options(validate_p) "1"]
    foreach attname $attributes {
        array set attinfo $att($attname)

        set optional_p [get_value_if attinfo(null) "1"]
        if { $optional_p && [get_value_if item($attname) ""] eq {} } {
            array unset attinfo
            continue
        }
        assert { exists("item($attname)") }

        set maxlen [get_value_if attinfo(maxlen) ""]
        if { $maxlen ne {} } {
            assert { [string length $item($attname)] < $maxlen }
        }

        set datatype [get_value_if attinfo(type) ""]
        if { $datatype ne {} } {
            assert { [pattern matchall [list $datatype] item($attname)] } {
                printvars
            }

        }

        array unset attinfo
    }

    set target [to_path $item($pk)]

    # log target=$target

    # TODO: encode item data
    set data [array get item]

    ::persistence::insert_column $target $data
    
    foreach {index_name index_item} [array get idx] {
        if { $index_name eq "by_$pk" } {
            continue
        }

        array set idxinfo $index_item
        set atts $idxinfo(atts)

        set row_key [list]
        foreach attname $atts {
            lappend row_key $item($attname)
        }

        set axis $index_name
        set src [to_path_by ${axis} ${row_key} $item($pk)]
        ::persistence::insert_link $src $target

     }

}

# TODO: options or filter tags for get proc
# get some_oid {{offset ""} {limit ""} {order_by ""}}
proc ::persistence::orm::get {oid {exists_pVar ""}} {
    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    set exists_p [::persistence::exists_data_p $oid]
    if { $exists_p } {
        return [::persistence::get_data $oid]
    } else {
        error "no such oid (=$oid) in storage system (=mystore)"
    }
}

# TODO: expand/unfold oid to column oids (in case it is a supercolumn or row oid)
# 0or1row -
# * returns a single record for the given oid, if it exists
proc ::persistence::orm::0or1row {where_clause_argv {exists_pVar ""}} {
    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    set slicelist [find $where_clause_argv]

    set llen [llength $slicelist]

    if { $llen > 1 } {
        error "persistence (ORM): more records in slice than expected (0or1row)"
    }

    # note that lindex returns "" if no elements in the list
    return [lindex $slicelist 0]

}


# retrieves a record without any explicit ordering
proc ::persistence::orm::take {oid {num 1}} {
    set data [get $oid]
    set llen [llength $data]
    if { $llen < $num } {
        error "not enough items: oid (=$oid), req (=$num), llen (=$llen)"
    }
    return [lrange [get $oid] 0 [expr { $num - 1 }]]
}

proc ::persistence::orm::mtime {oid} {
    return [::persistence::mtime $oid]
}

proc ::persistence::orm::find_by_id {value} {
    variable [namespace __this]::pk
    variable [namespace __this]::att

    array set attinfo $att($pk)
    foreach datatype $attinfo(type) {
        assert { vcheck("value",$datatype) }
    }

    set querypath [to_path $value]
    set oid [::persistence::get_column $querypath]

    return $oid
}

proc ::persistence::orm::find_by_axis {argv {predicate ""}} {
    variable [namespace __this]::idx

    set argc [llength $argv]
    assert { $argc in {5 4 3 2 1} }

    log "argc = $argc"
    
    if { $argc >= 3 } {

        lassign $argv attname attvalue id dataVar exists_pVar
        set varname ""
        if { $dataVar ne {} } {
            upvar $dataVar _
            set varname _
        }
        if { $exists_pVar ne {} } {
            upvar $exists_pVar exists_p
        }
        set path [to_path_by by_$attname $attvalue $id]
        set oid [::persistence::get_column $path ${varname} exists_p]
        return $oid

    } elseif { $argc == 2 } {

        lassign $argv attname attvalue
        set path [to_path_by by_$attname $attvalue]
        set slicelist [::persistence::get_slice $path $predicate]
        return $slicelist

    } elseif { $argc == 1 } {

        lassign $argv attname
        set path [to_path_by by_$attname]
        return [::persistence::multiget_slice $path $predicate]

    }

}


# find -
# * finds all nodes matching some conditions
proc ::persistence::orm::find {{where_clause_argv ""} {optionsVar ""}} {
    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    if { $where_clause_argv eq {} } {

        # __find_all starting from the given axis
        variable [namespace __this]::pk
        variable [namespace __this]::idx

        set axis_attname [value_if options(axis_attname) ${pk}]
        assert { exists("idx(by_${axis_attname})") }
        set slicelist [find_by_axis ${axis_attname}]

    } else {

        set n_clauses [llength $where_clause_argv]
        if { $n_clauses == 1 && [llength [lindex $where_clause_argv 0]] == 1 } {
            return [find_by_id [lindex $where_clause_argv 0]]
        } else {
            set find_by_axis_args [list]
            set attname [__choose_axis $where_clause_argv find_by_axis_args]
            set predicate [__rewrite_where_clause $attname $where_clause_argv]
            log "chosen axis (attribute) = $attname"
            log "chosen axis (args) = $find_by_axis_args"
            log "rewritten predicate = $predicate"
            set slicelist [find_by_axis $find_by_axis_args $predicate]
        }

    }

    set option_expand_p [get_value_if options(expand_p) "1"] 
    set option_order_by [get_value_if options(order_by) ""]

    if { $option_expand_p } {
        set slicelist [::persistence::expand_slice $slicelist]
    }

    if { $option_order_by ne {} } {
        assert { $option_expand_p }
        
        lassign $option_order_by sort_attname sort_direction

        assert { $sort_direction in {increasing decreasing} }

        set slicelist [::persistence::sort $slicelist $sort_attname $sort_direction]
    }

    if { exists("options(offset)") || exists("options(limit)") } {
        set offset [get_value_if options(offset) "0"]
        set limit [get_value_if options(limit) "end"]
        set slicelist [lrange $slicelist $offset $limit]
    }

    return $slicelist
}

proc ::persistence::orm::__choose_axis {argv find_by_axis_argsVar} {
    variable [namespace __this]::pk
    variable [namespace __this]::idx

    upvar $find_by_axis_argsVar find_by_axis_args

    foreach arg $argv {
        lassign $arg attname op attvalue
        if { $attname eq $pk } { 
            continue
        }
        if { $op eq {=} && [info exists idx(by_$attname)] } {
            set find_by_axis_args [list $attname $attvalue]
            return $attname
        }
    }
    set find_by_axis_args $pk
    return $pk
}

# TODO: reorder/group expressions in argv/predicate
# based on the idx/counter we have at our disposal
# rewrites expressions in terms of persistence::predicate=* procs
proc ::persistence::orm::__rewrite_where_clause {axis_attname argv} {
    set predicate [list]
    while { $argv ne {} } {
        set argv [lassign $argv arg]
        lassign $arg attname op attvalue

        if { $op eq {=} } {
            if { $attname eq $axis_attname } {
                continue
            }
            set path [to_path_by by_${attname} ${attvalue}]
            lappend predicate [list "maybe_in_path" [list $path]]
            lappend predicate [list "in_path" [list $path]]
        } else {
            error "persistence (ORM): op (=$op) not implemented yet"
        }
    }
    return $predicate
}


if {0} {
    proc write_x {dataVar type value} {
        upvar $dataVar data
        set len [string bytelength $value]
        append data [binary format i $len]
        append data $value
        return
    }

    proc read_x {dataVar valueVar} {
        upvar $dataVar data
        upvar $valueVar value

        set binval ""
        binary scan $binval i len
        set value [string range $data $i [expr { $i + $len }]]
        return
    }

    proc ::persistence::orm::encode {itemVar dataVar} {
        variable [namespace __this]::att

        upvar $itemVar item
        upvar $dataVar data

        set data ""
        set names [array names item]
        foreach name $names {
            array set attinfo $att($name)
            set datatype [value_if attinfo(type) "varchar"]
            write_x data $datatype $item($name)
            array unset attinfo
        }
    }

    proc ::persistence::orm::decode {dataVar itemVar} {
        upvar $dataVar
        upvar $itemVar
        
        array set item [list]
        set datalen [string bytelength $data]
        while { $i < $datalen } {
            incr i [read_x data name]
            incr i [read_x data item($name)]
        }

        return
    }

    # first -
    # * retrieves the first record ordered by the primary key
    # * you can pass a numerical argument to return up to that
    #   number of results
    proc ::persistence::orm::first {oid {num 1}} {}

    # last -
    # * retrieves the last record ordered by the primary key
    # * you can pass a numerical argument to return up to that
    #   number of results
    proc ::persistence::orm::last {oid {num 1}} {}


}

