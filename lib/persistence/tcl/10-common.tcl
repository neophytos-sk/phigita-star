namespace eval ::persistence {

    # snapshot's current xid (transaction id)
    variable __xid_stack ""

}

namespace eval ::persistence::fs {;}

namespace eval ::persistence::common {

    variable base_dir
    set base_dir [config get ::persistence base_dir]

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
        multirow_slice \
        multiget_slice \
        exists_p \
        is_supercolumn_oid_p \
        is_column_oid_p \
        is_row_oid_p \
        is_link_oid_p \
        sort \
        get \
        begin_batch \
        end_batch \
        predicate=in_idxpath \
        new_transaction_id \
        cur_transaction_id \
        split_xid \
        get_leafs \
        get_multirow \
        get_multirow_names \
        get_filename

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

    # hack to load object types until all instances 
    # are notified (and load all) of the new types
    #
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


proc ::persistence::common::__exec_filter_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    array set options_arr $options
    set slice_predicate [value_if options_arr(__slice_predicate) ""]
    if { $slice_predicate ne {} } {
        predicate=forall slicelist $slice_predicate
    }

}

proc ::persistence::common::__exec_sort_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    array set options_arr $options
    set option_order_by [value_if options_arr(order_by) ""]
    if { $option_order_by ne {} } {
        lassign $option_order_by sort_attname sort_direction sort_comparison
        set sort_comparison [coalesce $sort_comparison "dictionary"]
        assert { $sort_direction in {increasing decreasing} }
        assert { $sort_comparison in {ascii dictionary integer} }
        set type_nsp $options_arr(__type_nsp)
        set slicelist [sort slicelist $type_nsp $sort_attname $sort_direction]
    }
}

proc ::persistence::common::__exec_range_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    array set options_arr $options
    if { [info exists options_arr(offset)] || [info exists options_arr(limit)] } {
        set offset [value_if options_arr(offset) "0"]
        set limit [value_if options_arr(limit) ""]

        assert { vcheck("offset","naturalnum") }

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



proc ::persistence::common::__exec_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    __exec_filter_options slicelist $options
    __exec_sort_options slicelist $options
    __exec_range_options slicelist $options

}


proc ::persistence::common::__exec_multirow_filter_options {multirowVar options} {
    upvar $multirowVar multirow
    # TODO: filter criteria w.r.t the row_key (e.g. a date index enables us to
    # filter row keys to answer "between" queries)
    #
    # upside is that any filtering at the multirow (row keys) level speeds up
    # multiget_slice considerably (e.g. bloom filters for membership/in filtering)
}

proc ::persistence::common::__exec_multirow_sort_options {multirowVar options} {
    upvar $multirowVar multirow
    array set options_arr $options
    set multirow_orderby [value_if options_arr(multirow_orderby) ""]
    if { $multirow_orderby ne {} } {
        lassign $multirow_orderby sort_direction sort_comparison
        set sort_comparison [coalesce $sort_comparison "dictionary"]
        # sort in the direction that is given,
        # e.g. for a query that makes use of a sort axis/index
        assert { $sort_direction in {decreasing increasing} }
        assert { $sort_comparison in {dictionary ascii integer} }
        set multirow [lsort -${sort_comparison} -${sort_direction} $multirow]
        log "multirow: sorting in $sort_direction order"
        # note: this is less than optimal as we sort ks/cf_axis,
        # which is the same in a multirow
    }
}

proc ::persistence::common::num_cols {row_oid} {
    set delim {+}
    return [llength [::persistence::get_subdirs ${row_oid}/${delim}]]
}

proc ::persistence::common::__exec_multirow_range_options {multirowVar options} {
    upvar $multirowVar multirow

    # TODO: uses statistics (e.g. column counts) to pick topn rows
    # case when there are no filter criteria is simple,
    # gets more complicated when having to deal with filtering criteria
    #
    # returns the number of cols skipped so that the caller/invoker would
    # subtract their number from the original query offset 

    array set options_arr $options

    set slice_predicate [value_if options_arr(__slice_predicate) ""]
    set offset [value_if options_arr(offset) "0"]
    set limit [value_if options_arr(limit) ""]

    set has_filter_options_p [expr { $slice_predicate ne {} }]
    set has_range_options_p [expr { $offset > 0 || $limit ne {} }]

    # note: for anything but offset == 0, it would require to return
    # a delta to adjust the offset of the actual query (multiget_slice)

    if { !$has_filter_options_p && $has_range_options_p } {
        set llen [llength $multirow]
        set n 0
        set n_skipped 0
        set result [list]
        foreach row $multirow {
            incr n [num_cols $row]
            if { $n >= $offset } {
                lappend result $row
            }
            if { $result eq {} } {
                set n_skipped $n
            }
            if { $n >= $offset + $limit } {
                break
            }
        }
        set multirow $result
        set new_llen [llength $multirow] 
        log "multirow: $n_skipped skipped cols, \
            (only ${new_llen} of ${llen} row keys will have to be processed)"
        return [list offset [expr { $offset - $n_skipped }]]
    }
}

