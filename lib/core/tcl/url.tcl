package require uri

namespace eval ::url {
    namespace ensemble create -subcommands {
        normalize resolve
        join split
        parse_query
    }
}

proc ::url::normalize {url} {

    if { [string range ${url} 0 1] ne {//} } {
        set i [string first {:} ${url}] 
        set j [string first {.} ${url}]
        if { ( ${i} == -1 ) && ( ${i} < ${j} )} {
            # if no colon character found before the first dot
            set url "http://${url}"
        }
    }
    return [::uri::join {*}[::uri::split ${url}]]
}
proc ::url::resolve {base url} {
    return [::uri::resolve $base $url]
}
proc ::url::join {url} {
    return [::uri::join $url]
}
proc ::url::split {url} {
    return [::uri::split $url]
}

proc ::url::parse_query {str} {
    set result [list]
    foreach param [::split $str {&}] {
        lappend result [::split $param {=}]
    }
    return $result
}

#proc ::url::annotate_query {str} {
#    set list [parse_query $str]
#    return [map x $list {::pattern::typeof [lindex $x 1]}]
#}

proc ::url::match_format {fmt url} {
    array set fmtarr [url split $fmt]
    array set urlarr [url split $url]
}
