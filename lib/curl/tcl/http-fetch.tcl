package require core
package require util_procs
package require persistence

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


proc ::web::cache_fetch {contentVar url {optionsVar ""} {infoVar ""}} {

    upvar $contentVar content

    if { ${optionsVar} ne {} } {
        upvar ${optionsVar} options
    }

    if { ${infoVar} ne {} } {
        upvar ${infoVar} info
    }

    # set domain [::util::domain_from_url $url]
    # set reversedomain [reversedomain $domain]
    # set path "webdb/web_page.by_domain/${reversedomain}/${urlsha1}"
    # set oid [::persistence::get_column $path html exists_p]

    array set item [list]
    set urlsha1 [::sha1::sha1 -hex $url]
    set oid [::webdb::web_page_t find_by_id $urlsha1]

    if { $oid ne {} } {

        ::webdb::web_page_t get $oid item

        set mtime [::webdb::web_page_t mtime $oid]

        set timeout [expr { 15 * 60 }]
        set now [clock seconds]
        if { $mtime + $timeout > $now } {
            # returns content of web page as upvar with the given name
            log "fetching page from cache: $url"
            set content $item(content)
            return 0
        }
    }

    if { ![set errorcode [::web::fetch content $url options info]] } {

        array set item [list    \
            urlsha1 $urlsha1    \
            url $url            \
            content $content]
            
        ::webdb::web_page_t insert item

        if {0} {
            ::persistence::insert_column \
                $keyspace \
                $column_family \
                $row_key \
                $column_path \
                $html
        }
    }

    return $errorcode

}


