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
    variable __mem_row_keys

    # __xid_to_commitlog(xid) => commitlog
    variable __xid_to_commitlog
    array set __xid_to_commitlog [list]

    # __commitlog_pending(commitlog_name) => number of pending batches/xids
    variable __commitlog_pending
    array set __commitlog_pending [list]

    # current commitlog
    variable commitlog_name
    set commitlog_name {}

    # all open commitlog names
    variable commitlog_names
    set commitlog_names {}

    # commitlog(commitlog_name,{size,entries}) => value
    variable commitlog
    array set commitlog [list]
    
    # threshold_exceeded_p configuration settings
    variable commitlog_threshold
    array set commitlog_threshold [list]
    set commitlog_threshold(size) 9999999
    set commitlog_threshold(n_entries) 99999

    # all open commitlog file pointers
    variable fp
    array set fp [list]

    array set __mem_row_keys [list]
    set __mem_id 0
    array set __mem [list]
    array set __mem_tmp [list]
    array set __mem_new [list]
    array set __mem_cur [list]
    array set __rev_to_mem_id [list]

    # namespace import ::persistence::common::split_oid
    # namespace import ::persistence::common::join_oid
    # namespace import ::persistence::common::type_oid

    namespace __copy ::persistence::common

}

proc ::persistence::commitlog::compare_commitlog_files {f1 f2} {
    set m1 [lindex [split $f1 {-}] 1]
    set m2 [lindex [split $f2 {-}] 1]

    if { $m1 < $m2 } {
        return -1
    } elseif { $m1 > $m2 } {
        return 1
    } else {
        return 0
    }
}

proc ::persistence::commitlog::init {} {

    ::persistence::fs::init

    # log "initializing commitlog..."

    variable base_dir
    variable commitlog_name
    variable commitlog_names

    set dir [file join $base_dir cur]
    set commitlog_names [glob -nocomplain -tails -directory $dir CommitLog-*]
    set commitlog_names [lsort -command compare_commitlog_files ${commitlog_names}]
    if { ${commitlog_names} eq {} } {
        set commitlog_names [new_commitlog]
    }

    foreach commitlog_name ${commitlog_names} {
        log "!!! init commitlog ${commitlog_name}"
        init_commitlog ${commitlog_name}
        open_commitlog ${commitlog_name}
        load_commitlog ${commitlog_name}
    }
    # at_shutdown close_commitlog ${commitlog_name}
}

proc ::persistence::commitlog::new_commitlog {} {
    variable commitlog_name
    variable commitlog_names

    set micros [clock microseconds]
    set commitlog_name "CommitLog-${micros}"
    lappend commitlog_names ${commitlog_name}

    init_commitlog ${commitlog_name}
    open_commitlog ${commitlog_name}

    return ${commitlog_name}
}

proc ::persistence::commitlog::init_commitlog {commitlog_name} {
    variable fp
    variable commitlog

    set commitlog(${commitlog_name},size) 0
    set commitlog(${commitlog_name},n_entries) 0
    set fp($commitlog_name) {}
}

proc ::persistence::commitlog::open_commitlog {commitlog_name} {
    variable fp

    if { $fp(${commitlog_name}) ne {} } {
        return
    }

    # log "opening commitlog..."

    set filename [::persistence::common::get_cur_filename ${commitlog_name}]
    file mkdir [file dirname ${filename}]
    set exists_p [file exists ${filename}]

    if { $exists_p } {
        set fp(${commitlog_name}) [open ${filename} "r+"]
    } else {
        set fp(${commitlog_name}) [open ${filename} "w+"]
    }

    chan configure $fp(${commitlog_name}) -translation binary

    seek $fp(${commitlog_name}) 0 start

    # Two integers:
    # * pos1 - up to which point the commitlog has been processed
    # * pos2 - up to which point the commitlog has been written

    if { $exists_p } {

        set pos1 [::util::io::read_int $fp(${commitlog_name})]
        set pos2 [::util::io::read_int $fp(${commitlog_name})]
        seek $fp(${commitlog_name}) $pos2

        set size [file size $filename]
        if { $size > $pos2 } {
            log "!!! truncating the CommitLog up to the last proper write"
            chan truncate $fp(${commitlog_name}) $pos2
        }

    } else {

        set pos 8
        ::util::io::write_int $fp(${commitlog_name}) ${pos}
        ::util::io::write_int $fp(${commitlog_name}) ${pos}
        seek $fp(${commitlog_name}) ${pos}

    }

    return ${commitlog_name}

}

