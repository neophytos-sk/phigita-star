#!/usr/bin/tclsh
package require tdom

#textData is a string with space separated words that each odd word is a tag and each even word is the value
# example: br 0.5 im 0.3
# the values will be negated automatically



namespace eval ::ttext {;}

Class ::ttext::Worker -parameter {
    maxf
    maxNode
    maxStart
    maxEnd
    tagValues
}

::ttext::Worker instproc init {} {
    my instvar tagValues cssClassValues
    array set tagValues {
	head 50000
	body 30000
	table 5000
	tbody 2000
	tr 1000
	th 1000
	td 500
	title 1000
	ul 50
	form 500
	select 250
	option 100
	xo__option 100
	input 250
	img 20
	div 20
	object 5
	embed 5
	param 5
	p 4
	a 9.5
	br 5
	b 2.5
	i 2.5
	span 10
    }
    array set cssClassValues {
	post-body 1000
	entrytext 300
	blogPost 200
	entry-content 200
	snap_preview 200
	postmetadata -100
	postContent 500
	entry 500
    }
    array set tagAttrValues {
	embed {src ::xo::buzz::video_p 200}
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
	} elseif { $ch eq {|} } {
	    set textValue [expr ${textValue}-100]
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

::ttext::Worker instproc getTagCost {node} {
    my instvar tagValues tagAttrValues
    set tagName [$node nodeName]
    set tagName [string tolower ${tagName}]
    if {[my exists tagValues(${tagName})]} {
	set result $tagValues(${tagName})
    } else {
	set result 25
    }
    if { [info exists tagAttrValues($tagName)] } {
	foreach {attname guard value} $tagAttrValues($tagName) {
	    if { [$node hasAttribute $attname] } {
		set attvalue [$node getAttribute $attname "0"]
		if { [$guard $attvalue] } {
		    set result [expr { $result + $value }]
		}
	    }
	}
    }
    return $result
}

::ttext::Worker instproc getClassValue {classList} {
    my instvar cssClassValues
    set cssClassName [lindex ${classList} 0]
    if {[my exists cssClassValues(${cssClassName})]} {
	return $cssClassValues(${cssClassName})
    } else {
	return 0
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
    if { [llength $list_of_valuations] > 100 } return ""
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

    set nf 0
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
	set cssClassValue [my getClassValue [${node} getAttribute class ""]]
	set nf [expr ${nv}+${cssClassValue}-[my getTagCost ${node}]]
	${node} setAttribute nv ${nv}
	${node} setAttribute nf ${nf}
	${node} setAttribute cv ${cssClassValue}

	
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
