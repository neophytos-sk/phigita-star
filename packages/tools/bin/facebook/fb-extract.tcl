set filename [lindex $argv 0]

if { $filename eq {} } {
    set filename data/fb-test-3.html
}

set fp [open $filename]
set data [read $fp]
close $fp

proc get_data {inDataVar outDataVar indicesVar} {
    upvar $inDataVar inData
    upvar $outDataVar outData
    upvar $indicesVar indices

    foreach {startIndex endIndex} [join $indices] {
	lappend outData [string range $inData $startIndex $endIndex]
    }
    return
}

set pattern {<a class="title" href="http://([^/]+)/people/([^/]+)/([^"]*)" rel="friend" title="([^"]+)"><img class="[^"]+" src="([^"]+/[a-zA-Z]([0-9]+)_[0-9]+.jpg)" alt="([^"]+)" />}

#'" for single/double quotes

set indices [regexp -indices -all -inline -- $pattern $data]
set fields "__dummy__ host vanity_url fb_id fb_name fb_photo_url fb_id_confirm fb_name_confirm"

#puts $indices
get_data data extracted_data indices

set i 0

set header ""
set includelist ""
foreach field $fields {
    if { [string match "_*" $field] } {
	lappend includelist 0
    } else {
	lappend includelist 1
	lappend header $field
    }
}


set fb_info ""
foreach $fields $extracted_data {
    set record [list]
    foreach field $fields include_p $includelist {
	if { $include_p } {
	    lappend record [set $field]
	}
	incr i
    }
    lappend fb_info $record
}

puts $header
puts [join $fb_info \n]


