# log server=[use_p server]
if { ![use_p "server"] || ![setting_p "sstable"] } {
    return
}

namespace eval ::persistence::ss {
    #namespace import ::persistence::common::split_oid
    #namespace import ::persistence::common::join_oid
    #namespace import ::persistence::common::type_oid
    #namespace import ::persistence::common::typeof_oid
    #namespace import ::persistence::common::get_cur_filename
    #namespace import ::persistence::common::is_column_rev_p
    #namespace import ::persistence::common::is_link_rev_p

    # namespace __copy ::persistence::fs
    # rename get_leafs fs.get_leafs

    # namespace __copy ::persistence::commitlog
    # rename get_leafs commitlog.get_leafs

    namespace __copy ::persistence::common

    namespace path "::persistence::commitlog ::persistence::fs ::persistence::common"

    variable base_dir
    set base_dir [config get ::persistence base_dir]
}

proc ::persistence::ss::define_ks {args} {}
proc ::persistence::ss::define_cf {args} {}

proc ::persistence::ss::set_column {args} {
    return [::persistence::commitlog::set_column {*}${args}]
}

proc ::persistence::ss::begin_batch {args} {
    return [::persistence::commitlog::begin_batch {*}${args}]
}

proc ::persistence::ss::end_batch {args} {
    return [::persistence::commitlog::end_batch {*}${args}]
}

proc ::persistence::ss::get_mtime {rev} {
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    return [expr { $ts / (10**6) }]
}

proc ::persistence::ss::read_sstable {dataVar row_endpos file_i {lambdaExpr ""}} {
    upvar $dataVar data

    # log read_sstable,datalen=[string length $data]

    # seek _fp $row_endpos start
    # read_int _fp row_startpos

    assert { $row_endpos ne {} }

    set pos $row_endpos
    set scan_p [binary scan $data "@${pos}i" row_startpos]
    incr pos 4

    assert { $scan_p } {
        log row_endpos=$row_endpos
        log failed,row_startpos,scan_p=$scan_p
    }

    # log row_startpos=$row_startpos

    assert { $row_startpos < $row_endpos } {
        log row_startpos=$row_startpos
        log row_endpos=$row_endpos
    }

    set pos $row_startpos

    # seek _fp $startpos start
    # read_string _fp row_key
    binary scan $data @${pos}i len
    incr pos 4
    incr pos $len  ;# skip_string (row_key)

    set revs [list]

    while { $pos < $row_endpos } {

        # read_string _fp rev
        binary scan $data @${pos}i len
        incr pos 4
        binary scan $data @${pos}a${len} rev
        incr pos $len

        # log pos=$pos,rev=$rev

        if { $lambdaExpr eq {} || [apply $lambdaExpr data $rev] } {
            lappend revs [list $rev $file_i $pos]
        }

        # skip_string _fp
        binary scan $data @${pos}i len

        incr pos 4
        incr pos $len  ;# skip_string (data)

    }

    return $revs

}

# Even though ss::get_leafs helps work around the issue
# discussed in ss::get_subdirs_helper, it lacks
# when it comes to (generalized) providence for retrieving 
# the list of subdirs and leafs from distributed nodes
# compared to the fs::get_leafs.

proc ::persistence::ss::get_leafs {path {direction "0"} {limit ""}} {
    set fs_leafs [::persistence::fs::get_leafs $path]
    if { [string match "sysdb/*" $path] } {
        return $fs_leafs
    }

    # set cl_leafs [::persistence::commitlog::get_leafs $path]
    set commitlog_leafs [::persistence::commitlog::get_leafs $path]
    log commitlog_leafs=$commitlog_leafs

    set ss_leafs [::persistence::ss::get_leafs_helper $path]
    if { $fs_leafs eq {} } {
        return [resolve_latest_revs $ss_leafs]
    }

    set result [lsort -unique -command ::persistence::compare_files [concat $fs_leafs $ss_leafs]]
    return [resolve_latest_revs $result]
}

proc ::persistence::ss::get_leafs_helper {path {direction "0"} {limit ""}} {
    set type_oid [type_oid $path]
    if { [load_sstable $type_oid] } {
        variable __cbt_TclObj
        set result [::cbt::prefix_match $__cbt_TclObj(${type_oid},cols) $path]
        return $result
    }
    return
}

