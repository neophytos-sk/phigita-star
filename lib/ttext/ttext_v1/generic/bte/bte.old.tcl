#!/usr/bin/tclsh
package require tdom

#textData is a string with space separated words that each odd word is a tag and each even word is the value
# example: br 0.5 im 0.3
# the values will be negated automatically

namespace eval ::ttext {;}

proc ttext::initTagValuesFromText {arrayName text} {
    global tagValues
    set words [split $text]
    set len [llength $words]
    for {set i 0} {$i < [expr $len-1]} {set i [expr $i+1]} {
	set tagName [lindex $words $i]
	set tagValue [lindex $words [expr $i+1]]
	set tagValues($tagName) $tagValue
    }
}


proc ttext::initTagValues {tagsFilename} {
    set tagsfile [open $tagsFilename "r"]
    set tagsText [read $tagsfile]
    ttext::initTagValuesFromText tagValues $tagsText
}


proc ttext::getTagCost {tagName} {
    global tagValues
    if {[info exists tagValues(${tagName})]} {
	return $tagValues(${tagName})
    } else {
	return 10
    }
}


proc ttext::getTextValue {text} {
    set textValue 0
    set chars [split $text {}]
    foreach ch $chars {
	if {[string is alpha $ch]} {
	    if {[string is lower $ch]} {
		set textValue [expr $textValue+1]
	    } else {
		set textValue [expr $textValue+0.5]
	    }
	} elseif {[string is digit $ch]} {
	    set textValue [expr $textValue-0.1]
	} elseif {[string is punct $ch]} {
	    set textValue [expr $textValue-0.5]
	} elseif {[string is space $ch]} {
	    set textValue [expr $textValue-0.25]
	} else {
	    set textValue [expr $textValue-2]
	}
    }
    return $textValue
}

proc ttext::isValid {tagName} {
    set bad_tags "select a script comment style form"
    if {[lsearch -exact $bad_tags $tagName] == -1} {
	return 1
    } else { 
	return 0 
    }
}

proc ttext::getNode {node} {
    global maxNode
    global maxStart
    global maxEnd

    set result ""
    if [$node hasChildNodes] {
	set children [$node childNodes]
	
        foreach child $children {
            if {[ttext::isValid [$child nodeName]] == 1} {
                append result [ttext::getNode $child]
            }
        }
    } else {
        if {[$node nodeType] == "TEXT_NODE"} {
            set result [$node nodeValue]
        }
    }
    return ${result}
}



proc ttext::getBody {node} {
    global maxNode
    global maxStart
    global maxEnd

    set result ""
    if {[$node nodeType] eq {ELEMENT_NODE}} {
	foreach child [lrange [$node childNodes] $maxStart $maxEnd] {
	    append result "[getNode $child]"
	}
    } else {
	if {[$node nodeType] eq "TEXT_NODE"} {
	    set result [$node nodeValue]
	}
    }
    return ${result}
}

proc ttext::evaluateBestSubseq {node list_of_valuations} {
    global maxf
    global maxNode
    global maxStart
    global maxEnd

    set i 0
    foreach valuation_i ${list_of_valuations} {
	for {set j [expr 1+${i}]} {${j} < [llength ${list_of_valuations}]} {incr j} {
	    set valuation_j [lindex ${list_of_valuations} ${j}]
	    set valuation_i [expr ${valuation_i}+${valuation_j}]
	    if {${valuation_i} > ${maxf}} {
		set maxf ${valuation_i}
		set maxNode ${node}
		set maxStart ${i}
		set maxEnd ${j}	
		#puts BESTSUB:[${maxNode} nodeName]:${maxf}:${maxStart}-${maxEnd}	
	    }
	}
	incr i
    }
}

proc ttext::evaluateNode {node} {
    global maxf
    global maxNode
    global maxStart
    global maxEnd

    set valuation 0
    set list_of_valuations ""
    if {[$node nodeType] == "TEXT_NODE"} {
	set valuation [ttext::getTextValue [$node nodeValue]]
    } elseif {[$node nodeType] == "ELEMENT_NODE"} {
	set valuation -[ttext::getTagCost [${node} nodeName]]
	foreach child_node [${node} childNodes] {
	    set child_valuation [ttext::evaluateNode ${child_node}]
	    set valuation [expr ${valuation}+${child_valuation}]
	    lappend list_of_valuations ${child_valuation}
	    #puts "[$child_node nodeName]: ${child_valuation}"
	}
	ttext::evaluateBestSubseq ${node} ${list_of_valuations}
    }

    if {${valuation} > ${maxf}} {
	set maxf ${valuation}
	set maxNode ${node}
	set maxStart 0
	set maxEnd [llength ${list_of_valuations}]
	#puts BEST:[${maxNode} nodeName]:${maxf}:${maxStart}-${maxEnd}
    }
    return ${valuation}
}


proc ::ttext::bte {data} {
    global maxf
    global maxNode
    global maxStart
    global maxEnd
    
    set data [regsub -all -nocase -- {<!--[^>]*-->|<empty>|<noembed>|<noscript>} $data {}]
    if {[catch {
	set doc [dom parse -simple -html ${data}]
    } errmsg]} {
	puts $errmsg
	return ""
    }
    set root [$doc documentElement]

    #remove comments
    foreach node [${root} selectNodes {//comment()|//*[local-name()='style' or local-name()='script']}] {
	${node} delete
    }

    set maxf -100000000
    ttext::evaluateNode $root
    return [ttext::getBody ${maxNode}]
}


proc ttext::getHtmlFileText {filename} {
    if {[file exists $filename]} {
	set f [open $filename r]
	return [read $f]
    } else {
	puts "Error : File does not exist" 
	return "error"
    }
}

#main
if {$argc == 1} {
    ttext::initTagValues "TagValues"
    set text [ttext::getHtmlFileText [lindex $argv 0]]    
    if {$text != "error"} {
	puts [ttext::bte $text]
    }
} else {    
    puts "Wrong \# args: should be \"bte html_filename\""
}