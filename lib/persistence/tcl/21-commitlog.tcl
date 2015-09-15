if { ![use_p "server"] || ![setting_p "commitlog"] } {
    return
}

package require core

namespace eval ::persistence::commitlog {

    variable __mem_id
    variable __mem
    variable __mem_cur
    variable __mem_tmp
    variable __mem_new
    variable __rev_to_mem_id
    variable __fp
    variable __mem_row_keys

    array set __mem_row_keys [list]
    set __fp ""
    set __mem_id 0
    array set __mem [list]
    array set __mem_tmp [list]
    array set __mem_new [list]
    array set __mem_cur [list]
    array set __rev_to_mem_id [list]

    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::join_oid
    namespace import ::persistence::common::type_oid

    namespace __copy ::persistence::common

}

proc ::persistence::commitlog::init {} {

    # log "initializing commitlog..."

    open_commitlog
    load_commitlog
    # at_shutdown close_commitlog
}

proc ::persistence::commitlog::new_commitlog {} {
    variable __fp
    set old_fp ${__fp}
    set filename [::persistence::common::get_cur_filename "CommitLog"]
    # open_commitlog
    set new_fp [open $filename "w+"]
    chan configure $new_fp -translation binary
    set __fp ${new_fp}
}

proc ::persistence::commitlog::open_commitlog {} {
    variable __fp

    if { $__fp ne {} } {
        return
    }

    # log "opening commitlog..."

    set filename [::persistence::common::get_cur_filename "CommitLog"]
    file mkdir [file dirname $filename]
    set exists_p [file exists $filename]

    if { $exists_p } {
        set __fp [open $filename "r+"]
    } else {
        set __fp [open $filename "w+"]
    }

    chan configure $__fp -translation binary

    seek $__fp 0 start

    # Two integers:
    # * pos1 - up to which point the commitlog has been processed
    # * pos2 - up to which point the commitlog has been written

    if { $exists_p } {

        set pos1 [::util::io::read_int $__fp]
        set pos2 [::util::io::read_int $__fp]
        seek $__fp $pos2

        set size [file size $filename]
        if { $size > $pos2 } {
            log "!!! truncating the CommitLog up to the last proper write"
            chan truncate $__fp $pos2
        }

    } else {

        set pos 8
        ::util::io::write_int $__fp $pos
        ::util::io::write_int $__fp $pos
        seek $__fp $pos

    }

}

proc ::persistence::commitlog::close_commitlog {} {
    variable __fp
    if { $__fp ne {} } {
        close $__fp
    }
    unset __fp
}

proc ::persistence::commitlog::write_to_commitlog {mem_id} {

    variable __fp
    variable __mem

    assert { $__fp ne {} }

    array set item [list]
    set item(commitlog_name)    $__mem(${mem_id},commitlog_name)
    set item(name)              $__mem(${mem_id},offset)
    set item(instr)             $__mem(${mem_id},instr)
    set item(oid)               $__mem(${mem_id},oid)
    set item(data)              $__mem(${mem_id},data)
    set item(xid)               $__mem(${mem_id},xid)
    set item(codec_conf)        $__mem(${mem_id},codec_conf)

    ::util::io::write_string ${__fp} [::sysdb::commitlog_item_t encode item]

    # TODO: if threshold exceeded:
    # 1. create new commitlog
    # 2. compact old commitlog

}


proc ::persistence::commitlog::checkpoint {pos} {
    variable __fp
    seek $__fp 0 start
    ::util::io::write_int $__fp $pos
    seek $__fp $pos start
}

proc ::persistence::commitlog::logpoint {pos} {
    variable __fp
    seek $__fp 4 start
    ::util::io::write_int $__fp $pos
    seek $__fp $pos start
}


