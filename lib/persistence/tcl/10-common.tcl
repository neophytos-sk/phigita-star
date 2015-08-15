namespace eval ::persistence::common {

    namespace export -clear \
        join_oid \
        split_oid \
        typeof_oid \
        ins_column \
        del_column \
        ins_link \
        del_link \
        get_link \
        get_slice \
        multiget_slice \
        exists_p \
        is_supercolumn_oid_p \
        is_column_oid_p \
        is_column_rev_p \
        is_row_oid_p \
        is_link_oid_p \
        sort \
        __exec_options \
        get

    set storage_type [config get ::persistence "default_storage_type"]
    set nsp "::persistence::${storage_type}"

    foreach procname {
        get_files
        get_subdirs
        get_leafs
        exists_supercolumn_p
        exists_column_rev_p
        exists_column_p
        exists_link_p
        set_column
        get_column
        set_link
    } {
        interp alias {} ::persistence::common::${procname} {} ${nsp}::${procname}
    }
}

proc ::persistence::common::typeof_oid {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path
    if { $column_path ne {} } {
        return "col"
    } elseif { $row_key ne {} } {
        return "row"
    } else {
        return "type"
    }
}

proc ::persistence::common::join_oid {ks cf_axis {row_key ""} {column_path ""}} {
    assert { $ks ne {} }        ;# is_ks $ks
    assert { $cf_axis ne {} }   ;# is_cf_axis $cf_axis

    set oid ${ks}/${cf_axis}

    if { $row_key ne {} } {
        append oid "/" $row_key "/+"
        if { $column_path ne {} } {
            append oid "/" $column_path
            #if { $ts ne {} } {
            #    append oid "@${ts}"
            #}
        } else {
            # assert { $ts eq {} }
        }
    } else {
        assert { $column_path eq {} }
        # assert { $ts eq {} }
    }

    return $oid

}


proc ::persistence::common::split_oid {oid_with_ts} {
    lassign [split ${oid_with_ts} {@}] oid ts
    set column_path_args [lassign [split $oid {/}] ks cf_axis row_key __delimiter__]
    set column_path [join $column_path_args {/}]
    set ext [file extension $column_path] 
    return [list $ks $cf_axis $row_key $column_path $ext]
}



proc ::persistence::common::is_supercolumn_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} }]
    # set first_char [string index $column_path 0]
    # return [expr { $column_path ne {} && $first_char eq {^} }]
}


proc ::persistence::common::is_column_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} && $ext eq {} }]
}


proc ::persistence::common::is_column_rev_p {rev} {
    lassign [split ${rev} {@}] oid ts
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} && ${ts} ne {} }]
}


proc ::persistence::common::is_row_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { ${row_key} ne {} && $column_path eq {} }]
}

proc ::persistence::common::is_link_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    if { $ext eq {.link} } {
        return 1
    }
    return 0
}

proc ::persistence::common::sort {
    slicelistVar 
    type_nsp 
    attname 
    sort_direction 
    {sort_comparison "dictionary"}
} {
    upvar $slicelistVar slicelist

    assert { $sort_direction in {decreasing increasing} }
    assert { $sort_comparison in {dictionary ascii integer} }

    set sortlist [list]
    set i 0
    foreach oid $slicelist {
        array set item [$type_nsp get ${oid}]
        lappend sortlist [list $i $item($attname) $oid]
        incr i
    }
    set sortlist [lsort -${sort_direction} -${sort_comparison} -index 1 $sortlist] 

    set sorted_slicelist [map x $sortlist {lindex $x 2}]
    return $sorted_slicelist 
}


proc ::persistence::common::__exec_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    # hack to load feed_reader types until all types are loaded in zz-postinit
    #namespace eval :: {
    #    package require feed_reader
    #}

    array set options_arr $options

    set slice_predicate [value_if options_arr(__slice_predicate) ""]
    if { $slice_predicate ne {} } {
        predicate=forall slicelist $slice_predicate
    }

    set option_order_by [value_if options_arr(order_by) ""]
    if { $option_order_by ne {} } {
        lassign $option_order_by sort_attname sort_direction sort_comparison
        # assert { $sort_direction in {increasing decreasing} }
        # assert { $sort_comparison in {ascii dictionary integer} }
        set type_nsp $options_arr(__type_nsp)
        set slicelist [sort slicelist $type_nsp $sort_attname $sort_direction]
    }

    if { exists("options_arr(offset)") || exists("options_arr(limit)") } {
        set offset [value_if options_arr(offset) "0"]
        set limit [value_if options_arr(limit) ""]
        set first $offset
        if { $limit ne {} } {
            set last [expr { $offset + $limit - 1 }]
        } else {
            set last end
        }
        if { $first ne {0} || $last ne {end} } {
            set slicelist [lrange $slicelist $first $last]
        }
    }


}

proc ::persistence::common::ins_column {oid data {codec_conf ""}} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    set oid [join_oid $ks $cf_axis $row_key $column_path]
    set mtime [clock seconds] ;# TODO: improve timestamps handling
    set_column ${oid} ${data} $mtime ${codec_conf}
}

