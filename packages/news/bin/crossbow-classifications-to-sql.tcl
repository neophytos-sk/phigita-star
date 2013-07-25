#!/usr/bin/tclsh



if { [llength $argv] != 4 } {
    error "Usage: $argv0 start_time_in_seconds topic_sk clusterTable documentTable"
}

namespace eval ::util {;}
proc ::util::dbquotevalue {text} {
    if { ${text} eq {} } {
	return NULL
    } else {
	return '[string map {' \\'} $text]'
    }
}

set start_time [lindex $argv 0]
set topic_sk [lindex $argv 1]
set clusterTable [lindex $argv 2]
set documentTable [lindex $argv 3]

set timepoint_sk [clock format $start_time -format "%Y %m %d %H %M"]
foreach line [split [read stdin] \n] {
    foreach {filename __dummy__ cluster_sk_part} [split $line] {
	set cluster_sk [join [concat $topic_sk $timepoint_sk [string map {/ .} [string trim $cluster_sk_part /]]] .]
	set url_sha1 [lindex [split $filename /] end]
	lappend cluster($cluster_sk) [::util::dbquotevalue $url_sha1]
    }
}


if { [llength [array names cluster]] } {
    foreach cluster_sk [array names cluster] {
	puts "update $clusterTable set cnt_documents=[::util::dbquotevalue [llength $cluster($cluster_sk)]] where cluster_sk @> [::util::dbquotevalue $cluster_sk];"
	puts "update $documentTable set clustering__cluster_sk=[::util::dbquotevalue $cluster_sk]::ltree || clustering__cluster_sk where url_sha1 in ([join $cluster($cluster_sk) ,]);"
    }
}