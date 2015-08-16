if { ![setting_p "memtable"] } {
    return
}

namespace eval ::persistence::mem {

    variable __mem
    array set __mem [list]

    variable __cnt 0

    variable __dir
    array set __dir [list]

    # master branch
    variable __latest_idx
    array set __latest_idx [list]

    variable __dirty_idx
    array set __dirty_idx [list]

    variable __trans_list [list]

    namespace import ::persistence::common::split_trans_id

}

proc ::persistence::mem::get_leafs {path} {
    variable __latest_idx

    set names [array names __latest_idx ${path}/*]
    return [lsort -unique ${names}]

}

proc ::persistence::mem::get_subdirs {path} {

    set len [llength [split $path {/}]]

    set files [get_files ${path}]
    set result [list]
    foreach oid $files {
        set oid_parts [split $oid {/}] 
        lappend result [join [lrange $oid_parts 0 $len] {/}]
    }

    return [lsort -unique ${result}]

}

proc ::persistence::mem::exists_column_rev_p {rev} {
    variable __mem
    return [info exists __mem(${rev},data)]
}

proc ::persistence::mem::exists_column_p {oid} {
    variable __latest_idx
    return [info exists __latest_idx(${oid})]
}

proc ::persistence::mem::exists_link_p {oid} {
    variable __latest_idx
    return [info exists __latest_idx(${oid})]
}

proc ::persistence::mem::exists_p {oid} {
    if { [::persistence::is_link_oid_p $oid] } {
        return [exists_link_p $oid]
    } else {
        return [exists_column_p $oid]
    }
}

proc ::persistence::mem::exists_supercolumn_p {oid} {
    variable __latest_idx

    return [expr { [array names  __latest_idx "${oid}/*"] ne {} }]
}

proc ::persistence::mem::get_column {oid {codec_conf ""}} {
    variable __latest_idx
    variable __mem

    set rev $__latest_idx(${oid})
    return $__mem(${rev},data)
}

proc ::persistence::mem::get_link {oid {codec_conf ""}} {
    variable __latest_idx
    variable __mem

    set rev $__latest_idx(${oid})
    return [::persistence::get $__mem(${rev},data) $codec_conf]

}


# Even though upd_column_data and set_column appear equivalent,
# they are not. upd_column_data replaces the values of an existing
# record whereas, set_column creates a new record if none already
# exists.
proc ::persistence::mem::upd_column {oid data {codec_conf ""}} {}

proc ::persistence::mem::get_mtime {oid} {
    variable __latest_idx
    variable __mem

    set rev $__latest_idx(${oid})
    set trans_id $__mem(${rev},trans_id)
    lassign [split_trans_id $trans_id] micros pid n_mutations mtime
    return $mtime
}

proc ::persistence::mem::set_column {oid data trans_id codec_conf} {
    variable __mem
    variable __cnt
    variable __latest_idx
    variable __dirty_idx
    variable __trans_list

    lassign [split_trans_id $trans_id] micros pid n_mutations mtime

    set rev "${oid}@${micros}"

    if { [exists_column_rev_p $rev] } {
        # log "!!! memtable (set_col): oid revision already exists (=${rev})"
    }

    if { [string match *by_reversedomain* $oid] } {
         log "~~~~~~~~~~~~~ oid=$oid"
    }

    incr __cnt

    lappend __trans_list            $trans_id
    lappend __dirty_idx(${trans_id})     $rev

    set __mem(${rev},oid)           $oid
    set __mem(${rev},data)          $data
    set __mem(${rev},trans_id) $trans_id
    set __mem(${rev},codec_conf)    $codec_conf
    set __mem(${rev},size)          [string bytelength $data]
    set __mem(${rev},index)         $__cnt
    set __mem(${rev},dirty_p)       1
    set __mem(${rev},type)          "f"

    set ext [file extension ${oid}]
    if { $ext eq {.gone} } {
        set orig_oid [file rootname ${oid}]
        if { [info exists __latest_idx(${orig_oid})] } {
            unset __latest_idx(${orig_oid})
        }
    } else {
        set __latest_idx(${oid}) ${rev}
    }

}

proc ::persistence::mem::dump {} {
    #log "dumping memtable to filesystem"
    variable __mem
    variable __dirty_idx
    variable __trans_list

    #set fp [open /tmp/memtable.txt w]
    #puts $fp [join [array names __mem *,data] \n]
    #close $fp

    #log __trans_list=$__trans_list
    #log __dirty_idx=[array names __dirty_idx]

    set count 0
    foreach __trans_id $__trans_list {
        #log "dumping transaction: $__trans_id"
        set rev_list [lsort -unique $__dirty_idx($__trans_id)]
        foreach rev $rev_list {
            #log "dumping rev: $rev"
            if { !$__mem(${rev},dirty_p) } {
                error "mismatch between __dirty_idx and __mem data"
            }

            set oid $__mem(${rev},oid)
            set data $__mem(${rev},data)
            set trans_id $__mem(${rev},trans_id)
            set codec_conf $__mem(${rev},codec_conf)

            assert { $__trans_id eq $trans_id }

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

            call_orig_of ::persistence::set_column $oid $data $trans_id $codec_conf

            set __mem(${rev},dirty_p) 0

            incr count
        }
        unset __dirty_idx(${__trans_id})
    }
    set __trans_list ""

    #log "dumped $count records"
}

proc ::persistence::mem::printall {} {
    variable __latest_idx
    log ========
    log [join [lsort [array names __latest_idx]] \n]
    log --------
}

