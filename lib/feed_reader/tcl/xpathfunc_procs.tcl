
namespace eval ::dom::xpathFunc {

    array set mapping [list]

    set mapping_dir [::feed_reader::get_conf_dir]

    set filelist [glob -nocomplain -directory ${mapping_dir} *]

    foreach filename ${filelist} {
	set locale [string trimleft [file extension ${filename}] {.}]
	set mapping(${locale}) [::util::readfile ${filename}]
    }

}

proc ::dom::xpathFunc::normalizedate_helper {textVar locale} {
    upvar $textVar text

    variable mapping

    if { [info exists mapping(${locale})] } {

	set text [string trim [string map $mapping(${locale}) ${text}]]

    }
}

proc ::dom::xpathFunc::normalizedate {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] ni { 4 6 } } {
	error "normalizedate(string): wrong # of args"
    }


    lassign ${args} \
	arg1Typ arg1Value \
	arg2Typ arg2Value \
	arg3Typ arg3Value


    set ts_string [::dom::xpathFuncHelper::coerce2string ${arg1Typ} ${arg1Value}]
    set locale $arg2Value

    normalizedate_helper ts_string ${locale}

    if { ${ts_string} eq {now} } {

        set ts_string [clock format [clock seconds] -format "%Y%m%dT%H%M"]

    } elseif { [lindex ${ts_string} end] eq {ago} } {

        # TODO: convert pretty age to a timestamp
        set ts_string [::util::dt::age_to_timestamp ${ts_string} [clock seconds]]

    } elseif { [regexp -- {ago ([0-9]+)'} ${ts_string} _whole_ num_mins] } {

        set ts_string [::util::dt::age_to_timestamp "${num_mins} mins ago" [clock seconds]]

    } else {

        set format ${arg3Value}	
        return [::dom::xpathFunc::returndate $ctxNode $pos $nodeListNode $nodeList string ${ts_string} string ${format} string ${locale}]

    }

    return [list string ${ts_string}]

}

proc tokenSimilarity {tokens_text1 tokens_text2} {

    lassign [intersect3 ${tokens_text1} ${tokens_text2}] t1 _dummy_ t2
    set n1 [llength ${t1}]
    set n2 [llength ${t2}]
    set score [expr { ${n1} + ${n2} }]
    
}

proc subseqSimilarity {tokens_text1 tokens_text2} {

    set l2 [llength ${tokens_text2}]
    set tokens_text1 [lrange ${tokens_text1} 0 ${l2}]

    lassign [intersect3 ${tokens_text1} ${tokens_text2}] t1 _common_ t2

    set score [expr { -1 * [llength ${_common_}] }]

    return ${score}

}


proc stringDistance {a b} {

    set n [string length $a]
    set m [string length $b]
    for {set i 0} {$i<=$n} {incr i} {set c($i,0) $i}
    for {set j 0} {$j<=$m} {incr j} {set c(0,$j) $j}
    for {set i 1} {$i<=$n} {incr i} {
	for {set j 1} {$j<=$m} {incr j} {
	    set x [expr { $c([expr { $i - 1 }],$j) + 1 }]
	    set y [expr { $c($i,[expr { $j - 1 }]) + 1 }]
	    set z $c([expr { $i - 1 }],[expr { $j - 1 }])
	    if {[string index $a [expr { $i - 1 }]] != [string index $b [expr { $j - 1 }]]} {
		incr z
	    }
	    set c($i,$j) [min $x $y $z]
	}
    }
    set c($n,$m)
}

proc min args {lindex [lsort -real $args] 0}
proc max args {lindex [lsort -real $args] end}


proc stringSimilarity {a b} {
    set totalLength [string length "${a}${b}"]
    max [expr {double(${totalLength} - 2 * [stringDistance ${a} ${b}]) / ${totalLength}}] 0.0
}


proc ::dom::xpathFunc::currentdate {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != 0 } {
	error "currentdate(): wrong # of args (takes not arguments)"
    }
 
    return [list "string" [clock format [clock seconds] -format "%Y %m %d %H:%M"]]
}


proc ::dom::xpathFunc::similar_to_text {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != 8 } {
        error "similar_to_text(nodes,text,score_fn,tokenizer): wrong # of args"
    }

    lassign ${args} \
        arg1Typ nodes \
        arg2Typ text2 \
        arg3Type score_fn \
        arg4Type tokenizer

    set tokenizer [lsearch -inline -not [list ${tokenizer} "::util::tokenize"] {}]

    set tokens_text2 [${tokenizer} ${text2}]

    set similarnode ""

    if { ${tokens_text2} ne {} } {

        set min_score 999999
        foreach node ${nodes} {

            set text1 [${node} asText]

            if { ${text1} eq {} } {
            continue
            }
            set tokens_text1 [${tokenizer} ${text1}]

            set score [${score_fn} ${tokens_text1} ${tokens_text2}]

            if { ${score} <= ${min_score} } {
            set similarnode ${node}
            set min_score ${score}
            }

        }
    }

    #puts similarnode=${similarnode}

    if { ${similarnode} eq {} } {
        return [list string ""]
    } else {
        return [list string ${similarnode}]
    }

}



proc ::dom::xpathFunc::split-string {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != 4  } {
        error "split-string(string,pattern): wrong # of args"
    }


    lassign ${args} \
        arg1Typ str \
        arg2Typ splitChars


    set doc [$ctxNode ownerDocument]
    set nodes [list]
    foreach str [split ${str} ${splitChars}] {
        lappend nodes [${doc} createTextNode ${str}]
    }
    return [list nodes ${nodes}]
}
