
proc ::feed_reader::log {msg} {
    puts $msg
}

proc ::feed_reader::generate_url_fmt {anchor_nodesVar feed_url matching_pairsVar} {
    upvar $anchor_nodesVar anchor_nodes
    upvar $matching_pairsVar matching_pairs

    #puts feed_url=$feed_url

    set feed_url [url normalize ${feed_url}]
    set domain [::util::domain_from_url ${feed_url}]
    
    array set url_shape [list]
    set max 0
    set max_path {}

    array set count_matched [list]
    array set sample_matched [list]
    array set intersection_url [list]

    set first_node [lindex $anchor_nodes 0]
    set href [$first_node @href ""]
    set title [$first_node @title [$first_node text]]

    set canonical_url [url normalize [url resolve $feed_url $href]]
    set fmt [url fmt_ex $canonical_url]
    set queue [list]
    lappend queue $fmt


    set count_matched($fmt) 0
    set intersection_url($fmt) $href
    set sample_matched($fmt) [list $title $canonical_url]

    while { $queue ne {} } {
        set fmt [lindex $queue 0]
        set queue [lreplace $queue 0 0]

        foreach anchor_node $anchor_nodes {
            set href [$anchor_node @href ""]
            set title [$anchor_node @title [$anchor_node text]]

            if { [string match -nocase "javascript:*" $href] } {
                continue
            }

            set canonical_url [url normalize [url resolve $feed_url $href]]

            if { ![url match $fmt $canonical_url] } {
                set new_fmt [url fmt_ex $canonical_url]
                if { ![info exists count_matched($new_fmt)] } {
                    lappend queue $new_fmt
                    set count_matched($new_fmt) 0
                    set intersection_url($new_fmt) $canonical_url
                    set sample_matched($new_fmt) [list $title $canonical_url]
                }

                #puts "match failed: $canonical_url"
                #exit
            } else {
                incr count_matched($fmt)
                set intersection_url($fmt) [url intersect $intersection_url($fmt) $canonical_url]
            }

        }
        #puts $queue
        
    }

    foreach fmt [array names intersection_url] {
        set intersection_url($fmt) [url fmt_sp $fmt $intersection_url($fmt)]
    }

    puts [join [map {x y} [array get count_matched] {list $x $y}] "\n"]
    puts -----
    puts [join [map {x y} [array get intersection_url] {set y}] "\n"]
    #puts [array get intersection_url]

    set sorted [lsort -decreasing -integer -index 1 [map {x y} [array get count_matched] {list $x $y}]] 
    set chosen_url_fmt [lindex [lindex $sorted 0] 0]
    set chosen_intersection_url_fmt $intersection_url($chosen_url_fmt)

    puts ""
    puts "Top 5 URL shapes"
    puts "================"
    set top5_url_shapes [lrange $sorted 0 4]
    foreach shape $top5_url_shapes {
        lassign $shape fmt count
        lassign $sample_matched($fmt) title link

        puts "$intersection_url($fmt) count=$count log=[expr { log($count) }]"
        puts $title
        puts $link
        puts ""
    }
    puts ""

    return $chosen_intersection_url_fmt

}

proc ::feed_reader::to_pretty_xpath_cleanup_helper {args} {

    # rationalize id on given and parent node
    foreach node ${args} {
	foreach att {id class} {

	    if { [${node} hasAttribute ${att}] } {

		set attvalue [${node} getAttribute ${att} ""]

		set re {[0-9]{4,}}
		if { [regexp -- ${re} ${attvalue}] } {
		    ${node} removeAttribute ${att}
		}
	    }

	}
    }
}

