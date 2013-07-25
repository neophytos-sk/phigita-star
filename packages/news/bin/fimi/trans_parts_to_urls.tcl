#!/usr/bin/tclsh

set filename [lindex $argv 0]
set vertex_to_doc_file [lindex $argv 1]
set doc_to_url_file [lindex $argv 2]

set fp [open $filename r]
set vd_fp [open $vertex_to_doc_file r]
set du_fp [open $doc_to_url_file r]

set nparts 0
set vertex 0
while {![eof $fp]} {
    set p [gets $fp]
    if { $p > $nparts } {set nparts $p}
    ### lassign [gets $vd_fp] __vertex__ doc
    lassign [gets $du_fp] __doc__ url
    lappend partition($p) http://buzz.phigita.net/admin/cache?url_sha1=$url
    incr vertex
}

close $du_fp
close $vd_fp
close $fp 


for {set p 0} { $p < $nparts } {incr p} {
    puts [join $partition($p) \n]\n\n
}

puts "nparts=$nparts"