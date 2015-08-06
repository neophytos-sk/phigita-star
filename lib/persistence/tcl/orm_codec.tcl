namespace eval ::persistence::orm::codec_txt_1 {
    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -encoding utf-8 -translation lf]
    proc codec_conf {} {
        return [namespace current]::codec_conf 
    }

}

proc ::persistence::orm::codec_txt_1::encode {itemVar} {
    upvar $itemVar item
    return [array get item]

}

proc ::persistence::orm::codec_txt_1::decode {data} {
    array set item $data
    return [array get item]
}


namespace eval ::persistence::orm::codec_txt_2 {
    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -encoding utf-8 -translation lf]
    proc codec_conf {} {
        return [namespace current]::codec_conf 
    }

}


proc ::persistence::orm::codec_txt_2::encode {itemVar} {
    variable [namespace __this]::__attributes
    upvar $itemVar item
    set data [list]
    foreach attname $__attributes {
        lappend data [get_value_if item($attname) ""]
    }
    return $data
}

proc ::persistence::orm::codec_txt_2::decode {data} {
    variable [namespace __this]::__attributes
    array set item [list]
    foreach attname $__attributes attvalue $data {
        set item($attname) $attvalue
    }
    return [array get item]
}




namespace eval ::persistence::orm::codec_bin_1 {
    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -translation "binary"]
    proc codec_conf {} {
        return [namespace current]::codec_conf 
    }
}


proc ::persistence::orm::codec_bin_1::encode {itemVar} {
    variable [namespace __this]::__attributes

    upvar $itemVar item

    set bytes ""
    foreach attname $__attributes {
        set attvalue [get_value_if item($attname) ""]
        set attvalue [encoding convertto utf-8 $attvalue]
        set num_bytes [string bytelength $attvalue]
        append bytes [binary format "iu1A${num_bytes}" $num_bytes $attvalue]
    }

    return $bytes
}

proc ::persistence::orm::codec_bin_1::decode {bytes} {
    variable [namespace __this]::__attributes

    array set item [list]
    set pos 0
    set num_bytes 0
    foreach attname $__attributes {
        binary scan $bytes "@${pos}iu1" num_bytes
        incr pos 4
        binary scan $bytes "@${pos}A${num_bytes}" item($attname) 
        set item($attname) [encoding convertfrom utf-8 [get_value_if item($attname) ""]]
        incr pos $num_bytes
    }
    return [array get item]
}




namespace eval ::persistence::orm::codec_bin_2 {

    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -translation "binary"]
    proc codec_conf {} {
        return [namespace current]::codec_conf 
    }
                         

    # type => encoding_fmt decoding_fmt decoding_num_bytes
    array set ::__type_to_bin {
        {} {"" "" ""}
        "integer"       {i   i      4}
        "naturalnum"    {iu  iu     4}
        "boolean"       {c   c      1}
        "sha1_hex"      {H40 H40    20}
    }

}



proc ::persistence::orm::codec_bin_2::encode {itemVar} {
    variable [namespace __this]::__attributes
    variable [namespace __this]::__attinfo

    upvar $itemVar item

    set bytes ""

    # header (marks null values)
    foreach attname $__attributes {
        set v [info exists item($attname)]
        append bytes [binary format "c" $v]
    }

    # body / data
    foreach attname $__attributes {
        set type [get_value_if __attinfo($attname,type) ""]
        lassign [get_value_if ::__type_to_bin($type) ""] fmt _ num_bytes

        if { !exists("item($attname)") } continue

        set attvalue [get_value_if item($attname) ""]

        if { $fmt ne {} } {
            #log "type=$type fmt=$fmt num_bytes=$num_bytes"
            append bytes [binary format $fmt $attvalue]
        } else {
            set attvalue [encoding convertto utf-8 $attvalue]
            set num_bytes [string bytelength $attvalue]
            append bytes [binary format "iu1A${num_bytes}" $num_bytes $attvalue]
        }
    }
    # log [string repeat - 80]

    return $bytes
}

proc ::persistence::orm::codec_bin_2::decode {bytes} {
    variable [namespace __this]::__attributes
    variable [namespace __this]::__attinfo

    array set item [list]
    set pos 0
    set num_bytes 0

    # header (marks null values)
    foreach attname $__attributes {
        binary scan $bytes "@${pos}c" exists_p($attname)
        incr pos 1
    }

    foreach attname $__attributes {
        if { !$exists_p($attname) } {
            #log "attname=$attname does not exist"
            set item($attname) ""
            continue
        }

        set type [get_value_if __attinfo($attname,type) ""]

        lassign [get_value_if ::__type_to_bin($type) ""] _ fmt num_bytes

        # log "attname=$attname fmt=$fmt num_bytes=$num_bytes"

        if { $fmt ne {} } {
            append bytes [binary scan $bytes "@${pos}${fmt}" item($attname)]
            incr pos $num_bytes
        } else {
            binary scan $bytes "@${pos}iu1" num_bytes
            incr pos 4
            # log "attname=$attname num_bytes=$num_bytes"
            binary scan $bytes "@${pos}A${num_bytes}" item($attname) 
            set item($attname) [encoding convertfrom utf-8 [get_value_if item($attname) ""]]
            # log $item($attname)
            incr pos $num_bytes
        }

    }
    return [array get item]
}


