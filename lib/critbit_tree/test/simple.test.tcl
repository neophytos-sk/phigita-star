#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require critbit_tree
package require tcltest

namespace import tcltest::test

test simple-1.1 { prefix_match } -setup {
    cbt create $::cbt::STRING db
} -cleanup {
    cbt destroy $db
} -body {
    cbt insert $db abc=123
    cbt insert $db abd=456
    cbt insert $db acc=888
    cbt prefix_match $db "ab"
} -result {abc=123 abd=456}

test simple-1.1 { match } -setup {
    cbt create $::cbt::STRING db
} -cleanup {
    cbt destroy $db
} -body {
    cbt insert $db abc=123
    cbt insert $db abd=456
    cbt insert $db acc=888
    cbt prefix_match $db "abc="

    puts get_bytes=[cbt::get_bytes $db]

    cbt::create 0 db2
    cbt::set_bytes $db2 [cbt::get_bytes $db]

    puts get_bytes2=[cbt::get_bytes $db2]

    cbt::prefix_match $db2 "abc="

} -result {abc=123}
