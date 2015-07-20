
package require core
package require json

set fp [open ../data/cs373.json]
set data [read $fp]
close $fp

set mydict [json::parse_json data]
#puts $mylist

set units [dict get $mydict payload course_rev units]
foreach unit $units {
    puts "Unit: [dict get $unit name]"
    foreach nugget [dict get $unit nuggets] {
	set nuggetType [dict get $nugget nuggetType]
	puts "\tNugget: [dict get $nugget name] ($nuggetType)"
	if { $nuggetType eq {lecture} } {
	    set youtube_id [dict get $nugget media youtube_id]
	    puts $youtube_id
	} elseif { $nuggetType eq {program} } {
	    set code [dict get $nugget suppliedCode]
	    puts $code
	} elseif { $nuggetType eq {quiz} } {
	    # do nothing
	} else {
	    puts $nugget
	}
    }
}
