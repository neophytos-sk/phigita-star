# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here

namespace eval ::persistence::orm {
    namespace export \
        to_path \
        from_path \
        init_type \
        find_by_id \
        find_by_axis \
        find \
        get \
        mtime \
        1row \
        0or1row \
        insert \
        delete

    #exists

}

proc ::persistence::orm::init_type {} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx
    variable [namespace __this]::att
    variable [namespace __this]::__attributes
    variable [namespace __this]::__derived_attributes
    variable [namespace __this]::__attinfo
    variable [namespace __this]::__indexes
    variable [namespace __this]::__idxinfo

    ## 
    # helpers and speedups
    #

    # attributes

    set __attributes [array names att]
    set __derived_attributes [list]
    array set __attinfo [list]

    foreach attname $__attributes {
        array set attinfo $att($attname)

        set type [get_value_if attinfo(type) ""]
        set func [get_value_if attinfo(func) ""]
        set null [get_value_if attinfo(null) "1"]
        set maxlen [get_value_if attinfo(maxlen) ""]

        set __attinfo(${attname},type) $type
        set __attinfo(${attname},func) $func
        set __attinfo(${attname},null) $null
        set __attinfo(${attname},maxlen) $maxlen

        if { $func ne {} } {
            lappend __derived_attributes $attname
        }

        array unset attinfo
    }

    # indexes
    set __indexes [array names idx]
    array set __idxinfo [list]
    foreach idxname $__indexes {
        array set idxinfo $idx($idxname)

        set atts [get_value_if idxinfo(atts) ""]
        set type [get_value_if idxinfo(type) ""]

        assert { $atts ne {} }
        # TODO: assert { $type ne {} }

        set __idxinfo(${idxname},atts) $atts

        array unset idxinfo
    }



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

    return $target
}

proc ::persistence::orm::to_path {id} {
    variable [namespace __this]::pk
    set axis "by_$pk"
    return [to_path_by $axis $id {*}$id]
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

# to_row_key_by -
# * raises an error if any of the pk attributes
#   is missing from the given item
#
proc ::persistence::orm::to_row_key_by {idxname itemVar} {
    variable [namespace __this]::__idxinfo

    upvar $itemVar item
    set atts $__idxinfo(${idxname},atts)

    set row_key [list]
    foreach attname $atts {
        lappend row_key $item($attname)
    }
    return $row_key
}


proc ::persistence::orm::insert {itemVar {optionsVar ""}} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx
    variable [namespace __this]::att
    variable [namespace __this]::__attributes
    variable [namespace __this]::__derived_attributes
    variable [namespace __this]::__attinfo
    variable [namespace __this]::__indexes
    variable [namespace __this]::__idxinfo

    upvar $itemVar item

    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    # compute derived attributes
    foreach attname $__derived_attributes {
        set func $__attinfo(${attname},func)
        if { $func ne {} && ![info exists item($attname)] } {
            set item($attname) [apply $func item]
        }
    }


    # validate attribute values
    set option_validate_p [get_value_if options(validate_p) "1"]
    if { $option_validate_p } {
        foreach attname $__attributes {

            set optional_p $__attinfo(${attname},null)
            if { $optional_p && [get_value_if item($attname) ""] eq {} } {
                continue
            }
            assert { exists("item($attname)") }

            set maxlen $__attinfo(${attname},maxlen)
            if { $maxlen ne {} } {
                assert { [string length $item($attname)] < $maxlen }
            }

            set datatype $__attinfo(${attname},type)
            if { $datatype ne {} } {
                assert { [pattern matchall [list $datatype] item($attname)] } {
                    printvars
                }

            }

        }
    }

    set target [to_path $item($pk)]

    # log target=$target

    # TODO: encode item data
    set data [array get item]

    ::persistence::insert_column $target $data
    
    foreach idxname $__indexes {
        if { $idxname eq "by_$pk" } {
            continue
        }

        set row_key [to_row_key_by $idxname item]
        set src [to_path_by $idxname $row_key {*}$item($pk)]
        ::persistence::insert_link $src $target
     }

}

# delete -
# * deletes the record with the given oid
#
proc ::persistence::orm::delete {oid {exists_pVar ""}} {
    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    set exists_p [::persistence::exists_column_p $oid]
    if { $exists_p } {

        array set item [get $oid]

        variable [namespace __this]::__indexes
        variable [namespace __this]::pk

        foreach idxname $__indexes {
            set row_key [to_row_key_by $idxname item]
            set to_delete_oid [to_path_by $idxname $row_key {*}$item($pk)]

            if { $idxname eq "by_$pk" } {
                ::persistence::delete_column $to_delete_oid
            } else {
                ::persistence::delete_link $to_delete_oid
            }
        }


    } else {
        error "no such oid (=$oid) in storage system (=mystore)"
    }

}

# get -
# * returns the data for a given oid
# * raises an error if the oid does not exist
#
proc ::persistence::orm::get {oid {exists_pVar ""}} {
    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    set exists_p [::persistence::exists_column_p $oid]
    if { $exists_p } {
        return [::persistence::get_column_data $oid]
    } else {
        error "no such oid (=$oid) in storage system (=mystore)"
    }
}

# 0or1row -
# * returns at most one record that satisfies the specified conditions
# * raises an error if more records are found
proc ::persistence::orm::0or1row {where_clause_argv {optionsVar ""}} {
    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    set slicelist [find $where_clause_argv options]
    set llen [llength $slicelist]
    if { $llen > 1 } {
        error "persistence (ORM): more records in slice than expected (0or1row)"
    }

    # note that lindex returns "" if no elements in the list
    return [lindex $slicelist 0]

}

# 1row -
# * returns a single record that satisfies the specified conditions
# * raises an error if any other number of records are found
proc ::persistence::orm::1row {where_clause_argv {optionsVar ""}} {
    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    set slicelist [find $where_clause_argv]
    set llen [llength $slicelist]
    if { $llen != 1 } {
        error "persistence (ORM): $llen records found (must be exactly 1row)"
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

    #log "argc = $argc"

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
        set path [to_path_by by_$attname $attvalue {*}$id]
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
            #log "chosen axis (attribute) = $attname"
            #log "chosen axis (args) = $find_by_axis_args"
            #log "rewritten predicate = $predicate"
            set slicelist [find_by_axis $find_by_axis_args $predicate]
        }

    }

    set expand_fn [get_value_if option(expand_fn) ""]
    set slicelist [::persistence::expand_slice $slicelist $expand_fn]

    set option_order_by [get_value_if options(order_by) ""]
    if { $option_order_by ne {} } {
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

