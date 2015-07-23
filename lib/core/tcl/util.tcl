namespace eval ::util { 
    namespace export \
        coalesce \
        value_if \
        set_if
}

proc ::util::coalesce {args} {
    return [lsearch -not -inline $args {}]
}

proc ::util::value_if {varlist {defaults ""}} {
    set result [list]
    foreach varname $varlist default_value $defaults {
        upvar $varname _
        lappend result [if { [info exists _] } { set _ } else { set default_value }]
    }
    return ${result}
}


proc ::util::set_if {varname value} {
    upvar $varname _
    if { ![info exists _] } { 
        set _ $value
    } else {
        set _
    }
}


namespace eval :: {
    namespace import ::util::coalesce
    namespace import ::util::value_if
    namespace import ::util::set_if
}
