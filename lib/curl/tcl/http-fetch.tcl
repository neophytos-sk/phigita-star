namespace eval ::xo::http {;}

proc ::xo::http::fetch {contentVar url} {
    upvar ${contentVar} content

    set errorcode [curl::transfer -url $url \
		       -bodyvar content \
		       -infohttpcode httpcode \
		       -infocontenttype contenttype]


    if { $errorcode == 0 && $httpcode == 200} {;}

    return $errorcode
}

