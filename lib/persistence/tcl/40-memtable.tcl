if { ![setting_p "memtable"] } {
    return
}

namespace eval ::persistence::mem {

    # __mem - 
    #
    #   where we store the revision info:
    #
    #   __mem(${rev},oid)
    #   __mem(${rev},data)
    #   __mem(${rev},xid)
    #   __mem(${rev},codec_conf)
    #   __mem(${rev},dirty_p)

    variable __mem
    array set __mem [list]

    # __idx
    #
    #   where we keep track of revisions, 
    #   node (files, subdirs) hierarchy

    variable __idx
    array set __idx [list]

    # __xid_rev
    #
    #   all revisions pertaining to a given transaction (xid)

    variable __xid_rev
    array set __xid_rev [list]

    # __xid_list
    #
    #   all committed (but not yet fsync-ed) transactions,
    #   in the order they were committed

    variable __xid_list [list]

    # __xid_committed
    #
    #   all committed (but not yet fsync-ed) transactions (xid),
    #   for checking whether a transaction (xid) is committed or not,
    #   also an indicator for "open" transactions

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
        set revs [array names __idx ${pattern}]

    } else {
        set pattern "${nodepath}*"
        set revs [array names __idx ${pattern}]
    }


    set len [string length $nodepath]

    #log --------------
    #log patte=$pattern
    #log nodep=$nodepath
    #log __idx=[array names __idx]
    #log rev_names=$rev_names

    set result [list]
    foreach rev $revs {
        lassign [split $rev "@"] oid micros

        set xid $__mem(${rev},xid)

        set committed_p [value_if __xid_committed($xid) "0"]
        if { !$committed_p } { 
            # TODO: 
            #   check for revs that qualify 
            #   from transactions in progress 
            continue 
        }

        lappend result $rev

    }
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

    return [expr { [array names __idx "${nodepath}/*"] ne {} }]
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

    set __mem(${rev},oid)           $oid
    set __mem(${rev},data)          $data
    set __mem(${rev},xid)           $xid
    set __mem(${rev},codec_conf)    $codec_conf
    set __mem(${rev},dirty_p)       1

    set ext [file extension ${oid}]
    if { $ext eq {.gone} } {
        #set orig_oid [file rootname ${oid}]
        #if { [info exists __idx(${orig_oid})] } {
        #    unset __idx(${orig_oid})
        #}
    } else {
        set __idx(${rev}) ""
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
    variable __xid_list
    assert { !$__xid_committed($xid) }
    set __xid_committed($xid) 1
    lappend __xid_list $xid
}

proc ::persistence::mem::read_sstable {idxVar fp file_i} {
    upvar $idxVar idx

    log "reading sstable..."

    seek $fp -4 end
    # log "tell=[tell $fp]"
    while { [tell $fp] != 0} {
        set endpos [tell $fp]
        log "endpos=$endpos"
        set startpos [::util::io::read_int $fp]
        log "startpos=$startpos"
        seek $fp $startpos start
        ::util::io::read_string $fp row_key

        log "startpos=$startpos endpos=$endpos row_key=$row_key"

        while { [tell $fp] < $endpos } {
            ::util::io::read_string $fp rev
            set pos [tell $fp]
            #::util::io::skip_string $fp 
            ::util::io::read_string $fp data

            # log "row_key=$row_key"

            # lappend idx(${row_key}) [list $rev $file_i $pos]
            lappend idx(${row_key}) [list $rev $file_i $data]
        }
        if { $startpos == 0 } {
            break
        }
        seek $fp $startpos start
        seek $fp -4 current
    }

    log "done reading sstable"

}

proc ::persistence::mem::compact {type_oid} {
    set dir "/web/data/mystore/"
    set filelist [lsort -increasing [glob  -directory $dir ${type_oid}-*]]
    # log "compact: filelist=$filelist"
    set llen [llength $filelist]
    # log "compact: llen=$llen"
    if { $llen == 1 } {
        return
    }

    log "compacting... type_oid=$type_oid #files=$llen"

    set file_i 0
    array set fp [list]
    array set idx [list]
    foreach filename $filelist {
        log "filename=$filename size=[file size $filename]"
        if { [file size $filename] == 0 } {
            log "skip sstable (size=0)... $filename"
            continue
        }
        set fp($file_i) [open $filename]
        fconfigure $fp($file_i) -translation binary
        if { [catch {
            read_sstable idx $fp($file_i) $file_i
        } errmsg] } {
            log "errmsg=$errmsg"
            log "exiting..."
            exit
        }
        incr file_i
    }

    set round [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]
    set filename "/web/data/mystore/${type_oid}-${round}.sstable"
    log "merging sstables..."
    set ofp [open $filename "w"]
    set row_keys [lsort [array names idx]]
    foreach row_key $row_keys {
        log "row_key=$row_key"
        set savepos [tell $ofp]
        ::util::io::write_string $ofp $row_key
        set idx($row_key) [lsort -index 0 $idx($row_key)]
        foreach item $idx($row_key) {
            #lassign $item rev file_i pos
            lassign $item rev file_i data
            #log "rev=$rev file_i=$file_i pos=$pos fp=$fp($file_i)"
            #seek $fp($file_i) $pos start
            # log "reading data... from tell=[tell $fp($file_i)]"
            # ::util::io::read_string $fp($file_i) data
            #log "done reading data"
            #log "ofp tell=[tell $ofp]"
            ::util::io::write_string $ofp $rev
            ::util::io::write_string $ofp $data
            # log "done writing data ofp.tell=[tell $ofp]"
        }
        ::util::io::write_int $ofp $savepos
    }
    close $ofp
    log "merged sstables, new file: $filename"

    for {set file_i 0} { $file_i < [llength $filelist] } {incr file_i} {
        close $fp($file_i)
        set filename [lindex $filelist $file_i] 
        log "deleting sstable... $filename"
        file delete $filename
    }
}

