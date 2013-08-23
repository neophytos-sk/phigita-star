
proc ::feed_reader::generate_include_re {linksVar feed_url matching_pathsVar} {
    upvar $linksVar links
    upvar $matching_pathsVar matching_paths

    set domain [::util::domain_from_url ${feed_url}]

    array set url_shape [list]
    set max 0
    set max_path {}

    set paths [list]
    foreach link ${links} {

	set canonical_link \
	    [::uri::canonicalize \
		 [::uri::resolve \
		      ${feed_url} \
		      ${link}]]

	if { ${domain} ne [::util::domain_from_url ${canonical_link}] } {
	    continue
	}

	if { ![regexp -- {https?://[^/]+(/.+)$} ${canonical_link} _dummy_ path] } {
	    continue
	}

	# store it before it changes
	lappend paths ${path}

	foreach {re subSpec} {
	    {[[:lower:]]} {x}
	    {[[:upper:]]} {X}
	    {[0-9]} {d}
	    {d{4,}} {N\1}
	    {d{1,3}} {D\1}
	    {=x+(&|$)} {=y\1}
	    {=X+(&|$)} {=Y\1}
	    {=x[Xx]+(&|$)} {=w\1}
	    {=X[Xx]+(&|$)} {=W\1}
	    {x+} {P}
	    {X+} {Q}
	    {[Xx]+} {R}
	    {[^[:alpha:]\/?&=.\-]+} {o}
	    {([.?])} {\\\1}
	    {[PQR\-]{2,}} {T}
	    {(Po|oP|Qo|oQ|Ro|oR|oDo|oNo|oTo)+} {o}
	    {/[PQRT](/[PQRT])+} {/T}
	} {

	    regsub -all -- ${re} ${path} ${subSpec} path

	}

	#regsub -all -- {[[:alpha:]]+} ${path} {o} path
	#puts ${path}

	set count [incr url_shape(${path})]
	if { ${count} > ${max} && -1 != [string first {N} ${path}] } {
	    set max ${count}
	    set max_path ${path}
	}

	#puts "${canonical_link} ${path}"
	


    }

    set include_re ""
    set num_paths [llength ${paths}]
    if { ${max} } {

	# if more than ${coeff} of links are recognized by ${max_path}
	# then turn it into a regular expression

	#puts "url_shape=${max_path} count=${max}"

	set include_re ${max_path}

	foreach {re subSpec} {
	    {N}     {[0-9]{4,}}
	    {D}     {[0-9]{1,3}}
	    {y}     {[a-z]+}
	    {Y}     {[A-Z]+}
	    {w}     {[a-z][a-zA-Z]+}
	    {W}     {[A-Z][a-zA-Z]+}
	    {o}     {.*}
	    {P}     {([[:lower:]]+)}
	    {Q}     {([[:upper:]]+)}
	    {R}     {([[:alpha:]]+)}
	    {T}     {([[:alpha:]\-]+)}
	    {(\.\*)+} {.*}
	} {
	    regsub -all -- ${re} ${include_re} ${subSpec} include_re
	}

	append include_re {$}

	array set inline_parts [list]
	set max_count 0
	set max_inline_match [list]
	set second_best_inline_match [list]
	set matching_paths [list]
	foreach path ${paths} {

	    # lrange is there to ensure that we exclude whole match from inline parts
	    set inline_match0 [regexp -inline -- ${include_re} ${path}]
	    set inline_match [lrange ${inline_match0} 1 end]

	    if { ${inline_match0} ne {} } {
		
		lappend matching_paths ${path}

		set count [incr inline_parts(${inline_match})]

		if { ${count} > ${max_count} } {
		    if { ${max_inline_match} ne {} && ${inline_match} ne ${max_inline_match} } {
			set second_best_inline_match ${max_inline_match}
		    }
		    set max_count ${count}
		    set max_inline_match ${inline_match}
		}

	    }

	}

	if { ${max_count} } {

	    #puts "max_inline_match=$max_inline_match"
	    #puts "second_best_inline_match=$second_best_inline_match"

	    #set re {\(\[\[:[a-z]+:\]\]\+\)}
	    set re {\([^\)]+\)}
	    foreach inline_part ${max_inline_match} inline_part2 ${second_best_inline_match} {
		if { ${inline_part2} ne {} && ${inline_part} ne ${inline_part2} } {
		    set inline_part {[[:alnum:]\-]+}
		}
		# finds and substitutes first match
		regsub -- ${re} ${include_re} ${inline_part} include_re
	    }

	}
	#puts "---"
	puts include_re=${include_re}

    } else {

	puts "sorry, could not generate feed, could not figure out url_shape"

    }

    return ${include_re}
}


proc ::feed_reader::to_pretty_xpath {doc node} {

    set pn [${node} parentNode]
    set candidate_xpath ""
    append candidate_xpath "//[${pn} tagName]"
    if { [set id [${pn} @id ""]] ne {} } {

	append candidate_xpath "\[@id=\"${id}\"\]"

    } elseif { [set cls [${pn} @class ""]] ne {} } {

	append candidate_xpath "\[@class=\"${cls}\"\]"

    } else {

	append candidate_xpath "//[$pn tagName]"
	set xpath_list [list]
	foreach att [${pn} attributes] {
	    if { [set attvalue [${pn} getAttribute ${att} ""]] ne {} } {
		lappend xpath_list "@${att}=\"${attvalue}\""
	    }
	}
	if { ${xpath_list} ne {} } {
	    append candidate_xpath "\[[join ${xpath_list} { and }]\]"
	}

    }

    if { [set id [${node} @id ""]] ne {} } {

	set candidate_xpath "//[${node} tagName]\[@id=\"${id}\"\]"

    } elseif { [set cls [${node} @class ""]] ne {} } {

	append candidate_xpath "/[${node} tagName]\[@class=\"${cls}\"\]"

    } else {

	append candidate_xpath "/[${node} tagName]"

	set xpath_list [list]
	foreach att [${node} attributes] {
	    if { [set attvalue [${node} getAttribute ${att} ""]] ne {} } {
		lappend xpath_list "@${att}=\"${attvalue}\""
	    }
	}

	if { ${xpath_list} ne {} } {
	    append candidate_xpath "\[[join ${xpath_list} { and }]\]"
	}

    }

    if { ${candidate_xpath} ne {} } {

	#set candidate_xpath "returntext(${candidate_xpath})"

    } else {

	append candidate_xpath "/[${node} tagName]"

    }

    return ${candidate_xpath}

}



proc ::feed_reader::generate_xpath_helper {doc xpath_candidate xpathlist score_fn {xpathfunc ""}} {

    set quoted_score_fn [::util::doublequote ${score_fn}]

    set xpath_result ""
    foreach xpath_inner ${xpathlist} {

	set xpath_outer [subst -nocommands -nobackslashes {
	    similar_to_text(${xpath_candidate},
			    ${xpath_inner},
			    ${quoted_score_fn})
	}]

	set similarnode [${doc} selectNodes ${xpath_outer}]

	if { ${similarnode} ne {} } {
	    set xpath_result [to_pretty_xpath ${doc} ${similarnode}]
	    break
	}

    }
    
    if { ${xpath_result} ne {} && ${xpathfunc} ne {} } {
	set xpath_result "${xpathfunc}(${xpath_result})"
    }

    return ${xpath_result}

}


proc ::feed_reader::generate_xpath_article_title {doc} {

    set xpath_candidate {//div | //h1 | //h2 | //h3}

    set xpathlist {
	{returnstring(//title)}
	{string(//meta[@property="og:title"]/@content)}
	{string(//meta[@name="twitter:title"]/@content)}
	{string(//meta[@name="title"]/@content)}
    }

    set score_fn "tokenSimilarity"

    return [generate_xpath_helper ${doc} ${xpath_candidate} ${xpathlist} ${score_fn} "returnstring"]
}


proc ::feed_reader::generate_xpath_article_body {doc} {

    set xpath_candidate {//div}

    set xpathlist {
	{string(//meta[@property="og:description"]/@content)}
	{string(//meta[@name="twitter:description"]/@content)}
	{string(//meta[@name="description"]/@content)}
    }

    set score_fn "subseqSimilarity"

    set xpath_result [generate_xpath_helper ${doc} ${xpath_candidate} ${xpathlist} ${score_fn} "returntext"]

    if { ${xpath_result} eq {} } {
	# use other techniques to get the xpath
	# e.g. body text extraction
    }

    return ${xpath_result}

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

proc ::feed_reader::generate_xpath_article_image {doc} {

    set xpath_candidate {//img}

    set xpathlist {
	{string(//meta[@property="og:img"]/@content)}
	{string(//meta[@name="twitter:image"]/@content)}
    }

    set xpath_result ""
    foreach xpath ${xpathlist} {

	set imgsrc1 [${doc} selectNodes ${xpath}]
	if { ${imgsrc1} eq {} } {
	    continue
	}

	set imgnodes [${doc} selectNodes ${xpath_candidate}]
	foreach imgnode ${imgnodes} {
	    set imgsrc2 [${imgnode} @src]

	    #puts imgsrc1=${imgsrc1}
	    #puts imgsrc2=${imgsrc2}

	    set similarity [stringSimilarity ${imgsrc1} ${imgsrc2}]
	    if { ${similarity} > 0.85 } {
		${imgnode} removeAttribute alt
		${imgnode} removeAttribute src
		set xpath_result [to_pretty_xpath ${doc} ${imgnode}]
		break
	    }
	}

    }


    if { ${xpath_result} eq {} } {

	# use other techniques to get the xpath
	# choose the one with the most unsimilar src
	#

	set imgnodes [${doc} selectNodes {//div/img[contains(@src,"jpg")]}]
	set min_score "99999"
	set min_imgnode ""
	foreach imgnode1 ${imgnodes} {

	    set imgsrc1 [$imgnode1 @src]
	    set score "0.0"
	    foreach imgnode2 ${imgnodes} {
		if { ${imgnode1} eq ${imgnode2} } {
		    continue
		}
		set imgsrc2 [$imgnode2 @src]
		set score [expr { ${score} + [stringSimilarity $imgsrc1 $imgsrc2] }]
	    }

	    if { ${score} < ${min_score} } {
		set min_score ${score}
		set min_imgnode ${imgnode1}
	    }

	}
	if { ${min_imgnode} ne {} } {
	    foreach att {src alt title} {
		${min_imgnode} removeAttribute ${att}
	    }
	    set xpath_result [to_pretty_xpath ${doc} ${min_imgnode}]
	}
    }


    if { ${xpath_result} ne {} } {
	set xpath_result [list values(${xpath_result}/@src)]
    }

    return ${xpath_result}

}


proc ::feed_reader::generate_xpath_article_body_using_bte {doc} {

    bte bte_info ${doc}

    set maxnode $bte_info(maxnode)

    if { ${maxnode} eq {} } {
	puts "no maxnode"
	return
    }

    set candidate_xpath [to_pretty_xpath ${doc} ${maxnode}]


    set xpath [$maxnode toXPath]
    set text1 [${doc} selectNodes returntext(${xpath})]
    set text2 [${doc} selectNodes returntext(${candidate_xpath})]


    if { ${text1} ne ${text2} } {

	puts "-> text1 != text2"
	#puts $text1
	#puts ---
	#puts $text2

	set candidate_xpath ""

    }

    return returntext(${candidate_xpath})

    # puts "text2=$text2"

}

proc ::feed_reader::generate_xpath {xpathVar feed_url matching_pathsVar encoding} {

    upvar $xpathVar xpath
    upvar $matching_pathsVar matching_paths

    set parts [array names xpath]

    set sample_last 4
    set matching_paths [lrange ${matching_paths} 0 ${sample_last}]
    array set xpath_count [list]
    foreach part ${parts} {
	set max_count(${part}) 0
    }
    foreach path ${matching_paths} {

	set canonical_link \
	    [::uri::canonicalize \
		 [::uri::resolve \
		      ${feed_url} \
		      ${path}]]


	set errorcode [::xo::http::fetch html ${canonical_link}]
	if { ${errorcode} } {
	    return $errorcode
	}

	if { ${encoding} ne {} } {
	    set html [encoding convertfrom ${encoding} ${html}]
	}
	
	if { [catch { set doc [dom parse -html ${html}] } errmsg] } {
	    set html [::htmltidy::tidy ${html}]
	    set doc [dom parse -html ${html}]
	}

	puts ""
	puts canonical_link=${canonical_link}

	foreach part ${parts} {
	    set candidate_xpath [generate_xpath_${part} ${doc}]

	    puts "candidate xpath (${part}) = ${candidate_xpath}"

	    set count [incr xpath_count(${part},${candidate_xpath})]

	    if { ${count} > $max_count(${part}) } {

		set xpath(${part}) ${candidate_xpath}
		set max_count(${part}) ${count}

	    }
	}

	${doc} delete

    }

}


proc ::feed_reader::generate_feed {feed_url {encoding "utf-8"}} {

    set errorcode [::xo::http::fetch html $feed_url]
    if { ${errorcode} } {
	return $errorcode
    }

    if { ${encoding} ne {} } {
	set html [encoding convertfrom ${encoding} ${html}]
    }

    if { [catch { set doc [dom parse -html ${html}] } errmsg] } {
	set html [::htmltidy::tidy ${html}]
	set doc [dom parse -html ${html}]
    }


    set links [${doc} selectNodes {values(//a[@href]/@href)}]
    $doc delete

    # generate include_re

    set matching_paths [list]
    set include_re [generate_include_re links ${feed_url} matching_paths]
    if { ${include_re} eq {} } {
	puts "sorry, got nothing to show for it"
	return
    }

    ########### fetch article

    array set xpath \
	[list \
	     article_title "" \
	     article_body  "" \
	     article_image ""]

    if { ${include_re} ne {} } {
	generate_xpath xpath ${feed_url} matching_paths $encoding
    }


    array set feed \
	[list \
	     url ${feed_url} \
	     include_re ${include_re} \
	     xpath_article_title $xpath(article_title) \
	     xpath_article_body $xpath(article_body) \
	     xpath_article_image $xpath(article_image)]
    
    puts [string repeat - 80]
    puts ""
    foreach {key value} [array get feed] {
	puts [list ${key} ${value}]
    }
    puts ""
    puts ""
 

}


proc ::feed_reader::bte_helper {resultVar node} {

    upvar $resultVar result


    if { ${node} eq {} || [${node} nodeType] ne {ELEMENT_NODE} } {
	return 0
    }

    set langclass [::ttext::langclass [$node text]]
    set value 0
    if { [llength ${langclass}]==1 && [lindex ${langclass} 0] in {el.utf8 en.utf8} } {
	set value 1
    }

    set total_value ${value}
    set childnodes [${node} childNodes]
    foreach child ${childnodes} {
	incr total_value [bte_helper result ${child}]
    }

    if { ${total_value} > $result(maxlen) && [${node} tagName] in {div p span} } {
	set result(maxlen) ${total_value}
	set result(maxnode) ${node}
    }

    return ${value}

}

# body text extraction
proc ::feed_reader::bte {resultVar doc} {

    upvar $resultVar result

    foreach cleanup_xpath {
	{//script}
	{//style}
    } {
	foreach cleanup_node [${doc} selectNodes ${cleanup_xpath}] {
	    ${cleanup_node} delete
	}
    }

    set result(maxlen) 0
    set result(maxnode) {}
    return [bte_helper result [${doc} selectNodes {//body[1]}]]

}


