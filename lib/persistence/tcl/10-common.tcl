namespace eval ::persistence {

    # snapshot's current xid (transaction id)
    variable __xid_stack ""

}

namespace eval ::persistence::fs {;}

namespace eval ::persistence::common {

    namespace path "::persistence ::persistence::fs"

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
        is_row_oid_p \
        is_link_oid_p \
        sort \
        __exec_options \
        get \
        begin_batch \
        end_batch \
        predicate=in_idxpath \
        new_transaction_id \
        cur_transaction_id \
        split_xid \
        get_leafs

    set storage_type [config get ::persistence "default_storage_type"]
    set nsp "::persistence::${storage_type}"

}

proc ::persistence::common::init {} {}

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

proc ::persistence::common::join_oid {ks cf_axis {row_key ""} {column_path ""} {ext ""} {ts ""}} {
    assert { $ks ne {} }        ;# is_ks $ks
    assert { $cf_axis ne {} }   ;# is_cf_axis $cf_axis

    set oid ${ks}/${cf_axis}

    if { $row_key ne {} } {
        append oid "/" $row_key "/+"
        if { $column_path ne {} } {
            append oid "/" $column_path
            if { $ext ne {} } {
                append oid ${ext}
            }
            if { $ts ne {} } {
                append oid "@${ts}"
            }
        } else {
            assert { $ext eq {} }
            assert { $ts eq {} }
        }
    } else {
        assert { $column_path eq {} }
        assert { $ext eq {} }
        assert { $ts eq {} }
    }

    return $oid

}


proc ::persistence::common::split_oid {oid_with_ts} {
    lassign [split ${oid_with_ts} {@}] oid ts
    set column_path_args [lassign [split $oid {/}] ks cf_axis row_key __delimiter__]
    set column_path [join $column_path_args {/}]
    set ext [file extension $column_path] 
    return [list $ks $cf_axis $row_key $column_path $ext $ts]
}



proc ::persistence::common::is_supercolumn_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext ts
    return [expr { $column_path ne {} && $ts eq {} }]
    # return [expr { $column_path ne {} && $ext eq {} && $ts eq {} }]
}


proc ::persistence::common::is_column_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext ts
    return [expr { $column_path ne {} && $ext eq {} && $ts eq {} }]
}


proc ::persistence::common::is_column_rev_p {rev} {
    # log [info frame -5]
    # log [info frame -4]
    # log [info frame -3]
    # log is_column_rev_p,rev=$rev
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    return [expr { $column_path ne {} && ${ts} ne {} }]
}


proc ::persistence::common::is_row_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext ts
    return [expr { ${row_key} ne {} && $column_path eq {} && $ts eq {} }]
}

proc ::persistence::common::is_link_rev_p {rev} {
    # log [info frame -1]
    # log is_link_rev_p,rev=$rev
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    if { $ext eq {.link} && $ts ne {} } {
        return 1
    }
    return 0
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

    assert { [namespace exists $type_nsp] } {
        # TODO: broadcast to all server instances
        # when a new ::sysdb::object_type_t is added
        #
        ::persistence::load_all_types_from_db
        # log "^^^^^ object types: [::sysdb::object_type_t find]"
    }

    set sortlist [list]
    set i 0
    foreach rev $slicelist {
        array set item [$type_nsp get ${rev}]
        lappend sortlist [list $i $item($attname) $rev]
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

        # set slicelist [lrange $slicelist 0 $limit]
        # return

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

proc ::persistence::common::split_xid {xid} {
    lassign [split $xid {.}] micros pid n_mutations type
    set mtime [expr { int( ${micros} / (10**6) ) }]
    return [list $micros $pid $n_mutations $mtime $type]
}

proc ::persistence::common::ins_column {oid data {codec_conf ""}} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    set oid [join_oid $ks $cf_axis $row_key $column_path]
    set xid [cur_transaction_id]
    set_column ${oid} ${data} ${xid} ${codec_conf}
}

proc ::persistence::common::del_column {rev} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] } {
        log failed,del_column,rev=$rev
    }
    lassign [split $rev {@}] oid micros
    set new_rev "${oid}.gone@${micros}"
    ins_column ${new_rev} ""
}

proc ::persistence::common::del_link {rev} {
    # TODO: DecrRefCount
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] } {
        log failed,del_column,rev=$rev
    }
    lassign [split $rev {@}] oid micros
    set new_rev "${oid}.link@${micros}"
    del_column ${new_rev}
}


proc ::persistence::common::ins_link {oid target_oid {codec_conf ""}} {
    # TODO: IncrRefCount
    assert { $oid ne $target_oid } 
    assert { [is_column_oid_p $target_oid] || [is_link_oid_p $target_oid] }
    lassign [split_oid $oid] ks cf_axis row_key column_path ext ts

    set xid [cur_transaction_id]
    lassign [split_xid $xid] micros pid n_mutations mtime

    set target_rev ${target_oid}@${micros}
    set_column ${oid}.link ${target_rev} ${xid} ${codec_conf}
}

