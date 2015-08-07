#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require murmur_hash


set seed1 [expr { int(rand() * [clock seconds]) }]
set seed2 [expr { int(rand() * [clock seconds]) }]
set hash1 [::murmur_hash::murmur_hash "this is a test" $seed1]
set hash2 [::murmur_hash::murmur_hash "this is a test" $seed2]

log hash1=$hash1
log hash2=$hash2

