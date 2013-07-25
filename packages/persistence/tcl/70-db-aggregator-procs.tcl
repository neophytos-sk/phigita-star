Class Aggregator -parameter {
    {volatile_p "no"}
    {preserve_pathexp_p "no"}
    targetClass
    maps_to
}

Aggregator instproc getImageOf {o1} {
    my instvar targetClass maps_to
    
    set o2 [${targetClass} new -mixin db::Object]

    ### Copy variables from o1 to o2
    foreach item ${maps_to} {
	if {[llength ${item}]==2} {
	    lassign ${item} o1_varname o2_varname
	} else {
	    set o1_varname ${item}
	    set o2_varname ${item}
	}
	if {[${o1} exists ${o1_varname}]} {
	    ${o2} set ${o2_varname} [${o1} set ${o1_varname}]
	}
    }

    return ${o2}

}

Aggregator instproc getPathExp {o1} {
    my instvar preserve_pathexp_p
    if { $preserve_pathexp_p } {
	return [$o1 set pathexp]
    }
    return ""
}

#Class instfilter traceFilter
Class Aggregator=Ad-hoc -superclass "Aggregator" -parameter {{volatile_p "no"}}



#Aggregator=Ad-hoc instproc destroy {} {ns_log notice "Under Destruction (custom -- precedence=[my info precedence]-- volatile_p=[my set volatile_p]): [self]";next}