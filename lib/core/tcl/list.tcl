###
## lempty <list>
##
##    Returns 1 if <list> is empty or 0 if it has any elements.  This command
##    emulates the TclX lempty command.
###

proc lempty {list} {
    if {[catch {llength $list} len]} { return 0 }
    return [expr $len == 0]
}

proc lrmdups list {
    if [lempty $list] {
        return {}
    }
    set list [lsort $list]
    set last [lindex $list 0]
    lappend result $last
    foreach element $list {
        if ![string equal $last $element] {
            lappend result $element
            set last $element
        }
    }
    return $result
}

#
# intersect3 - perform the intersecting of two lists, returning a list
# containing three lists.  The first list is everything in the first
# list that wasn't in the second, the second list contains the intersection
# of the two lists, the third list contains everything in the second list
# that wasn't in the first.
#

proc intersect3 {list1 list2} {
    set la1(0) {} ; unset la1(0)
    set lai(0) {} ; unset lai(0)
    set la2(0) {} ; unset la2(0)
    foreach v $list1 {
        set la1($v) {}
    }
    foreach v $list2 {
        set la2($v) {}
    }
    foreach elem [concat $list1 $list2] {
        if {[info exists la1($elem)] && [info exists la2($elem)]} {
            unset la1($elem)
            unset la2($elem)
            set lai($elem) {}
        }
    }
    list [lsort [array names la1]] [lsort [array names lai]] \
         [lsort [array names la2]]
}


#
# intersect - perform an intersection of two lists, returning a list
# containing every element that was present in both lists
#
proc intersect {list1 list2} {
    set intersectList ""

    set list1 [lsort $list1]
    set list2 [lsort $list2]

    while {1} {
        if {[lempty $list1] || [lempty $list2]} break

        set compareResult [string compare [lindex $list1 0] [lindex $list2 0]]

        if {$compareResult < 0} {
            lvarpop list1
            continue
        }

        if {$compareResult > 0} {
            lvarpop list2
            continue
        }

        lappend intersectList [lvarpop list1]
        lvarpop list2
    }
    return $intersectList
}


################################################################################
# SETS OPERATIONS
################################################################################

proc lintersect {a b} {
    foreach e $a {
	set x($e) {}
    }
    set result {}
    foreach e $b {
	if {[info exists x($e)]} {
	    lappend result $e
	}
    }
    return $result
}

proc lunion {a b} {
    foreach e $a {
	set x($e) {}
    }
    foreach e $b {
	if {![info exists x($e)]} {
	    lappend a $e
	}
    }
    return $a
}

proc ldifference {a b} {
    foreach e ${b} {
        set x(${e}) {}
    }
    set result {}
    foreach e ${a} {
        if {![info exists x(${e})]} {
            lappend result ${e}
        }
    }
    return ${result}
}

# keylget --
#   returns value associated with key from the keyed list in the
#   variable listvar
#
# Syntax
#
#   keylget listvar [key] [retvar | {}]
#
# Description
#
#   Returns the value associated with key from the keyed list in 
#   the variable listvar. If retvar is not specified, then the 
#   value will be returned as the result of the command. In this
#   case, if key is not found in the list, an error will result.
#   
#   If retvar is specified and key is in the list, then the value 
#   is returned in the variable retvar and the command returns 1 
#   if the key was present within the list. If key is not in the 
#   list, the command will return 0, and retvar will be left 
#   unchanged.
#
# NOT IMPLEMENTED:
#
#   If {} is specified for retvar, the value is not returned, 
#   allowing the Tcl programmer to determine if a key is present 
#   in a keyed list without setting a variable as a side-effect.
#
#   If key is omitted, then a list of all the keys in the keyed 
#   list is returned.
# 
proc keylget {listVar key {resultVar ""}} {
    upvar $listVar _
    set pos 0
    foreach {k v} $_ {
        if { $key eq $k } {
            if { $resultVar ne {} } {
                upvar $resultVar result
                set result $v
                return 1
            } else {
                return $v
            }
        }
    }

    if { $resultVar eq {} } {
        error "no such key (=$key) in list"
    }

    return 0
}
