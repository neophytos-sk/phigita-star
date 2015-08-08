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

    if { $exists_p } {

        set pos [::util::io::read_int $fp]
        seek $fp $pos

        set size [file size $filename]
        if { $size > $pos } {
            # truncate the CommitLog up to the last proper write
            chan truncate $fp $pos
        }

    } else {
        set pos 4
        ::util::io::write_int $fp $pos
        seek $fp $pos
    }

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
    seek $fp 0 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start

    log "commitlog: pos=$pos"
}


proc ::persistence::commitlog::analyze {} {
    variable fp
    open_if

    seek $fp 0 start
    set pos [::util::io::read_int $fp]

    log "commitlog (analyze): end of commit log, pos=$pos"
    while { [tell $fp] != $pos } {
        ::util::io::read_string $fp oid
        ::util::io::skip_string $fp
        log "commitlog (analyze): oid=$oid"
        # log "commitlog (analyze): pos=[tell $fp]"
    }

}

