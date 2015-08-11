namespace eval ::persistence::mem {

    variable __mem
    array set __mem [list]

    variable __oid
    set __oid [list]

    variable __cnt 0

}

proc ::persistence::mem::exists_column_data_p {oid} {
    variable __mem
    return [info exists __mem(${oid},data)]
}

proc ::persistence::mem::get_column_data {oid {codec_conf ""}} {
    variable __mem

    set exists_p [exists_column_data_p $oid]
    if { $exists_p } {
        return $__mem(${oid},data)
    }
    return
}

# insert or replace 
proc ::persistence::mem::set_column_data {oid data {codec_conf ""}} {
    if { [exists_column_data_p $oid] } {
        del_column_data $oid
    }
    ins_column_data $oid $data $codec_conf
}

# Even though upd_column_data and set_column_data appear equivalent,
# they are not. upd_column_data replaces the values of an existing
# record whereas, set_column_data creates a new record if none already
# exists.
proc ::persistence::mem::upd_column_data {oid data {codec_conf ""}} {
    if { ![exists_column_data_p $oid] } {
        error "memtable (upd): no such oid"
    }

    # * delete old revisions or not?
    # * get_column returns oid of the latest revision
    set revision_oid [get_column $oid]

    del_column_data $revision_oid
    ins_column_data $oid $data

}

proc ::persistence::mem::ins_column_data {oid data {codec_conf ""}} {
    variable __mem
    variable __oid
    variable __cnt

    if { [exists_column_data_p $oid] } {
        error "memtable (ins): oid already exists"
    }

    lappend __oid $oid

    set __mem(${oid},data) $data
    set __mem(${oid},conf) $codec_conf
    set __mem(${oid},size) [string bytelength $data]
    set __mem(${oid},index) $__cnt

    incr __cnt
}

# del_column_data
proc ::persistence::mem::del_column_data {oid} {
    variable __mem
    variable __oid
    variable __cnt

    if { [exists_column_data_p $oid] } {
        set index $__mem(${oid},index)
        set __oid [lreplace __oid $index $index {}]
        incr __cnt -1
        unset __mem(${oid},data)
        unset __mem(${oid},conf)
        unset __mem(${oid},size)
        unset __mem(${oid},index)
    } else {
        error "memtable (del): no such oid"
    }

}

