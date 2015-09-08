namespace eval ::persistence::orm::codec_txt_1 {
    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -encoding utf-8 -translation lf]
    proc codec_conf {} {
        return [array get [namespace current]::codec_conf]
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
        return [array get [namespace current]::codec_conf]
    }

}


proc ::persistence::orm::codec_txt_2::encode {itemVar} {
    variable [namespace __this]::__attnames
    upvar $itemVar item
    set data [list]
    foreach attname $__attnames {
        lappend data [value_if item($attname) ""]
    }
    return $data
}

proc ::persistence::orm::codec_txt_2::decode {data} {
    variable [namespace __this]::__attnames
    array set item [list]
    foreach attname $__attnames attvalue $data {
        set item($attname) $attvalue
    }
    return [array get item]
}



namespace eval ::persistence::orm::codec_bin_3 {

    namespace export \
        encode \
        decode \
        codec_conf

    variable codec_conf
    array set codec_conf [list -translation "binary"]
    proc codec_conf {} {
        return [array get [namespace current]::codec_conf]
    }
                         

    # type => encoding_fmt decoding_fmt decoding_num_bytes
    variable __type_to_bin
    array set __type_to_bin {
        {} {"" "" ""}
        "integer"       {i   i      4}
        "naturalnum"    {iu  iu     4}
        "boolean"       {c   c      1}
        "sha1_hex"      {H40 H40    20}
        "datetime"      {a13 a13    13}
    }

}



proc ::persistence::orm::codec_bin_3::encode {itemVar} {
    variable __type_to_bin
    variable [namespace __this]::__attnames
    variable [namespace __this]::__attinfo

    upvar $itemVar item

    set bytes ""

    # header (marks null values)
    set uvalue "0"
    foreach attname $__attnames {
        set attvalue [value_if item($attname) ""] 
        set v [expr { $attvalue ne {} }]
        set uvalue [expr { ($uvalue << 1) | $v }]
        #log "attname=$attname v=$v uvalue=$uvalue"
    }
    #log uvalue=$uvalue
    set num_encoded_bytes [encode_unsigned_varint bytes $uvalue]

    # body / data
    foreach attname $__attnames {
        set type [value_if __attinfo($attname,type) "varchar"]
        lassign [value_if __type_to_bin($type) ""] fmt _ num_bytes

        set attvalue [value_if item($attname) ""]
        
        if { $attvalue eq {} } continue

        if { $fmt ne {} } {
            append bytes [binary format $fmt $attvalue]
        } else {

            if { $type eq {bytearr} } {
                set attvalue [binary encode base64 $attvalue]
            } else {
                set attvalue [encoding convertto utf-8 $attvalue]
                set len [string length $attvalue]
                # OLD: set attvalue [binary format "A${len}" $attvalue]
            }

            set len [string length $attvalue]
            set num_encoded_bytes [encode_unsigned_varint bytes $len]
            append bytes $attvalue

        }
    }
    # log [string repeat - 80]

    return $bytes
}

proc ::persistence::orm::codec_bin_3::decode {bytes} {
    variable __type_to_bin
    variable [namespace __this]::__attnames
    variable [namespace __this]::__attinfo

    # log "decoding item for [namespace __this]"

    array set item [list]
    set pos 0
    set num_bytes 0

    # header (marks null values)

    set uvalue [decode_unsigned_varint bytes num_decoded_bytes $pos]
    incr pos $num_decoded_bytes

    # log "uvalue=$uvalue num_decoded_bytes=$num_decoded_bytes"

    foreach attname [lreverse $__attnames] {
        set exists_p($attname) [expr { $uvalue & 0x1 }]
        set uvalue [expr { $uvalue >> 1 }]
        # log exists_p($attname)=$exists_p($attname)
    }

    foreach attname $__attnames {
        if { !$exists_p($attname) } {
            # log "attname=$attname does not exist"
            set item($attname) ""
            continue
        }

        set type [value_if __attinfo($attname,type) "varchar"]

        lassign [value_if __type_to_bin($type) ""] _ fmt num_bytes

        # log "attname=$attname fmt=$fmt num_bytes=$num_bytes"

        if { $fmt ne {} } {
            # log "pos=$pos num_bytes=$num_bytes"
            append bytes [binary scan $bytes "@${pos}${fmt}" item($attname)]
            incr pos $num_bytes
            #log $item($attname)
        } else {
            set len [decode_unsigned_varint bytes num_decoded_bytes $pos]
            incr pos $num_decoded_bytes

            # log "attname=$attname pos=$pos len=$len num_decoded_bytes=$num_decoded_bytes"

            set scan_p [binary scan $bytes "@${pos}A${len}" item($attname)]
            incr pos $len

            # log "scan_p=$scan_p len=$len"

            if { $type eq {bytearr} } {
                set item($attname) [binary decode base64 $item($attname)]
                # set scan_p [binary scan $item($attname) a* item($attname)]
            } else {
                set item($attname) [encoding convertfrom utf-8 $item($attname)]
            }

            # log ">>>> $attname = $item($attname)"
        }

    }
    return [array get item]
}


