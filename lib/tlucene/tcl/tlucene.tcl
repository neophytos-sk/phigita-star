
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
    {pool ""}
    {name ""}
    {weight ""}
    {tokenizer "::ttext::analysis::tsWindowTokenizer"}
    {qualifier ""}
}

::ttext::analysis::Field instproc tsTerm.Qualifier {} {
    my instvar qualifier
    set result ""
    if { $qualifier ne {} } {
	set result "${qualifier}\#"
    }
    return $result
}

::ttext::analysis::Field instproc tsTerm.Text {text} {
    return [string map {{ } {_}} $text]
}

::ttext::analysis::Field instproc tsTerm {text} {
    my instvar tokenizer
    set prefix [my tsTerm.Qualifier]
    set result [xo::fun::map x [my tsTerm.Text $text] { set y ${prefix}${x} }]
    #set result ""
    #foreach value [my tsTerm.Text $text] {
    #	lappend result ([join [$tokenizer tsVector $value] {&}])
    #}
    if { $result ne {} } {
	return ([join $result {|}])
    }
    return "NULL\#NULL"
}


Class ::ttext::analysis::FKey -superclass {::ttext::analysis::Field} -parameter {
    {reference ""}
    {keyColumn ""}
    {valueColumn ""}
    {searchColumn ""}
}


namespace eval ::xo {;}
namespace eval ::xo::db {;}
namespace eval ::xo::db::op {;}


proc ::ttext::getTrigrams {text} {
    return [::xo::fun::map x [::ttext::trigrams $text] { string map {{ } {_}} $x }]

}
proc ::ttext::trigrams.tsQuery {text} {
    set text [string tolower ${text}]
    return plainto_tsquery([ns_dbquotevalue [::ttext::getTrigrams ${text}]])::tsquery
}


#
#set criteria [::xo::db::qualifier ${searchColumn} contains-trigrams-of ${text} ::ttext::trigrams.tsQuery]
#set criteria [::xo::db::qualifier lower(${valueColumn}) eq ${text}]
#
proc ::xo::db::getColumn {pool reference columnName criteria} {
    set criteria [::xo::db::qualifier {*}${criteria}]

    set data [::db::Set new -pool ${pool} -select ${columnName} -type ${reference} -where [list $criteria]]
    $data load
    set result [::xo::fun::map o [$data set result] { $o set $columnName }]
    return $result
}

::ttext::analysis::FKey instproc tsTerm.Text {text} {
    my instvar pool reference keyColumn valueColumn tokenizer searchColumn
    return [::xo::db::getColumn ${pool} ${reference} ${keyColumn} "${valueColumn} eq [list ${text}]"]
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
	if { [dict exists $cellData $dictKey] } {
	    foreach term [$tokenizer tsVector -spec $o [dict get $cellData $dictKey]] {
		lappend result $term
	    }
	}
    }
    return [::util::dbquotevalue $result]::tsvector
}

::ttext::analysis::Analyzer instproc to_superColumn {cellData} {
    my instvar index
    set result ""
    set weight 0
    foreach o [lreverse $index] {
	set dictKey [$o name]
	set tokenizer [$o tokenizer]
	set OID [dict get $cellData id]
	if { [dict exists $cellData $dictKey] } {
	    lassign [$tokenizer superColumn -spec $o -OID $OID -weight $weight [dict get $cellData $dictKey]] name cfmap
	    ### HERE: COLLAPSE
	    if { $cfmap ne {} } {
		set arrayName superColumn_$name
		array set $arrayName $cfmap
	    }
	}
	incr weight
    }
    array set superColumn [list]
    foreach arrayName [info vars superColumn_*] {
	lassign [split $arrayName _] __prefix__ name
	set superColumn($name) [array get superColumn_$name]
    }
    return [array get superColumn]
}




::ttext::analysis::Analyzer instproc getField {name} {
    return [::xo::fun::filter [my index] x { [$x name] eq ${name} }]
}

