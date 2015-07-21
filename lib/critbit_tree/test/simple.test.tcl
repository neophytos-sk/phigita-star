package require critbit_tree
package require tcltest

namespace import tcltest::test

test simple-1.1 {simple critbit tree} -setup {
    cbt create $::cbt::STRING db
} -cleanup {
    cbt destroy $db
} -body {
    cbt insert $db abc=123
    cbt insert $db abd=456
    cbt insert $db acc=888
    cbt prefix_match $db "ab"
} -result {abc=123 abd=456}
