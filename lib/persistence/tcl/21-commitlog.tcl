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

    log "initializing commitlog..."

    open_commitlog
    load_commitlog
    # at_shutdown close_commitlog
}

proc ::persistence::commitlog::get_leafs {path {direction "0"} {limit ""}} {
    variable __mem_cur

    set result [list]
    set type_oid [type_oid $path]
    if { [info exists __mem_cur(${type_oid})] } {
        set result [::cbt::prefix_match $__mem_cur(${type_oid}) $path]
        # log "!!! path=$path"
        # log "!!! leafs=[::cbt::prefix_match $__mem_cur(${type_oid}) ""]"
    } else {
        log "no such type_oid (=$type_oid)"
    }

    log [namespace current],get_leafs,result=$result

    return $result
}
                                         
proc ::persistence::commitlog::set_mem {instr rev data xid codec_conf} {

    variable __mem_id
    variable __mem
    variable __mem_tmp
    variable __rev_to_mem_id

    incr __mem_id
    set __mem(${__mem_id},instr)    $instr
    set __mem(${__mem_id},rev)      $rev
    set __mem(${__mem_id},data)     $data
    set __mem(${__mem_id},xid)      $xid
    set __mem(${__mem_id},codec_conf) $codec_conf

    lappend __mem_tmp(${xid}) ${__mem_id}

    set __rev_to_mem_id(${rev}) ${__mem_id}

    return ${__mem_id}

}

proc ::persistence::commitlog::readfile {rev} {
    variable __mem
    variable __rev_to_mem_id

    set mem_id $__rev_to_mem_id(${rev})
    return $__mem(${mem_id},data)
}

proc ::persistence::commitlog::unset_mem {mem_id} {
    variable __mem
    unset __mem(${mem_id},instr)
    unset __mem(${mem_id},rev)
    unset __mem(${mem_id},data)
    unset __mem(${mem_id},xid)
    unset __mem(${mem_id},codec_conf)
}

proc ::persistence::commitlog::write_to_new {xids {fsync_p "1"}} {
    variable __fp
    variable __mem_tmp
    variable __mem_new

    # set savepos [tell $__fp]

    foreach xid ${xids} {
        foreach mem_id $__mem_tmp(${xid}) {
            if { ${fsync_p} } {
                write_to_commitlog ${mem_id}
            }
            lappend __mem_new(${xid}) ${mem_id}
        }
    }

    # logpoint $savepos
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
    set_mem "begin_batch" "" "" $xid ""
    return $xid
}

proc ::persistence::commitlog::end_batch {} {
    set xid [::persistence::fs::end_batch]
    set_mem "end_batch" "" "" $xid ""

    write_to_new $xid
    delete_from_tmp $xid
    finalize_commit $xid

    return $xid
}

proc ::persistence::commitlog::set_column {rev data xid codec_conf} {
    set_mem "set_column" $rev $data $xid $codec_conf
}


proc ::persistence::commitlog::open_commitlog {} {
    variable __fp

    if { $__fp ne {} } {
        return
    }

    log "opening commitlog..."

    set filename [::persistence::common::get_filename "CommitLog"]
    set exists_p [file exists $filename]

    if { $exists_p } {
        set __fp [open $filename "r+"]
    } else {
        set __fp [open $filename "w+"]
    }

    fconfigure $__fp -translation binary

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

    ::util::io::write_string $__fp $__mem(${mem_id},instr)
    ::util::io::write_string $__fp $__mem(${mem_id},rev)
    ::util::io::write_string $__fp $__mem(${mem_id},data)
    ::util::io::write_string $__fp $__mem(${mem_id},xid)
    ::util::io::write_string $__fp $__mem(${mem_id},codec_conf)

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

    log "loading commitlog..."

    seek $__fp 0 start
    set pos1 [::util::io::read_int $__fp]
    set pos2 [::util::io::read_int $__fp]

    # log "last_checkpoint (pos1): $pos1 --- last_logpoint (pos2): $pos2"

    seek $__fp $pos1 start

    set xids [list]
    array set seen [list]
    while { $pos1 < $pos2 } {

        ::util::io::read_string $__fp instr
        ::util::io::read_string $__fp oid
        ::util::io::read_string $__fp data
        ::util::io::read_string $__fp xid
        ::util::io::read_string $__fp codec_conf
        set pos1 [tell $__fp]

        set_mem $instr $oid $data $xid $codec_conf

        if { ![info exists seen(${xid})] } {
            set seen(${xid}) {}
            lappend xids ${xid}
        }

    }

    write_to_new $xids 0 ;# fsync_p=0
    delete_from_tmp $xids
    finalize_commit $xids

}


if {0} {

    # OLD
    proc ::persistence::commitlog::write_to_fs {mem_id} {

        variable __mem

        ::persistence::fs::$__mem(${mem_id},instr) \
            $__mem(${mem_id},rev) \
            $__mem(${mem_id},data) \
            $__mem(${mem_id},xid) \
            $__mem(${mem_id},codec_conf)

        checkpoint $__mem(${mem_id},offset)

    }

    # OLD
    proc ::persistence::commitlog::compact_all {} {
        set type_oids [list]

        set revs [get_leafs ""]
        foreach rev $revs {
            set type_oid [type_oid $rev]
            lappend type_oids $type_oid

            write_to_fs $mem_id

        }


        foreach type_oid $type_oids {
            ::persistence::fs::compact $type_oid 
        }
    }

    variable loading_p
    variable timer
    variable __fp

    if { $__fp eq {} } {
        ::persistence::commitlog::init
    }

    if { $timer ne {} } {
        after cancel $timer
        set timer ""
    }

    if { $loading_p } {
        log "loading, please wait..."
        set millis [setting "process_commitlog_millis"] 
        set timer [after $millis [list ::persistence::commitlog::process]]
        return
    }

    set loading_p 1

    set read_committed_p \
        [expr { [setting "isolation_level"] ne {READ UNCOMMITTED} }]


        if { $read_committed_p } {
            if { $bootstrap_p } {
                # wrap_proc in zz-postinit.tcl submits oid to commitlog and memtable
                # so, this only for the roll-forward recovery after server startup

                ::persistence::mem::set_column $oid $data $xid $codec_conf
            }
        } else {

            # 1. exec command
            call_orig_of ::persistence::fs::set_column $oid $data $xid $codec_conf

            # 2. increase and write int to pos1
            checkpoint [tell $__fp]  ;# must be equal to pos1 at this point
        }


    if { $read_committed_p } {
        ::persistence::mem::dump
        checkpoint [tell $__fp]  ;# must be equal to pos2 at this point
    }

    set inprogress_p 0
    #log "done processing commitlog..."

    set millis [setting "process_commitlog_millis"] 
    set timer [after $millis [list ::persistence::commitlog::process]]

}

::persistence::commitlog::init