proc ::persistence::common::__exec_multirow_options {multirowVar options} {
    upvar $multirowVar multirow
    __exec_multirow_filter_options multirow $options
    __exec_multirow_sort_options multirow $options

    # returns a map of values, in particular a modified offset value
    # adjusted for the number of columns that are skipped while
    # processing __exec_multirow_range_options

    return [__exec_multirow_range_options multirow $options]
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
    set orig_xid $xid
    if { $orig_xid eq {} } {
        set xid [begin_batch]
    }

    set_column ${oid} ${data} ${xid} ${codec_conf}

    if { $orig_xid eq {} } {
        end_batch $xid
    }
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

    # TODO: make use of ins_column provided that we have resolved the
    # issue that requires us to store the rev (i.e. oid with ts) as 
    # opposed to the oid (i.e. without ts) as the target of the link

    set xid [cur_transaction_id]
    set orig_xid $xid
    if { $orig_xid eq {} } {
        set xid [begin_batch]
    }

    lassign [split_xid $xid] micros pid n_mutations mtime

    set target_rev ${target_oid}@${micros}
    set_column ${oid}.link ${target_rev} ${xid} ${codec_conf}

    if { $orig_xid eq {} } {
        end_batch $xid
    }
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

proc ::persistence::common::multirow_slice {nodepath row_keys {options ""}} {
    #assert { [is_cf_nodepath_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis

    set result [list]
    foreach row_key ${row_keys} {
        set row_path [join_oid $ks $cf_axis $row_key]
        set slicelist [get_slice $row_path $options]
        lappend result $row_key $slicelist
    }
    return $result
}

proc ::persistence::common::multiget_slice {nodepath row_keys {options ""}} {

    # depending on the type of query, we would prefer to have the
    # filtering be done by the get_slice processor, i.e. it would
    # depend on the type of the index (if each row key corresponds
    # to many columns, then passing partial/filter options seems to
    # make sense, otherwise it does not)
    #
    if {1} {
        # disables sort and range options for get_slice queries
        # and classifies the query in terms of the nature of
        # the request, whether it requires sorting, range selection,
        # and so forth
        array set options_arr $options
        unset_if options_arr(order_by)
        unset_if options_arr(offset)
        unset_if options_arr(limit)
        set partial_options [array get options_arr]
        unset options_arr
    }

    set multirow_slicelist [multirow_slice $nodepath $row_keys $partial_options]

    set result [list]
    foreach {row_key slicelist} $multirow_slicelist {
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

    # TODO: 
    #   set target_oid [get_link_target $rev]
    #   set target_rev [lindex [get_files $target_oid] 0]


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

proc ::persistence::common::exists_row_data_p {row_oid} {
    assert { [is_row_oid_p $row_oid] }
    set filename [get_filename $row_oid]
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
    return [lindex $__xid_stack end] ;# if empty, returns ""
}

proc ::persistence::common::begin_batch {} {
    variable ::persistence::__xid_stack
    lappend __xid_stack [set xid [new_transaction_id "batch"]]
    # log "begin_batch $xid"
    return $xid
}

proc ::persistence::common::end_batch {{xid ""}} {
    variable ::persistence::__xid_stack
    assert { $__xid_stack ne {} }
    set __xid [lindex $__xid_stack end]
    assert { $xid eq {}  || $xid eq $__xid }
    # log "end_batch $xid"
    set __xid_stack [lreplace $__xid_stack end end]
    return $__xid
}

proc ::persistence::common::get_multirow {ks cf_axis {options ""}} {
    assert_cf ${ks} ${cf_axis}

    set multirow [::persistence::get_subdirs ${ks}/${cf_axis}]
    set delta_options [__exec_multirow_options multirow $options]

    array set options_arr $options
    array set options_arr $delta_options
    set revised_options [array get options_arr]

    return [list $multirow $revised_options]
}

proc ::persistence::common::get_multirow_names {nodepath {options ""}} {
    set residual_path [lassign [split $nodepath {/}] ks cf_axis]

    lassign [get_multirow $ks $cf_axis $options] multirow revised_options

    set result [list]
    foreach row $multirow {
        set row_key [get_name $row]
        lappend result $row_key
    }
    return [list $result $revised_options]

}

proc ::persistence::common::get_filename {path} {
    variable base_dir
    return [file normalize ${base_dir}/${path}]
}


proc ::persistence::common::get_leafs {path} {
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

proc ::persistence::common::compact {type_oid} {
    # assert { [is_type_oid_p $type_oid] }
    lassign [split_oid $type_oid] ks cf_axis

    # 1. get row keys
    set multirow_options [list]
    lassign [get_multirow_names $type_oid $multirow_options] \
        row_keys revised_multirow_options

    # 2. get_leafs/slicelist for each row key
    set multirow_slicelist [multirow_slice $type_oid $row_keys $options]

    # 3. merge them in one sorted-strings (sstable) file
    set index [list]
    set output_data ""
    foreach {row_key slicelist} $multirow_slicelist {
        set savepos [string length $output_data]
        set len [string length $row_key]
        lappend index $row_key [binary format i $savepos]
        append output_data [binary format i $len] $row_key
        foreach rev $slicelist {
            set len [string length $rev]
            append output_data [binary format i $len] $rev 
            set data [get $rev]
            set len [string length $data]
            append output_data [binary format i $len] $data
        }
        append output_data [binary format i $savepos]
    }

    ##
    # 4. write the (sstable) file
    #

    set xid [begin_batch]
    lassign [split_xid $xid] micros pid n_mutations mtime

    set name [binary encode base64 $type_oid]
    array set item [list name $name data $output_data index $index]

    ## ::sysdb::sstable_t insert item
    set oid [join_oid sysdb sstable.by_name $name ${name}.sstable@${micros}]
    set encoded_data [::sysdb::sstable_t encode item]
    set codec_conf "-translation binary"
    write_column $oid $encoded_data $xid $codec_conf
    foreach row_key $row_keys {
      set row_oid [join_oid $ks $cf_axis $row_key]
      del_row $row_oid
      # => foreach column_oid [get_slice $row_oid] {
      #      del_column $column_oid
      #    }
      #    rmdir $row_oid
    }
    end_batch

}

if { [setting "mvcc"] } {
    wrap_proc ::persistence::common::get_leafs {path} {

        set revs [call_orig $path]

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

}
