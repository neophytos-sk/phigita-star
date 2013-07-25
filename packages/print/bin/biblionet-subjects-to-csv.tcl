#!/usr/bin/tclsh

set infile [lindex $argv 0]

set ifp [open $infile]
set data [read $ifp]
close $ifp


foreach subject $data {
    lassign [list "" "" "" ""] subject_name ddc_first ddc_second ddc_third
    regexp -- {^\s*([^\)]+)\s*[(]\s*DDC:\s*([0-9]{3})([.][0-9]+)?\s*([0-9]+)?\s*[)]\s*$} $subject __match__ subject_name ddc_first ddc_second ddc_third
    set ddc [string trim "${ddc_first}${ddc_second} ${ddc_third}"]
    set subject_name [string trim $subject_name]
    if { $ddc ne {} } {
	puts "el|${ddc}|${subject_name}"
    }
}
