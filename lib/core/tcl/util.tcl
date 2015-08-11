namespace eval ::util { 
    namespace export \
        coalesce \
        boolval \
        valuelist_if \
        value_if \
        set_if
}

proc ::util::coalesce {args} {
    return [lsearch -not -inline $args {}]
}

proc ::util::boolval {value} {
    set true_p [string is true -strict $value]
    set false_p [string is false -strict $value]
    assert { !(${true_p} && ${false_p}) }
    return ${true_p}
}

proc ::util::value_if {varname {default ""}} {
    upvar $varname var
    if { [info exists var] } {
        return ${var}
    }
    return ${default}
}

proc ::util::valuelist_if {varlist {defaults ""}} {
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
    namespace import ::util::boolval
    namespace import ::util::value_if
    namespace import ::util::valuelist_if
    namespace import ::util::set_if
}
