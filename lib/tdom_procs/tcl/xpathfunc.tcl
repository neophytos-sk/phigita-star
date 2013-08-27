namespace eval ::dom::xpathFunc {;}
proc ::dom::xpathFunc::names { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'names'"
    }
    foreach { type value } $args break
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "names only applicable for node or attribute nodelists!"
    }
    set n {}
    if {$type == "nodes"} {
	foreach node $value { lappend n [$node nodeName] }
    } else {
	foreach {attrName attrValue} $value { lappend n $attrName }
    }
    return [list string $n]
}
proc ::dom::xpathFunc::values { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'values'"
    }
    foreach { type value } $args break
    if {${type} == "empty"} {
	return [list string ""]
    }
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "values only applicable for node or attribute nodelists!"
    }
    set result {}
    if {$type == "nodes"} {
	foreach node $value { lappend result [$node nodeValue] }
    } else {
	foreach attrNode ${value} {
	    foreach {attrName attrValue} ${attrNode} { lappend result ${attrValue} }
	}
    }
    return [list string ${result}]
}

proc ::dom::xpathFunc::returnstring {ctxNode pos nodeListNode nodeList args} {
    if {[llength $args] != 2} {
        error "returnstring(): wrong # of args!"
    }
    foreach {arg1Typ arg1Value} $args break
    set result [::dom::xpathFuncHelper::coerce2string $arg1Typ $arg1Value]
    return [list string $result]
}


proc ::dom::xpathFunc::textvalues { ctxNode pos nodeListType nodeList args } {
    if {[llength $args] != 2} {
	error "wrong # of args for XPATH function 'values'"
    }
    foreach { type value } $args break
    if {${type} == "empty"} {
	return [list string ""]
    }
    if {($type != "nodes") && ($type != "attrnodes") } {
	error "values only applicable for node or attribute nodelists!"
    }
    set result {}
    if {$type == "nodes"} {
	foreach node $value { lappend result [$node text] }
    } else {
	foreach attrNode ${value} {
	    foreach {attrName attrValue} ${attrNode} { lappend result ${attrValue} }
	}
    }
    return [list string ${result}]
}

proc ::dom::xpathFunc::match_attribute {ctxNode pos nodeListType nodeList args} {
    if {[llength $args] != 6} {
        error "match_attribute(): wrong # of args! Usage: match_attribute(nodes,attribute,pattern)"
    }
    foreach {arg1Typ arg1Value arg2Typ arg2Value arg3Typ arg3Value} $args break
    if { $arg1Typ ne {nodes} } {
	error "match_attribute(nodes,attribute,pattern)"
    }
    set nodes $arg1Value
    set attrname [::dom::xpathFuncHelper::coerce2string $arg2Typ $arg2Value]
    set pattern [::dom::xpathFuncHelper::coerce2string $arg3Typ $arg3Value]

    ns_log notice "attrname=$attrname pattern=$pattern"

    set result_nodes [list]
    foreach node $nodes {
	if { [string match -nocase $pattern [$node getAttribute $attrname ""]] } {
	    lappend result_nodes $node
	}
    }

    return [list nodes $result_nodes]
}



#----------------------------------------------------------------------------
#   coerce2html
#
#----------------------------------------------------------------------------
proc ::dom::xpathFuncHelper::coerce2html { type value } {
puts value=$value
    switch $type {
        empty      { return "" }
        number -
        string     { return $value }
        attrvalues { return [lindex $value 0] }
        nodes      { return [[lindex $value 0] asHTML] }
        attrnodes  { return [lindex $value 1] }
    }
}

proc ::dom::xpathFunc::returnhtml {ctxNode pos nodeListNode nodeList args} {
    if {[llength $args] != 2} {
        error "returnstring(): wrong # of args!"
    }
    foreach {arg1Typ arg1Value} $args break
    set result [::dom::xpathFuncHelper::coerce2html $arg1Typ $arg1Value]
    return [list string $result]
}



#----------------------------------------------------------------------------
#   coerce2text
#
#----------------------------------------------------------------------------
proc ::dom::xpathFuncHelper::coerce2text_helper {htmlVar node} {

    upvar $htmlVar html

    set nodeType [$node nodeType]

    if { ${nodeType} eq {ELEMENT_NODE} } {

        set tagname [$node tagName]
        if { ${tagname} eq {a} } {

            set href [$node @href ""]

            set imgnode [$node selectNodes {descendant::img[@src]}]

            if { ${imgnode} ne {} } {
                coerce2text_helper html ${imgnode}
            } else {
                if { ${href} ne {} } {
                    set text [string trim [$node asText]]
                    if { ${text} ne {} } {
                        append html " \"${text}\":${href} "
                    }
                }
            }

        } elseif { ${tagname} eq {img} } {

            set imageurl [string trim [$node @src ""]]
            if { ${imageurl} ne {} } {

                set baseurl [[$node ownerDocument] baseURI]

                set imageurl [::uri::canonicalize \
                          [::uri::resolve \
                               ${baseurl} \
                               ${imageurl}]]

                append html "{image: ${imageurl}} "

            }

        } elseif { ${tagname} eq {iframe} && [set src [${node} @src ""]] ne {} } {

            set re {(youtube|vimeo|dailymotion)} 
            if { [regexp -- ${re} ${src}] } {
                append html "{video: ${src} }"
            }
            
        } else {

            if { ${tagname} in {p div h1 h2 h3} } {
                set str "\n\n"
            } elseif { ${tagname} eq {br} } {
                set str "\n"
            } else {
                set str " "
            }

            append html ${str}

            foreach child [${node} childNodes] {
                coerce2text_helper html ${child}
            }

            append html ${str}

        }

    } elseif { ${nodeType} eq {TEXT_NODE} } {

        append html [$node nodeValue]

    }
    
}

