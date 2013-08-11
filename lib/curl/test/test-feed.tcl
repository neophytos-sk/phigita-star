source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri

set feeds [dict create \
	       philenews {
		   url http://www.philenews.com/
		   include_re {/el-gr/.+/[0-9]+/[0-9]+/}
	       } \
	       sigmalive {
		   url http://www.sigmalive.com/
		   include_re {/[0-9]+}
		   exclude_re {/inbusiness/}
		   keep_title_from_feed_p 0
		   xpath_article_title {//h2[@class="cat_article_title"]/a}
		   xpath_article_body {//div[@id="article_content"]}
		   xpath_article_image {
		       {//div[@id="article_content"]/img}
		       {//div[@id="article_content"]//img[@class="pyro-image"]}
		   }
		   xpath_article_cleanup {//div[@class="soSialIcons"]}
	       } \
	       paideia-news {
		   url http://www.paideia-news.com/
		   include_re {id=[0-9]+&hid=[0-9]+}
		   htmltidy_article_p 1
		   xpath_article_title {//div[@class="main_resource_title_single"]}
		   xpath_article_author {//div[@class="main_resource_summ2"]/p/strong/span}
		   xpath_article_body {//div[@class="main_resource_summ2"]}
		   xpath_article_image {values(//div[@class="main_resource_img_single"]/img)}
	       }]


#array set feed [dict get $feeds philenews]
array set feed [dict get $feeds sigmalive]
#array set feed [dict get $feeds paideia-news]

proc compare_href_attr {n1 n2} {
    return [string compare [${n1} @href ""] [${n2} @href ""]]
}

proc filter_title {stoptitlesVar title} {
    upvar $stoptitlesVar stoptitles

    if { [info exists stoptitles(${title})] } {
	return ""
    } else {
	return ${title}
    }
}

#TODO: trim non-greek and non-latin letters from beginning and end of title
proc trim_title {title} {
    #set re {^[^0-9a-z\u0370-\03FF]*}
    #return [regexp -inline -- ${re} ${title}]
    return [string trim ${title} " -\t\n\r"]
}


proc get_title_old {node} {

    # returns all text node children of that current node combined
    set t0 [filter_title stoptitles [trim_title [${node} text]]]

    # for ELEMENT_NODEs, outputs the string-value of every text node 
    # descendant of node in document order without any escaping
    set t1 [filter_title stoptitles [trim_title [${node} asText]]]

    # title attribute of the current node
    set t2 [filter_title stoptitles [trim_title [${node} @title ""]]]

    set list_of_titles [list ${t0} ${t1} ${t2}]
    set title [lsearch -inline -not ${list_of_titles} {}]

    return ${title}

}

proc get_title {stoptitlesVar node} {
    upvar $stoptitlesVar stoptitles

    set nodeType [${node} nodeType]

    if { ${nodeType} eq {ELEMENT_NODE} } {

	# returns all text node children of that current node combined
	set title [filter_title stoptitles [trim_title [${node} text]]]

	if { ${title} ne {} } {
	    return ${title}
	}

	foreach child [${node} childNodes] {
	    set title [get_title stoptitles ${child}]
	    if { ${title} ne {} } {
		return ${title}
	    }
	}

    } elseif { ${nodeType} eq {TEXT_NODE} } {

	return [filter_title stoptitles [trim_title [${node} nodeValue]]]

    }

}

proc ::util::domain_from_url {url} {

    set index [string first {:} ${url}]
    if { ${index} == -1 } {
	return
    }

    set scheme [string range ${url} 0 ${index}]
    if { ${scheme} ne {http:} && ${scheme} ne {https:} } {
	return
    }

    array set uri_parts [::uri::split ${url}]
    return $uri_parts(host)
}


proc get_feed_items {resultVar feedVar {stoptitlesVar ""}} {
    upvar $resultVar result
    upvar $feedVar feed
    upvar $stoptitlesVar stoptitles

    set url         $feed(url)
    set include_re  $feed(include_re)
    set exclude_re  $feed(exclude_re)

    if { [info exists feed(domain)] } {
	set domain $feed(domain)
    } else {
	set domain [::util::domain_from_url ${url}]
    }

    set xpath {//a[@href]}
    if { [info exists feed(xpath)] } {
	set xpath $feed(xpath)
    }

    set encoding {utf-8}
    if { [info exists feed(encoding)] } {
	set encoding $feed(encoding)
    }

    ::xo::http::fetch html $url
    
    set html [encoding convertfrom ${encoding} ${html}]

    set doc [dom parse -html ${html}]
    set nodes [$doc selectNodes ${xpath}]

    set nodes2 [list]
    array set title_for_href [list]
    foreach node $nodes {

	# turn relative urls into absolute urls and canonicalize	
	set href [::uri::canonicalize [::uri::resolve ${url} [${node} @href ""]]]

	# drop urls from other domains
	if { [::util::domain_from_url ${href}] ne ${domain} } {
	    continue
	}

	# drop links that do not match regular expression
	if { ![regexp -- ${include_re} ${href}] || [regexp -- ${exclude_re} ${href}] } {
	    continue
	}

	${node} setAttribute href ${href}
	
	set title [get_title stoptitles ${node}]

	if { ![info exists title_for_href(${href})] } {
	    # coalesce title candidate values
	    set title_for_href(${href}) ${title}
	} else {
	    set title_for_href(${href}) [lsearch -inline -not [list ${title} $title_for_href(${href})] {}]
	}


	lappend nodes2 ${node}

    }

    # remove duplicates
    set nodes3 [lsort -unique -command compare_href_attr ${nodes2}]

    array set result [list links "" titles ""]
    foreach node ${nodes3} {

	set href [${node} @href]
	lappend result(links)  ${href}
	lappend result(titles) $title_for_href(${href})

    }

    # cleanup
    $doc delete
}

array set stoptitles [list]
foreach title [split [::util::readfile stoptitles.txt] "\n"] {
    set stoptitles(${title}) 1
}

get_feed_items result feed stoptitles

foreach link $result(links) title_in_feed $result(titles) {
    puts ${title_in_feed}
    puts ${link}
    puts "---"


    set encoding [::util::var::get_value_if feed(encoding) utf-8]

    set htmltidy_article_p [::util::var::get_value_if \
				feed(htmltidy_article_p) \
				0]

    set keep_title_from_feed_p [::util::var::get_value_if \
				    feed(keep_title_from_feed_p) \
				    0]

    set xpath_article_title [::util::var::get_value_if \
				 feed(xpath_article_title) \
				 {//title}]

    set xpath_article_body [::util::var::get_value_if \
				feed(xpath_article_body) \
				{}]

    set xpath_article_cleanup [::util::var::get_value_if \
				   feed(xpath_article_cleanup) \
				   {}]

    set xpath_article_author [::util::var::get_value_if \
				  feed(xpath_article_author) \
				  {}]

    set xpath_article_image [::util::var::get_value_if \
				 feed(xpath_article_image) \
				 {}]


    set html ""
    ::xo::http::fetch html ${link}

    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_article_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    set doc [dom parse -html ${html}]

    set title_node [${doc} selectNodes ${xpath_article_title}]
    set title_in_article [string trim [${title_node} text]]
    ${title_node} delete

    set author_in_article ""
    if { ${xpath_article_author} ne {} } {
	set author_node [${doc} selectNodes ${xpath_article_author}]
	set author_in_article [string trim [${author_node} text]]
	${author_node} delete
    }

    if { ${keep_title_from_feed_p} || ${title_in_article} eq {} } {
	set article_title ${title_in_feed}
    } else {
	set article_title ${title_in_article}
    }

    set article_image [list]
    if { ${xpath_article_image} ne {} } {
	foreach image_xpath ${xpath_article_image} {
	    foreach image_node [${doc} selectNodes ${image_xpath}] {
		lappend article_image [::uri::canonicalize \
					   [::uri::resolve \
						$link \
						[$image_node @src]]]
		${image_node} delete
	    }
	}
    }

    # remove script nodes
    foreach cleanup_node [${doc} selectNodes {//script}] {
	$cleanup_node delete
    }

    if { ${xpath_article_cleanup} ne {} } {
	foreach cleanup_node [${doc} selectNodes ${xpath_article_cleanup}] {
	    ${cleanup_node} delete
	}
    }

    set article_body ""
    if { ${xpath_article_body} ne {} } {
	set article_body_node [${doc} selectNodes ${xpath_article_body}]
	set article_body [${article_body_node} asText]
	#set article_body [${doc} selectNodes returnstring(${xpath_article_body})]
    }


    puts "Title: $article_title"
    puts "Author: $author_in_article"
    puts "Image: $article_image"

    # TODO: xpathfunc returntext (that returns structured text from html)
    puts "Content: [string range $article_body 0 100]"
    # puts "Content: $article_body"

    $doc delete

    break

}
