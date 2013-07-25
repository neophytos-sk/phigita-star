#!/usr/bin/tclsh
package require tdom

namespace eval ::ttext {;}

Class ::ttext::Worker -parameter {
    maxf
    maxNode
    maxStart
    maxEnd
    tagValues
}

::ttext::Worker instproc init {} {
    my instvar tagValues
    array set tagValues {
	head 50000
	body 30000
	table 5000
	tbody 2000
	tr 1000
	th 1000
	td 500
	div 50
	p 50
	a 10
	br 25
	b 2.5
	i 2.5
	span 10
    }
}


::ttext::Worker instproc getTextValue {node} {
    set textValue 0
    set chars [split [${node} nodeValue] {}]
    foreach ch ${chars} {
	if {[string is alpha ${ch}]} {
	    if {[string is lower $ch]} {
		set textValue [expr ${textValue}+1.0]
	    } else {
		set textValue [expr ${textValue}+0.5]
	    }
	} elseif {[string is digit $ch]} {
	    set textValue [expr ${textValue}-0.05]
	} elseif {[string is punct ${ch}]} {
	    set textValue [expr ${textValue}-3.5]
	} elseif {[string is space ${ch}]} {
	    set textValue [expr ${textValue}-0.05]
	} elseif { ${ch} eq "\u00A9" } {
	    set textValue [expr ${textValue}-100]
	} else {
	    set textValue [expr ${textValue}-2]
	}
    }
    [${node} parentNode] setAttribute tv ${textValue}
    return ${textValue}
}

::ttext::Worker instproc getTagCost {tagName} {
    my instvar tagValues
    set tagName [string tolower ${tagName}]
    if {[my exists tagValues(${tagName})]} {
	return $tagValues(${tagName})
    } else {
	return 25
    }
}


::ttext::Worker instproc getNode {node} {
    my instvar maxNode maxStart maxEnd

    set result ""
    foreach child [${node} childNodes] {
	if { [${node} hasChildNodes] } {
	    append result [my getNode ${child}]
	} else {
	    append result [${node} nodeValue]
	}
    }
    return ${result}
}



::ttext::Worker instproc getBody {node} {
    my instvar maxNode maxStart maxEnd

    set result ""
    if {[$node nodeType] eq {ELEMENT_NODE}} {
	foreach child [lrange [$node childNodes] ${maxStart} ${maxEnd}] {
	    append result [${child} asText]
	    #append result [my getNode $child]
	}
    } else {
	if {[$node nodeType] eq "TEXT_NODE"} {
	    set result [$node nodeValue]
	}
    }
    return ${result}
}

::ttext::Worker instproc evaluateBestSubseq {node list_of_valuations} {
    my instvar maxf maxNode maxStart maxEnd

    set bestSubseqValuation ""
    set i 0
    set n [llength ${list_of_valuations}]
    foreach valuation_i ${list_of_valuations} {
	set j 0
	set current_valuation 0
        for { set j ${i} } { ${j} < ${n} } { incr j } {
	    set valuation_j [lindex ${list_of_valuations} ${j}]
	    set current_valuation [expr ${current_valuation}+${valuation_j}]
	    if { ${current_valuation} > ${maxf} } {
		set bestSubseqValuation ${current_valuation}
		set maxf ${current_valuation}
		set maxNode ${node}
		set maxStart ${i}
		set maxEnd ${j}	
		#puts BESTSUB:[${maxNode} nodeName]:${maxf}:${maxStart}-${maxEnd}	
	    }
	}
	incr i
    }
    return ${bestSubseqValuation}
}

::ttext::Worker instproc evaluateNode {node} {
    my instvar maxf maxNode maxStart maxEnd

    if {[$node nodeType] == "TEXT_NODE"} {
	set nf [my getTextValue ${node}]
    } elseif {[$node nodeType] == "ELEMENT_NODE"} {

	set nv 0
	set list_of_valuations ""
	foreach child_node [${node} childNodes] {
	    set child_valuation [my evaluateNode ${child_node}]
	    set nv [expr ${nv}+${child_valuation}]
	    lappend list_of_valuations ${child_valuation}
	}
	set bestSubseqValuation [my evaluateBestSubseq ${node} ${list_of_valuations}]
	set nv [::util::coalesce ${bestSubseqValuation} ${nv}]
	set nf [expr ${nv}-[my getTagCost [${node} nodeName]]]
	${node} setAttribute nv ${nv}
	${node} setAttribute nf ${nf}
	
	if {${nf} > ${maxf}} {
	    set maxf ${nf}
	    set maxNode ${node}
	    set maxStart 0
	    set maxEnd [llength ${list_of_valuations}]
	}
    }

    return ${nf}
}


::ttext::Worker instproc bte {doc} {
    my instvar maxf maxNode maxStart maxEnd

    foreach node [${doc} selectNodes {//*[local-name()='script' or local-name()='style' or local-name()='SCRIPT' or local-name()='STYLE']}] {
	${node} delete
    }
    
    set root [${doc} documentElement]
    set maxf -100000000
    my evaluateNode $root
    return [my getBody ${maxNode}]
}
