source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri
package require sha1

namespace eval ::feed_reader {;}

proc ::feed_reader::compare_href_attr {n1 n2} {
    return [string compare [${n1} @href ""] [${n2} @href ""]]
}

proc ::feed_reader::filter_title {stoptitlesVar title} {
    upvar $stoptitlesVar stoptitles

    if { [info exists stoptitles(${title})] } {
	return ""
    } else {
	return ${title}
    }
}

#TODO: trim non-greek and non-latin letters from beginning and end of title
proc ::feed_reader::trim_title {title} {
    #set re {^[^0-9a-z\u0370-\03FF]*}
    #return [regexp -inline -- ${re} ${title}]
    return [string trim ${title} " -\t\n\r"]
}


proc ::feed_reader::get_title {stoptitlesVar node} {
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


proc ::feed_reader::get_feed_items {resultVar feedVar {stoptitlesVar ""}} {
    upvar $resultVar result
    upvar $feedVar feed
    upvar $stoptitlesVar stoptitles

    set url         $feed(url)
    set include_re  $feed(include_re)
    set exclude_re  [get_value_if feed(exclude_re) ""]

    if { [info exists feed(domain)] } {
	set domain $feed(domain)
    } else {
	set domain [::util::domain_from_url ${url}]
    }

    set xpath_feed_item {//a[@href]}
    if { [info exists feed(xpath_feed_item)] } {
	set xpath_feed_item $feed(xpath_feed_item)
    }

    set htmltidy_feed_p [get_value_if \
			     feed(htmltidy_feed_p) \
			     0]

    set xpath_feed_cleanup [get_value_if \
				feed(xpath_feed_cleanup) \
				{}]

    set encoding {utf-8}
    if { [info exists feed(encoding)] } {
	set encoding $feed(encoding)
    }

    ::xo::http::fetch html $url
    
    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_feed_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    set doc [dom parse -html ${html}]


    foreach cleanup_xpath ${xpath_feed_cleanup} {
	foreach cleanup_node [${doc} selectNodes $cleanup_xpath] {
	    $cleanup_node delete
	}	    
    }

    set nodes [$doc selectNodes ${xpath_feed_item}]

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
	if { ![regexp -- ${include_re} ${href}] || ( ${exclude_re} ne {} && [regexp -- ${exclude_re} ${href}] ) } {
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
	# TODO: thumbnail urls are a good way to group similar articles
	#lappend result(thumbnail) $thumbnail

    }

    # cleanup
    $doc delete
}


proc ::feed_reader::exec_xpath {resultVar doc xpath} {
    upvar $resultVar result

    set result ""
    if { ${xpath} ne {} } {
	set result [string trim [${doc} selectNodes "${xpath}"]]
    }

}


proc ::feed_reader::fetch_item_helper {link title_in_feed feedVar itemVar} {

    upvar $feedVar feed
    upvar $itemVar item

    set encoding [get_value_if feed(encoding) utf-8]

    set htmltidy_article_p [get_value_if \
				feed(htmltidy_article_p) \
				0]

    set keep_title_from_feed_p [get_value_if \
				    feed(keep_title_from_feed_p) \
				    0]

    # {//meta[@property="og:title"]}
    set xpath_article_title [get_value_if \
				 feed(xpath_article_title) \
				 {string(//meta[@property="og:title"]/@content)}]

    set xpath_article_body [get_value_if \
				feed(xpath_article_body) \
				{}]

    set xpath_article_cleanup [get_value_if \
				   feed(xpath_article_cleanup) \
				   {}]

    set xpath_article_author [get_value_if \
				  feed(xpath_article_author) \
				  {}]

    set xpath_article_image [get_value_if \
				 feed(xpath_article_image) \
				 {string(//meta[@property="og:image"]/@content)}]

    set xpath_article_attachment [get_value_if \
				      feed(xpath_article_attachment) \
				      {}]

    set xpath_article_description [get_value_if \
				       feed(xpath_article_description) \
				       {string(//meta[@property="og:description"]/@content)}]


    set xpath_article_date [get_value_if \
				feed(xpath_article_date) \
				{string(//meta[@property="article:published_time"]/@content)}]

    set xpath_article_modified_time [get_value_if \
				feed(xpath_article_modified_time) \
				{string(//meta[@property="article:modified_time"]/@content)}]


    set xpath_article_tags [get_value_if \
				feed(xpath_article_tags) \
				{}]


    set html ""
    ::xo::http::fetch html ${link}

    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_article_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    set doc [dom parse -html ${html}]

    exec_xpath title_in_article $doc $xpath_article_title
    exec_xpath author_in_article $doc $xpath_article_author

    if { ${keep_title_from_feed_p} || ${title_in_article} eq {} } {
	set article_title ${title_in_feed}
    } else {
	set article_title ${title_in_article}
    }

    set article_image [list]
    if { ${xpath_article_image} ne {} } {
	foreach image_xpath ${xpath_article_image} {
	    foreach image_url [${doc} selectNodes ${image_xpath}] {
		lappend article_image [::uri::canonicalize \
					   [::uri::resolve \
						$link \
						$image_url]]
	    }
	}
    }

    set article_attachment [list]
    if { ${xpath_article_attachment} ne {} } {
	foreach attachment_xpath ${xpath_article_attachment} {
	    foreach attachment_url [${doc} selectNodes ${attachment_xpath}] {
		# TODO: schedule to fetch and recognize content type
		# TODO: include_attachment_re, e.g. for stockwatch /media/announce_pdf
		lappend article_attachment [::uri::canonicalize \
						[::uri::resolve \
						     $link \
						     $attachment_url]]
	    }
	}
    }


    exec_xpath article_date $doc $xpath_article_date
    exec_xpath article_modified_time $doc $xpath_article_modified_time
    exec_xpath article_description $doc $xpath_article_description
    exec_xpath article_tags $doc $xpath_article_tags


    # remove script and style and link nodes (in addition to the ones specified by the feed spec)
    lappend xpath_article_cleanup {//script}
    lappend xpath_article_cleanup {//style}
    lappend xpath_article_cleanup {//link}
    foreach cleanup_xpath ${xpath_article_cleanup} {
	foreach cleanup_node [${doc} selectNodes ${cleanup_xpath}] {
	    ${cleanup_node} delete
	}
    }

    exec_xpath article_body $doc $xpath_article_body

    array set item [list \
			link $link \
			title $article_title \
			description $article_description \
			body $article_body \
			tags ${article_tags} \
			author $author_in_article \
			image $article_image \
			attachment $article_attachment \
			date $article_date \
			modified_time $article_modified_time \
			content $article_body]

    puts "Link: $link"
    puts "Title: $article_title"
    if { $article_tags ne {} } {
	puts "Tags: $article_tags"
    }
    if { $article_description ne {} } {
	puts "Description: $article_description"
    }
    if { $author_in_article ne {} } {
	puts "Author: $author_in_article"
    }
    if { $article_image ne {} } {
	puts "Image(s): $article_image"
    }
    if { $article_date ne {} } {
	puts "Date: $article_date"
    }
    if { $article_modified_time ne {} } {
	puts "Last modified: $article_modified_time"
    }
    if { $article_attachment ne {} } {
	puts "Attachment(s): $article_attachment"
    }

    # TODO: xpathfunc returntext (that returns structured text from html)
    puts "Content (snippet): [string range $article_body 0 200]"
    puts "---"

    $doc delete
}

proc ::feed_reader::fetch_item {link title_in_feed feedVar itemVar} {

    upvar $feedVar feed
    upvar $itemVar item

    if { [catch {fetch_item_helper ${link} ${title_in_feed} feed item} errmsg] } {
	puts errmsg=$errmsg
	array set item [list \
			    link $link \
			    title $title_in_feed \
			    status failure \
			    errno 1 \
			    errmsg $errmsg]
    }
}

proc ::feed_reader::get_base_dir {} {
    return {/web/data/crawldb}
}

proc ::feed_reader::get_item_dir {link} {

    array set uri_parts [::uri::split ${link}]

    set reversehost [join [lreverse [split $uri_parts(host) {.}]] {.}]

    set urlsha1 [::sha1::sha1 -hex ${link}]

    #set first3Chars [string range ${urlsha1} 0 2]

    set dir [get_base_dir]/${reversehost}/${urlsha1}/

    return ${dir}

}

proc ::feed_reader::get_content_dir {} {
    return [get_base_dir]/content/
}

proc ::feed_reader::exists_item {link feedVar} {
    upvar $feedVar feed

    return [file isdirectory [get_item_dir ${link}]]

}

proc ::feed_reader::write_item {link feedVar itemVar} {
    upvar $feedVar feed
    upvar $itemVar item


    # save to content file
    set content_dir [get_content_dir]
    if { ![file isdirectory ${content_dir}] } {
	file mkdir ${content_dir}
    }
    set content [list title $item(title) body $item(body)]
    set contentsha1 [::sha1::sha1 -hex ${content}]
    set contentfilename ${content_dir}/${contentsha1}

    set item(contentsha1) ${contentsha1}
    if { [file exists ${contentfilename}] } {
	# we have seen this item before
	set item(is_copy_p) 1
    } else {
	set fp [open ${contentfilename} "w"]
	puts $fp ${content}
	close $fp
    }

    set timestamp [clock seconds] 
    set item(timestamp) ${timestamp}


    # save to list of articles
    set articles_filename [get_base_dir]/articles.txt
    set fp [open ${articles_filename} "a"]
    puts $fp [list ${timestamp} ${contentsha1} ${link} $item(title)]
    close ${fp}
    

    # save data to item_dir
    # note that it overwrites the file if it already exists with the same content
    #


    array unset item title
    array unset item body

    set item_dir [get_item_dir ${link}]
    if { ![file isdirectory ${item_dir}] } {
	file mkdir ${item_dir}
    }

    set data [array get item]
    set datafilename ${item_dir}/${contentsha1}
    set fp [open ${datafilename} "w"]
    puts $fp ${data}
    close ${fp}

}


#TODO: we need a way to test feed (before starting to store it)
proc ::feed_reader::test_feed {feedVar {stoptitlesVar ""}} {
    upvar $feedVar feed
    if { $stoptitlesVar ne {} } {
	upvar $stoptitlesVar stoptitles
    }

    get_feed_items result feed stoptitles

    foreach link $result(links) title_in_feed $result(titles) {
	puts ""
	puts ${title_in_feed}
	puts ${link}
	puts "---"

	fetch_item ${link} ${title_in_feed} feed item
	puts "Content:\n$item(body)"

	if { [incr count] == 7 } {
	    break
	}

    }

}

proc ::feed_reader::sync_feeds {feedsVar stoptitlesVar} {

    upvar $feedsVar feeds
    if { $stoptitlesVar ne {} } {
	upvar $stoptitlesVar stoptitles
    }

    #haravgi, 24h, politis, stockwatch
    foreach feed_name {
	philenews
	sigmalive
	paideia-news
	inbusiness
	ant1iwo
	24h
	stockwatch
	newsit
	alitheia
    } {

	array set feed [dict get ${feeds} ${feed_name}]

	# set feed_type [get_value_if feed(type) ""] 
	# if { ${feed_type} eq {rss} } {
	# set feed(xpath_feed_item) //item
	# }

	get_feed_items result feed stoptitles

	foreach link $result(links) title_in_feed $result(titles) {
	    #puts ""
	    #puts ${title_in_feed}
	    #puts ${link}
	    #puts "---"

	    #continue
	    
	    # TODO: if it exists and it's the first item in the feed,
	    # fetch it and compare it to stored item to ensure sanity
	    # of feed/article/page
	    if { ![exists_item ${link} feed] } {
		fetch_item ${link} ${title_in_feed} feed item
		write_item ${link} feed item
	    }

	}

    }
}
