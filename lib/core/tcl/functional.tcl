proc value_if {varlist {defaults ""}} {
    set result [list]
    foreach varname $varlist default_value $defaults {
        upvar $varname _
        lappend result [if { [info exists _] } { set _ } else { set default_value }]
    }
    return ${result}
}

proc map {varlist list script} {
    set result [list]
    set lambdaExpr [list ${varlist} ${script}]
    foreach $varlist ${list} {
        lappend result [apply ${lambdaExpr} {*}[value_if $varlist]]
    }
    return ${result}
}

proc filter {varlist list script} {
    set result [list]
    set lambdaExpr [list ${varlist} [list {expr} ${script}]]
    foreach ${varlist} ${list} {
        set _ [value_if ${varlist}]
        if { [apply ${lambdaExpr} {*}${_}] } {
            lappend result ${_}
        }
    }
    return ${result}
}
