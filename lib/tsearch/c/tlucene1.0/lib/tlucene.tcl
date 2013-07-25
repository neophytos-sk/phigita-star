::util::loadIf /opt/naviserver/bin/tlucene1.0.so

proc subsets {l} {
    set subsets [list [list]]
    foreach e $l {
	foreach subset $subsets {
	    lappend subsets [lappend subset $e]
	}
    }
     return $subsets
}

proc subsets2 { list size } {
    if { $size == 0 } {
	return [list [list]]
    }
    set retval {}
    for { set i 0 } { ($i + $size) <= [llength $list] } { incr i } {
	set firstElement [lindex $list $i]
	set remainingElements [lrange $list [expr { $i + 1 }] end]
	foreach subset [subsets2 $remainingElements [expr { $size - 1 }]] {
	    lappend retval [linsert $subset 0 $firstElement]
	}
    }
     return $retval

}

proc map2keyl {map} {
    # Converts a map (i.e. {key1 value1 key2 value} list as returned by array get)
    # Into a list of lists a.k.a. keyed list (i.e. {{key1 value1} {key2 value2}})
    
    set result [list]
    set i 1
    foreach element $map {
        if $i {
            set key $element
        } else {
            lappend result [list $key $element]
        }
        #alternate between 0 and 1:
        set i [expr {abs($i-1)}]
    }
    return $result

}

proc list2tuples {size list} {
    set result [list]
    set i 0
    set tuple [list]
    foreach el $list {
	if { $i < $size } {
	    lappend tuple $el
	    incr i
	} else {
	    lappend result $tuple
	    set tuple [list $el]
	    set i 1
	}
    }
    lappend result $tuple
    return $result
}

namespace eval ::util {;}

proc ::util::dbquotevalue {text} {
    if { $text eq {} } {
        return NULL
    } else {
        return E'[string map {' '' \\ \\\\} $text]'
    }
}

proc ::util::plus {num list} {
    set result ""
    foreach item $list {
	lappend result [incr item $num]
    }
    return $result
}



namespace eval ::ttext {;}
namespace eval ::ttext::analysis {;}

Class ::ttext::analysis::Field -parameter {
    {name ""}
    {weight ""}
    {tokenizer "::ttext::analysis::tsWindowTokenizer"}
    {table ""}
    {columnName ""}
    {targetName ""}
}


Class ::ttext::analysis::Analyzer -parameter {
    {index ""}
    {stopwords ""}
}

::ttext::analysis::Analyzer instproc init {args} {
    #initialize stopwords
}

::ttext::analysis::Analyzer instproc to_tsvector {cellData} {
    my instvar index
    set result ""
    foreach o $index {
	set dictKey [$o name]
	set weight [$o weight]
	set tokenizer [$o tokenizer]
	foreach term [$tokenizer tsVector -spec $o [dict get $cellData $dictKey]] {
	    lappend result $term
	}
    }
    return [::util::dbquotevalue $result]::tsvector
}

::ttext::analysis::Analyzer instproc superColumn {cellData} {
    # to cassandra supercolumn
}


# HERE: REVISIT
::ttext::analysis::Analyzer instproc toTSQuery {{-spec ""} searchQuery} {
    set tokenizer [$spec tokenizer]
    set stream [$tokenizer tokenStream -spec $spec $searchQuery]

    if { ${stream} eq {} } {
	return
    }

    set stream [lsort -decreasing -index 2 [list2tuples 3 $stream]]
    set stream [join $stream " "]

    set result ""
    foreach {token positions isset_p} $stream {
	if { $isset_p } {
	    set tokenlist [split ${token} ","]
	    foreach word $tokenlist {
		set seen(${word}) ""
	    }
	    lappend result "(${token}|[join ${tokenlist} {&}])"
	} else {
	    if { ![info exists seen(${token})] } {
		lappend result $token
	    }
	}
    }

    return '[join $result {&}]'::tsquery
}



###
### Tokenizer
###

Class ::ttext::analysis::Tokenizer -parameter {
    {prefix ""}
}

::ttext::analysis::Tokenizer instproc getTerm {token} {
    my instvar prefix
    set result ""
    if { $prefix ne {} } {
	append result ${prefix}:
    }
    append result $token
    return $result
}



###
### SimpleTokenizer - Unaccent
###
Class ::ttext::analysis::SimpleTokenizer -parameter {
    {unaccent "1"}
}

