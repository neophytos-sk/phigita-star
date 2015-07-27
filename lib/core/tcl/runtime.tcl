namespace eval ::runtime {

    variable __nsp [list]

    namespace export    \
        stack_push      \
        stack_pop       \
        stack_top       \
        stack_with

}

proc ::runtime::stack_push {varname value} {
    variable ${varname}
    set ${varname} [linsert [set ${varname}] 0 ${value}]
}
proc ::runtime::stack_pop {varname} {
    variable ${varname}
    set ${varname} [lreplace [set ${varname}] 0 0]
}
proc ::runtime::stack_top {varname} { 
    variable ${varname}
    lindex [set ${varname}] 0
}
proc ::runtime::stack_with {varname value args} {
    stack_push ${varname} ${value}
    set result [uplevel ${args}]
    stack_pop ${varname}
    return ${result}
}
