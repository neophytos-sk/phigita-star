proc encode_unsigned_varint {bufferVar value} {
    upvar $bufferVar buffer

    set num_encoded_bytes 0
    while { 1 } {
        set next_byte [expr { $value & 0x7f }]
        set value [expr { $value >> 7 }]
        if { $value } {
            set next_byte [expr { $next_byte | 0x80 }]
        }
        append buffer [binary format "c" $next_byte]
        incr num_encoded_bytes
        if { !$value } {
            break
        }
    }
    return $num_encoded_bytes
}

proc encode_signed_varint {bufferVar value} {
    upvar $bufferVar buffer
    set uvalue [expr { $value < 0 ? ~($value << 1) : ($value << 1) }]
    return [encode_unsigned_varint buffer $uvalue]
}

proc decode_unsigned_varint {dataVar num_decoded_bytesVar {pos "0"}} {
    upvar $dataVar data
    upvar $num_decoded_bytesVar num_decoded_bytes

    set i 0
    set decoded_value 0
    set shift_amount 0

    while { 1 } {

        binary scan $data "@${pos}c" byte
        incr pos
        incr i

        set decoded_value [expr { $decoded_value | (($byte & 0x7f) << $shift_amount) }]
        incr shift_amount 7


        if { !($byte & 0x80) } {
            break
        }

    }

    set num_decoded_bytes $i
    return $decoded_value

}

proc decode_signed_varint {dataVar num_decoded_bytesVar {pos "0"}} {
    upvar $dataVar data
    upvar $num_decoded_bytesVar num_decoded_bytes
    set uvalue [decode_unsigned_varint data num_decoded_bytes $pos]
    return [expr { $uvalue & 1 ? ~( $uvalue >> 1 ) : ( $uvalue >> 1 ) }]
}

