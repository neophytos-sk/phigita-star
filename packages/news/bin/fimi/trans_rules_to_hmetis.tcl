#!/usr/bin/tclsh

set filename [lindex $argv 0]
set vertex_to_doc_file [lindex $argv 1]
set edge_file [lindex $argv 2]

proc get_edge_key {u v} {
    if { $u > $v } {
	### swap vertices so that v < v
	### to ensure that any pair of vertices is counted only once
	set tmp $u
	set u $v
	set v $tmp
    }
    return ${u},${v}
}


set max_length 3

set e_fp [open $edge_file w]
set vd_fp [open $vertex_to_doc_file w]


set cmd "cat $filename"
set fp [open "|$cmd" r]

set num_vertices 0
set num_edges 0
while {![eof $fp]} { 
    set line [string trim [gets $fp]]
    if { ${line} ne {} } {

	set firstIndex [string first <= $line]
	set lastIndex [string last <= $line]
	###puts $firstIndex=?=$lastIndex--$line
	if { $firstIndex != $lastIndex } {   continue }

	### (0.900000, 0.006189) 1399 <= 3627 3626 (        20)
	set rule [split [regsub -all {[ ]{2,}} [string map {{ <= } { } {(} {} {)} {} {,} {}} $line] { }]]
	### puts $rule
	if {[llength $rule] < 5} {
	    continue
	}

	lassign [lrange $rule 0 1] confidence support
	set head [string trim [lindex $rule 2]]
	set itemset [lrange $rule 3 end-1]
	set occ [lindex $rule end]

	if { ![info exists vertex(${head})] } {
	    incr num_vertices
	    set vertex(${head}) $num_vertices
	    puts $vd_fp [list $num_vertices ${head}]
	}

	set u $vertex(${head})
	foreach id $itemset {

	    if { ${head} eq ${id} } {
		puts ERROR-${head} 
		exit
	    }

	    if { ![info exists vertex(${id})] } {
		incr num_vertices
		set vertex(${id}) $num_vertices
		puts $vd_fp [list $num_vertices ${id}]
	    }

	    set v $vertex(${id})

	    set key [get_edge_key ${u} ${v}]
	    if { ![info exists edge(${key})] } {
		incr num_edges
		set edge(${key}) $num_edges
		lappend adj(${u}) $num_edges
		lappend adj(${v}) $num_edges
		puts $e_fp [list $num_edges $u $v]
	    }

	    set e $edge(${key})
	    lappend edge_weight(${e}) ${confidence} 
	}
    }
}

close $vd_fp
close $e_fp

proc get_sum list {
    set result 0.0
    foreach num $list {
	set result [expr { $result + $num }]
    }
    return $result
}

proc get_avg list {
    return [expr { [get_sum $list] / [llength $list] }]
}

proc get_edge_weight list {
    return [expr { 1+round(pow(16,1+[get_avg $list])) }]
}


set fmt 1 ;# the graph has weights associated with the edges
puts "$num_vertices $num_edges $fmt"

set k 0
for {set i 1} {$i <= $num_vertices} {incr i} {
    ### needed for chaco following line
    ### puts -nonewline $i
    foreach e $adj(${i}) {
	incr k
	puts -nonewline " [expr { $e - 1}] [get_edge_weight $edge_weight(${e})]"
    }
    puts ""
}


#puts "% num_edges=$num_edges k=$k (k/2 must be equal to N)"