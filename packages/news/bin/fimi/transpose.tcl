#!/usr/bin/tclsh

set count 0
set m 0
set sep " "
if { [llength $argv] > 0 } {
    set sep [lindex $argv 1]
}

array set t [list]
while { ![eof stdin] } {
    set eles [split [gets stdin] $sep]
    foreach item $eles {
	lappend t(${item}) ${count}
	if { ${item} > ${m} } { set m $item }
    }
    incr count
}

for {set i 0} {$i < $m} {incr i} {
    puts $t(${i})
}