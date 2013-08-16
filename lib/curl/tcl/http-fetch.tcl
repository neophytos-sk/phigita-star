namespace eval ::xo::http {;}

proc ::xo::http::fetch {contentVar url} {
    upvar ${contentVar} content

    if { [catch {set errorcode [curl::transfer -url ${url} \
				    -bodyvar content \
				    -infohttpcode httpcode \
				    -infocontenttype contenttype] } errmsg] } {

	if { [string is integer ${errmsg}] } {
	    return ${errmsg}
	} else {
	    return 1 ;# failed with errorcode 1
	}

    }


    if { $errorcode == 0 && $httpcode == 200} {;}

    return $errorcode
}

