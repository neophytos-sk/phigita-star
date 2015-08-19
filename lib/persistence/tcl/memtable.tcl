if { ![setting_p "memtable"] } {
    return
}

namespace eval ::persistence::mem {

    variable __mem
    array set __mem [list]

    variable __cnt 0

    variable __dir
    array set __dir [list]

    variable __idx
    array set __idx [list]

    variable __xid_rev
    array set __xid_rev [list]

    variable __xid_list [list]

    variable __xid_committed
    array set __xid_committed [list]

    namespace import ::persistence::common::split_xid

    namespace path "::persistence ::persistence::common"

}

proc ::persistence::mem::init {} {}
proc ::persistence::mem::define_cf {ks cf_axis} {}

proc ::persistence::mem::visible_p {xid_micros} {
    return 1
}

proc ::persistence::mem::get_files {nodepath} {

    # log get_files,path=$nodepath

    variable __idx
    variable __mem
    

    if { [is_column_rev_p $nodepath] || [is_link_rev_p $nodepath] } {
        set pattern "${nodepath}"
        set rev_names [array names __idx ${pattern}]

    } else {
        set pattern "${nodepath}*"
        set rev_names [array names __idx ${pattern}]
    }


    set len [string length $nodepath]

    #log --------------
    #log patte=$pattern
    #log nodep=$nodepath
    #log __idx=[array names __idx]
    #log rev_names=$rev_names

    array set latest_rev [list]
    foreach rev $rev_names {
        lassign [split $rev "@"] oid micros

        set xid $__mem(${rev},xid)

        set committed_p [value_if __xid_committed($xid) "0"]
        if { !$committed_p } { 
            # TODO: 
            #   check for revs that qualify 
            #   from transactions in progress 
            continue 
        }

        # check timestamp based on the oid
        # (without the .gone suffix)
        # we exclude deleted oids below
        set is_gone_p 0
        set normalized_oid $oid
        if { [file extension $oid] eq {.gone} } {
            set is_gone_p 1
            set normalized_oid [file rootname $oid]
        }

        lassign [value_if latest_rev($normalized_name) ""] is_gone_already_p latest_micros

        if { $latest_micros < $micros } {
            set latest_rev($normalized_oid) [list $is_gone_p $micros]
        }
    }

    set latest_rev_oids [array names latest_rev]

    # log get_files,latest_rev_oids=$latest_rev_oids

    set result [list]
    foreach normalized_oid $latest_rev_oids {
        lassign $latest_rev($normalized_oid) is_gone_p micros
        if { $is_gone_p } { continue }
        set rev ${normalized_oid}@${micros}
        lappend result ${rev}
    }

    set result [lsort -unique ${result}]

    # log mem,get_files,result=$result

    return $result

}

proc ::persistence::mem::get_subdirs {path} {

    #log get_subdirs,path=$path

    set len [llength [split $path {/}]]

    set files [get_files "${path}/"]  ;# slash is important

    #log get_subdirs,ls=$files

    set result [list]
    foreach oid $files {
        set oid_parts [split $oid {/}] 
        lappend result [join [lrange $oid_parts 0 $len] {/}]
    }

    #log get_subdirs,result=$result

    return [lsort -unique ${result}]

}

proc ::persistence::mem::exists_column_rev_p {rev} {
    assert { [is_column_rev_p $rev] }
    variable __idx
    return [info exists __idx(${rev})]
}

proc ::persistence::mem::exists_link_rev_p {rev} {
    assert { [is_link_rev_p $rev] }
    variable __idx
    return [info exists __idx(${rev})]
}

proc ::persistence::mem::exists_p {rev} {
    assert { [is_link_rev_p $rev] || [is_column_rev_p $rev] }
    if { [is_link_rev_p $rev] } {
        return [exists_link_rev_p $rev]
    } else {
        return [exists_column_rev_p $rev]
    }
}

proc ::persistence::mem::exists_supercolumn_p {nodepath} {
    variable __idx

    return [expr { [array names  __idx "${nodepath}/*"] ne {} }]
}

proc ::persistence::mem::get_column {rev {codec_conf ""}} {
    variable __mem
    return $__mem(${rev},data)
}

proc ::persistence::mem::get_link {rev {codec_conf ""}} {
    variable __mem
    return [::persistence::get $__mem(${rev},data) $codec_conf]

}


# Even though upd_column_data and set_column appear equivalent,
# they are not. upd_column_data replaces the values of an existing
# record whereas, set_column creates a new record if none already
# exists.
proc ::persistence::mem::upd_column {oid data {codec_conf ""}} {}

proc ::persistence::mem::get_mtime {rev} {
    variable __mem
    set xid $__mem(${rev},xid)
    lassign [split_xid $xid] micros pid n_mutations mtime
    return $mtime
}

