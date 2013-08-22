
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


proc stringDistance {a b} {
        set n [string length $a]
        set m [string length $b]
        for {set i 0} {$i<=$n} {incr i} {set c($i,0) $i}
        for {set j 0} {$j<=$m} {incr j} {set c(0,$j) $j}
        for {set i 1} {$i<=$n} {incr i} {
           for {set j 1} {$j<=$m} {incr j} {
                set x [expr {$c([- $i 1],$j)+1}]
                set y [expr {$c($i,[- $j 1])+1}]
                set z $c([- $i 1],[- $j 1])
                if {[string index $a [- $i 1]]!=[string index $b [- $j 1]]} {
                        incr z
                }
                set c($i,$j) [min $x $y $z]
            }
        }
        set c($n,$m)
 }
 # some little helpers:
 if {[catch {
    # DKF - these things (or rather improved versions) are provided by the 8.5 core
    package require Tcl 8.5
    namespace path {tcl::mathfunc tcl::mathop}
 }]} then {
    proc min args {lindex [lsort -real $args] 0}
    proc max args {lindex [lsort -real $args] end}
    proc - {p q} {expr {$p-$q}}
 }

 proc stringSimilarity {a b} {
        set totalLength [string length $a$b]
        max [expr {double($totalLength-2*[stringDistance $a $b])/$totalLength}] 0.0
 }


proc tokenSimilarity {tokens_text1 tokens_text2} {
    # TODO: use cosine similarity
    set re {<([ad]>[^<>]+</[ad]>)}
	
    lassign [intersect3 ${tokens_text1} ${tokens_text2}] t1 _dummy_ t2
    set len1 [llength ${tokens_text1}]
    set len2 [llength ${tokens_text2}]
    set num_diff_tokens [expr { [llength ${t1}] + [llength ${t2}] }]
    
}

proc ::dom::xpathFunc::similar_to_text {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != { 6 } } {
	error "similar(string): wrong # of args"
    }

    lassign ${args} \
	arg1Typ arg1Value \
	arg2Typ arg2Value \
	arg3Type score_fn

    set text2 [::dom::xpathFuncHelper::coerce2string ${arg2Typ} ${arg2Value}]
    set tokens_text2 [::util::tokenize ${text2}]

    set similarnode ""
    set min_score 999999
    foreach node ${arg1Value} {
	set text1 [${node} text]
	set tokens_text1 [::util::tokenize ${text1}]

	#set score [stringSimilarity ${tokens_text1} ${tokens_text2}]
	set score [${score_fn} ${tokens_text1} ${tokens_text2}]

	if { ${score} < ${min_score} } {
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
