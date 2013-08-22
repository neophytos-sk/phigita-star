
namespace eval ::dom::xpathFunc {

    array set mapping [list]

    set mapping_dir [::feed_reader::get_conf_dir]

    set filelist [glob -nocomplain -directory ${mapping_dir} *]

    foreach filename ${filelist} {
	set locale [string trimleft [file extension ${filename}] {.}]
	set mapping(${locale}) [::util::readfile ${filename}]
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

    variable mapping

    if { [info exists mapping(${locale})] } {

	set ts_string [string trim [string map $mapping(${locale}) ${ts_string}]]

    }

    if { ${ts_string} eq {now} } {
	set ts_string [clock format [clock seconds] -format "%Y%m%dT%H%M"]
    } elseif { [lindex ${ts_string} end] eq {ago} } {
	# TODO: convert pretty age to a timestamp
	set ts_string [::util::dt::age_to_timestamp ${ts_string} [clock seconds]]
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

    set len [llength ${tokens_text2}]
    set tokens_text1 [lrange ${tokens_text1} 0 ${len}]

    lassign [intersect3 ${tokens_text1} ${tokens_text2}] t1 _common_ t2

    set n1 [llength ${t1}]
    set n2 [llength ${t2}]

    set score [expr { -1 * [llength ${_common_}] }]

    return ${score}

    set score [expr { ${n1} + ${n2} }]
    
}

proc exactImageSrc {tokens_text1 tokens_text2} {

    return [expr { ${tokens_text1} eq ${tokens_text2} }]
    
}


proc ::dom::xpathFunc::similar_to_text {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != { 6 } } {
	error "similar(string): wrong # of args"
    }

    lassign ${args} \
	arg1Typ nodes \
	arg2Typ text2 \
	arg3Type score_fn


    set tokens_text2 [::util::tokenize ${text2}]

    set similarnode ""
    set min_score 999999
    foreach node ${nodes} {
	set text1 [${node} asText]
	if { ${text1} eq {} } {
	    continue
	}
	set tokens_text1 [::util::tokenize ${text1}]

	set score [${score_fn} ${tokens_text1} ${tokens_text2}]

	if { ${score} <= ${min_score} } {
	    set similarnode ${node}
	    set min_score ${score}
	}

    }

    #puts similarnode=${similarnode}

    if { ${similarnode} eq {} } {
	return [list string ""]
    } else {
	return [list string ${similarnode}]
    }

}