proc ::persistence::common::get_slice {nodepath {options ""}} {
    assert { [is_row_oid_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis row_key
    set row_path [join_oid ${ks} ${cf_axis} ${row_key}]
    set slicelist [::persistence::get_leafs ${row_path}]
    #log !!!!!!!!!get_slice,nodepath=$nodepath
    #log !!!!!!!!!get_slice,slicelist=$slicelist
    __exec_options slicelist $options
    return ${slicelist}
}

proc ::persistence::common::multiget_slice {nodepath row_keys {options ""}} {
    #assert { [is_cf_nodepath_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis

    set result [list]
    foreach row_key ${row_keys} {
        set row_path [join_oid $ks $cf_axis $row_key]
        set slicelist [get_slice $row_path ""]
        set result [concat $result $slicelist]
    }
    
    __exec_options result $options
    return ${result}
}

proc ::persistence::common::exists_p {rev} {
    if { [is_link_rev_p $rev] } {
        return [exists_link_rev_p $rev]
    } else {
        return [exists_column_rev_p $rev]
    }
}

proc ::persistence::common::get_link_target {rev} {
    assert { [is_link_rev_p $rev] } 
    set target_rev [get_column $rev]
    return $target_rev
}

proc ::persistence::common::get_link {rev {codec_conf ""}} {
    assert { [is_link_rev_p $rev] }
    set target_rev [get_link_target $rev]
    return [get $target_rev $codec_conf]
}

proc ::persistence::common::get {rev {codec_conf ""}} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] }
    if { [is_link_rev_p $rev] } {
        return [get_link $rev $codec_conf]
    } else {
        return [get_column $rev $codec_conf]
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
    } elseif { [is_column_oid_p $oid] || [is_supercolumn_oid_p $oid] } {
        return [expr { [exists_p $oid] || [exists_supercolumn_p $oid] }]
    } else {
        error "unknown oid (=$oid) type: must be row, column, or supercolumn"
    }
}

proc ::persistence::common::predicate=in_idxpath {slicelistVar parent_oid {predicate ""}} {
    upvar $slicelistVar slicelist
    set result [list]
    foreach oid $slicelist {
        lassign [split_oid $oid] ks cf_axis row_key column_path ext
        set other_oid "${parent_oid}${column_path}"

        # TODO: wrap_proc exists_data_p {} {}
        set may_contain_p 1
        if { [setting_p "bloom_filters"] } {
            # TODO: add bloom filters support for rows
            # set may_contain_p [::persistence::bloom_filter::may_contain $parent_oid $other_oid]
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

proc ::persistence::common::new_transaction_id {type} {
    variable ::persistence::__n_mutations

    set micros [clock microseconds]
    set pid [pid] ;# process id
    incr __n_mutations
    return ${micros}.${pid}.${__n_mutations}.${type}
}

proc ::persistence::common::cur_transaction_id {} {
    variable ::persistence::__xid_stack
    if { $__xid_stack ne {} } {
        return [lindex $__xid_stack end]
    } else {
        return [new_transaction_id "single"]
    }
}

proc ::persistence::common::begin_batch {} {
    variable ::persistence::__xid_stack
    lappend __xid_stack [set xid [new_transaction_id "batch"]]
    # log "begin_batch $xid"
    return $xid
}

proc ::persistence::common::end_batch {} {
    variable ::persistence::__xid_stack
    assert { $__xid_stack ne {} }
    set xid [lindex $__xid_stack end]
    # log "end_batch $xid"
    set __xid_stack [lreplace $__xid_stack end end]
    return $xid
}


proc ::persistence::common::__get_leafs {path} {
    set subdirs [get_subdirs $path]
    if { $subdirs eq {} } {
        return [get_files $path]
    } else {
        set result [list]
        foreach subdir_path $subdirs {
            assert { $subdir_path ne $path }
            foreach oid [__get_leafs $subdir_path] {
                lappend result $oid
            }
        }
        return $result
    }
}

proc ::persistence::common::get_leafs {path} {

    set revs [__get_leafs $path]

    array set latest_rev [list]
    foreach rev $revs {
        lassign [split $rev "@"] oid micros

        # check timestamp based on the oid
        # (without the .gone suffix)
        # we exclude deleted oids below
        set is_gone_p 0
        set normalized_oid $oid
        if { [file extension $oid] eq {.gone} } {
            set is_gone_p 1
            set normalized_oid [file rootname $oid]
        }

        lassign [value_if latest_rev($normalized_oid) ""] is_gone_already_p latest_micros

        if { $latest_micros < $micros } {
            set latest_rev($normalized_oid) [list $is_gone_p $micros]
        }
    }

    set latest_rev_oids [array names latest_rev]

    set result [list]
    foreach normalized_oid $latest_rev_oids {
        lassign $latest_rev($normalized_oid) is_gone_p micros
        if { $is_gone_p } { continue }
        set rev ${normalized_oid}@${micros}
        lappend result ${rev}
    }
    return [lsort -unique $result]

}


