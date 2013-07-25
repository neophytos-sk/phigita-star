#!/usr/bin/tclsh

if { [llength $argv] != 2 } {
    error "Usage: $argv0 inputFile targetDir"
}

set inputFile [lindex $argv 0]
set targetDir [lindex $argv 1]

file mkdir $targetDir

namespace eval ::util {;}
proc ::util::coalesce {args} {
    foreach item ${args} {
        if { ![string equal {} ${item}] } {
            return ${item}
        }
    }
    return {}
}


namespace eval ::bow {;}
proc ::bow::getExpandedVector tsVector {
    set result [list]
    foreach lexeme [split $tsVector " "] {
	foreach {word positions} [string map {: " "} $lexeme] break
	set word [string trim $word ']
	set times [llength [split $positions ,]]
	lappend result [string repeat "$word " $times]
    }
    return [join $result]
}


set ifp [open $inputFile r]
set data [read $ifp]
close $ifp


set count 0
foreach line [split $data \n] {

    incr count

    foreach {topic edition cluster_topic cluster_edition outputFile tsVector} [split $line |] break
#    set topic [string map {. /} [string trim $topic]]
#    set cluster_topic [string map {. /} [string trim $cluster_topic]]
#    set cluster_edition [string map {. /} [string trim $cluster_edition]]
    set cluster_topic [string map {. _} [string trim $cluster_topic]]
    set cluster_edition [string map {. _} [string trim $cluster_edition]]

    set topic [string trim $topic]
    set edition [string trim $edition]

    if { $cluster_topic eq {} } {
	set cluster_sk ""
    } else {
	#	set cluster_sk [join [concat [string trim [lindex [split $cluster_topic .] 0]] [string trim [lindex [split $cluster_edition .] end]]] .]
	set cluster_sk [join [concat $cluster_topic $cluster_edition] /]
    }


    set outputFile [string trim $outputFile]
    set tsVector [string trim $tsVector]



    foreach sk {topic edition} {
	if { [set $sk] ne {} } {
	    file mkdir ${targetDir}/${sk}/[set ${sk}]
	    set ofp [open ${targetDir}/${sk}/[set ${sk}]/${outputFile} w]
	    #puts $ofp [split $url "./&?"]
	    puts $ofp [::bow::getExpandedVector $tsVector]
	    close $ofp
	}
    }

}