# Write-Ahead Logging (Wal) is a standard method for ensuring data
# integrity. Briefly, WAL's central concept is that changes to data
# files (where tables and indexes reside) must be written only after
# those changes have been logged, that is, after log records
# describing the changes that have not been applied to the data pages
# can be redone from the log records. This is roll-forward recovery, 
# also known as REDO.
proc ::persistence::commitlog::load_commitlog {} {
    variable __fp

    assert { ${__fp} ne {} }

    # log "loading commitlog..."

    seek $__fp 0 start
    set pos1 [::util::io::read_int $__fp]
    set pos2 [::util::io::read_int $__fp]

    log "last_checkpoint (pos1): $pos1 --- last_logpoint (pos2): $pos2"

    seek $__fp $pos1 start

    set xids [list]
    array set seen [list]
    while { $pos1 < $pos2 } {

        ::util::io::read_string ${__fp} commitlog_item_data
        set pos1 [tell $__fp]

        array set item [::sysdb::commitlog_item_t decode $commitlog_item_data]

        set_mem             \
            $item(instr)    \
            $item(oid)      \
            $item(data)     \
            $item(xid)      \
            $item(codec_conf)

        if { ![info exists seen($item(xid))] } {
            set seen($item(xid)) {}
            lappend xids $item(xid)
        }

        array unset item

        unset commitlog_item_data

    }

    write_to_new $xids 0 ;# fsync_p=0
    delete_from_tmp $xids
    finalize_commit $xids

}


proc ::persistence::commitlog::get_leafs {path {direction "0"} {limit ""}} {
    variable __mem_cur

    set result [list]

    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::get_leafs $path]
    }

    set type_oid [type_oid $path]
    if { [info exists __mem_cur(${type_oid})] } {
        # log "!!! path=$path"
        # log "!!! leafs=[join [::cbt::prefix_match $__mem_cur(${type_oid}) ""] \n]"
        set result [::cbt::prefix_match $__mem_cur(${type_oid}) $path]
    } else {
        # log "no data for type_oid (=$type_oid) yet"
    }

    # log [namespace current],get_leafs,result=$result

    return $result
}

proc ::persistence::commitlog::get_subdirs {path} {
    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::get_subdirs $path]
    }

    set type_oid [type_oid $path]
    lassign [split_oid $path] ks cf_axis row_key_prefix delim

    # row_key_prefix either empty or actual row key 
    # i.e. not as much a prefix

    if { $row_key_prefix ne {} } {
        # get_leafs is expected to be called directly in this case
        return
    }

    variable __mem_row_keys

    set row_keys [lsort [value_if __mem_row_keys(${type_oid}) ""]]
    set result [list]
    foreach row_key $row_keys {
        lappend result ${type_oid}/${row_key}
    }
    return $result

}
                                         
proc ::persistence::commitlog::set_mem {instr oid data xid codec_conf} {

    variable __mem_id
    variable __mem
    variable __mem_tmp
    variable __rev_to_mem_id
    variable __mem_row_keys
    variable __mem_num_cols
    variable __fp

    set offset [tell $__fp]
    set commitlog_name "CommitLog"

    set rev ""
    if { $oid ne {} } {
        lassign [split_xid $xid] micros pid n_mutations mtime
        set rev ${oid}@${micros}
    }

    incr __mem_id
    set __mem(${__mem_id},commitlog_name) $commitlog_name
    set __mem(${__mem_id},offset)   $offset
    set __mem(${__mem_id},instr)    $instr
    set __mem(${__mem_id},oid)      $oid
    set __mem(${__mem_id},rev)      $rev
    set __mem(${__mem_id},data)     $data
    set __mem(${__mem_id},xid)      $xid
    set __mem(${__mem_id},codec_conf) $codec_conf

    lappend __mem_tmp(${xid}) ${__mem_id}

    if { $oid ne {} } {
        set __rev_to_mem_id(${rev}) ${__mem_id}
        lassign [split_oid $rev] ks cf_axis row_key
        set type_oid [type_oid $rev]
        if { ![info exists __mem_num_cols(${type_oid},${row_key})] } {
            lappend __mem_row_keys(${type_oid}) ${row_key}
        }
        incr __mem_num_cols(${type_oid},${row_key})
    }

    return ${__mem_id}

}

proc ::persistence::commitlog::readfile {rev args} {
    lassign [split_oid $rev] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::readfile $rev]
    }

    # set codec_conf $args

    variable __mem
    variable __rev_to_mem_id

    set mem_id $__rev_to_mem_id(${rev})
    return $__mem(${mem_id},data)
}

