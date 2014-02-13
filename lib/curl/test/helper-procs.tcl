source ../../naviserver_compat/tcl/module-naviserver_compat.tcl


::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs


proc exec_xpath {resultVar doc xpath} {
    upvar $resultVar result
    set result [$doc selectNodes ${xpath}]
}

proc tokenize {text} {
    return [lsearch -inline -all -not [split [string tolower [regsub -all {([^[:alnum:] ]+)} $text { \1 }]] " "] {}]
}

proc tokenize_pretty {text} {
    return [lsearch -inline -all -not [split [regsub -all {([^[:alnum:] ]+)} $text " \x01\\1\x02 "] " "] {}]
}


proc remove_special_chars {text} {
    set re "( \x01|\x02 |\x01|\x02)"
    return [regsub -all $re $text {}]
}

proc highlight_minWin {max_text max_keywords} {

    set max_text_tokens [tokenize $max_text]
    set max_text_tokens_pretty [tokenize_pretty $max_text]

    set minWin [minWindow $max_text_tokens $max_keywords list_of_boundaries]
    
    set highlight_text ""
    foreach boundaries $list_of_boundaries {
        # "boundaries=\[[join $boundaries ","]\] \n"
        append highlight_text "\n-~-~-~-\n" [remove_special_chars [highlight $max_text_tokens_pretty $boundaries]]
    }

    # comment-in to debug result
    # append highlight_text "\n\n" "$max_text"

    return $highlight_text

}

# relies on tokenize to maintain empty tokens
proc highlight {max_text_tokens boundaries} {


    lassign $boundaries minPos maxPos

    set minContextPos 0
    set maxContextPos end

    set beforeTokens [lrange $max_text_tokens $minContextPos [expr {$minPos - 1}]]
    set highlightTokens [lrange $max_text_tokens $minPos $maxPos]
    set afterTokens [lrange $max_text_tokens [expr {$maxPos + 1}] $maxContextPos]

    set statementStartPos [lindex [lsearch -all -regexp $beforeTokens {;\s*\n}] end]
    if { $statementStartPos != -1 } {
        set beforeTokens [lrange $beforeTokens [expr { $statementStartPos + 1 }] end]
    }

    set statementEndPos [lsearch -regexp $afterTokens {;\s*\n}]
    if { $statementEndPos != -1 } {
        set afterTokens [lrange $afterTokens 0 $statementEndPos]
    }

    return [join [concat $beforeTokens ">>>" $highlightTokens "<<<" $afterTokens]]

}

proc intersect3_alnum {list1 list2} {
    set la1(0) {} ; unset la1(0)
    set lai(0) {} ; unset lai(0)
    set la2(0) {} ; unset la2(0)

    set re {^[[:alnum:]]+$}

    foreach v $list1 {
        if { ![regexp -- $re $v] } continue
        set la1($v) {}
    }

    foreach v $list2 {
        if { ![regexp -- $re $v] } continue
        set la2($v) {}
    }

    foreach elem [concat $list1 $list2] {
        if {[info exists la1($elem)] && [info exists la2($elem)]} {
            unset la1($elem)
            unset la2($elem)
            set lai($elem) {}
        }
    }
    list [lsort [array names la1]] [lsort [array names lai]] \
         [lsort [array names la2]]
}