proc ::persistence::commitlog::close_commitlog {commitlog_name} {
    variable __xid_to_commitlog
    variable __commitlog_pending
    variable commitlog_names

    set timer [list ::persistence::commitlog::close_commitlog ${commitlog_name}]
    if { [value_if __commitlog_pending(${commitlog_name}) "0"] } {
        after 0 ${timer}
        return
    }

    after cancel ${timer}

    variable fp
    if { $fp(${commitlog_name}) ne {} } {

        # remove name from open commitlog_names variable
        set i [lsearch -exact ${commitlog_names} ${commitlog_name}]
        assert { ${i} != -1 }
        set commitlog_names [lreplace ${commitlog_names} ${i} ${i}]
    
        # compact_all using the old commitlog file
        # compact_all

        # close old commitlog file
        close $fp(${commitlog_name})
    }
    unset fp(${commitlog_name})
}

proc ::persistence::commitlog::threshold_exceeded_p {commitlog_name} {
    variable commitlog
    variable commitlog_threshold

    set size $commitlog(${commitlog_name},size)
    set n_entries $commitlog(${commitlog_name},n_entries)

    # if size exceeded, or
    # if number of entries exceeded
    if { 
        ${size} > $commitlog_threshold(size) 
        || ${n_entries} > $commitlog_threshold(n_entries)
    } {
        return 1
    } 
    return 0
}

proc ::persistence::commitlog::write_to_commitlog {commitlog_name mem_id} {

    variable fp

    variable __mem

    assert { $fp(${commitlog_name}) ne {} }

    array set item [list]
    set item(commitlog_name)    $__mem(${mem_id},commitlog_name)
    set item(name)              $__mem(${mem_id},offset)
    set item(instr)             $__mem(${mem_id},instr)
    set item(oid)               $__mem(${mem_id},oid)
    set item(data)              $__mem(${mem_id},data)
    set item(xid)               $__mem(${mem_id},xid)
    set item(codec_conf)        $__mem(${mem_id},codec_conf)

    set commitlog_item_data [::sysdb::commitlog_item_t encode item]
    set commitlog_item_data [binary format a* $commitlog_item_data]
    ::util::io::write_string $fp(${commitlog_name}) $commitlog_item_data

    if { [threshold_exceeded_p ${commitlog_name}] } {

        log "!!! threshold exceeded"

        # 1. create new commitlog
        new_commitlog

        # 2.1. wait until all open batches are completed
        # 2.2. compact old commitlog
        # 2.3. close old commitlog

        after 0 [::persistence::commitlog::close_commitlog ${commitlog_name}]

    }

}


proc ::persistence::commitlog::checkpoint {commitlog_name {pos ""}} {
    variable fp
    if { ${pos} eq {} } {
        set pos [tell $fp(${commitlog_name})]
    }
    seek $fp(${commitlog_name}) 0 start
    ::util::io::write_int $fp(${commitlog_name}) $pos
    seek $fp(${commitlog_name}) $pos start
}

proc ::persistence::commitlog::logpoint {commitlog_name {pos ""}} {
    variable fp  
    if { ${pos} eq {} } {
        set pos [tell $fp(${commitlog_name})]
    }
    seek $fp(${commitlog_name}) 4 start
    ::util::io::write_int $fp(${commitlog_name}) $pos
    seek $fp(${commitlog_name}) $pos start
}


