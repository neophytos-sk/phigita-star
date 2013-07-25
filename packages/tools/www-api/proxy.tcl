ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}



set error_p 1
set maxRedirects 3
curl::transfer -url $url -bodyvar body -headervar header -followlocation 1 -maxredirs $maxRedirects -inforesponsecode meta(responsecode) -infocontenttype meta(content_type) -infoeffectiveurl meta(effective_url)
doc_return 200 $meta(content_type) "code=$meta(responsecode) [ad_quotehtml $body]"
return


for {set i 0} {$i < $maxRedirects} {incr i} {
    set r [::xo::HttpRequest new -url $url]
    array set meta [$r set meta]
    if { [$r set status_code] eq {301} || [$r set status_code] eq {302} } {
	set url $meta(location)
    } else {
	set error_p 0
	break
    }
}

if { $error_p } {
    error "error occured: $i redirects (maxRedirects=$maxRedirects)"
}

doc_return 200 $meta(content-type) [$r set data]
return
