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


proc ::persistence::orm::insert {itemVar} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::idx
    variable [namespace __this]::att

    upvar $itemVar item

    # compute derived attributes
    set derived_attributes [list]
    foreach attname [array names att] {
        array set attinfo $att($attname)
        if { [info exists attinfo(func)] && ![info exists item($attname)] } {
            # log $attinfo(func)
            set item($attname) [apply $attinfo(func) item]
        }
        array unset attinfo
    }

    set data [array get item]

    set target [to_path $item($pk)]

    # log target=$target

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
        # TODO: options for get_data
        set data [::persistence::get_data $oid]
        return $data
    } else {
        error "no such oid (=$oid) in storage system (=mystore)"
    }
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


# finds the records satisfying the specified predicate(s)
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
        return [find_by_axis ${axis_attname}]

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
            return [find_by_axis $find_by_axis_args $predicate]
        }

    }
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

