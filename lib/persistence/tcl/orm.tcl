# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here
#
# Such calls to procs are hereby prefixed with the ::persistence
# namespace in order to perform remote method invocation in the
# case when the package is loaded without the server use flag,
# i.e. when it is used in client mode. client/server separation
# is specified in zz-postinit.tcl

set dir [file dirname [info script]]
source [file join $dir orm_codec.tcl]

namespace eval ::persistence::orm {

    # namespace path "::persistence::[setting "storage_type"]"
    namespace path "::persistence::ss"

    ##
    # import encode / decode procs
    #
    # namespace import ::persistence::orm::codec_txt_1::*
    # namespace import ::persistence::orm::codec_txt_2::*
    namespace import ::persistence::orm::codec_bin_3::*

    namespace export \
        to_path \
        from_path \
        init_type \
        install_type \
        find_by_id \
        find_by_axis \
        find \
        get \
        mtime \
        1row \
        0or1row \
        insert \
        delete \
        update \
        exists \
        encode \
        decode \
        sort

    #exists

}

proc ::persistence::orm::init_type {} {
    set nsp [namespace __this]
    variable ${nsp}::__spec
    variable ${nsp}::ks
    variable ${nsp}::cf
    variable ${nsp}::pk
    variable ${nsp}::idx
    variable ${nsp}::att
    variable ${nsp}::__attnames
    variable ${nsp}::__derived_attributes
    variable ${nsp}::__attinfo
    variable ${nsp}::__idxnames
    variable ${nsp}::__idxinfo

    # log ------${nsp}
    set indexes ""
    set attributes ""
    set aggregates ""
    foreach varname [array names __spec] {
        set $varname $__spec($varname)
        #log varname=$varname
    }

    if { ![info exists idx] } {
        set map [list]
        foreach list $indexes {
            set name [keylget list name]
            lappend map $name $list
        }
        array set idx $map
    }

    if { ![info exists att] } {
        set map [list]
        foreach list $attributes {
            set name [keylget list name]
            lappend map $name $list
        }
        array set att $map
    }

    # log "init_type ${nsp}"

    ## 
    # helpers and speedups
    #

    # attributes

    set __attnames [lsort [array names att]]
    set __derived_attributes [list]
    array set __attinfo [list]

    foreach attname $__attnames {
        array set attinfo $att($attname)

        set type    [value_if attinfo(type) ""]
        set func    [value_if attinfo(func) ""]
        set null_p  [boolval [value_if attinfo(null_p) "1"]]
        set immu_p  [boolval [value_if attinfo(immu_p) "0"]]
        set maxl    [value_if attinfo(maxl) ""]
        set dval    [value_if attinfo(dval) ""]

        set __attinfo(${attname},type)      $type
        set __attinfo(${attname},func)      $func
        set __attinfo(${attname},null_p)    $null_p
        set __attinfo(${attname},maxl)      $maxl
        set __attinfo(${attname},immu_p)    $immu_p
        set __attinfo(${attname},dval)      $dval

        if { $func ne {} } {
            lappend __derived_attributes $attname
        }

        array unset attinfo
    }

    # indexes
    set __idxnames [array names idx]
    array set __idxinfo [list]
    foreach idxname $__idxnames {
        array set idxinfo $idx($idxname)

        set atts [value_if idxinfo(atts) ""]
        set type [value_if idxinfo(type) ""]

        assert { $atts ne {} }
        # TODO: assert { $type ne {} }

        set __idxinfo(${idxname},atts) $atts
        
        array unset idxinfo
    }

    set pk_atts $__idxinfo(by_${pk},atts)
    foreach attname $pk_atts {
        set __attinfo(${attname},immu_p) "1"
    }


    # log "persistence (ORM): initializing ${nsp} ensemble/type"

    assert { vcheck("ks","required notnull sysdb_slot_name") }
    assert { vcheck("cf","required notnull sysdb_slot_name") }
    assert { vcheck("pk","required notnull sysdb_slot_name") }

}