proc ::persistence::commitlog::unset_mem {mem_id} {
    variable __mem
    unset __mem(${mem_id},instr)
    unset __mem(${mem_id},oid)
    unset __mem(${mem_id},rev)
    unset __mem(${mem_id},data)
    unset __mem(${mem_id},xid)
    unset __mem(${mem_id},codec_conf)
}

proc ::persistence::commitlog::write_to_new {xids {fsync_p "1"}} {
    variable __fp
    variable __mem_tmp
    variable __mem_new

    foreach xid ${xids} {
        foreach mem_id $__mem_tmp(${xid}) {
            if { ${fsync_p} } {
                write_to_commitlog ${mem_id}
            }
            lappend __mem_new(${xid}) ${mem_id}
        }
    }

    logpoint [tell ${__fp}]
}

proc ::persistence::commitlog::delete_from_tmp {xids} {
    variable __mem_tmp

    foreach xid $xids {
        # set begin_batch_mem_id [lindex $__mem_tmp(${xid}) 0]
        # set end_batch_mem_id [lindex $__mem_tmp(${xid}) end]

        array unset __mem_tmp ${xid}

        # unset_mem ${begin_batch_mem_id}
        # unset_mem ${end_batch_mem_id}
    }

}

proc ::persistence::commitlog::finalize_commit {xids} {
    variable __mem
    variable __mem_new
    variable __mem_cur

    foreach xid ${xids} {
        foreach mem_id $__mem_new(${xid}) {
            set instr $__mem(${mem_id},instr)
            if { $instr in {begin_batch end_batch} } {
                continue
            }
            set rev $__mem(${mem_id},rev)

            # log [namespace current],rev=$rev

            set type_oid [type_oid $rev]
            if { ![info exists __mem_cur(${type_oid})] } {
                set __mem_cur(${type_oid}) [::cbt::create $::cbt::STRING]
                # log "!!! created type_oid (=$type_oid)"
            }
            ::cbt::insert $__mem_cur(${type_oid}) $rev
            # log leafs=[::cbt::prefix_match $__mem_cur(${type_oid}) ""]
        }
        array unset __mem_new $xid
    }

}

proc ::persistence::commitlog::begin_batch {} {
    set xid [::persistence::fs::begin_batch]

    # indirect way to check if it is about a sysdb ks or not
    variable __fp
    if { $__fp ne {} } { 
        set_mem "begin_batch" "" "" $xid ""
    }

    return $xid
}

proc ::persistence::commitlog::end_batch {} {
    set xid [::persistence::fs::end_batch]

    # indirect way to check if it is about a sysdb ks or not
    variable __fp
    if { $__fp ne {} } {
        set_mem "end_batch" "" "" $xid ""

        write_to_new $xid
        delete_from_tmp $xid
        finalize_commit $xid
    }

    return $xid
}

proc ::persistence::commitlog::set_column {rev data xid codec_conf} {
    lassign [split_oid $rev] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::set_column $rev $data $xid $codec_conf]
    }

    set_mem "set_column" $rev $data $xid $codec_conf
}



