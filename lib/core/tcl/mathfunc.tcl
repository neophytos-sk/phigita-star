proc ::tcl::mathfunc::exists {varname} { 
    upvar $varname _ 
    return [info exists _]
}

proc ::tcl::mathfunc::vcheck {datatype value} {
    return [::ext::data::vcheck.${datatype} value]
}

# IN PROGRESS
proc ::tcl::mathfunc::foreach {varname list expression} {
    ::foreach $varname $list {
        puts "varname=$varname $varname=[set $varname] expression=[subst $expression]"
        uplevel [list assert [subst ${expression}]]
    }
    return true
} 
