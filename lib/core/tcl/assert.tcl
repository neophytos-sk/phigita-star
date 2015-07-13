# abort the program if assertion is false
# alternatively, ensure assertion becomes
# true by running the given script
#
# assert { !( exists("all") && exists("almost-all") ) } {
#     ## Conflict Resolution
#     #  prefer exists(all) over exists(almost-all)
#     disable_flag almost-all
# }
#
proc assert {expression {script ""}} {

    if { ${script} eq {} } {
        set script [list error "failed to assert expression: $expression"]
    }
    
    if { ![uplevel [list {expr} ${expression}]] } {
        uplevel ${script}
    }

}