proc ::feed_reader::to_pretty_xpath {doc node} {

    set ignore_attributes {href src alt title}

    set pn [${node} parentNode]

    to_pretty_xpath_cleanup_helper ${node} [${node} parentNode]

    set candidate_xpath ""
    if { [set id [${pn} @id ""]] ne {} } {

        set candidate_xpath "//[${pn} tagName]"
        append candidate_xpath "\[@id=\"${id}\"\]"

    } elseif { [set cls [${pn} @class ""]] ne {} } {

        set candidate_xpath "//[${pn} tagName]"
        append candidate_xpath "\[@class=\"${cls}\"\]"

    } else {

        set candidate_xpath "//[$pn tagName]"
        set xpath_list [list]
        foreach att [${pn} attributes] {
            if { ${att} in ${ignore_attributes} } {
            continue
            }
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
            if { ${att} in ${ignore_attributes} } {
                continue
            }
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



proc ::feed_reader::generate_xpath_helper {doc xpath_candidate xpathlist score_fn {xpathfunc ""} {tokenizer ""}} {

    set xpath_result ""
    foreach xpath_inner ${xpathlist} {

        set xpath_outer [subst -nobackslashes {
            similar_to_text(${xpath_candidate},
            ${xpath_inner},
            [::util::doublequote ${score_fn}],
            [::util::doublequote ${tokenizer}])
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
        {string(//title_from_feed)}
    }

    set score_fn "tokenSimilarity"

    return [generate_xpath_helper ${doc} ${xpath_candidate} ${xpathlist} ${score_fn} "returnstring"]
}


# Google's example of how to mark up your timestamps using microdata is:
# <time itemprop="startDate" datetime="2009-10-15T19:00-08:00">
# https://support.google.com/webmasters/answer/176035

proc ::feed_reader::generate_xpath_article_date {doc} {

    set xpath_candidate {//div | //span | //p}

    set xpathlist {
        {string(//meta[@property="article:published_time"]/@content)}
        {string(//meta[@name="dc.date.created"]/@content)}
        {string(//meta[@name="date"]/@content)}
        {string(//meta[@name="dc.date"]/@content)}
        {currentdate()}
    }

    set score_fn "subseqSimilarity"

    set tokenizer "::util::tokenize_date"

    set xpath_result [generate_xpath_helper ${doc} ${xpath_candidate} ${xpathlist} ${score_fn} "" ${tokenizer}]

    # verify date xpath, figure out format, 
    # and rewrite xpath_result accordingly

    set text [${doc} selectNodes "string(${xpath_result})"]

    set recognizer_result [::util::recognize_date_format ${text}]

    if { ${recognizer_result} ne {} } { 

        lassign ${recognizer_result} format locale timeval
        set xpath_result \
            [subst -nobackslashes \
            {normalizedate(${xpath_result}, [::util::doublequote ${locale}],[::util::doublequote ${format}])}]

    } else {

        set xpath_result {}

    }

    return ${xpath_result}
}


proc ::feed_reader::generate_xpath_article_modified_time {doc} {

    set xpath_candidate {//div | //span | //p}

    set xpathlist {
	{string(//meta[@property="article:modified_time"]/@content)}
	{string(//meta[@name="dc.date.modified"]/@content)}
	{currentdate()}
    }

    set score_fn "tokenSimilarity"
    set tokenizer "::util::tokenize_date"

    set xpath_result [generate_xpath_helper ${doc} ${xpath_candidate} ${xpathlist} ${score_fn} "returnstring" ${tokenizer}]

    # verify date xpath, figure out format, 
    # and rewrite xpath_result accordingly

    set text [${doc} selectNodes "string(${xpath_result})"]

    set recognizer_result [::util::recognize_date_format ${text}]

    if { ${recognizer_result} ne {} } { 

	lassign ${recognizer_result} format locale timeval
	set xpath_result \
	    [subst -nobackslashes \
		 {normalizedate(${xpath_result}, [::util::doublequote ${locale}],[::util::doublequote ${format}])}]

    } else {

	set xpath_result {}

    }

    return ${xpath_result}
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

		set xpath_result [to_pretty_xpath ${doc} ${imgnode}]
		break
	    }
	}

    }


    if { ${xpath_result} eq {} } {

	# use other techniques to get the xpath
	# choose the one with the most unsimilar src
	#

	set imgnodes [${doc} selectNodes {//div/img[contains(@src,"jpg")] | //div/a/img[contains(@src,"jpg")]}]
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

proc ::feed_reader::generate_xpath {feedVar xpathVar matching_pairsVar encoding} {

    upvar $feedVar feed
    upvar $xpathVar xpath
    upvar $matching_pairsVar matching_pairs

    set parts [array names xpath]

    set sample_last 4
    set matching_pairs [lrange ${matching_pairs} 0 ${sample_last}]
    array set xpath_count [list]

    foreach part ${parts} {
        set max_count(${part}) 0
    }

    foreach title_path_pair $matching_pairs {
        lassign $title_path_pair title_from_feed path

        set canonical_url [url normalize [url resolve $feed(url) $path]]

        set errorcode [web cache_fetch html ${canonical_link}]
        if { ${errorcode} } {
            return $errorcode
        }

        if { ${encoding} ne {} } {
            set html [encoding convertfrom ${encoding} ${html}]
        }

        if { [catch { set doc [dom parse -html ${html}] } errmsg] } {
            set feed(htmltidy_article_p) 1
            set html [::htmltidy::tidy ${html}]
            set doc [dom parse -html ${html}]
        }

        # adds a element node of the form <title_from_feed>blah blah</title_from_feed>
        $doc appendFromList [list title_from_feed {} [list [list {#text} $title_from_feed]]]

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

        if { $xpath(article_title) eq {//title_from_feed} } {
            set feed(keep_title_from_feed) 1
        }

        ${doc} delete

    }

}


proc ::feed_reader::generate_feed {args} {

    getopt::init {
        {exclude_inurl "" {__arg_exclude_inurl exclude_strings}}
        {include_inurl "" {__arg_include_inurl include_strings}}
        {phase   "" {__arg_phase phase}}
        {encoding "" {__arg_encoding encoding}}
        feed_url
    }
    getopt::getopt $args

    # defaults
    set_if exclude_strings ""
    set_if include_strings ""
    set_if encoding utf-8


    array set feed  \
        [list \
            url $feed_url \
            encoding $encoding \
            url_fmt "" \
            include_inurl $include_strings \
            exclude_inurl $exclude_strings \
            include_re "" \
            exclude_re "" \
            htmltidy_feed_p 0 \
            htmltidy_article_p 0]



    if { [set errorcode [web cache_fetch html $feed_url options info]] } {
        return $errorcode
    }

    if { ${encoding} ne {} } {
        set html [encoding convertfrom ${encoding} ${html}]
    }

    if { [catch { set doc [dom parse -html ${html}] } errmsg] } {
        set feed(htmltidy_feed_p) 1
        set html [::htmltidy::tidy ${html}]
        set doc [dom parse -html ${html}]
    }

    set anchor_nodes [${doc} selectNodes {//a[@href]}]

    set result [list]
    foreach node $anchor_nodes {
        set href [$node @href ""]

        if { $href eq {} } {
            continue
        }

        if { [string match -nocase "javascript:*" $href] } {
            continue
        }

        if { $exclude_strings ne {} } {
            set skip_p 0
            foreach str $exclude_strings {
                if { -1 != [string first $str $href] } {
                    set skip_p 1
                    break
                }
            }
            if { $skip_p } {
                continue
            }
        }

        if { $include_strings ne {} } {
            set skip_p 0
            foreach str $include_strings {
                if { -1 == [string first $str $href] } {
                    set skip_p 1
                    break
                }
            }
            if { $skip_p } {
                continue
            }
        }

        set canonical_url [url normalize [url resolve $feed_url $href]]

        set domain [::util::domain_from_url ${feed_url}]
        if { ${domain} ne [::util::domain_from_url ${canonical_url}] } {
            continue
        }

        lappend result $node

    }
    set anchor_nodes $result


    set num_links [llength $anchor_nodes]
    puts "#links = $num_links"

    if { $num_links == 0 } {
        error "no anchor links found: \
            \n\tresponsecode=$info(responsecode) \
            \n\t[join [map {x y} [array get info] {list $x $y}] \n\t]"
    }

    foreach node $anchor_nodes {
        puts [$node asText]
        puts [$node @href ""]
        puts ""
    }

    # generate url_fmt

    set matching_pairs [list]
    set feed(url_fmt) [generate_url_fmt anchor_nodes $feed_url matching_pairs]

    if { $feed(url_fmt) eq {} } {
        puts "sorry, got nothing to show for it"
        return
    }

    $doc delete

    ########### fetch article

    array set xpath \
        [list \
            article_title "" \
            article_body  "" \
            article_image "" \
            article_date  "" \
            article_modified_time ""]


    if { $feed(include_re) ne {} } {
        # note that the feed url is stored in feed(url)
        generate_xpath feed xpath matching_pairs $encoding
    }


    foreach name [array names xpath] {
        set feed(xpath_${name}) $xpath(${name})
    }

    puts [string repeat - 80]
    puts ""
    set ordered_names [get_feed_ordered_names feed]
    foreach name ${ordered_names} {
        puts [list ${name} $feed(${name})]
    }
    puts ""
    puts ""


}


proc ::feed_reader::compare_feed_element {name1 name2} {

    set ordered_names {
	url 
	include_re 
	htmltidy_feed_p 
	htmltidy_article_p
	xpath_article_title 
	xpath_article_body 
	xpath_article_image
	xpath_article_date
	xpath_article_modified_time
    }

    set i1 [lsearch ${ordered_names} ${name1}]
    set i2 [lsearch ${ordered_names} ${name2}]

    return [expr { ${i1} < ${i2} ? -1 : ( ${i1} > ${i2} ? 1 : 0 ) }]
}

proc ::feed_reader::get_feed_ordered_names {feedVar} {
    upvar $feedVar feed
    set names [lsort -command compare_feed_element [array names feed]]
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


