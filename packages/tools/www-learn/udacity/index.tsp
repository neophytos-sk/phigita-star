## TODO: http://www.udacity.com/ajax?{%22data%22:{%22path%22:%22%23Course/cs373/CourseRev/feb2012%22},%22method%22:%22course.get%22,%22version%22:%22dacity-13%22}

ad_page_contract {
    @author Neophytos Demetriou
} {
    {force_p:boolean false}
}

if { $force_p } {
    set filelist  [glob -nocomplain [::util::curr_dir]/udacity-*]
    foreach filename $filelist {
	file delete $filename
    }
}

proc process_udacity_yt_channel {doc feedVar} {
    upvar $feedVar feed

    set prefixUriList {
	a http://www.w3.org/2005/Atom
	media http://search.yahoo.com/mrss/
	yt http://gdata.youtube.com/schemas/2007
    }

    set titles [$doc selectNodes -namespaces $prefixUriList {values(//a:entry/a:title/text())}]
    
    set urls [$doc selectNodes -namespaces $prefixUriList {values(//a:entry/media:group/media:content[@yt:format = "5"]/@url)}]

    foreach t $titles u $urls {
	lappend feed [list $t $u]
    }
    set feed [lsort -index 0 $feed]

    return [llength $titles]
}


set dir [::util::curr_dir]

set url "http://gdata.youtube.com/feeds/api/videos?author=udacity&v=2&max-results=50&orderby=published&safeSearch=none"
# set url "http://gdata.youtube.com/feeds/api/videos?max-results=50&orderby=published&format=5&safeSearch=none&author=Udacity"

set feed [list]
set i 1
set startIndex 1
set max_results 50

set done false
set filename ""
while {!$done} {
    set second_to_last_filename $filename
    set filename [file join $dir udacity-${i}]
    # ns_log notice filename=$filename
    if { ![file exists $filename] } {
	set api_url "\"${url}&start-index=${startIndex}\""
	# ns_log notice "fetch $api_url filename=$filename"
	exec /bin/sh -c "wget -O $filename $api_url || exit 0" 2> /dev/null
    }

    set fp [open $filename]
    set doc [dom parse -channel $fp]
    set num_entries [process_udacity_yt_channel $doc feed]
    close $fp

    if { $num_entries == 0 } { 
	file delete $filename
	set done true 
    }
    incr i
    incr startIndex ${max_results}
    # if { 2 == [incr count] } break
}

if { $second_to_last_filename ne {} } {
    file delete $second_to_last_filename
}

set feed [lsort -index 0 $feed]
set result [llength $feed]-[join $feed \n]
#set result [$doc asXML]
doc_return 200 text/plain $result

$doc delete