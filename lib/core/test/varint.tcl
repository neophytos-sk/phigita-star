#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core

set value "300"

set num_encoded_bytes [encode_signed_varint bytes $value]

set decoded_value [decode_signed_varint bytes num_decoded_bytes]

puts encoded_value=$value
puts decoded_value=$decoded_value
puts num_encoded_bytes=$num_encoded_bytes
puts num_decoded_bytes=$num_decoded_bytes
