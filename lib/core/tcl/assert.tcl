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

set debug_p 0

if { $debug_p } {
    proc assert {expression {script ""}} {

        if { $script ne {} } {
            if { ![uplevel [list {expr} ${expression}]] } {
                uplevel ${script}
            } else {
                return
            }
        }

        
        if { ![uplevel [list {expr} ${expression}]] } {
            set script [list error "failed to assert expression: $expression"]
            uplevel ${script}
        }

    }
} else {
    proc assert {expression {script ""}} {
    }
}