proc ::persistence::mem::set_column {oid data xid codec_conf} {
    variable __mem
    variable __cnt
    variable __xid_rev
    variable __xid_list
    variable __xid_committed
    variable __idx

    # log mem,set_column,oid=$oid

    lassign [split_xid $xid] micros pid n_mutations mtime xid_type

    # log mem,set_column,xid=$xid

    set rev "${oid}@${micros}"

    # log memtable,set_column,rev=$rev

    if { [exists_column_rev_p $rev] } {
        log "!!! memtable (set_col): oid revision already exists (=${rev})"
    }

    if { [string match *by_reversedomain* $rev] } {
         log "~~~~~~~~~~~~~ rev=$rev"
    }

    incr __cnt

    set __mem(${rev},oid)           $oid
    set __mem(${rev},data)          $data
    set __mem(${rev},xid)           $xid
    set __mem(${rev},codec_conf)    $codec_conf
    set __mem(${rev},dirty_p)       1

    set ext [file extension ${oid}]
    if { $ext eq {.gone} } {
        # set orig_oid [file rootname ${oid}]
        # if { [info exists __idx(${orig_oid})] } {
        #    unset __idx(${orig_oid})
        #}
    } else {
        set __idx(${rev}) ${oid}
    }

    # __xid_rev
    lappend __xid_rev(${xid}) $rev

    # __xid_committed
    if { $xid_type eq {batch} } {
        # assert { [info exists __xid_committed($xid)] }
        set __xid_committed($xid) 0
    } elseif { $xid_type eq {single} } {
        set __xid_committed($xid) 1
    } else {
        error "unknown transaction type"
    }

    # __xid_list
    if { $__xid_committed($xid) } {
        lappend __xid_list $xid
    }

}

proc ::persistence::mem::begin_batch {xid} {
    variable __xid_committed
    assert { ![info exists __xid_committed($xid)] }
    set __xid_committed($xid) ""
}

proc ::persistence::mem::end_batch {xid} {
    variable __xid_committed
    assert { !$__xid_committed($xid) }
    set __xid_committed($xid) 1
}

proc ::persistence::mem::dump {} {
    # log "dumping memtable to filesystem"
    variable __mem
    variable __xid_rev
    variable __xid_list
    variable __xid_committed

    #set fp [open /tmp/memtable.txt w]
    #puts $fp [join [array names __mem *,data] \n]
    #close $fp

    #log __xid_list=$__xid_list
    #log __xid_rev=[array names __dirty_idx]

    set count 0
    foreach xid $__xid_list {
        # log "dumping xid (=$xid)"
        set committed_p [value_if __xid_committed($xid) "0"]
        if { !$committed_p } {
            log "cannot fsync transaction (=$xid) that is still in progress"
            continue
        }
        # log "dumping transaction: $xid"
        set rev_list [lsort -unique $__xid_rev($xid)]
        foreach rev $rev_list {
            # log "dumping rev: $rev"
            if { !$__mem(${rev},dirty_p) } {
                error "mismatch between __xid_rev and __mem data"
            }

            set oid $__mem(${rev},oid)
            set data $__mem(${rev},data)
            set __xid $__mem(${rev},xid)
            set codec_conf $__mem(${rev},codec_conf)

            assert { $xid eq $__xid }

            # part of the statement that writes the revision is fine
            # problem with the statement is part that publishes to head
            # (currently it is neither isolated nor atomic)
            #
            # for the ::persistence::fs::* case, we need a second head/master, 
            # say head/master0 and head/master1 (and a link from head/master to
            # one of them - switching from one to another on each transaction),
            # i.e. a cheap way to make snapshots
            #
            # it is not so much about concurrency control as it is for the principle
            # that the persistence layer supports read_committed isolation level
            # just as well as with fancier structures

            call_orig_of ::persistence::set_column $oid $data $xid $codec_conf

            set __mem(${rev},dirty_p) 0

            incr count
        }

        # transaction fsync-ed
        array unset __xid_committed $__xid

        # clear transaction revisions (tuples)
        array unset __xid_rev ${__xid}

        # when all revisions in a transaction have been applied
        # remove them from memtable, which is different than a cache
        # in the sense that it only keeps transactions that are in progress
        foreach rev $rev_list {
            array unset __idx ${rev}
            array unset __mem ${rev},*
        }

    }
    set __xid_list ""

    # log "dumped $count records"
}

proc ::persistence::mem::printall {} {
    variable __idx
    log ========
    log [join [lsort [array names __idx]] \n]
    log --------
}




if { [setting_p "bloom_filters"] } {

    wrap_proc ::persistence::mem::define_cf {ks cf_axis} {
        set type_oid [join_oid $ks $cf_axis]
        ::persistence::bloom_filter::init $type_oid
    }

    wrap_proc ::persistence::mem::set_column {oid data xid codec_conf} {
        # log [info frame 0]
        # log "ins_column oid=$oid"
        lassign [split_oid $oid] ks cf_axis row_key column_path
        call_orig $oid $data $xid $codec_conf
        set type_oid [join_oid $ks $cf_axis]
        ::persistence::bloom_filter::insert $type_oid $oid
    }

    wrap_proc ::persistence::mem::exists_p {oid} {
        lassign [split_oid $oid] ks cf_axis row_key column_path
        set type_oid [join_oid $ks $cf_axis]
        # set may_contain_p [::persistence::bloom_filter::may_contain_p $type_oid $oid]
        set may_contain_p 1
        if { $may_contain_p } {
            return [call_orig $oid]
        }
        return 0
    }

    wrap_proc ::persistence::mem::dump {} {
        ::persistence::bloom_filter::dump
        call_orig
    }

}


