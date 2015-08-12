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

    set filename [::persistence::fs::get_filename "CommitLog"]
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
            # truncate the CommitLog up to the last proper write
            chan truncate $fp $pos2
        }

    } else {

        set pos 8
        ::util::io::write_int $fp $pos
        ::util::io::write_int $fp $pos
        seek $fp $pos

    }

    # after 10 seconds, process commitlog
    after 10000 [list ::persistence::commitlog::process]
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

proc ::persistence::commitlog::set_column_data {
    oid 
    data 
    {codec_conf "-translation binary"}
} {
    variable fp

    open_if

    ::util::io::write_string $fp $oid
    ::util::io::write_string $fp $data

    # set ts [clock microseconds]
    # set log_item_oid "sysdb/wal_item_t.by_timestamp/__default__/+/$ts"
    # set log_item_data [list timestamp $ts oid $oid data $data deleted_p "0"]
    # ::persistence::fs::set_column_data $log_item_oid $log_item_data
    #
    ## array set log_item $log_item_data
    ## ::sysdb::wal_item_t insert log_item
    #
    # set log_info_oid "sysdb/wal_info_t.by_attname/__default__/+/pos1"
    # set log_info_data $ts
    # ::persistence::fs::set_column_data $log_info_oid $log_info_data
    #
    # set log_info_oid "sysdb/wal_info_t.by_attname/__default__/+/"
    # ::persistence::fs::update_row $log_info_oid [list pos1 $ts]
    #
    ## array set wal_info [list pos2 $ts]
    ## ::sysdb::wal_info_t update wal_info 

    set pos [tell $fp]
    seek $fp 4 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start

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
        log "commitlog (analyze): oid=$oid"
        # log "commitlog (analyze): pos=[tell $fp]"
    }

}

proc ::persistence::commitlog::checkpoint {pos} {
    variable fp
    seek $fp 0 start
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

    log "processing commitlog..."

    seek $fp 0 start
    set pos1 [::util::io::read_int $fp]
    set pos2 [::util::io::read_int $fp]

    log "pos1=$pos1 pos2=$pos2 tell=[tell $fp]"

    set mem_p 0

    seek $fp $pos1 start
    while { $pos1 < $pos2 } {
        ::util::io::read_string $fp oid
        ::util::io::read_string $fp data
        set pos1 [tell $fp]

        if { $mem_p } {
            ::persistence::mem::set_column_data $oid $data "-translation binary"
        } else {

            # 1. exec command
            call_orig_of ::persistence::fs::set_column_data $oid $data "-translation binary"

            # 2. increase and write int to pos1
            checkpoint $pos1
        }

    }

    if { $mem_p } {
        ::persistence::mem::dump
        checkpoint $pos2
    }

    after 10000 [list ::persistence::commitlog::process]
    
}

after_package_load persistence ::persistence::commitlog::open_if