# Write-Ahead Logging (Wal) is a standard method for ensuring data
# integrity. Briefly, WAL's central concept is that changes to data
# files (where tables and indexes reside) must be written only after
# those changes have been logged, that is, after log records
# describing the changes that have not been applied to the data pages
# can be redone from the log records. This is roll-forward recovery, 
# also known as REDO.
proc ::persistence::commitlog::load_commitlog {commitlog_name} {
    variable fp

    assert { $fp(${commitlog_name}) ne {} }

    # log "loading commitlog..."

    seek $fp(${commitlog_name}) 0 start
    set pos1 [::util::io::read_int $fp(${commitlog_name})]
    set pos2 [::util::io::read_int $fp(${commitlog_name})]

    log "last_checkpoint (pos1): $pos1 --- last_logpoint (pos2): $pos2"

    seek $fp(${commitlog_name}) $pos1 start

    set xids [list]
    array set seen [list]
    while { $pos1 < $pos2 } {

        ::util::io::read_string $fp(${commitlog_name}) commitlog_item_data

        set pos1 [tell $fp(${commitlog_name})]

        array set item [::sysdb::commitlog_item_t decode commitlog_item_data]

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


# NOTE that path may contain a commitlog_name prefix,
# e.g. CommitLog-12345:newsdb/news_item.by_urlsha1
#
# TODO: must support this kind of querying by maintaining a parallel
# critbit-tree structure for each commitlog.

# limit := -1 (=all)
proc ::persistence::commitlog::get_leafs {path {direction "0"} {limit ""}} {
    variable __mem_cur

    set limit [coalesce ${limit} "-1"]

    set result [list]

    lassign [split_oid ${path}] ks
    if { ${ks} eq {sysdb} } {
        return [::persistence::fs::get_leafs ${path} ${direction} ${limit}]
    }

    variable commitlog_names
    assert { ${commitlog_names} ne {} }
    set result [list]
    set type_oid [type_oid $path]
    foreach commitlog_name ${commitlog_names} {

        if { [info exists __mem_cur(${commitlog_name},${type_oid})] } {

            set result [concat ${result} \
                [::cbt::prefix_match \
                    $__mem_cur(${commitlog_name},${type_oid}) \
                    ${path} \
                    ${direction} \
                    ${limit}]]

        } else {
            # log "no data for type_oid (=$type_oid) yet"
        }

    }

    # log [namespace current],get_leafs,result=$result

    return [lsort -unique -command ::persistence::compare_files ${result}]
}

proc ::persistence::commitlog::get_subdirs {path {direction "0"} {limit ""}} {

    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::get_subdirs $path $direction $limit]
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
    variable commitlog_names

    # log commitlog_names=$commitlog_names

    set result [list]
    foreach commitlog_name ${commitlog_names} {

        set varname "__mem_row_keys(${commitlog_name},${type_oid})"
        if { [info exists ${varname}] } {

            set cbt_id [set ${varname}]

            set row_keys [::cbt::prefix_match \
                $__mem_row_keys(${commitlog_name},${type_oid}) \
                "" \
                ${direction} \
                [coalesce ${limit} "-1"]]

            foreach row_key $row_keys {
                lappend result ${type_oid}/${row_key}
            }

        }

    }

    if { ${direction} == 0 } {
        set sort_direction "decreasing"
    } else {
        set sort_direction "increasing"
    }

    set result [lsort -${sort_direction} ${result}]
    if { $limit ne {} && [llength ${commitlog_names}] > 1 } {
        set result [lrange ${result} 0 ${limit}]
    }
    return $result

}

# TO BE CHECKED AGAIN
proc ::persistence::commitlog::exists_p {rev} {
    lassign [split_oid $rev] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::exists_p $rev]
    }
    return [expr { [get_leafs $rev 0 1] ne {} }]
}
                                         
proc ::persistence::commitlog::set_mem {instr oid data xid codec_conf} {

    variable __mem_id
    variable __mem

    variable __mem_tmp
    variable __commitlog_pending
    variable __xid_to_commitlog

    variable __rev_to_mem_id
    variable __mem_row_keys
    variable __mem_num_cols

    if { ![info exists __xid_to_commitlog(${xid})] } {
        variable commitlog_name
        set __xid_to_commitlog(${xid}) ${commitlog_name}
        set __commitlog_pending(${commitlog_name}) 1
    } else {
        set commitlog_name $__xid_to_commitlog(${xid})
    }

    variable fp
    set offset [tell $fp(${commitlog_name})]

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
        if { 
            ![info exists __mem_row_keys(${commitlog_name},${type_oid})] 
        } {
            set __mem_row_keys(${commitlog_name},${type_oid}) [::cbt::create $::cbt::STRING]
        }

        ::cbt::insert $__mem_row_keys(${commitlog_name},${type_oid}) ${row_key}

        incr __mem_num_cols(${type_oid},${row_key})
    }

    set len [string length ${data}]
    incr commitlog(${commitlog_name},size) ${len}
    incr commitlog(${commitlog_name},n_entries)

    return ${__mem_id}

}

proc ::persistence::commitlog::readfile {rev args} {
    lassign [split_oid $rev] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::readfile $rev]
    }

    # log "!!!!!!!!!!!!!!!!!!!!!! commitlog::readfile"

    # set codec_conf $args

    variable __mem
    variable __rev_to_mem_id

    set mem_id $__rev_to_mem_id(${rev})
    set data $__mem(${mem_id},data)
    return $data
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
    variable __xid_to_commitlog
    variable fp

    variable __mem_tmp
    variable __mem_new

    foreach xid ${xids} {

        if { ${fsync_p} } {
            set commitlog_name [value_if __xid_to_commitlog(${xid}) ""]
        }

        set parent_xid [lrange [split $xid {/}] 0 end-1]
        if { $parent_xid ne {} } {

            # TODO: handle nested transactions/batches
            # in commitlog::write_to_new proc

            log parent_xid=$parent_xid
        }

        foreach mem_id $__mem_tmp(${xid}) {
            if { ${fsync_p} } {
                write_to_commitlog ${commitlog_name} ${mem_id}
            }
            lappend __mem_new(${xid}) ${mem_id}
        }
    }

}

