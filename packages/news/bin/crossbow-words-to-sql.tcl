#!/usr/bin/tclsh


if { [llength $argv] != 3 } {
    error "Usage: $argv0 start_time topic_sk clusterTable"
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
set inputString [read stdin]

if { $inputString ne {} } {

    puts "update $clusterTable set live_p='f' where cluster_sk <@ [::util::dbquotevalue $topic_sk];"
    set timepoint_sk [clock format $start_time -format "%Y %m %d %H %M"]
    foreach line [split $inputString \n] {
	set lineElements [split $line]
	foreach {cluster_sk_part score} [lrange $lineElements 0 1] {
	    set cluster_sk [join [concat $topic_sk $timepoint_sk [string map {/ .} [string trim $cluster_sk_part /]]] .]
	    set score [string trim $score]
	    set words [string trim [lrange $lineElements 2 end-1]]


	    puts "insert into ${clusterTable} (cluster_sk,cnt_documents,score,ts_query,live_p) values ([::util::dbquotevalue $cluster_sk],0,[::util::dbquotevalue $score], [util::dbquotevalue [join $words &]]::tsquery,'t');"

	}
    }
}