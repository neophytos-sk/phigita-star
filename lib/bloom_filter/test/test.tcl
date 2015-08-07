#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require bloom_filter
package require core

namespace eval abc {
    variable bf
    array set bf [list]
}

proc abc::A {items_estimate false_positive_prob filename} {
    variable bf

    set bf(1) [::bloom_filter::create $items_estimate $false_positive_prob]
    ::bloom_filter::insert $bf(1) abc
    ::bloom_filter::insert $bf(1) qwerty

    puts [::bloom_filter::may_contain $bf(1) abc]
    puts [::bloom_filter::may_contain $bf(1) test]
    puts [::bloom_filter::may_contain $bf(1) qwerty]

    puts bytes(bf)=[binary encode hex [::bloom_filter::get_bytes $bf(1)]]

    ::util::writefile $filename \
        [binary format a* [::bloom_filter::get_bytes $bf(1)]] \
        -translation binary

    # calls bf_free_rep
    unset bf

}

# just for testing bf_string_rep
# (where obj->bytes, and obj->length can be set)
#
# puts bf=$bf


proc abc::B {items_estimate false_positive_prob filename} {
    variable bf

    binary scan [::util::readfile $filename -translation binary] a* bytes

    set bf(2) [::bloom_filter::create $items_estimate $false_positive_prob]
    set num_bytes [::bloom_filter::set_bytes $bf(2) $bytes]
    puts num_bytes=$num_bytes

    set oid "news_item.by_urlsha1/a0348bd66b0492ff3765c7b72d05f66b918c335f/+/a0348bd66b0492ff3765c7b72d05f66b918c335f/a7e192c0feed8b306d690ea421fc8c802bf198a9"

    ::bloom_filter::insert $bf(2) $oid

    puts [::bloom_filter::may_contain $bf(2) abc]
    puts [::bloom_filter::may_contain $bf(2) test]
    puts [::bloom_filter::may_contain $bf(2) qwerty]
    puts [::bloom_filter::may_contain $bf(2) $oid]
    puts [::bloom_filter::may_contain $bf(2) asdf]
    puts [::bloom_filter::may_contain $bf(2) $oid]

}

set dir [file dirname [info script]]
set filename [file join $dir test.dat]

set items_estimate 10
set false_positive_prob 0.1

abc::A $items_estimate $false_positive_prob $filename
abc::B $items_estimate $false_positive_prob $filename
