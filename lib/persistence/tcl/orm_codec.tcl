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
        "integer"       {i   i      4}
        "naturalnum"    {iu  iu     4}
        "boolean"       {c   c      1}
        "sha1_hex"      {H40 H40    20}
    }

}



proc ::persistence::orm::codec_bin_3::encode {itemVar} {
    variable __type_to_bin

    set nsp [namespace __this]
    variable ${nsp}::__attnames
    variable ${nsp}::__attinfo

    upvar $itemVar item

    set bytes {}

    # header (marks null values)
    array set exists_p [list]
    set uvalue "0"
    foreach attname $__attnames {
        set v [info exists item(${attname})]
        set uvalue [expr { ($uvalue << 1) | $v }]
        set exists_p(${attname}) $v
    }

    set num_encoded_bytes [encode_unsigned_varint bytes $uvalue]

    # body / data
    foreach attname ${__attnames} {
        if { !$exists_p(${attname}) } continue

        set type [value_if __attinfo(${attname},type) "varchar"]

        lassign [value_if __type_to_bin(${type}) ""] fmt _ num_bytes

        set attvalue [value_if item(${attname}) ""]

        if { $fmt ne {} } {
            append bytes [binary format $fmt ${attvalue}]
        } else {
            if { ${type} eq {bytearr} } {
                set attvalue [binary format "a*" ${attvalue}]
            } else {
                set attvalue [encoding convertto utf-8 ${attvalue}]
            }
            set len [string length $attvalue]
            set num_encoded_bytes [encode_unsigned_varint bytes $len]
            append bytes $attvalue
        }
    }

    set bytes_len [string length $bytes]
    # log enc,bytes_len=$bytes_len
    set num_encoded_bytes [encode_unsigned_varint bytes $bytes_len]

    return $bytes
}

proc ::persistence::orm::codec_bin_3::decode {bytesVar {pos 0} {select ""}} {
    upvar $bytesVar bytes

    # if {0} {
    #   set bytes_len [string length $bytes]
    #   log dec,bytes_len=$bytes_len
    # }

    variable __type_to_bin
    variable [namespace __this]::__attnames
    variable [namespace __this]::__attinfo

    # log "decoding item for [namespace __this]"

    set num_bytes 0

    # header (marks null values)

    set uvalue [decode_unsigned_varint bytes num_decoded_bytes ${pos}]
    incr pos ${num_decoded_bytes}

    foreach attname [lreverse ${__attnames}] {
        set exists_p($attname) [expr { ${uvalue} & 0x1 }]
        set uvalue [expr { ${uvalue} >> 1 }]
    }

    set data [list]
    set count_empty_fmt 0
    foreach attname ${__attnames} {
        if { !$exists_p(${attname}) } {
            lappend data ${attname} {}
            continue
        }

        set type [value_if __attinfo(${attname},type) "varchar"]

        lassign [value_if __type_to_bin(${type}) ""] _ fmt num_bytes

        # log "attname=$attname fmt=$fmt num_bytes=$num_bytes"

        if { ${fmt} ne {} } {
            set scan_p [binary scan ${bytes} "@${pos}${fmt}" attvalue]
            incr pos ${num_bytes}
        } else {

            incr count_empty_fmt

            set len [decode_unsigned_varint bytes num_decoded_bytes ${pos}]
            incr pos ${num_decoded_bytes}

            # log "attname=$attname pos=$pos len=$len num_decoded_bytes=$num_decoded_bytes"

            set scan_p [binary scan ${bytes} "@${pos}a${len}" attvalue]
            incr pos ${len}

            # log "scan_p=$scan_p len=$len"

            if { ${type} eq {bytearr} } {
                set scan_p [binary scan ${attvalue} a* attvalue]
            } else {
                set attvalue [encoding convertfrom utf-8 ${attvalue}]
            }
        }
        lappend data ${attname} ${attvalue}

    }

    # TODO: add/decode a checksum/hash value
    # set scan_p [binary scan ${bytes} "@${pos}i" checksum]
    # incr pos 4
    # assert { $scan_p }
    # assert { $checksum == [crc32 ${bytes}] }

    set bytes_len [decode_unsigned_varint bytes num_decoded_bytes ${pos}]
    assert { $pos == $bytes_len } {
        log pos=$pos
        log bytes_len=$bytes_len
        log bytes_range=[string range $bytes $pos $bytes_len]
    }

    return ${data}
}