proc ::persistence::common::del_column {oid} {
    assert { [is_column_oid_p $oid] || [is_link_oid_p $oid] }
    ins_column ${oid}.gone ""
}

proc ::persistence::common::set_link {oid target_oid mtime codec_conf} {
    set_column ${oid}.link $target_oid $mtime
}

proc ::persistence::common::ins_link {oid target_oid {codec_conf ""}} {
    assert { $oid ne $target_oid } 
    # TODO: IncrRefCount
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    set oid [join_oid $ks $cf_axis $row_key $column_path]
    set mtime [clock seconds] ;# TODO: improve timestamps handling
    set_link ${oid} ${target_oid} $mtime ${codec_conf}
}

proc ::persistence::common::del_link {oid} {
    # TODO: DecrRefCount
    del_column ${oid}.link
}

proc ::persistence::common::get_slice {nodepath {options ""}} {
    assert { [is_row_oid_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis row_key
    set row_path [join_oid ${ks} ${cf_axis} ${row_key}]
    set slicelist [get_files ${row_path}]
    set slicelist [expand_slice slicelist ""]  ;# expand_fn used to be latest_mtime
    __exec_options slicelist $options
    return ${slicelist}
}

proc ::persistence::common::multiget_slice {nodepath row_keys {options ""}} {
    #assert { [is_cf_nodepath_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis

    set result [list]
    foreach row_key ${row_keys} {
        set row_path [join_oid $ks $cf_axis $row_key]
        set slicelist [get_slice $row_path $options]
        set result [concat $result $slicelist]
    }
    __exec_options result $options
    return ${result}
}

proc ::persistence::common::exists_p {oid} {
    if { [is_link_oid_p $oid] } {
        return [exists_link_p $oid]
    } else {
        return [exists_column_p $oid]
    }
}

proc ::persistence::common::expand_slice {slicelistVar fn} {

    upvar $slicelistVar slicelist

    #if { [is_expanded_p $slicelist] } {
        # HERE HERE HERE - FIX
        # return $slicelist
    #}

    set result [list]
    foreach oid $slicelist {
        set leafs [expand_oid $oid]

        if { $fn ne {} } {
            if { [llength $fn] == 1 } {
                predicate=$fn leafs
            } elseif { [llength $fn] == 2 } {
                apply $fn leafs
            } else {
                error "unknown type of expand_fn: must be lambda or procname"
            }
        }
        
        foreach leaf_oid $leafs {
            lappend result $leaf_oid
        }
    }

    return $result
}

proc ::persistence::common::expand_oid {oid} {
    #log "is_row_oid_p=[is_row_oid_p $oid]"
    #log "is_supercolumn_oid_p=[is_supercolumn_oid_p $oid]"

    if { [is_row_oid_p $oid] && [exists_row_data_p $oid] } {
        return [get_leafs $oid]
    } elseif { [is_supercolumn_oid_p $oid] && [exists_supercolumn_p $oid] } {
        set leafs [get_leafs $oid]
        #log "expand_oid->leafs=$leafs"
        return $leafs
    } else {
        #log "expand_oid->column oid $oid"
        return [list $oid]
    }
}

proc ::persistence::common::get_link_target {oid} {
    assert { [is_link_oid_p $oid] } 
    set target_oid [get_column $oid]
    return $target_oid
}

proc ::persistence::common::get_link {oid {codec_conf ""}} {
    assert { [is_link_oid_p $oid] }
    set target_oid [get_link_target $oid]
    return [get $target_oid $codec_conf]
}

proc ::persistence::common::get {oid {codec_conf ""}} {
    if { [is_link_oid_p $oid] } {
        return [get_link $oid $codec_conf]
    } else {
        return [get_column $oid $codec_conf]
    }
}

proc ::persistence::common::predicate=forall {slicelistVar predicates} {
    upvar $slicelistVar slicelist
    foreach predicate $predicates {
        lassign ${predicate} cmd argv
        predicate=$cmd slicelist {*}$argv
    }
}

proc ::persistence::common::exists_row_data_p {oid} {
    assert { [is_row_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::common::exists_data_p {oid} {
    if { [is_row_oid_p $oid] } {
        return [exists_row_data_p $oid]
    } elseif { [::persistence::is_column_oid_p $oid] || [::persistence::is_supercolumn_oid_p $oid] } {
        return [expr { [exists_p $oid] || [exists_supercolumn_p $oid] }]
    } else {
        error "unknown oid (=$oid) type: must be row, column, or supercolumn"
    }
}

proc ::persistence::common::predicate=in_path {slicelistVar parent_path {predicate ""}} {
    upvar $slicelistVar slicelist
    set result [list]
    foreach oid $slicelist {
        lassign [split_oid $oid] ks cf_axis row_key column_path ext
        set other_oid "${parent_path}${column_path}"

        # TODO: wrap_proc exists_data_p {} {}
        set may_contain_p 1
        if { [setting_p "bloom_filters"] } {
            # TODO:
            # set may_contain_p [::persistence::bloom_filter::may_contain $type_oid $other_oid]
        }

        if { $may_contain_p } {
            set exists_p [exists_data_p $other_oid]
            if { $exists_p } {
                lappend result $oid
            }
        }
    }
    set slicelist $result

}

