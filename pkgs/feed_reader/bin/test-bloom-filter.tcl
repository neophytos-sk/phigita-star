#!/bin/sh
#\
 exec tclsh "$0" "$@"

lassign $argv ks cf_axis oid

package require util_procs
package require bloom_filter
package require persistence

set bff [::persistence::fs::get_filename ${ks}/${cf_axis}.bff]

set __bf(${ks}/${cf_axis}) [::bloom_filter::create 10000 0.01]
binary scan [::util::readfile $bff -translation binary] a* bytes
bloom_filter::set_bytes $__bf(${ks}/${cf_axis}) $bytes

puts may_contain_p=[::bloom_filter::may_contain $__bf(${ks}/${cf_axis}) $oid]
