source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

package require http
package require tdom_procs

set feeds [dict create \
    philenews {
	url http://www.philenews.com/
	re {/el-gr/.+/[0-9]+/[0-9]+/}
    } \
    sigmalive {
	url http://www.sigmalive.com/
	re {/[0-9]+}
    }]


array set feed [dict get $feeds philenews]

set re $feed(re)
set url $feed(url)

::http::fetch html $url

proc same_origin_links {resultVar htmlVar url} {
    upvar $resultVar result
    upvar $htmlVar html

    ::xo::html::extract links html {//a/@href} "" "values"

    # turn relative urls into absolute urls
    set links2 [list]
    foreach link $links {
	lappend links2 [::uri::canonicalize [::uri::resolve $url $link]]
    }

    # remove duplicates
    set links3 [lsort -unique $links2]

    # keep same-origin links
    set pattern ${url}*
    set result [lsearch -all -inline -glob ${links3} ${pattern}]

}

same_origin_links links html ${url}

# keep article links
set links [lsearch -all -inline -regexp ${links} ${re}]

puts ${links}
