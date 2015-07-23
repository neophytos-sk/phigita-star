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


proc ::web::cache_fetch {htmlVar url {optionsVar ""} {infoVar ""}} {

    upvar $htmlVar html

    if { ${optionsVar} ne {} } {
        upvar ${optionsVar} options
    }

    if { ${infoVar} ne {} } {
        upvar ${infoVar} info
    }

    set domain [::util::domain_from_url $url]
    set reverse_domain [reversedomain $domain]
    array set url_a [url split ${url}]
    set urlencoded_path [url encode $url_a(path)]
    set urlencoded_query [url encode $url_a(query)]

    set keyspace "web_cache_db"
    set column_family "web_page/by_domain"
    set row_key $reverse_domain
    set column_path [list $urlencoded_path $urlencoded_query]

    set filename \
        [::persistence::get_column \
            $keyspace \
            $column_family \
            $row_key \
            $column_path \
            html \
            exists_column_p]

    if { $exists_column_p } {
        set mtime [file mtime $filename]
        set timeout [expr { 15 * 60 }]
        set now [clock seconds]
        if { $mtime + $timeout > $now } {
            # returns content of web page as upvar with the given name
            log "fetching page from cache: $url"
            return 0
        }
    }

    if { ![set errorcode [::web::fetch html $url]] } {

        ::persistence::insert_column \
            $keyspace \
            $column_family \
            $row_key \
            $column_path \
            $html
    }

    return $errorcode

}


