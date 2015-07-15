package require uri

namespace eval ::url {
    namespace ensemble create -subcommands {
        normalize resolve
        join split
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
proc ::url::resolve {args} {}
proc ::url::join {args} {}
proc ::url::split {args} {}