proc ::persistence::commitlog::delete_from_tmp {xids} {
    variable __mem_tmp

    foreach xid $xids {
        # set begin_batch_mem_id [lindex $__mem_tmp(${xid}) 0]
        # set end_batch_mem_id [lindex $__mem_tmp(${xid}) end]

        unset __mem_tmp(${xid})

        # FIXME: issue with nested transactions
        set commitlog_name [value_if __xid_to_commitlog(${xid}) ""]

        if { ${commitlog_name} ne {} } {
            unset __xid_to_commitlog(${xid})
            incr __commitlog_pending(${commitlog_name}) -1
            if { $__commitlog_pending(${commitlog_name}) == 0 } {
                unset __commitlog_pending(${commitlog_name})
            }
        }

        # unset_mem ${begin_batch_mem_id}
        # unset_mem ${end_batch_mem_id}
    }

}

proc ::persistence::commitlog::finalize_commit {xids} {
    variable __mem
    variable __mem_new
    variable __mem_cur
    variable __xid_to_commitlog

    foreach xid ${xids} {

        set commitlog_name $__xid_to_commitlog(${xid})

        foreach mem_id $__mem_new(${xid}) {
            set instr $__mem(${mem_id},instr)
            if { $instr in {begin_batch end_batch} } {
                continue
            }
            set rev $__mem(${mem_id},rev)

            # log [namespace current],rev=$rev

            set type_oid [type_oid $rev]
            if { ![info exists __mem_cur(${commitlog_name},${type_oid})] } {
                set __mem_cur(${commitlog_name},${type_oid}) [::cbt::create $::cbt::STRING]
            }
            if { ![info exists __mem_row_keys(${commitlog_name},${type_oid})] } {
                set __mem_row_keys(${commitlog_name},${type_oid}) [::cbt::create $::cbt::STRING]
            }
            ::cbt::insert $__mem_cur(${commitlog_name},${type_oid}) $rev
        }
        array unset __mem_new $xid
    }

}

proc ::persistence::commitlog::begin_batch {} {
    set xid [::persistence::fs::begin_batch]

    # indirect way to check if it is about a sysdb ks or not
    variable commitlog_name
    variable fp
    if { $fp(${commitlog_name}) ne {} } { 
        set_mem "begin_batch" "" "" $xid ""
    }

    return $xid
}

proc ::persistence::commitlog::end_batch {} {
    set xid [::persistence::fs::end_batch]

    variable __xid_to_commitlog
    set commitlog_name [value_if __xid_to_commitlog(${xid}) ""]

    variable fp

    # indirect way to check if it is about a sysdb ks or not
    if { $fp(${commitlog_name}) ne {} } {
        set_mem "end_batch" "" "" $xid ""

        write_to_new $xid

        logpoint ${commitlog_name}
        
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

    # 1. get row keys
    set multirow_options [list]
    lassign [get_multirow_names $type_oid $multirow_options] \
        row_keys revised_multirow_options

    # 2. get_leafs/slicelist for each row key
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

        set row_startpos $pos

        set len [string length $row_key]
        append output_data [binary format i $len] $row_key
        incr pos 4
        incr pos $len

        foreach rev $slicelist {

            set rev_startpos $pos

            # start of code using sstable_item_t
            array set sstable_item [list]
            set sstable_item(rev) $rev
            set sstable_item(data) [get_column $rev "-translation binary"]
            set scan_p [binary scan $sstable_item(data) a* sstable_item(data)]
            assert { $scan_p }
            set encoded_rev_data [::sysdb::sstable_item_t encode sstable_item]
            set len [string length $encoded_rev_data]
            append output_data [binary format i $len] $encoded_rev_data
            incr pos 4
            incr pos $len
            unset sstable_item
            # end of code using sstable_item_t

            lappend cols $rev $rev_startpos

        }

        set row_endpos $pos
        append output_data [binary format i $row_startpos]
        incr pos 4

        lappend rows $row_key $row_endpos

    }

    ##
    # 4. write the (sstable) file
    #

    set name [binary encode base64 $type_oid]
    set round [clock microseconds]

    array set item [list]
    set item(name) $name
    set item(data) $output_data
    set item(rows) $rows 
    set item(cols) $cols
    set item(round) $round

    ::sysdb::sstable_t insert item

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

    variable commitlog_names
    foreach commitlog_name ${commitlog_names} {
        checkpoint ${commitlog_name}
        # log delete_commitlog ${commitlog_name}
    }

}

# ::persistence::commitlog::init