::ttext::analysis::SimpleTokenizer instproc tokenStream {{-spec ""} text} {
    my instvar unaccent
    if { ${unaccent} } {
	set text [::ttext::unac utf-8 $text]
    }
    set stream [::xo::lib::lucene tokenize $text]
    return $stream
}



###
### Window Stream Tokenizer
###

Class ::ttext::analysis::WindowTokenizer -superclass {::ttext::analysis::SimpleTokenizer} -parameter {
    {window "10"}
}

::ttext::analysis::WindowTokenizer instproc combineTokens {t0 t1} {
    lassign $t0 w0 p0
    lassign $t1 w1 p1
    if { -1 == [string compare ${w0} ${w1}] } {
        set result [list ${w0},${w1} ${p0},${p1} 1]
    } else {
        set result [list ${w1},${w0} ${p1},${p0} 1]
    }
    return $result
}

::ttext::analysis::WindowTokenizer instproc tokenStream {{-spec ""} text} {
    my instvar window
    set stream [map2keyl [next]]
    set lastIndex [expr { $window - 1 }]
    set windowStream [list]
    set result [list]
    foreach token $stream {
	lappend result [concat $token 0]
	foreach otherToken $windowStream {
	    lappend result [my combineTokens ${token} ${otherToken}]
	}
	set windowStream [lrange [linsert $windowStream 0 $token] 0 $lastIndex]
    }
    set result [join [lsort -unique -dictionary -index 0 [concat $stream $result]]]
    return $result
}

::ttext::analysis::WindowTokenizer instproc tsVector {{-spec ""} text} {
    set result ""
    set weight [$spec weight]
    set stream [my tokenStream -spec ${spec} ${text}]
    foreach {token positions isset_p} ${stream} {
	#[join ${positions} "${weight},"]${weight}
	if { ${isset_p} } {
	    lappend result ${token}
	} else {
	    lappend result ${token}:[join [::util::plus 1 ${positions}] "${weight},"]${weight}
	}
    }
    return $result
}



###
### Dewey Decimal Classification (DDC) Tokenizer
###

Class ::ttext::analysis::DeweyTokenizer -superclass "::ttext::analysis::Tokenizer" -parameter {
    {prefix "DDC"}
}

::ttext::analysis::DeweyTokenizer instproc tokenStream {{-spec ""} text} {
    set result ""
    foreach ddc [split [string trim ${text}] {,}] {
	lassign [split [string trim $ddc] ". "] ddc_first ddc_second ddc_third
	lassign [split $ddc_first ""] d2 d1 d0
	if { ${ddc_third} ne {} } {
	    lappend result [my getTerm "${ddc_first}.${ddc_second}_${ddc_third}"]
	}
	if { ${ddc_second} ne {} } {
	    lappend result [my getTerm "${ddc_first}.${ddc_second}"]
	}
	lappend result [my getTerm "${d2}${d1}${d0}"]
	lappend result [my getTerm "${d2}${d1}0"]
	lappend result [my getTerm "${d2}00"]
    }
    return $result
}

::ttext::analysis::DeweyTokenizer instproc tsVector {{-spec ""} ddc} {
    set stream [my tokenStream -spec ${spec} ${ddc}]
    return [join [::xo::fun::map token ${stream} { string map {{:} {#}} $token }]]
}





::ttext::analysis::SimpleTokenizer ::ttext::analysis::tsSimpleTokenizer
::ttext::analysis::WindowTokenizer ::ttext::analysis::tsWindowTokenizer
::ttext::analysis::DeweyTokenizer ::ttext::analysis::tsDeweyTokenizer


::ttext::analysis::Analyzer ::ttext::analysis::tsBookAnalyzer \
    -index [list \
		[::ttext::analysis::Field new -name title -weight A] \
		[::ttext::analysis::Field new -name author -weight B] \
		[::ttext::analysis::Field new -name description -weight C] \
		[::ttext::analysis::Field new -name publisher -weight D] \
		[::ttext::analysis::Field new -name subject -tokenizer tsDeweyTokenizer -table "xo.xo__book__subject" -columnName "name" -targetName "ddc"]]



::ttext::analysis::Field ::ttext::analysis::tsQueryField
proc ::ttext::analysis::plain_to_tsquery {searchQuery {spec "::ttext::analysis::tsQueryField"} } {
    return [::ttext::analysis::tsBookAnalyzer toTSQuery -spec ${spec} ${searchQuery}]
}
