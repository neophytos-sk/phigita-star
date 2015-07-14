package require core

namespace eval ::xo::http {;}

proc ::xo::http::fetch {contentVar url {optionsVar ""} {infoVar ""}} {
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

