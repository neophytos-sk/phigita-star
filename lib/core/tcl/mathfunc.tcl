proc ::tcl::mathfunc::exists {varname} { 
    upvar $varname _ 
    return [info exists _]
}

proc ::tcl::mathfunc::vcheck {valueVar pattern_name} {
    upvar $valueVar _
    return [pattern match ${pattern_name} $_]
}

proc ::tcl::mathfunc::vcheck_if {valueVar pattern_name} {
    upvar $valueVar _
    return [expr { ![info exists _] || [pattern match ${pattern_name} $_] }]
}

# IN PROGRESS
proc ::tcl::mathfunc::foreach {varname list expression} {
    ::foreach $varname $list {
        puts "varname=$varname $varname=[set $varname] expression=[subst $expression]"
        uplevel [list assert [subst ${expression}]]
    }
    return true
} 