proc tokenSimilarity {tokens_text1 tokens_text2 resultVar} {

    upvar $resultVar result

    lassign [intersect3_alnum ${tokens_text1} ${tokens_text2}] t1 common t2

    set result ${common}
    set score [llength ${common}]
    
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

proc filter_tokens {tokens_in_order keep_tokens} {
    array set keep [list]
    foreach token $keep_tokens {
        set keep($token) 1
    }

    array set seen [list]
    set result [list]
    foreach token $tokens_in_order {
        if { [info exists keep($token)] && ![info exists seen($token)] } {
            set seen($token) 1
            lappend result $token
        }
    }
    return $result
}

proc to_xpath {node} {
    
    set default_xpath [$node toXPath]
    set relative_xpath [lindex [split $default_xpath {/}] end]
    set pn [$node parentNode]

    set suffix "/${relative_xpath}"
    set curr $pn
    while { $curr ne {} } {
        #set id [$curr @id ""]
        set cls [$curr @class ""]
        set elementTag [$curr nodeName]
        if { $cls ne {} } {
            return "$elementTag\[@class=\"${cls}\"\]${suffix}"
        }
        set suffix "${suffix}/${elementTag}"
        set curr [$curr parentNode]
    }
    return $default_xpath
}

proc find_data_fragment {url highlight_textVar {numContextTokens 20}} {

    upvar $highlight_textVar highlight_text

    set options(followlocation) 1
    set options(maxredirs) 5

    set dir [file dirname [info script]]
    set options(cookiefile) [file join ${dir} "cookies.txt"]

    set errorcode [::xo::http::fetch html $url options info]

    puts "--->>> errorcode=$errorcode"

    set doc [dom parse -html $html]

    exec_xpath page_title $doc {string(//title)}
    exec_xpath og_title $doc {string(//meta[@property='og:title'])}
    exec_xpath og_description $doc {string(//meta[@property='og:description'])}

    set title [lsearch -inline -not [list $og_title $page_title] {}]
    set tokens_title [tokenize $title]

    puts "--->>> title=$title"

    set max_node [list]
    set max_text [list]
    set max_similarity 0
    set nodes [$doc selectNodes {//script[not(@src)]}]
    foreach node $nodes {
        set text [$node text]

        set tokens_text [tokenize $text]
        # puts tokens_text=$tokens_text

        set similarity [tokenSimilarity $tokens_title $tokens_text common] 
        if { $similarity > $max_similarity } {
            set max_node $node
            set max_similarity $similarity
            set max_text [list $text]
            set max_keywords [filter_tokens $tokens_title $common]
            # puts "--->>> max_keywords=$max_keywords"
        } elseif { $similarity && $similarity == $max_similarity } {
            lappend max_node $node
            lappend max_text $text
        }
    }

    set highlight_text [list]
    set xpath [list]
    foreach node $max_node text $max_text {
        lappend xpath [to_xpath $node]
        lappend highlight_text [highlight_minWin $text $max_keywords]
    }

    $doc delete

    # puts [array get info]
    # puts errorcode=$errorcode
    # puts $options(cookiefile) 

    return $xpath

}

# @param tokens
# @param keywords
# @param n number of words in the text
# @param m number of keywords
# @param boundariesVar int[] 
# @returns minWin
#
# P[j] is the position of the jth keyword in a given window [i,n) where 0<=i<n
proc minWindow {tokens keywords boundariesVar} {

    set n [llength $tokens]
    set m [llength $keywords]

    set index 0
    foreach w $tokens {
        set a($index) $w
        incr index
    }
    set index 0
    foreach w $keywords {
        set b($index) $w
        incr index
    }

    upvar $boundariesVar boundaries
    set boundaries [list]

    set minPos [expr {$n + 1}]
    set maxPos [expr {$n + 1}]
    array set P [list]
    set nfound 0
    set minWin -1

    for {set j 0} { $j < $m } {incr j} {
        set P($j) -1
    }


    for {set i 0} {$i < $n} {incr i} {
        set nfound 0
        set minPos [expr { $n + 1 }]
        set maxPos -1
        for {set j 0} {$j < $m} {incr j} {
            for { set k [max $i $P($j)] } {$k < $n} {incr k} {
                if { $a($k) == $b($j) } {
                    # puts "$a($k) == $b($j)"
                    set P($j) $k
                    incr nfound
                    set minPos [min $minPos $k]
                    set maxPos [max $maxPos $k]
                    break
                }
            }
        }
        if { $nfound < $m } {
            # puts "--->>> nfound=$nfound m=$m"
            return $minWin
        }

        set win [expr { $maxPos - $minPos + 1 }]

        # for the first minimum window
        #
        # if { $minWin == -1 || $win < $minWin } {
            # set boundaries [list $minPos $maxPos]
            # set minWin $win
        # }

        # for all equal minimum windows
        if { $minWin == -1 || $win < $minWin } {
            set boundaries [list [list $minPos $maxPos]]
            set minWin $win
        } elseif { $win == $minWin } {
            lappend boundaries [list $minPos $maxPos]
        }

        set i $minPos

    }
    return $minWin
}

