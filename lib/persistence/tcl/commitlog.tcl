if { ![setting_p "write_ahead_log"] } {
    # log "write_ahead_log setting is off"
    return
}

package require core

namespace eval ::persistence::commitlog {
    variable fp
    set fp ""
                                         
}

proc ::persistence::commitlog::open_if {} {
    variable fp

    if { $fp ne {} } {
        return
    }

    log "commitlog using memtable: [use_p memtable]"

    set filename [::persistence::fs::get_meta_filename "CommitLog"]
    set exists_p [file exists $filename]

    if { $exists_p } {
        set fp [open $filename "r+"]
    } else {
        set fp [open $filename "w+"]
    }

    fconfigure $fp -translation binary

    seek $fp 0 start

    # Two integers:
    # * pos1 - up to which point the commitlog has been processed
    # * pos2 - up to which point the commitlog has been written

    if { $exists_p } {

        set pos1 [::util::io::read_int $fp]
        set pos2 [::util::io::read_int $fp]
        seek $fp $pos2

        set size [file size $filename]
        if { $size > $pos2 } {
            log "!!! truncating the CommitLog up to the last proper write"
            chan truncate $fp $pos2
        }

    } else {

        set pos 8
        ::util::io::write_int $fp $pos
        ::util::io::write_int $fp $pos
        seek $fp $pos

    }

    # after 30 seconds, process commitlog
    after 30000 [list ::persistence::commitlog::process]
    # process

}

proc ::persistence::commitlog::close_if {} {
    variable fp

    if { $fp eq {} } {
        return
    }

    close $fp

    set fp ""

}

proc ::persistence::commitlog::set_column {
    oid 
    data 
    ts
    codec_conf
} {
    assert { $ts ne {} }

    variable fp

    open_if

    ::util::io::write_string $fp $oid
    ::util::io::write_string $fp $data
    ::util::io::write_string $fp $ts
    ::util::io::write_string $fp $codec_conf

    # set ts [clock microseconds]
    # set log_item_oid "sysdb/wal_item_t.by_timestamp/__default__/+/$ts"
    # set log_item_data [list timestamp $ts oid $oid data $data deleted_p "0"]
    # ::persistence::fs::set_column $log_item_oid $log_item_data
    #
    ## array set log_item $log_item_data
    ## ::sysdb::wal_item_t insert log_item
    #
    # set log_info_oid "sysdb/wal_info_t.by_attname/__default__/+/pos1"
    # set log_info_data $ts
    # ::persistence::fs::set_column $log_info_oid $log_info_data
    #
    # set log_info_oid "sysdb/wal_info_t.by_attname/__default__/+/"
    # ::persistence::fs::update_row $log_info_oid [list pos1 $ts]
    #
    ## array set wal_info [list pos2 $ts]
    ## ::sysdb::wal_info_t update wal_info 

    logpoint [tell $fp]

    # log "commitlog: pos=$pos"
}


proc ::persistence::commitlog::analyze {} {
    variable fp
    open_if

    seek $fp 0 start
    set pos1 [::util::io::read_int $fp]
    set pos2 [::util::io::read_int $fp]

    log "commitlog (analyze): last processed commit, pos1=$pos1"
    log "commitlog (analyze): end of commit log, pos2=$pos2"
    log "tell=[tell $fp]"
    while { [tell $fp] != $pos2 } {
        ::util::io::read_string $fp oid
        ::util::io::skip_string $fp
        ::util::io::read_string $fp mtime
        ::util::io::read_string $fp codec_conf
        log "commitlog (analyze): rev=${oid}@${mtime}"
        # log "commitlog (analyze): pos=[tell $fp]"
    }

}

proc ::persistence::commitlog::checkpoint {pos} {
    variable fp
    seek $fp 0 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start
}

proc ::persistence::commitlog::logpoint {pos} {
    variable fp
    seek $fp 4 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start
}


# Write-Ahead Logging (Wal) is a standard method for ensuring data
# integrity. Briefly, WAL's central concept is that changes to data
# files (where tables and indexes reside) must be written only after
# those changes have been logged, that is, after log records
# describing the changes that have not been applied to the data pages
# can be redone from the log records. This is roll-forward recovery, 
# also known as REDO.
proc ::persistence::commitlog::process {} {
    variable fp
    set savedpos [tell $fp]

    # log "processing commitlog..."

    seek $fp 0 start
    set pos1 [::util::io::read_int $fp]
    set pos2 [::util::io::read_int $fp]

    log "last_checkpoint (pos1): $pos1 --- last_logpoint (pos2): $pos2"

    set mem_p [use_p "memtable"]

    seek $fp $pos1 start
    while { $pos1 < $pos2 } {
        ::util::io::read_string $fp oid
        ::util::io::read_string $fp data
        ::util::io::read_string $fp mtime
        ::util::io::read_string $fp codec_conf
        set pos1 [tell $fp]

        if { $mem_p } {
            set rev "${oid}@${mtime}"
            if { ![::persistence::mem::exists_column_rev_p $rev] } {
                # wrap_proc in zz-postinit.tcl submits oid to commitlog and memtable
                # so, the following, for the roll-forward recovery after server startup
                ::persistence::mem::set_column $oid $data $mtime $codec_conf
            }
        } else {

            # 1. exec command
            call_orig_of ::persistence::fs::set_column $oid $data $mtime $codec_conf

            # 2. increase and write int to pos1
            checkpoint [tell $fp]  ;# must be equal to pos1 at this point
        }

    }

    if { $mem_p } {
        ::persistence::mem::dump
        checkpoint [tell $fp]  ;# must be equal to pos2 at this point
    }

    after 10000 [list ::persistence::commitlog::process]
    
}

after_package_load persistence ::persistence::commitlog::open_if
