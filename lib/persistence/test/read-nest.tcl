set dir [file dirname [info script]]
lappend auto_path [file join $dir ".."]
package require nest

set filename [lindex $argv 0]
set lang_nsp ::nest::data
set doc [source_tdom $filename $lang_nsp]
puts [$doc asXML]
set root [$doc documentElement]
::dom::scripting::validate $lang_nsp $root
$doc delete
