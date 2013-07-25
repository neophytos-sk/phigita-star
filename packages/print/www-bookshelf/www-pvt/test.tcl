
    ad_proc get_book_url {
        {-associate_id ""}
        isbn
    } {
        set url "http://www.amazon.com/gp/product/$isbn"
        if { ![empty_string_p $associate_id] } {
            append url "/ref=nosim/$associate_id"
        }
        return $url
    }

    ad_proc get_book_info {
        -array:required
        isbn
    } {
        Find title and author from Amazon.
        for the cover thumbnail.
    } {
        # Select the info into the upvar'ed Tcl Array
        upvar $array row

        # Grab book info page from Amazon
        
        set url [get_book_url $isbn]

        set amazon_info_page [ns_httpget $url]

        if { ![regexp {<title>\s*Amazon.com: ([^:]+): [^<]*\s*</title>} $amazon_info_page match title] } {
            set row(book_title) ""
        } else {
            set row(book_title) [string trim $title]
        }
        

	set regexp {<a href="/exec/obidos/search-handle-url/index=books&field-author-exact=[^"]+">([^<]+)</a>}
	set row(book_author) ""
	set start 0
	while {[regexp -start $start -indices -- $regexp ${amazon_info_page} match submatch]} {
	    foreach {subStart subEnd} $submatch break
	    foreach {matchStart matchEnd} $match break
	    if {${subStart}>${start}} {
		lappend row(book_author) [string trim [string range ${amazon_info_page} ${subStart} ${subEnd}]]
	    }
	    set start ${matchEnd}
	}
return
        if { ![regexp {by\s+<a href="/exec/obidos/search-handle-url/index=books&field-author-exact=[^"]+">([^<]+)</a>} $amazon_info_page match author] } {
            set row(book_author) ""
        } else {
            set row(book_author) [string trim $author]
        }
}