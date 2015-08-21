if { ![setting_p "write_ahead_log"] } {
    # log "write_ahead_log setting is off"
    return
}

package require core

namespace eval ::persistence::commitlog {

    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::split_xid

    variable fp
    set fp ""

    variable commitlog_oid
    set commitlog_oid ""

}

proc ::persistence::commitlog::init {} {

    ##
    # commitlog_oid is empty when open_if invokes ::sysdb::commitlog_t->insert
    # for the first time, in effect ::sysdb::commitlog_t->insert won't produce
    # any ::sysdb::commitlog_item_t record
    #

    variable commitlog_oid
    set commitlog_oid ""

    array set options [list limit 1]
    set where_clause [list [list name = "CommitLog"]]
    set commitlog_oid [::sysdb::commitlog_t find $where_clause options]
    #log open_if,enter,commitlog_oid=$commitlog_oid
    if { $commitlog_oid eq {} } {
        array set item [list]
        set item(name) "CommitLog"
        set item(last_checkpoint) 0
        set item(last_logpoint) 0
        # set commitlog_oid "sysdb/commitlog.by_name/CommitLog/+/CommitLog"
        set commitlog_oid [::sysdb::commitlog_t insert item]
    }
    assert { $commitlog_oid ne {} }
    #log open_if,leave,commitlog_oid=$commitlog_oid

    open_if

    process true ;# bootstrap_p=true

}
                                         

proc ::persistence::commitlog::insert {itemVar} {
    variable fp

    open_if

    upvar $itemVar item
    assert { $item(oid) ne {} }

    if { ![string match *bloom_filter* $item(oid)] } {
        # log >>>commitlog_item,insert,$item(xid),$item(oid)
    }

    ##
    # log commitlog_item,insert,oid=$item(oid)
    #
    # first log notice produced by "commitlog_t insert":
    # commitlog,insert,oid=sysdb/commitlog.by_name/CommitLog/+/CommitLog

    lassign [split_oid $item(oid)] ks cf_axis row_key column_path ext
    lassign [split $cf_axis {.}] cf idxname

    if { 0 && $ks ne {sysdb} } {
        # NOT SURE IF commitlog_item_t SHOULD BE KEPT IN THIS WAY
        # TODO: fix me, should work with any keyspace
        # log "commitlog_item_t new $item(oid)"
        set item(commitlog_name) "CommitLog"
        set item(name) [tell $fp]
        ::sysdb::commitlog_item_t insert item
    }

    ::persistence::commitlog::set_column \
        $item(oid) $item(data) $item(xid) $item(codec_conf)

    ::persistence::mem::set_column \
        $item(oid) $item(data) $item(xid) $item(codec_conf)


    # log object_types=[join [::sysdb::object_type_t find] \n\t\t>>>]

}

proc ::persistence::commitlog::open_if {} {
    variable fp

    if { $fp ne {} } {
        return
    }

    log "commitlog using memtable: [setting_p memtable]"

    set filename [::persistence::common::get_filename "CommitLog"]
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

    after 0 [list ::persistence::commitlog::process]

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
    xid
    codec_conf
} {
    assert { $xid ne {} }

    variable fp

    open_if

    # log oid=$oid

    ::util::io::write_string $fp $oid
    ::util::io::write_string $fp $data
    ::util::io::write_string $fp $xid
    ::util::io::write_string $fp $codec_conf

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
        ::util::io::read_string $fp xid
        ::util::io::read_string $fp codec_conf
        lassign [split_xid $xid] micros pid n_mutations mtime
        log "commitlog (analyze): rev=${oid}@${micros}"
        # log "commitlog (analyze): pos=[tell $fp]"
    }

}

proc ::persistence::commitlog::checkpoint {pos} {
    variable fp
    seek $fp 0 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start

    if {0} {
        variable commitlog_oid
        assert { $commitlog_oid ne {} }
        array set item [list last_checkpoint $pos]
        ::sysdb::commitlog_t update $commitlog_oid item
    }
}

proc ::persistence::commitlog::logpoint {pos} {
    variable fp
    seek $fp 4 start
    ::util::io::write_int $fp $pos
    seek $fp $pos start

    if {0} {
        variable commitlog_oid
        assert { $commitlog_oid ne {} }
        array set item [list last_logpoint $pos]
        ::sysdb::commitlog_t update $commitlog_oid item
    }
}


# Write-Ahead Logging (Wal) is a standard method for ensuring data
# integrity. Briefly, WAL's central concept is that changes to data
# files (where tables and indexes reside) must be written only after
# those changes have been logged, that is, after log records
# describing the changes that have not been applied to the data pages
# can be redone from the log records. This is roll-forward recovery, 
# also known as REDO.
proc ::persistence::commitlog::process {{bootstrap_p "0"}} {
    variable fp
    set savedpos [tell $fp]

    # log "processing commitlog..."

    seek $fp 0 start
    set pos1 [::util::io::read_int $fp]
    set pos2 [::util::io::read_int $fp]

    # log "last_checkpoint (pos1): $pos1 --- last_logpoint (pos2): $pos2"

    set mem_p [setting_p "memtable"]

    seek $fp $pos1 start
    while { $pos1 < $pos2 } {
        ::util::io::read_string $fp oid
        ::util::io::read_string $fp data
        ::util::io::read_string $fp xid
        ::util::io::read_string $fp codec_conf
        set pos1 [tell $fp]

        if { $mem_p } {
            lassign [split_xid $xid] micros pid n_mutations mtime
            set rev "${oid}@${micros}"
            if { $bootstrap_p } {
                if { ![::persistence::mem::exists_column_rev_p $rev] } {
                    # wrap_proc in zz-postinit.tcl submits oid to commitlog and memtable
                    # so, the following, for the roll-forward recovery after server startup

                    ::persistence::mem::set_column $oid $data $xid $codec_conf
                }
            }
        } else {

            # 1. exec command
            call_orig_of ::persistence::fs::set_column $oid $data $xid $codec_conf

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

after_package_load persistence ::persistence::commitlog::init
