
if { 0 && ![use_p "memtable"] } {
    return
}

namespace eval ::persistence::mem {

    variable __mem
    array set __mem [list]

    variable __rev_list
    set __rev_list [list]

    variable __cnt 0

    variable __dir
    array set __dir [list]

    # master branch
    variable __latest_idx
    array set __latest_idx [list]

}

proc ::persistence::mem::get_files {path} {
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
    return $__mem(${rev},mtime)
}

proc ::persistence::mem::set_column {oid data mtime codec_conf} {
    variable __mem
    variable __rev_list
    variable __cnt
    variable __latest_idx

    set rev "${oid}@${mtime}"

    if { [exists_column_rev_p $rev] } {
        log "!!! memtable (set_col): oid revision already exists (=${rev})"
    }

    if { [string match *by_reversedomain* $oid] } {
         log "~~~~~~~~~~~~~ oid=$oid"
    }

    set __latest_idx(${oid}) ${rev}

    lappend __rev_list ${rev}

    set __mem(${rev},oid)           $oid
    set __mem(${rev},data)          $data
    set __mem(${rev},mtime)         $mtime
    set __mem(${rev},codec_conf)    $codec_conf
    set __mem(${rev},size)          [string bytelength $data]
    set __mem(${rev},index)         $__cnt
    set __mem(${rev},dirty_p)       1
    set __mem(${rev},type)          "f"

    # mkdir [file dirname ${oid}]

    incr __cnt
}

# del_column_data
proc ::persistence::mem::del_column {oid} {
    variable __mem
    variable __oid
    variable __cnt

    return

    if { [exists_column_p $oid] } {
        set index $__mem(${oid},index)
        set __oid [lreplace $__oid $index $index]
        incr __cnt -1
        unset __mem(${oid},data)
        unset __mem(${oid},mtime)
        unset __mem(${oid},codec_conf)
        unset __mem(${oid},size)
        unset __mem(${oid},index)
        unset __mem(${oid},dirty_p)
        unset __mem(${oid},type)
    } else {
        error "memtable (del): no such oid"
    }

}


proc ::persistence::mem::dump {} {
    #log "dumping memtable to filesystem"
    variable __mem
    variable __rev_list

    #set fp [open /tmp/memtable.txt w]
    #puts $fp [join [array names __mem *,data] \n]
    #close $fp

    set count 0
    foreach rev $__rev_list {
        #log ">>> rev=$rev"
        if { $__mem(${rev},dirty_p) } {
            # log "dumping $rev"

            set oid $__mem(${rev},oid)
            set data $__mem(${rev},data)
            set mtime $__mem(${rev},mtime)
            set codec_conf $__mem(${rev},codec_conf)

            call_orig_of ::persistence::fs::set_column $oid $data $mtime $codec_conf

            set __mem(${rev},dirty_p) 0
            incr count
        }
    }

    #log "dumped $count records"
}
