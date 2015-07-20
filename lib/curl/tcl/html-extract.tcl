namespace eval ::http {;}

proc ::http::fetch {contentVar url} {
    upvar ${contentVar} content

    set errorcode [curl::transfer -url $url \
		       -bodyvar content \
		       -infohttpcode httpcode \
		       -infocontenttype contenttype]


    if { $errorcode == 0 && $httpcode == 200} {;}

    return $errorcode
}


package require tdom


namespace eval ::xo::html {;}
proc ::xo::html::extract {outResultVar inHtmlVar xpath {domNodeFunc "asHTML"} {xpathFunc ""}} {
    upvar $outResultVar result
    upvar $inHtmlVar html

    set doc [dom parse -html $html]
    if { $xpathFunc ne {} } {
	set xpath "${xpathFunc}($xpath)"
    }

    set nodes [$doc selectNodes $xpath]

    if { $domNodeFunc ne {} } {
	set result [list]
	foreach node $nodes {
	    lappend result [$node {*}${domNodeFunc}]
	}
    } else {
	set result $nodes
    }

    $doc delete
}

# tDOM: asText converts {&nbsp;} to \xa0
proc ::xo::html::table_to_multilist {dataVar htmltableVar} {
    upvar $dataVar data
    upvar $htmltableVar htmltable

    set doc [dom parse -html $htmltable]
    set xpath "//tr"
    set nodes [$doc selectNodes $xpath]

    set data [list]
    foreach node $nodes {
	set row [list]
	foreach childNode [$node childNodes] {
	    lappend row [string trim [$childNode asText] " \xa0"]
	}
	lappend data $row
    }
    $doc delete

}
