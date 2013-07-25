package require nsjava

# import the google search classes
nsjava::import -package com.google.soap.search GoogleSearch GoogleSearchResult
set result ""


#set q "Neophytos Demetriou" ;#"this is a test"


# create a google search instance
set s [nsjava::new GoogleSearch]

# set the authorization key
$s {setKey String} Ys+Wu9abeEoZ62SvjJh1HTAlElr4nIDN ;#k2pts@yahoo.com thisisatest


nsjava::try {
    $s {setQueryString String} $q
    set r [$s doSearch]
} catch {GoogleSearchFault f} {
    append result " The call to Google failed:[$f toString]"
}

# was a result returned?
if [string equal $result ""] {
    set directoryCategories [$r getDirectoryCategories]
    set searchComments [$r getSearchComments]
    set searchTips [$r getSearchTips]
    set count [$r getEstimatedTotalResultsCount]
    set etime [$r getSearchTime]
    set sidx [$r getStartIndex]
    set eidx [$r getEndIndex]
    set els [$r getResultElements]
    set result "<small><i>Non-commercial testing of the Google Web APIs.</i></small>"
    append result ${searchComments}<p>
    append result ${searchTips}<p>
    append result "<table width=100% bgcolor=EEF3FB><tr><td><small>Searched the web for <b>${q}</b>.</small></td><td align=right><small>Results <b>${sidx}</b> to <b>$eidx</b> of about <b>$count</b>. Search took [format %2f $etime] seconds.</small></td></tr></table><p>"

    for {set i 0} {$i < [${directoryCategories} length]} {incr i} {
	set directoryCategory [${directoryCategories} get $i]
	set fullViewableName [$directoryCategory getFullViewableName]
	set prettyFullViewableName [join [split ${fullViewableName} /] " > "]
	append result "<font size=-1 color=\#666666>Category:</font> <a href=\"http://directory.google.com/${fullViewableName}\"><font size=-1 color=\#666666>${prettyFullViewableName}</font></a><br>"
    }

    append result <p>

    set cnt 1
if {${sidx} > 0} {
    for {set i [expr $sidx-1]} {$i < $eidx} {incr i} {
        set el [$els get $i]
	set title [$el getTitle]
	set url [$el getURL]
	set hostname [$el getHostName]
	set snippet [$el getSnippet]
	set cachedSize [$el getCachedSize]
	set relatedInformationPresent [$el getRelatedInformationPresent]
	set summary [$el getSummary]
	set directoryTitle [$el getDirectoryTitle]
	set directoryCategory [$el getDirectoryCategory]

	set fullViewableName [$directoryCategory getFullViewableName]
	set prettyFullViewableName [join [split ${fullViewableName} /] " > "]

	regsub -all -- {^(http://)[.]*} ${url} {} onlyurl

	if { [string equal $title ""] } {set title "Untitled"}
        append result "<a href=\"$url\">$title</a><br>"

	if {![string equal ${snippet} ""]} {
	    append result "<font size=-1>${snippet}</font><br>"
	}

	if {![string equal ${summary} ""]} {
	    append result "<font size=-1><font color=\#666666>Description:</font> ${summary}</font><br>"
	}

	if {![string equal ${fullViewableName} ""]} {
	    append result "<font size=-1 color=\#666666>Category:</font> <a href=\"http://directory.google.com/${fullViewableName}\"><font size=-1 color=\#666666>${prettyFullViewableName}</font></a><br>"
	}

        append result "<font size=-1 color=green>$url</font>"
	if {![string equal ${cachedSize} ""]} {
	    append result "<font size=-1 color=green> - ${cachedSize}</font>"
	    append result " - "
	    append result "<a href=\"http://www.google.com/search?q=cache:${onlyurl}+[join ${q} +]\"><font size=-1 color=\"\#666666\">Cached</font></a>"
	}
	append result "</font>"
	if {${relatedInformationPresent}} {
	    append result " - "
	    append result "<a href=\"http://www.google.com/search?q=related:${onlyurl}\"><font size=-1 color=\"\#666666\">Similar Pages</font></a>"
	}
	append result "<p>"
        incr cnt
    }
}
}


t -disableOutputEscaping $result