::ttext::analysis::Analyzer instproc to_tsquery {{-spec ""} searchQuery} {

    set query [::tlucene::parse_query $searchQuery]


    if { ${query} eq {} } {
	return
    }
    set words ""
    set stream ""
    foreach {item} ${query} {
	lassign $item name text
	set term ""
	if { $name ne {FTS} } {
	    set field [my getField $name]
	    if { $field ne {} } {
		set term [$field tsTerm $text]
	    } else {
		append term "${name}\#"
		append term [string map {{ } {_}} $text]
	    }
	    lappend stream $term
	    lappend stream [incr count -1]
	    lappend stream 0 ;# isset_p = 0
	} else {
	    lappend words [string map {{ } {_}} $text]
	}
    }
    if { $words ne {} } {
	set stream [concat $stream [[$spec tokenizer] tokenStream $words]]
    }
    return [string trim [my tsQuery $stream]]
}

::ttext::analysis::Analyzer instproc tsQuery {stream} {

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
### StandardTokenizer - Unaccent
###
Class ::ttext::analysis::StandardTokenizer -parameter {
    {unaccent "1"}
}

::ttext::analysis::StandardTokenizer instproc tokenStream {{-spec ""} text} {
    my instvar unaccent
    if { ${unaccent} } {
	set text [::ttext::unaccent utf-8 $text]
    }
    set stream [::tlucene::tokenize $text]
    return $stream
}



###
### Window Stream Tokenizer
###

Class ::ttext::analysis::WindowTokenizer -superclass {::ttext::analysis::StandardTokenizer} -parameter {
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

::ttext::analysis::WindowTokenizer instproc superColumn {{-spec ""} {-OID ""} {-weight ""} text} {
    set result ""
    set weight [::util::coalesce $weight [$spec weight] 0]
    set stream [my tokenStream -spec ${spec} ${text}]
    array set columns [list]
    foreach {token positions isset_p} ${stream} {
	lappend columns(${token}) [list $OID $positions $weight]
    }
    set superColumn [list [::util::coalesce [$spec qualifier] FTS] [array get columns]]
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
    return [lsort -dictionary -unique $result]
}

::ttext::analysis::DeweyTokenizer instproc tsVector {{-spec ""} ddc} {
    set stream [my tokenStream -spec ${spec} ${ddc}]
    return [join [::xo::fun::map token ${stream} { string map {{:} {#}} $token }]]
}





::ttext::analysis::StandardTokenizer ::ttext::analysis::tsStandardTokenizer
::ttext::analysis::WindowTokenizer ::ttext::analysis::tsWindowTokenizer
::ttext::analysis::DeweyTokenizer ::ttext::analysis::tsDeweyTokenizer


::ttext::analysis::Analyzer create ::ttext::analysis::tsBookAnalyzer \
    -index [list \
		[::ttext::analysis::Field tsBookAnalyzer.title -name title -weight A] \
		[::ttext::analysis::Field tsBookAnalyzer.author -name author -weight B] \
		[::ttext::analysis::Field tsBookAnalyzer.description -name description -weight C] \
		[::ttext::analysis::Field tsBookAnalyzer.publisher -name publisher -weight D] \
		[::ttext::analysis::FKey tsBookAnalyzer.subject -name subject -pool bookdb -qualifier "DDC" -tokenizer tsDeweyTokenizer -reference "::Book::Subject" -keyColumn "ddc" -valueColumn "name" -searchColumn "ts_vector"]]



::ttext::analysis::Field ::ttext::analysis::tsQueryField

# ::ttext::analysis::plain_to_tsquery "this is a test hello world blah blah world"
#
# => '(blah,hello|blah&hello)&(blah,test|blah&test)&(blah,world|blah&world)&(hello,test|hello&test)&(hello,world|hello&world)&(test,world|test&world)'::tsquery
#
# 
#
proc ::ttext::analysis::plain_to_tsquery {searchQuery {spec "::ttext::analysis::tsQueryField"} } {
    return [::ttext::analysis::tsBookAnalyzer to_tsquery -spec ${spec} ${searchQuery}]
}
