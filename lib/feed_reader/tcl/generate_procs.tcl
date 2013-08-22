
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


proc ::feed_reader::generate_xpath_for_node {doc node} {

    set xpath [$node toXPath]
    #puts "xpath=$xpath path=${path}"
    set text1 [${doc} selectNodes returntext(${xpath})]
    #puts [${node} asHTML]

    set pn [${node} parentNode]
    set candidate_xpath ""
    append candidate_xpath "//[${pn} tagName]"
    if { [set id [${pn} @id ""]] ne {} } {

	append candidate_xpath "\[@id=\"${id}\"\]"

    } elseif { [set cls [${pn} @class ""]] ne {} } {

	append candidate_xpath "\[@class=\"${cls}\"\]"

    }

    if { [set id [${node} @id ""]] ne {} } {

	append candidate_xpath "/[${node} tagName]\[@id=\"${id}\"\]"

    } elseif { [set cls [${node} @class ""]] ne {} } {

	append candidate_xpath "/[${node} tagName]\[@class=\"${cls}\"\]"

    } else {

	set candidate_xpath "//[$pn tagName]"
	foreach att [${pn} attributes] {
	    set xpath_list [list]
	    if { [set attvalue [${pn} getAttribute ${att} ""]] ne {} } {
		lappend xpath_list "@${att}=\"${attvalue}\""
	    }
	}
	if { ${xpath_list} ne {} } {
	    append candidate_xpath "\[[join ${xpath_list} { and }]\]"
	}
	append candidate_xpath "/[${node} tagName]"
	foreach att [${node} attributes] {
	    set xpath_list [list]
	    if { [set attvalue [${node} getAttribute ${att} ""]] ne {} } {
		lappend xpath_list "@${att}=\"${attvalue}\""
	    }
	}
	if { ${xpath_list} ne {} } {
	    append candidate_xpath "\[[join ${xpath_list} { and }]\]"
	}

    }

    if { ${candidate_xpath} ne {} } {

	set candidate_xpath "returntext(${candidate_xpath})"

    } else {

	append candidate_xpath "/[${node} tagName]"

    }

    puts "candidate xpath = ${candidate_xpath}"


    set text2 [${doc} selectNodes ${candidate_xpath}]

    if { ${text1} ne ${text2} } {

	puts "-> text1 != text2"
	#puts $text1
	#puts ---
	#puts $text2

	set candidate_xpath ""

    }

    return ${candidate_xpath}

    # puts "text2=$text2"
}

proc ::feed_reader::generate_xpath_article_body {feed_url matching_pathsVar encoding} {

    upvar $matching_pathsVar matching_paths

    set xpath_article_body ""

    set matching_paths [lrange ${matching_paths} 0 4]
    array set xpath_count [list]
    set max_count 0
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

	bte bte_info ${doc}

	set maxnode $bte_info(maxnode)

	if { ${maxnode} eq {} } {
	    puts "no maxnode"
	    continue
	}

	set candidate_xpath [generate_xpath_for_node ${doc} ${maxnode}]

	set count [incr xpath_count(${candidate_xpath})]

	if { ${count} > ${max_count} } {

	    set xpath_article_body ${candidate_xpath}
	    set max_count ${count}

	}

	${doc} delete

    }

    return ${xpath_article_body}

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

    # generate xpath_article_body

    ########### fetch article

    set xpath_article_body ""
    if { ${include_re} ne {} } {
	set xpath_article_body [generate_xpath_article_body ${feed_url} matching_paths $encoding]
    }


    array set feed \
	[list \
	     url ${feed_url} \
	     include_re ${include_re} \
	     xpath_article_body ${xpath_article_body}]
    
    puts ""
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
	{//head}
	{//script}
	{//style}
	{//link}
    } {
	foreach cleanup_node [${doc} selectNodes ${cleanup_xpath}] {
	    ${cleanup_node} delete
	}
    }

    set result(maxlen) 0
    set result(maxnode) {}
    return [bte_helper result [${doc} selectNodes {//body[1]}]]

}