proc ::persistence::mem::dump {} {

    set round [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]

    log "dumping memtable to filesystem"
    variable __mem
    variable __xid_rev
    variable __xid_list
    variable __xid_committed
    variable __idx

    #set fp [open /tmp/memtable.txt w]
    #puts $fp [join [array names __mem *,data] \n]
    #close $fp

    set revs [list]
    set count 0
    foreach xid $__xid_list {
        # log "dumping xid (=$xid)"
        set committed_p [value_if __xid_committed($xid) "0"]
        if { !$committed_p } {
            log "cannot fsync transaction (=$xid) that is still in progress"
            continue
        }
        # log "dumping transaction: $xid"
        set fp ""
        set i ""
        set j ""
        set savepos ""
        set rev_list [lsort -unique $__xid_rev($xid)]
        foreach rev $rev_list {

            # log "dumping rev: $rev"
            if { !$__mem(${rev},dirty_p) } {
                error "mismatch between __xid_rev and __mem data"
            }
            lappend revs $rev
        }
    }


    # sorts revs in order to process sstables 
    # by type_oid/row_key once in this round

    set savepos ""
    set sorted_revs [lsort -unique $revs]
    foreach rev $sorted_revs {

        # TODO: this part of the code should be 
        # moved into (storage_ss.tcl) ::persistence::ss::set_column

        set oid $__mem(${rev},oid)
        set data $__mem(${rev},data)
        set xid $__mem(${rev},xid)
        set codec_conf $__mem(${rev},codec_conf)

        ##
        # sorted strings table (sstable)
        #

        lassign [split_oid $rev] ks cf_axis row_key column_path

        if { $i ne "${ks}/${cf_axis}" } {
            if { $savepos ne {} } {
                ::util::io::write_int $fp $savepos
            }
            if { $fp ne {} } {
                close $fp
                # log "sstable ready... ${filename}.part"

                if { [catch {
                    file rename ${filename}.part ${filename}
                } errmsg] } {
                    log errmsg=$errmsg
                    log "exiting..."
                    exit
                }

                # log "sstable renamed"
                compact $i
            }
            set i "${ks}/${cf_axis}"
            set j ""
            set filename "/web/data/mystore/${i}-${round}.sstable"
            file mkdir [file dirname ${filename}]
            set fp [open ${filename}.part "w"]
            fconfigure $fp {*}$codec_conf
        }

        if { $j ne $row_key } {
            if { $savepos ne {} } {
                ::util::io::write_int $fp $savepos
            }
            set j $row_key
            set savepos [tell $fp]
            ::util::io::write_string $fp $row_key
        }

        ::util::io::write_string $fp $oid
        ::util::io::write_string $fp $data

        #
        # end sstable stuff
        ##

        call_orig_of ::persistence::set_column $oid $data $xid $codec_conf
        set __mem(${rev},dirty_p) 0
        incr count

    }

    # sstable
    if { [info exists fp] && [info exists j] } {
        if { $j ne {} } {
            ::util::io::write_int $fp $savepos
        }
        if { $fp ne {} } {
            close $fp
        }
    }

    foreach __xid $__xid_list {

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


if { [setting_p "tree"] } {

    wrap_proc ::persistence::mem::define_cf {ks cf_axis} {
        call_orig $ks $cf_axis
        set type_oid [join_oid $ks $cf_axis]
        ::persistence::tree::init $type_oid
    }

    wrap_proc ::persistence::mem::set_column {oid data xid codec_conf} {
        call_orig $oid $data $xid $codec_conf
        lassign [split_oid $oid] ks cf_axis row_key column_path
        set type_oid [join_oid $ks $cf_axis]
        ::persistence::tree::insert $type_oid $oid $data $xid $codec_conf
    }

    wrap_proc ::persistence::mem::exists_p {oid} {
        lassign [split_oid $oid] ks cf_axis row_key column_path
        set type_oid [join_oid $ks $cf_axis]
        return [::persistence::tree::exists_p $type_oid $oid]
    }

    wrap_proc ::persistence::mem::dump {} {
        call_orig
        ::persistence::tree::dump
    }

}


if { [setting_p "bloom_filters"] } {

    wrap_proc ::persistence::mem::define_cf {ks cf_axis} {
        call_orig $ks $cf_axis
        set type_oid [join_oid $ks $cf_axis]
        ::persistence::bloom_filter::init $type_oid
    }

    wrap_proc ::persistence::mem::set_column {oid data xid codec_conf} {
        call_orig $oid $data $xid $codec_conf
        lassign [split_oid $oid] ks cf_axis row_key column_path
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
