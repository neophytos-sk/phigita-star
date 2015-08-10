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

proc ::persistence::mem::set_column_data {oid data {codec_conf ""}} {
    variable __mem
    variable __oid
    variable __cnt

    lappend __oid $oid

    set __mem(${oid},data) $data
    set __mem(${oid},conf) $codec_conf
    set __mem(${oid},size) [string bytelength $data]
    set __mem(${oid},index) $__cnt

    incr __cnt
}

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
        error "no such oid in memtable"
    }

}