proc ::dom::xpathFuncHelper::coerce2text { type value } {
    switch $type {
        empty      { return "" }
        number -
        string     { return $value }
        attrvalues { return [lindex $value 0] }
        nodes { 
            set html ""
            foreach node ${value} {
                coerce2text_helper html $node
            }
            regsub -all -- {([^\s])\s*[\r\n]+\s*[\r\n]+\s*([^\s])} ${html} "\\1\n\n\\2" html
            return [string trim ${html}]
        }
        attrnodes  { return [lindex $value 1] }
    }
}


proc ::dom::xpathFunc::returntext {ctxNode pos nodeListNode nodeList args} {
    if {[llength $args] != 2} {
        error "returntext(): wrong # of args!"
    }
    foreach {arg1Typ arg1Value} $args break
    set result [::dom::xpathFuncHelper::coerce2text $arg1Typ $arg1Value]
    return [list string $result]
}

namespace eval ::dom::xpathFunc {

    array set date_format \
	[list \
	     {Y-nn-nn nn:nn} {%Y-%m-%d %H:%M} \
	     {nn-nn-Y nn:nn} {%d-%m-%Y %H:%M} \
	     {nn/nn/Y nn:nn} {%d/%m/%Y %H:%M} \
	     {nn.nn.Y nn:nn} {%d.%m.%Y %H:%M} \
	     {nn/nn nn:nn} {%d/%m %H:%M} \
	     {nn Xxx Y} {%d %B %Y} \
	     {nn Xxx Y} {%d %B %Y} \
	     {Xxx nn, Y} {%B %d, %Y} \
	     {nn.Xxx.Y} {%d.%b.%Y} \
	     {Xxx, dd Xxx Y} {A, d B Y} \
	     {nn:nn - nn/nn/nn} {%H:%M - %d/%m/%y} \
	     {nn:nn nn/nn} {%H:%M - %d/%m} \
	     {nn:nn n/nn} {%H:%M %d/%m} \
	     {nn:nn nn/n} {%H:%M %d/%m} \
	     {nn:nn n/n} {%H:%M %d/%m} \
	     {nn/nn} {%d/%m} \
	     {nn:nn} {%H:%M}]
    
}

proc ::dom::xpathFunc::returndate_helper__date_shape {text} {

    foreach {re subSpec} {
	{[[:lower:]]} x
	{[[:upper:]]} X
	{[[:digit:]]} n
	{Xx+x} Xxx
	{n{4}} Y
    } {
	regsub -all -- ${re} ${text} ${subSpec} text
    }

    return ${text}

}

proc ::dom::xpathFunc::returndate {ctxNode pos nodeListNode nodeList args} {

    set argc [llength ${args}]

    if { ${argc} ni {4 6 8} } {

        error "returndate(xpath,input_format,?output_format?): wrong # of args!"

    } elseif { ${argc} == 4 } {

        lassign ${args} \
            arg1Typ arg1Value \
            arg2Typ arg2Value


        set locale en_US
        set output_format {%Y%m%dT%H%M}

    } elseif { ${argc} == 6 } {

        lassign ${args} \
            arg1Typ arg1Value \
            arg2Typ arg2Value \
            arg3Typ arg3Value

        set locale ${arg3Value}
        set output_format {%Y%m%dT%H%M}

    } elseif { ${argc} == 8 } {

        lassign ${args} \
            arg1Typ arg1Value \
            arg2Typ arg2Value \
            arg3Typ arg3Value \
            arg4Typ arg4Value

        set locale ${arg3Value}
        set output_format ${arg4Value}

    }

    set ts_string [::dom::xpathFuncHelper::coerce2string ${arg1Typ} ${arg1Value}]

    set input_format ${arg2Value}
    set ts [string trim ${ts_string}]
    set result ""
    if { ${ts} ne {} } {

        if { ${input_format} eq {auto} } {
            # date recognizer using date/string shapes, e.g. dd-dd-dddd OR d-m-Y

            regsub -all -- {[^[:alnum:][:punct:] ]} ${ts} {} ts

            variable date_format

            set shape [returndate_helper__date_shape ${ts}]

            if { [info exists date_format(${shape})] } {
            set input_format $date_format(${shape})
            } else {
            return [list string ""]
            }


        }


	if { [catch {set timeval [clock scan ${ts} -format ${input_format} -locale ${locale}]} errmsg] } {
	    puts "errmsg=${errmsg} ts=${ts} input_format=${input_format} locale=${locale}"
	    return [list string ""]
	}

	set result [clock format ${timeval} -format ${output_format}]
    }
    return [list string ${result}]
}
