#!/usr/bin/tclsh

package require algo
package require tcltest
namespace import tcltest::test

set dir [file dirname [info script]]
set infile [file join $dir data.txt]

test textalign-1 {
    adjust text to max length 40 chars
} -setup {
    set ifp [open $infile]
    fconfigure $ifp -encoding utf-8
    set text [read $ifp]
} -cleanup {
    close $ifp
} -body {
    textalign::adjust $text 40
} -result {}

