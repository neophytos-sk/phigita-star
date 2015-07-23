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
        set cmd [list apply ${lambdaExpr} {*}${_}]
        if { [uplevel ${cmd}] } {
            lappend result ${_}
        }
    }
    return ${result}
}
