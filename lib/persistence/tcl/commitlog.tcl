if { ![is_server_p] } {
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

    while { $pos1 < $pos2 && [tell $fp] != $pos2 } {
        ::util::io::read_string $fp oid
        ::util::io::read_string $fp data

        # 1. exec command
        ::persistence::fs::__set_column_data $oid $data "-translation binary"
        #set filename [::persistence::get_filename $oid]
        #file mkdir [file dirname $filename]
        #::util::writefile $filename $data -translation binary

        # 2. increase and write int to pos1
        set savedpos [tell $fp]
        seek $fp 0 start
        ::util::io::write_int $fp $savedpos
        seek $fp $savedpos start
        set pos1 $savedpos

    }

    seek $fp $savedpos start

    after 10000 [list ::persistence::commitlog::process]
    
}

after_package_load persistence ::persistence::commitlog::open_if