proc ::persistence::orm::install_type {} {
    set nsp [namespace __this]
    variable ${nsp}::ks
    variable ${nsp}::cf
    variable ${nsp}::idx

    # runtime definitions
    ::persistence::define_ks $ks
    foreach {idxname idxitem} [array get idx] {
        set axis $idxname
        ::persistence::define_cf $ks $cf.$axis
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

    set target "${ks}/${cf}.${axis}/"
    if { $row_key ne {} } {
        append target "${row_key}/+/"
        if { $column_path ne {} } {
            append target ${column_path}
        }
    }

    # log "to_path_by axis (=$axis) => target=$target"

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
    variable [namespace __this]::__attnames
    variable [namespace __this]::__derived_attributes
    variable [namespace __this]::__attinfo
    variable [namespace __this]::__idxnames
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
    set option_validate_p [value_if options(validate_p) "1"]
    if { $option_validate_p } {
        foreach attname $__attnames {

            set null_p          $__attinfo(${attname},null_p)
            set dval            $__attinfo(${attname},dval)
            set maxl            $__attinfo(${attname},maxl)
            set type            $__attinfo(${attname},type)

            if { $null_p && [value_if item($attname) ""] eq {} } {
                continue
            }

            if { $dval eq {} } {
                assert { [info exists item($attname)] } {
                    log "attribute (=$attname) does not exist and no default_value"
                }
            }

            if { $maxl ne {} } {
                assert { [string length $item($attname)] < $maxl } {
                    log "attribute (=$attname) exceeds maxlen (=$maxl)"
                }
            }

            if { $type ne {} } {
                assert { [pattern matchall [list $type] item($attname)] } {
                    log "attribute (=$attname) value does not match type (=$type)"
                    printvars
                }

            }

        }
    }

    set target_oid [to_path $item($pk)]

    # log orm,insert,target=$target

    set data [encode item]

    ::persistence::begin_batch

    set target_rev [::persistence::ins_column $target_oid $data [codec_conf]]
    
    foreach idxname $__idxnames {
        if { $idxname eq "by_$pk" } {
            continue
        }
        set row_key [to_row_key_by $idxname item]
        set src [to_path_by $idxname $row_key {*}$item($pk)]

        ::persistence::ins_link $src $target_oid

        #log "idxname=$idxname"
        #log "ins_link $src $target_oid"
    }

    ::persistence::end_batch

    return $target_rev

}

proc ::persistence::orm::update {oid new_itemVar {optionsVar ""}} {
    variable [namespace __this]::pk
    variable [namespace __this]::__attinfo
    variable [namespace __this]::__idxnames
    variable [namespace __this]::__idxinfo

    upvar $new_itemVar new_item

    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    # attributes to be updated
    set attnames [array names new_item]

    # check for existance and get the old item
    if { ![::persistence::exists_p $oid] } {
        error "persistence (ORM): no such oid (=$oid) in the store (=mystore)"
    }

    # old_item
    array set old_item [get $oid]

    # ensures that no immutable attributes are modified
    foreach attname $attnames {
        if { $__attinfo(${attname},immu_p) && [info exists new_item($attname)] } {
            if { $new_item($attname) ne $old_item($attname) } {
                error "persistence (ORM): attempted to modify immutable attribute"
            }
        }
    }

    # merges old with new data
    array set item [array get old_item]
    array set item [array get new_item]

    # updates indexes

    ::persistence::begin_batch

    set target [to_path $item($pk)] 
    foreach idxname $__idxnames {
        if { $idxname eq "by_$pk" } { continue }
        set count 0
        set changed 0
        set idx_atts $__idxinfo(${idxname},atts)
        foreach idx_attname $idx_atts {
            if { [info exists new_item($idx_attname)] } {
                incr count
                if { [info exists __changed($idx_attname)] } {
                    incr changed
                } elseif { $new_item($idx_attname) ne $old_item($idx_attname) } {
                    set __changed($idx_attname)
                    incr changed
                }
            }
        }
        if { $changed } {
            # update index
            set old_row_key [to_row_key_by $idxname old_item]
            set old_src [to_path_by $idxname $row_key {*}$old_item($pk)]
            ::persistence::del_link $old_src

            set row_key [to_row_key_by $idxname item]
            set src [to_path_by $idxname $row_key {*}$item($pk)]
            ::persistence::ins_link $src $target
            # upd_link $src $new_target

        }
    }

    # overwrites data
    set data [encode item]
    ::persistence::ins_column $target $data [codec_conf]

    ::persistence::end_batch

}

# delete -
# * deletes the record with the given oid
#
proc ::persistence::orm::delete {rev} {

    set exists_p [::persistence::exists_p $rev]
    if { $exists_p } {

        array set item [::persistence::get $rev]

        variable [namespace __this]::__idxnames
        variable [namespace __this]::pk

        lassign [split $rev {@}] oid micros
        foreach idxname $__idxnames {
            set row_key [to_row_key_by $idxname item]
            set to_delete_oid [to_path_by $idxname $row_key {*}$item($pk)]
            set to_delete_rev ${to_delete_oid}@${micros}

            if { $idxname eq "by_$pk" } {
                ::persistence::del_column $to_delete_rev
            } else {
                ::persistence::del_link $to_delete_rev
            }
        }


    } else {
        error "no such rev (=$rev) in storage system (=mystore)"
    }

}

proc ::persistence::orm::exists {where_clause_argv {optionsVar ""}} {
    upvar $optionsVar options
    set_if options(limit) 1
    assert { $options(limit) == 1 }
    set rev [0or1row $where_clause_argv options]
    return [expr { $rev ne {} }]
}


# get -
# * returns the data for a given oid
# * raises an error if the oid does not exist
#
proc ::persistence::orm::get {rev} {

    set exists_p [::persistence::exists_p $rev]
    if { $exists_p } {
        # log orm,get,rev=$rev
        set data [::persistence::get $rev [codec_conf]]
        return [decode data]
    } else {
        error "no such rev (=$rev) in storage system (=mystore)"
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
        puts [join $slicelist \n]
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

    set slicelist [find $where_clause_argv options]
    set llen [llength $slicelist]
    if { $llen != 1 } {
        error "persistence (ORM): $llen records found (must be exactly 1row)"
    }

    # note that lindex returns "" if no elements in the list
    return [lindex $slicelist 0]

}


proc ::persistence::orm::mtime {oid} {
    return [::persistence::get_mtime $oid]
}

proc ::persistence::orm::find_by_id {value} {
    variable [namespace __this]::pk
    variable [namespace __this]::att

    array set attinfo $att($pk)
    foreach datatype $attinfo(type) {
        assert { vcheck("value",$datatype) }
    }

    set nodepath [to_path $value]
    set oid [find_column $nodepath "" "" [codec_conf]]

    return $oid
}

proc ::persistence::orm::find_by_axis {argv {options_arrVar ""}} {
    if { $options_arrVar ne {} } {
        upvar $options_arrVar options_arr
    }

    variable [namespace __this]::idx

    set argc [llength $argv]
    assert { $argc in {5 4 3 2 1} }

    # log "argc = $argc argv=$argv"

    if { $argc >= 3 } {

        lassign $argv idxname idxvalue id dataVar exists_pVar
        set varname ""
        if { $dataVar ne {} } {
            upvar $dataVar _
            set varname _
        }
        if { $exists_pVar ne {} } {
            upvar $exists_pVar exists_p
        }
        set nodepath [to_path_by $idxname $idxvalue {*}$id]
        set oid [::persistence::find_column $nodepath ${varname} exists_p [codec_conf]]
        return $oid

    } elseif { $argc == 2 } {

        lassign $argv idxname idxvalue
        set nodepath [to_path_by $idxname $idxvalue]
        set options [array get options_arr]
        set slicelist [::persistence::get_slice $nodepath $options]

        # log find_by_axis,argc=2,options=$options
        return $slicelist

    } elseif { $argc == 1 } {

        lassign $argv idxname
        set nodepath [to_path_by $idxname]
        set options [array get options_arr]
        lassign [::persistence::get_multirow_names $nodepath $options] row_keys revised_options

        # TODO: 
        #   if sort axis (idx), then sort row_keys 
        #   in the requested direction

        if { $row_keys ne {} } {
            set slicelist [::persistence::multiget_slice $nodepath $row_keys $revised_options]

            # log argc=1,^^^slicelist=$slicelist
            return $slicelist
        }
        return

    }

}


# find -
# * finds all nodes matching some conditions
proc ::persistence::orm::find {{where_clause_argv ""} {optionsVar ""}} {
    if { $optionsVar ne {} } {
        upvar $optionsVar options
    }

    set nsp [namespace __this]
    set options(__type_nsp) ${nsp}
    
    if { $where_clause_argv eq {} } {

        # __find_all starting from the given axis
        variable [namespace __this]::pk
        variable [namespace __this]::idx

        set idxname [__choose_axis $where_clause_argv options find_by_axis_args]

        #log "chosen axis attname=$attname"

        #set attname [value_if options(axis_attname) ${pk}]

        assert { [info exists idx($idxname)] }

        set slicelist [find_by_axis $idxname options]

    } else {

        set n_clauses [llength $where_clause_argv]
        if { $n_clauses == 1 && [llength [lindex $where_clause_argv 0]] == 1 } {
            error "peristence (ORM): test find_by_id first before using"
            return [find_by_id [lindex $where_clause_argv 0]]
        } else {
            set find_by_axis_args [list]
            set idxname [__choose_axis $where_clause_argv options find_by_axis_args]
            set predicate [__rewrite_where_clause $idxname $where_clause_argv]
            # log "chosen axis (idxname) = $idxname"
            # log "chosen axis (args) = $find_by_axis_args"
            # log "rewritten predicate = $predicate"

            set options(__where_clause_argv) $where_clause_argv
            set options(__slice_predicate) $predicate
            set slicelist [find_by_axis $find_by_axis_args options]
        }

    }

    return $slicelist
}

proc ::persistence::orm::__choose_axis {argv optionsVar find_by_axis_argsVar} {
    variable [namespace __this]::pk
    variable [namespace __this]::idx
    variable [namespace __this]::__idxnames
    variable [namespace __this]::__idxinfo

    upvar $optionsVar options

    upvar $find_by_axis_argsVar find_by_axis_args

    array set item_eq [list]
    foreach arg $argv {
        lassign $arg attname op attvalue
        if { $op eq {=} } {
            set item_eq($attname) $attvalue
        }
    }

    # check if there exists an index that matches our where_clause
    set item_eq_names [array names item_eq]
    foreach idxname $__idxnames {
        set atts $__idxinfo(${idxname},atts) 
        lassign [intersect3 $atts $item_eq_names] la1 lai la2
        if { $la1 eq {} } { 
            set func [value_if __idxinfo(${idxname},func) ""]
            if { $func ne {} } {
                set value [apply $func item_eq]
            } else {
                set value [list]
                foreach attname $atts {
                    if { $attname in $lai } {
                        # for composite keys, order matters
                        lappend value $item_eq($attname)
                    }
                }
            }
            set find_by_axis_args [list $idxname [join $value]]
            return $idxname
        } elseif { $lai ne {} } {
            # set find_by_axis_args [list $idxname [join $value]]
        }
    }

    set option_order_by [value_if options(order_by) ""]
    lassign $option_order_by sort_attname sort_direction sort_comparison
    if { [info exists idx(by_$sort_attname)] } {
        set options(multirow_orderby) [list $sort_direction $sort_comparison]
        set find_by_axis_args by_$sort_attname
        return by_$sort_attname
    } else {
        set find_by_axis_args by_$pk
        return by_$pk
    }

}

# TODO: reorder/group expressions in argv/predicate
# based on the idx/counter we have at our disposal
# rewrites expressions in terms of persistence::predicate=* procs
proc ::persistence::orm::__rewrite_where_clause {idxname argv} {
    variable [namespace __this]::__idxinfo

    set idxatts $__idxinfo($idxname,atts)

    set predicate [list]
    while { $argv ne {} } {
        set argv [lassign $argv arg]
        lassign $arg attname op attvalue

        if { $op eq {=} } {
            if { $attname in $idxatts } { continue }
            set idxpath [to_path_by $idxname ${attvalue}]
            lappend predicate [list "in_idxpath" [list $idxpath]]
        } else {
            error "persistence (ORM): op (=$op) not implemented yet"
        }
    }
    return $predicate
}


if {0} {

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

