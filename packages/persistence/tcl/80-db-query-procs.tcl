package require XOTcl; namespace import -force xotcl::*


###############################################################################

Class Query -parameter { 
    {ns ""} 
    {alias "[namespace tail [self]]"} 
    {criteria ""}
    {group ""} 
    {group_criteria ""}
    {order ""} 
    {limit ""}
    {offset ""}
}

Query instproc addChild { extra cl name args } {
    if { ![Object isobject [self]::${extra}] } {
	my::Object [self]::${extra}
    }
#    puts "$cl [self]::${extra}::${name} ${args}"
    eval ${cl} [self]::${extra}::${name} ${args}
}

Query instproc select { list } {
    foreach select_item ${list} {
	eval [self] addChild SELECT ${select_item}
    }
}

Query instproc from { list } {

    if { [llength ${list}] > 1 } {
	eval [self] addChild FROM ${list}
    } else {
	eval [self] addChild FROM DQ_Proxy ${list}
    }

}

Query instproc asSQL {{ns ""}} {

    set from_list [list]
    foreach child [[self]::FROM info children] {
	set sql [${child} asSQL [util::coalesce [my ns] ${ns}]]
	if { ![string equal ${sql} ""] } {
	    lappend from_list ${sql}
	}
    }

    if { [string equal ${from_list} ""] } {
	return ""
    } else {
	set select_list [list]
	foreach child [[self]::SELECT info children] {
	    lappend select_list [${child} asSQL]
	}

	set extra ""
	if { ![string equal [my criteria] ""] } {
	    append extra " where [my criteria] "
	}
	if { ![string equal [my group] ""] } {
	    lappend extra " group by [my group] "
	    if { ![string equal [my group_criteria] ""] } {
		lappend extra " having [my group_criteria] "
	    }
	}
	if { ![string equal [my order] ""] } {
	    lappend extra " order by [my order] "
	}
	if { ![string equal [my limit] ""] } {
	    lappend extra " limit [my limit] "
	}
	if { ![string equal [my offset] ""] } {
	    lappend extra " offset [my offset] "
	}

	return "(select [join ${select_list} ,] from [join ${from_list} ,] [join ${extra}]) [my alias]"
    }
}

Query instproc src_list {{ns ""}} {

    set src_lists [list]
    foreach child [[self]::FROM info children] {
	lappend src_lists [${child} src_list [util::coalesce [my ns] ${ns}]]
    }

    return [join ${src_lists}]

}



Query instproc execute {} {

    set src_list [my src_list [my ns]]
    
    set conn [DB_Connection new -volatile]
    
    foreach {obj src exists_p} [${conn} check_src_list ${src_list}] {
	${obj} set exists_p ${exists_p}
    }
    set sql [[self] asSQL]
    return [${conn} query "select * from [[self] asSQL]"]

}


Class DB_Join -parameter {{ns ""} {alias "[namespace tail [self]]"} ON}

DB_Join instproc addChild {extra cl name args} {
    Class [self]::${extra}
    eval ${cl} [self]::${extra}::${name} ${args}
}

DB_Join instproc LHS { list } {
    eval [self] addChild LHS ${list}
}

DB_Join instproc RHS { list } {
    eval [self] addChild RHS ${list}
}

DB_Join instproc join_type {} {
    return "[string tolower [string map {_ " "} [namespace tail [[self] info class]]]]"
}


DB_Join instproc src_list {{ns ""}} {
    set lhs_src_list [[[self]::LHS info children] src_list [util::coalesce [my ns] ${ns}]]
    set rhs_src_list [[[self]::RHS info children] src_list [util::coalesce [my ns] ${ns}]]
    return [concat ${lhs_src_list} ${rhs_src_list}]
}

Class Inner_Join -superclass DB_Join

Inner_Join instproc asSQL {{ns ""}} {

    set ns [util::coalesce [my ns] ${ns}]
    set lhs_sql [[namespace children [self]::LHS] asSQL ${ns}]
    set rhs_sql [[namespace children [self]::RHS] asSQL ${ns}]
    if { [string equal ${lhs_sql} ""] || [string equal ${rhs_sql} ""] } {
	return ""
    } else {
	return "( ${lhs_sql} [my join_type]  ${rhs_sql} on ([my ON])) [my alias]"
    }

}

Class Left_Outer_Join -superclass DB_Join

Left_Outer_Join instproc asSQL {{ns ""}} {

    set ns [util::coalesce [my ns] ${ns}]
    set lhs_sql [[namespace children [self]::LHS] asSQL ${ns}]
    set rhs_sql [[namespace children [self]::RHS] asSQL ${ns}]

    return "( ${lhs_sql} [my join_type] ${rhs_sql} on ([my ON])) [my alias]"

}
###############################################################################

Class DQ_Proxy -parameter {{name "[namespace tail [self]]"}}

DQ_Proxy instproc asSQL {{ns ""}} {
    if { [my set exists_p] } {
	if { ![string equal ${ns} ""] } {
	    return xo__${ns}.xo__[namespace tail [self]]
	} else {
	    return xo__[namespace tail [self]]
	}
    } else {
	return [[self] asNULL]
    }

}

DQ_Proxy instproc src_list {{ns ""}} {
    if { ![string equal ${ns} ""] } {
	return [list [self] xo__${ns}.xo__[string tolower [namespace tail [self]]]]
    } else {
	return [list [self] xo__[string tolower [namespace tail [self]]]]
    }
}

DQ_Proxy instproc asNULL {} {
    
    return "([[my name] asNULL]) [my name]"

}

Class Out -parameter {{column ""}}

Out instproc asSQL {{ns ""}} {
    if { ![string equal [my column] ""] } {
	return "[my column] as [namespace tail [self]]"
    } else {
	return [namespace tail [self]]
    }
}

###############################################################################

Class Agg__Integer_Array -parameter "column" -instproc asSQL {{ns ""}} {return "int_array_aggregate([my column]) as [namespace tail [self]]"} -instproc asNULL {} {return "{} as [namespace tail [self]]"}

Class Agg__Count -instproc asSQL {{ns ""}} {return "count(1) as [namespace tail [self]]"} -instproc asNULL {} {return "0 as [namespace tail [self]]"}

###############################################################################

###############################################################################
##### THE FOLLOWING QUERY WORKS #####
##### select j0.* from ((select * from ((select id from xo__u814.xo__Blog_Item) j0_q0_j0_q0 left outer join (select int_array_aggregate(label_id),object_id from xo__u814.xo__Blog_Item_Label_Map group by object_id) j0_q0_j0_q1 on ( j0_q0_j0_q0.id = j0_q0_j0_q1.object_id )) j0_q0_j0) j0_q0 inner join (select * from ((select id from xo__u814.xo__Blog_Item) j0_q1_j0_q0 left outer join (select count(1),parent_id from xo__u814.xo__Blog_Item_Comment group by parent_id) j0_q1_j0_q1 on ( j0_q1_j0_q0.id = j0_q1_j0_q1.parent_id )) j0_q1_j0) j0_q1 on ( j0_q0.id = j0_q1.id )) j0
###############################################################################