proc ::persistence::ss::get_subdirs_helper {path} {

    set type_oid [type_oid $path]
    if { [load_sstable $type_oid sstable_itemVar sstable_item_colsVar sstable_item_rowsVar] } {
        upvar $sstable_itemVar sstable_item
        upvar $sstable_item_rowsVar sstable_item_rows

        lassign [split_oid $path] ks cf_axis row_key_prefix delim

        # row_key_prefix either empty or actual row key 
        # i.e. not as much a prefix

        if { $row_key_prefix ne {} } {

            # BUG:
            #
            # fs::get_leafs will take care of this case
            # when it comes to using the ss::get_files_helper proc,
            # yet this not entirely acceptable and it would have to be fixed,
            # in particular, when fs::get_subdirs returns a non-empty list, 
            # get_leafs won't call get_files but it would iterate over the subdir_paths
            # that ss::get_subdirs (fs::get_subdirs + ss::get_subdirs_helper) returned
            # for feed_reader->ls --lang el.utf8
            #
            # UPDATE: introduced ss::get_leafs that resolves this issue but kept the
            # comment as a reminder when mem/commitlog is rewritten/refactored
            #

            return

            if { $delim eq {} && [info exists sstable_item_rows(${row_key_prefix})] } {
                log row_key_prefix=$row_key_prefix
                return ${type_oid}/${row_key_prefix}/+
            }
            return

        }

        set row_keys [map {x y} $sstable_item(rows) {set x}]
        set result [list]
        foreach row_key $row_keys {
            lappend result ${type_oid}/${row_key}
        }
        return $result
    }

    error "sstable for type_oid (=$type_oid) not loaded"
}


# TODO:  add blob_file attribute type that writes data to filesystem
proc ::persistence::ss::ORM_get_sstable_rev {rev} {
    error "not implemented yet"
    set type_oid [type_oid $rev]
    set sstable_name [binary encode base64 $type_oid]
    set where_clause [list [list name = $sstable_name]]
    set sstable_rev [::sysdb::sstable_t 0or1row $where_clause]
    return $sstable_rev
}

proc ::persistence::ss::get_sstable_rev {rev} {

    set type_oid [type_oid $rev]
    set name [binary encode base64 $type_oid]

    # log get_sstable_rev,type_oid=$type_oid,name=$name

    variable base_dir
    set dir [file join $base_dir cur]
    set pattern "sysdb/sstable.by_name/${name}/+/${name}@*"

    set sstable_revs [glob \
        -nocomplain \
        -tails \
        -directory $dir \
        $pattern]

    set sstable_revs [lsort -command ::persistence::compare_files $sstable_revs]

    assert { [llength $sstable_revs] <= 1 }

    return [lindex $sstable_revs 0]
}

proc ::persistence::ss::load_sstable {
    type_oid 
    {sstable_itemVarVar ""} 
    {sstable_item_colsVarVar ""}
    {sstable_item_rowsVarVar ""}
} {

    if { $type_oid eq {sysdb/sstable.by_name} } {
        return 0
    }

    # log "!!! load_sstable,type_oid=$type_oid"

    if { $sstable_itemVarVar ne {} } {
        upvar $sstable_itemVarVar sstable_itemVar
    }

    if { $sstable_item_colsVarVar ne {} } {
        upvar $sstable_item_colsVarVar sstable_item_colsVar
    }

    if { $sstable_item_rowsVarVar ne {} } {
        upvar $sstable_item_rowsVarVar sstable_item_rowsVar
    }

    set nsp [namespace current]
    set sstable_itemVar "${nsp}::sstable_item__${type_oid}"
    set sstable_item_colsVar "${nsp}::sstable_item_cols__${type_oid}"
    set sstable_item_rowsVar "${nsp}::sstable_item_rows__${type_oid}"

    upvar $sstable_itemVar sstable_item
    upvar $sstable_item_colsVar sstable_item_cols
    upvar $sstable_item_rowsVar sstable_item_rows
    
    variable __cbt_TclObj

    if { ![info exists __cbt_TclObj(${type_oid},cols)] } {
        set sstable_rev [get_sstable_rev $type_oid]

        # log sstable_rev=$sstable_rev
        # log type_oid=$type_oid

        if { $sstable_rev eq {} } {
            return 0
        }

        #log sstable_rev=$sstable_rev

        array set sstable_item [::sysdb::sstable_t get $sstable_rev]

        set __cbt_TclObj(${type_oid},cols) [::cbt::create $::cbt::STRING]

        array set sstable_item_cols $sstable_item(cols)
        array set sstable_item_rows $sstable_item(rows)

        # To save some memory, comment in the following lines:
        # unset sstable_item(cols)
        # unset sstable_item(rows)

        ::cbt::set_bytes $__cbt_TclObj(${type_oid},cols) [array names sstable_item_cols]

        # ::cbt::set_bytes $__cbt_TclObj(${type_oid},cols) \
        #    [map {x y} [set ${sstable_itemVar}(cols)] {set x}]


        return 1

    } else {
        assert { [array size sstable_item] }
        assert { [array size sstable_item_cols] }
    }
    return 2
}

