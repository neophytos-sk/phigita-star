namespace eval ::util { 
    namespace export coalesce
}

proc ::util::coalesce {args} {
    return [lsearch -not -inline $args {}]
}


namespace eval :: {
    namespace import ::util::coalesce
}
