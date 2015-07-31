proc ::tcl::mathfunc::exists {varname} { 
    upvar $varname _ 
    return [info exists _]
}

proc ::tcl::mathfunc::vcheck {valueVar pattern_names} {
    upvar $valueVar value
    return [pattern matchall $pattern_names value]
}

proc ::tcl::mathfunc::vcheck_if {valueVar pattern_names} {
    upvar $valueVar _
    return [expr { ![info exists _] || [vcheck _ ${pattern_names}] }]
}

# IN PROGRESS
proc ::tcl::mathfunc::foreach {varname list expression} {
    ::foreach $varname $list {
        puts "varname=$varname $varname=[set $varname] expression=[subst $expression]"
        uplevel [list assert [subst ${expression}]]
    }
    return true
} 