proc ::persistence::ss::readfile_helper {rev args} {
    set codec_conf $args

    set type_oid [type_oid $rev]

    if { ![load_sstable $type_oid sstable_itemVar sstable_item_colsVar] } {
        error "sstable loading error"
    }
    upvar $sstable_itemVar sstable_item
    upvar $sstable_item_colsVar sstable_item_cols

    set rev_startpos $sstable_item_cols(${rev})

    # seek _fp $rev_startpos start
    set pos $rev_startpos

    binary scan $sstable_item(data) @${pos}i len
    incr pos 4
    binary scan $sstable_item(data) @${pos}a${len} rev_in_file
    incr pos $len

    assert { $rev eq $rev_in_file }

    binary scan $sstable_item(data) @${pos}i len
    incr pos 4
    binary scan $sstable_item(data) @${pos}a${len} ss_data
    incr pos $len


    # unset sstable_cols

    # log "!!! returning ss_data for rev=$rev"

    return $ss_data

}


proc ::persistence::ss::exists_p_helper {rev} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] }
    set type_oid [type_oid $rev]
    # log type_oid=$type_oid
    if { [load_sstable $type_oid] } {
        variable __cbt_TclObj
        set exists_p [::cbt::exists $__cbt_TclObj(${type_oid},cols) $rev]
        # log exists_p=$exists_p
        return $exists_p
    }
    return 0
}

proc ::persistence::ss::readfile {rev args} {
    set codec_conf $args
    
    # log fs,readfile,rev=$rev

    if { [::persistence::ss::exists_p_helper $rev] } {
        set ss_data [::persistence::ss::readfile_helper $rev {*}$codec_conf]
        return $ss_data
    } else {
        return [::persistence::fs::readfile $rev {*}$codec_conf]
    }

}

proc ::persistence::ss::get_files {path} {
    # log "ss::get_files $path"
    set fs_filelist [::persistence::fs::get_files $path]
    if { [string match "sysdb/*" $path] } {
        return $fs_filelist
    }

    set ss_filelist [::persistence::ss::get_files_helper $path]

    set result [lsort -unique [concat $fs_filelist $ss_filelist]]

    # log path=$path
    # log ss::get_files,#results=[llength $result]

    return $result
}

proc ::persistence::ss::get_subdirs {path} {
    set fs_subdirs [::persistence::fs::get_subdirs $path]
    if { [string match "sysdb/*" $path] } {
        return $fs_subdirs
    }

    set ss_subdirs [::persistence::ss::get_subdirs_helper $path]

    # log fs_subdirs=$fs_subdirs
    # log ss_subdirs=$ss_subdirs

    return [lsort -unique [concat $fs_subdirs $ss_subdirs]]
}


proc ::persistence::ss::exists_p {path} {
    if { [::persistence::ss::exists_p_helper $path] } {
        return 1
    } else {
        return [::persistence::fs::exists_p $path]
    }
}

proc ::persistence::ss::init {} {}

