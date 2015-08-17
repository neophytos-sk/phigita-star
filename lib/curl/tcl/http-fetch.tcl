namespace eval ::web {
    namespace ensemble create -subcommands {fetch cache_fetch}
}

proc ::web::fetch {contentVar url {optionsVar ""} {infoVar ""}} {
    upvar ${contentVar} content

    if { ${optionsVar} ne {} } {
        upvar ${optionsVar} options
    }

    if { ${infoVar} ne {} } {
        upvar ${infoVar} info
    }

    set httpversion [value_if options(httpversion) "1.1"]
    set followlocation [value_if options(followlocation) "0"]
    set maxredirs [value_if options(maxredirs) "0"]
    set timeout [value_if options(timeout) "30"]
    set cookiefile [value_if options(cookiefile) ""]
    set useragent [value_if options(useragent) "curl/7.41.0"]

    if { [catch {

        set errorcode [curl::transfer \
            -nosignal 1 \
            -noprogress 1 \
            -encoding "identity" \
            -url ${url} \
            -timeout ${timeout} \
            -httpversion ${httpversion} \
            -followlocation ${followlocation} \
            -maxredirs ${maxredirs} \
            -cookiefile ${cookiefile} \
            -useragent ${useragent} \
            -bodyvar content \
            -inforesponsecode info(responsecode) \
            -infocontenttype info(contenttype) \
            -infoeffectiveurl info(effectiveurl) \
            -inforedirecturl info(redirecturl) \
            -infocookielist info(cookielist)\
            -infonamelookuptime info(namelookuptime)\
            -infoconnecttime info(connecttime) \
            -infopretransfertime info(pretransfertime) \
            -infostarttransfertime info(starttransfertime) \
            -infototaltime info(totaltime) \
            -inforedirecttime info(redirecttime) \
            -inforedirectcount info(redirectcount)] 

    } errmsg] } {

        if { [string is integer ${errmsg}] } {
            return ${errmsg}
        } else {
            return 1 ;# failed with errorcode 1
        }

    }


    #if { $errorcode == 0 && $info(httpcode) == 200} {;}

    return $errorcode
}


proc ::web::cache_fetch {contentVar url {optionsVar ""} {infoVar ""} {cache_pVar ""}} {

    upvar $contentVar content

    if { ${optionsVar} ne {} } {
        upvar ${optionsVar} options
    }

    if { ${infoVar} ne {} } {
        upvar ${infoVar} info
    }

    set cache_p 0
    if { $cache_pVar ne {} } {
        upvar ${cache_pVar} cache_p
    }

    set urlsha1 [::sha1::sha1 -hex $url]

    set force_resync_p [value_if options(__force_resync_p) "0"]
    if { !$force_resync_p } {
        array set item [list]
        set where_clause [list [list urlsha1 = $urlsha1]]

        array set options [list]
        set options(order_by) [list last_update decreasing dictionary]
        set options(limit) 1
        set oid [::webdb::web_page_t 0or1row $where_clause options]

        if { $oid ne {} } {

            array set item [::webdb::web_page_t get $oid]
            set mtime [::webdb::web_page_t mtime $oid]
            set timeout [expr { 15 * 60 }]
            set now [clock seconds]
            set recent_fetch_p [expr { $mtime + $timeout > $now }]

            if { $recent_fetch_p } {
                # returns content of web page as upvar with the given name
                log "fetching page from cache: $url"
                set content $item(content)
                set cache_p 1
                return 0
            }
        }
    }

    if { ![set errorcode [::web::fetch content $url options info]] } {
        array set item [url split $url]
        array set item [list    \
            urlsha1 $urlsha1    \
            url $url            \
            content $content]

        ::webdb::web_page_t insert item
    }

    return $errorcode

}