proc ::persistence::commitlog::compact {type_oid todelete_rowsVar} {
    upvar $todelete_rowsVar todelete_rows

    # assert { [is_type_oid_p $type_oid] }

    lassign [split_oid $type_oid] ks cf_axis
    lassign [split $cf_axis {.}] cf idxname

    if { $ks eq {sysdb} } {
        return
    }

    # log "compact type_oid=$type_oid"

    # 1. get row keys
    set multirow_options [list]
    lassign [get_multirow_names $type_oid $multirow_options] \
        row_keys revised_multirow_options

    # 2. fget_leafs/slicelist for each row key
    set multirow_slicelist [multirow_slice \
        $type_oid $row_keys $revised_multirow_options]

    if { $multirow_slicelist eq {} } {
        log "no commitlog::leafs to compact: $type_oid"
        return
    }

    log "commitlog: compacting type_oid=$type_oid"

    # 3. merge them in one sorted-strings (sstable) file
    set output_data ""
    set pos 0
    set rows [list]
    set cols [list]
    foreach {row_key slicelist} $multirow_slicelist {

        # log -----
        # log fs::compact,row_key=$row_key
        # log slicelist=$slicelist

        set row_startpos $pos

        set len [string length $row_key]
        append output_data [binary format i $len] $row_key
        incr pos 4
        incr pos $len

        foreach rev $slicelist {

            set rev_startpos $pos

            set len [string length $rev]
            append output_data [binary format i $len] $rev 
            incr pos 4
            incr pos $len

            # one may be tempted to read 
            # the effective rev/oid
            # in the case of a .link rev,
            # however, the right thing is
            # copying the data content of
            # the given rev asis, 
            # i.e. the target rev in the
            # case of a .link rev
            #
            # NOT: set encoded_rev_data [get $rev]
            
            set encoded_rev_data [get_column $rev "-translation binary"]
            set scan_p [binary scan $encoded_rev_data a* encoded_rev_data]
            set len [string length $encoded_rev_data]

            # log encoded_rev_data,len=$len

            append output_data [binary format i $len] $encoded_rev_data
            incr pos 4
            incr pos $len

            lappend cols $rev $rev_startpos

        }

        set row_endpos $pos
        append output_data [binary format i $row_startpos]
        incr pos 4

        lappend rows $row_key $row_endpos

    }

    #log "commitlog::compact work in progress, exiting..."
    #exit

    ##
    # 4. write the (sstable) file
    #

    set name [binary encode base64 $type_oid]
    set round [clock microseconds]

    # assert { [llength $rows] % 2 == 0 }
    # assert { [llength $cols] % 2 == 0 }

    array set item [list]
    set item(name) $name
    set item(data) $output_data
    set item(rows) $rows 
    set item(cols) $cols
    set item(round) $round

    ::sysdb::sstable_t insert item

    # log "new sstable for $type_oid"

    # log "here,just for debugging nested transactions, exiting fs::compact..."
    # exit

    foreach row_key $row_keys {
        set row_oid [join_oid $ks $cf_axis $row_key]
        lappend todelete_rows $row_oid
    }

    # log "commitlog: done compacting $type_oid"

    # note that call to ::sysdb::sstable_t->insert above,
    # created a nested transaction
    # log "just for debugging nested transactions, exiting fs::compact..."
    # exit

}


proc ::persistence::commitlog::compact_all {} {

    set todelete_rows [list]
    set object_types [::sysdb::object_type_t find]

    assert { $object_types ne {} }

    foreach rev $object_types {

        set type_oids [list]
        array set object_type [::sysdb::object_type_t get $rev]

        foreach idx_data $object_type(indexes) {
            array set idx $idx_data
            set cf_axis $object_type(cf).$idx(name)
            set type_oid [join_oid $object_type(ks) $cf_axis]
            lappend type_oids $type_oid
            compact $type_oid todelete_rows
        }

        array unset object_type

        # only delete row dirs once we are done with compacting,
        # as a row might still be referenced in a link of another cf_axis

        # ATTENTION: do not use with production data just yet
        foreach todelete_row $todelete_rows {
            # deleting the given row dirs
            # renders the storage_fs dependable
            # on an implementation of
            # get_files and get_subdirs that reads
            # from the sstable files, without such
            # an implementation compact_all (at the
            # very least) won't be able to discover
            # the object types to compact, SO MAKE
            # SURE THAT get_files/get_subdirs FOR
            # READING FROM SSTABLE FILES IS COMPLETED
            # BEFORE COMMENTING-IN THE FOLLOWING LINES
            #
            # NOTE: consider deleting by marking the row as .gone
            #

            set todelete_dir [get_cur_filename $todelete_row]
            # TODO: delete_row $row_oid

            # set row_dir [file dirname $todelete_dir]
            # file delete -force $row_dir
            # log "deleted row_dir (=$row_dir)"
        }

    }

    variable __fp
    checkpoint [tell ${__fp}]

    # new_commitlog

}

# ::persistence::commitlog::init