# merge sstables in mem
proc ::persistence::ss::compact {type_oid} {

    set errorlist [list sysdb/object_type.by_nsp]
    if { 0 && $type_oid in $errorlist } {
        log "skipping sstable merge for $type_oid"
        return
    }

    set name [binary encode base64 $type_oid]

    # set where_clause [list]
    # lappend where_clause [list name = $name]
    # set sstable_revs [::sysdb::sstable_t find $where_clause]

    variable base_dir
    set dir [file join $base_dir cur]
    set pattern "sysdb/sstable.by_name/${name}/+/${name}@*"
    set sstable_revs [glob \
        -nocomplain \
        -tails \
        -directory $dir \
        $pattern]

    set sstable_revs [lsort -command ::persistence::compare_files $sstable_revs]

    if { [llength $sstable_revs] <= 1 } {
        log "-> type_oid (=$type_oid) already merged"
        return
    }

    #log llen=[llength $sstable_revs]
    # log \tsstable_revs=[join $sstable_revs \n\t]

    set file_i 0
    array set sstable_row_idx [list]
    foreach sstable_rev $sstable_revs {

        array set sstable_item__${file_i} [::sysdb::sstable_t get $sstable_rev]
        #log -----
        #log name=[binary decode base64 [set sstable_item__${file_i}(name)]]

        foreach {row_key row_endpos} [set sstable_item__${file_i}(rows)] {

            # log row_key=$row_key
            # log row_endpos=$row_endpos

            set sstable_data [set sstable_item__${file_i}(data)]

            set column_idx_items [::persistence::ss::read_sstable \
                sstable_data $row_endpos $file_i]

            foreach column_idx_item $column_idx_items {
                lappend sstable_row_idx(${row_key}) $column_idx_item
            }

            # log revs=$revs

        }

        incr file_i
    }

    # log \tsstable_row_idx=[join [array get sstable_row_idx] \n\t]

    set row_keys [lsort [array names sstable_row_idx]]

    if { $row_keys eq {} } {
        #log "!!! nothing to merge"
        return
    }

    set rows [list]
    set cols [list]
    set output_data ""
    set pos 0
    foreach row_key $row_keys {

        set row_startpos $pos

        # write row_key
        set len [string length $row_key]
        append output_data [binary format i $len] $row_key
        incr pos 4
        incr pos $len

        foreach column_idx_item $sstable_row_idx(${row_key}) {
            lassign $column_idx_item rev file_i file_pos

            set sstable_data [set sstable_item__${file_i}(data)]

            # write column rev/oid

            set rev_startpos $pos

            set len [string length $rev]
            append output_data [binary format i $len] $rev 
            incr pos 4
            incr pos $len

            # read data from file $file_i
            set scan_p [binary scan $sstable_data @${file_pos}i len]
            assert { $scan_p } {
                log file_pos=$file_pos
            }

            # assert { $len < 1000000 } {
            #     log failed,file_pos=$file_pos,rev=$rev
            #     log length=[string length $sstable_data]
            # }

            # write data for given rev
            incr file_pos 4
            set scan_p [binary scan $sstable_data @${file_pos}a${len} encoded_rev_data]
            assert { $scan_p } {
                log file_pos=$file_pos,len=$len
                exit
            }

            append output_data [binary format i $len] $encoded_rev_data
            incr pos 4
            incr pos $len

            lappend cols $rev $rev_startpos

        }

        # write row_startpos at end of row
        set row_endpos $pos
        append output_data [binary format i $row_startpos]
        incr pos 4

        lappend rows $row_key $row_endpos

        #log "merged file, row_key=$row_key row_endpos=$row_endpos row_startpos=$row_startpos"

    }

    # write merged sstable file

    set name [binary encode base64 $type_oid]
    set round [clock microseconds]

    array set item [list]
    set item(name) $name
    set item(data) $output_data  ;# [binary encode hex $output_data]
    set item(rows) $rows  ;# row_keys 
    set item(cols) $cols  ;# col_keys
    set item(round) $round

    # log "merged_sstable_rev for $type_oid"
    set merged_sstable_rev [::sysdb::sstable_t insert item]
    log merged_sstable_rev=$merged_sstable_rev

    # log "here,just for debugging nested transactions, exiting fs::compact..."
    # exit

    # NOTE: delete old sstable files,
    # but once the new sstable has been
    # committed
    set file_i 0
    foreach sstable_rev $sstable_revs {
        set sstable_filename [get_cur_filename $sstable_rev]
        file delete $sstable_filename
        log "deleted old sstable: $sstable_filename"
        # ::sysdb::sstable_t delete $sstable_rev

        array unset sstable_item__${file_i}
        incr file_i
    }

}


proc ::persistence::ss::compact_all {} {

    ::persistence::fs::compact_all

    set slicelist [::sysdb::object_type_t find]

    foreach rev $slicelist {

        set type_oids [list]

        array set object_type [::sysdb::object_type_t get $rev]
        foreach idx_data $object_type(indexes) {
            array set idx $idx_data
            set cf_axis $object_type(cf).$idx(name)
            set type_oid [join_oid $object_type(ks) $cf_axis]
            # if { $type_oid ne {sysdb/sstable.by_name} }
            # if { $object_type(ks) ne {sysdb} } {
                # compact $type_oid
                lappend type_oids $type_oid
            # }
            array unset idx
        }
        array unset object_type

        foreach type_oid $type_oids {
            log "merging sstables for $type_oid"
            if { [catch {
                ::persistence::ss::compact $type_oid
            } errmsg] } {
                log errmsg=$errmsg
                log errorInfo=$::errorInfo
                log exiting
                exit
            }
        }

    }

}

after_package_load persistence ::persistence::ss::compact_all

