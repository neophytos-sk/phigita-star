namespace eval ::fun {
    namespace export \
        map \
        filter
}

proc ::fun::map {varlist list script} {
    set result [list]
    set lambdaExpr [list ${varlist} ${script}]
    foreach $varlist ${list} {
        lappend result [apply ${lambdaExpr} {*}[valuelist_if $varlist]]
    }
    return ${result}
}

proc ::fun::filter {varlist list script} {
    set result [list]
    set lambdaExpr [list ${varlist} [list {expr} ${script}]]
    foreach ${varlist} ${list} {
        set _ [valuelist_if ${varlist}]
        set cmd [list apply ${lambdaExpr} {*}${_}]
        if { [uplevel ${cmd}] } {
            lappend result ${_}
        }
    }
    return ${result}
}

namespace eval :: {
    namespace import ::fun::map
    namespace import ::fun::filter
}

