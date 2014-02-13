#!/usr/bin/tclsh

proc __compare_md_files {file1 file2} {
    lassign [split $file1 {.}] prefix ms1 ext
    lassign [split $file2 {.}] prefix ms2 ext
    if { $ms1 < $ms2 } { 
	return -1
    } elseif { $ms1 > $ms2 } {
	return 1
    } else {
	return 0
    }
}


set filelist [glob -nocomplain -directory /web/db/system/ *]

set md_files [lsort -decreasing -integer -command __compare_md_files $filelist]

puts $filelist
set filename [lindex $md_files 0]
set fp [open $filename]
set data [read $fp]
close $fp
puts $data

puts "\n\n >>>>> showing file: $filename date: [clock format [file mtime $filename]]"