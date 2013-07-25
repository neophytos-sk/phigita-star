#!/usr/bin/tclsh


foreach line [split [read stdin] \n] {
    foreach {filename __dummy__ cluster_sk} [split $line] {
	set url_sha1 [lindex [split $filename /] end]
	lappend cluster($cluster_sk) $url_sha1
    }
}
foreach cluster_sk [array names cluster] {
    puts "$cluster_sk\t[llength $cluster($cluster_sk)]"
}
