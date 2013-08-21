namespace eval ::feed_reader {

    array set meta [list]
    array set stoptitles [list]

}


proc ::feed_reader::init {} {

    variable meta
    variable stoptitles

    read_meta meta

    if { $meta(stoptitles) ne {} } {
	foreach title $meta(stoptitles) {
	    set stoptitles(${title}) 1
	}
    }

}

proc ::feed_reader::read_meta {metaVar} {

    upvar ${metaVar} meta

    set conf_dir [get_conf_dir]

    set stoptitles [list]
    foreach title [split [::util::readfile ${conf_dir}/stoptitles.txt] "\n"] {
	lappend stoptitles [trim_title ${title}]
    }
    
    set end_of_text_strings [list]
    foreach end_of_text_string [split [::util::readfile ${conf_dir}/article_body_end_of_text_strings] "\n"] {
	if { ${end_of_text_string} ne {} } {
	    lappend end_of_text_strings ${end_of_text_string}
	}
    }

    array set meta [list stoptitles ${stoptitles} end_of_text_strings ${end_of_text_strings}]

}

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


# get_feed_items
proc ::feed_reader::fetch_feed {resultVar feedVar {stoptitlesVar ""}} {
    upvar $resultVar result
    upvar $feedVar feed
    if { ${stoptitlesVar} ne {} } {
	upvar $stoptitlesVar stoptitles
    }

    array set result [list links "" titles ""]

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

    set errorcode [::xo::http::fetch html $url]
    if { ${errorcode} } {
	return $errorcode
    }
    
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

    set link_stoplist [get_value_if feed(link_stoplist) ""]

    set nodes [$doc selectNodes ${xpath_feed_item}]

    set nodes2 [list]
    array set title_for_href [list]
    foreach node $nodes {

	# turn relative urls into absolute urls and canonicalize	
	# TODO: consider using urldecode, problem is decoded string might need to be
	# converted from another encoding, i.e. encoding convertfrom url_decoded_string
	set href [::uri::canonicalize [::uri::resolve ${url} [${node} @href ""]]]

	if { ${link_stoplist} ne {} && ${href} in ${link_stoplist} } {
	    continue
	}


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

    foreach node ${nodes3} {

	set href [${node} @href]
	lappend result(links)  ${href}
	lappend result(titles) $title_for_href(${href})
	# TODO: thumbnail urls are a good way to group similar articles
	#lappend result(thumbnail) $thumbnail

    }

    # cleanup
    $doc delete

    return 0  ;# no errors
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

    variable meta

    array set item [list]

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

    set xpath_article_video [get_value_if \
				 feed(xpath_article_video) \
				 {values(//iframe[contains(@src,"youtube")]/@src)}]

    set xpath_article_attachment [get_value_if \
				      feed(xpath_article_attachment) \
				      {}]

    set xpath_article_description [get_value_if \
				       feed(xpath_article_description) \
				       {string(//meta[@property="og:description"]/@content)}]


    set xpath_article_date [get_value_if \
				feed(xpath_article_date) \
				{returndate(string(//meta[@property="article:published_time"]/@content),"%Y-%m-%d %H:%M")}]

    set xpath_article_modified_time [get_value_if \
				feed(xpath_article_modified_time) \
				{returndate(string(//meta[@property="article:modified_time"]/@content),"%Y-%m-%d %H:%M")}]


    set xpath_article_tags [get_value_if \
				feed(xpath_article_tags) \
				{string(//meta[@property="og:keywords"]/@content)}]


    set html ""
    set errorcode [::xo::http::fetch html ${link}]
    if { ${errorcode} } {
	return ${errorcode}
    }

    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_article_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    set doc [dom parse -html ${html}]
    ${doc} baseURI ${link}

    exec_xpath title_in_article $doc $xpath_article_title
    exec_xpath author_in_article $doc $xpath_article_author

    if { ${keep_title_from_feed_p} || ${title_in_article} eq {} } {
	set article_title ${title_in_feed}
    } else {
	set article_title ${title_in_article}
    }

    set article_image [list]
    if { ${xpath_article_image} ne {} } {

	set image_stoplist [get_value_if feed(image_stoplist) ""]

	foreach image_xpath ${xpath_article_image} {
	    foreach image_url [${doc} selectNodes ${image_xpath}] {
		set canonical_image_url \
		    [::uri::canonicalize \
			 [::uri::resolve \
			      $link \
			      $image_url]]

		if { ${image_stoplist} ne {} && ${canonical_image_url} in ${image_stoplist} } {
		    continue
		}

		lappend article_image ${canonical_image_url}
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

    set article_video [list]
    if { ${xpath_article_video} ne {} } {
	foreach video_xpath ${xpath_article_video} {
	    foreach video_url [${doc} selectNodes ${video_xpath}] {
		# TODO: extract video id and convert to video url (if possible)
		lappend article_video ${video_url}
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

    if { [get_value_if feed(end_of_text_cleanup_p) "0"] } {
	# if end_of_string is found after the 1/3 of the article body
	# then drop text beyond that point
	#
	set end_of_text_cleanup_coeff [get_value_if feed(end_of_text_cleanup_coeff) "0.3"]
	set article_body_len [string length ${article_body}]
	set startIndex [expr { int( ${article_body_len} * ${end_of_text_cleanup_coeff} ) } ]
	foreach end_of_text_string $meta(end_of_text_strings) {
	    set index [string first ${end_of_text_string} ${article_body} ${startIndex}]
	    if { -1 != ${index} } {
		set article_body [string trim [string range ${article_body} 0 [expr { ${index} - 1 }]]]
	    }
	}
    }

    set article_langclass [get_value_if feed(article_langclass) "el.utf8"]

    if { ${article_langclass} eq {auto} } {
	set article_langclass [::ttext::langclass "$article_title $article_body"]
    }

    set domain [::util::domain_from_url ${link}]

    array set item [list \
			domain ${domain} \
			link $link \
			langclass $article_langclass \
			title $article_title \
			description $article_description \
			body $article_body \
			tags ${article_tags} \
			author $author_in_article \
			image $article_image \
			video $article_video \
			attachment $article_attachment \
			date $article_date \
			modified_time $article_modified_time]

    puts "Lang: $article_langclass"
    puts "Title: $article_title"
    puts "Link: $link"
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
    if { $article_video ne {} } {
	puts "Video(s): $article_video"
    }

    # TODO: xpathfunc returntext (that returns structured text from html)
    puts "Content (snippet): [string range $article_body 0 200]"
    puts "---"

    $doc delete

    return 0 ;# no errors
}

proc ::feed_reader::fetch_item {link title_in_feed feedVar itemVar} {

    upvar $feedVar feed
    upvar $itemVar item

    if { [catch {set retcode [fetch_item_helper ${link} ${title_in_feed} feed item]} errmsg] } {

	puts errmsg=$errmsg

	array set item [list \
			    link $link \
			    title $title_in_feed \
			    status failure \
			    errno 1 \
			    errmsg $errmsg]

	return ${retcode} ;# failed with errors
    }

    return ${retcode}
}


proc ::feed_reader::fetch_and_write_item {link title_in_feed feedVar} {

    upvar $feedVar feed


    set normalize_link_re [get_value_if feed(normalize_link_re) ""]
    if { ${normalize_link_re} ne {} } {
	regexp -- ${normalize_link_re} ${link} whole normalized_link
    } else {
	set normalized_link ${link}
    }

    # TODO: if it exists and it's the first item in the feed,
    # fetch it and compare it to stored item to ensure sanity
    # of feed/article/page

    set can_resync_p [get_value_if feed(check_for_revisions) "0"]

    set resync_p 0
    if { 
	![exists_item ${normalized_link}] 
	|| ( ${can_resync_p} && [set resync_p [auto_resync_p feed ${normalized_link}]] ) 
    } {
	
	set errorcode [fetch_item ${link} ${title_in_feed} feed item]
	if { ${errorcode} } {
	    puts "--->>> error ${link}"
	    # incr errorCount
	    return {ERROR_FETCH}
	}

	if { ${normalized_link} ne ${link} } {
	    set item(normalized_link) ${normalized_link}
	}

	set written_p [write_item ${normalized_link} feed item ${resync_p}]
	
	unset item

	if { ${written_p} } {
	    return {FETCH_AND_WRITE}
	} else {
	    return {NO_WRITE}
	}

    } else {

	return {NO_FETCH}

    }

}


proc ::feed_reader::get_base_dir {} {
    return {/web/data/newsdb}
}

proc ::feed_reader::reversedomain {domain} {
    return [join [lreverse [split ${domain} {.}]] {.}]
}

proc ::feed_reader::get_domain_dir {link} {

    set domain [::util::domain_from_url ${link}]

    set reversedomain [reversedomain ${domain}]

    return [get_base_dir]/site/${reversedomain}
}

proc ::feed_reader::get_urlsha1 {link} {
    set urlsha1 [::sha1::sha1 -hex ${link}]
    return ${urlsha1}
}

proc ::feed_reader::get_item_dir {linkVar {urlsha1Var ""}} {

    upvar ${linkVar} link
    if { ${urlsha1Var} ne {} } {
	upvar ${urlsha1Var} urlsha1
    }

    set domain_dir [get_domain_dir ${link}]

    set urlsha1 [::sha1::sha1 -hex ${link}]

    #set first3Chars [string range ${urlsha1} 0 2]

    set dir ${domain_dir}/${urlsha1}/

    return ${dir}

}

proc ::feed_reader::get_content_dir {} {
    return [get_base_dir]/content
}

proc ::feed_reader::get_log_dir {} {
    return [get_base_dir]/log
}

proc ::feed_reader::get_crawler_dir {} {
    return [get_base_dir]/crawler
}


proc ::feed_reader::get_index_dir {} {
    # multiple urls may have the same content
    return [get_base_dir]/contentsha1_to_urlsha1
}

proc ::feed_reader::get_contentsha1_to_label_dir {} {
    # multiple urls may have the same content
    return [get_base_dir]/contentsha1_to_label
}

proc ::feed_reader::get_url_dir {} {
    # multiple urls may have the same content
    return [get_base_dir]/url
}


proc ::feed_reader::exists_domain {link} {

    return [file isdirectory [get_domain_dir ${link}]]

}

proc ::feed_reader::compare_mtime {file_or_dir1 file_or_dir2} {

    set mtime1 [file mtime $file_or_dir1]
    set mtime2 [file mtime $file_or_dir2]

    if { ${mtime1} < ${mtime2} } {
	return -1
    } elseif { ${mtime1} > ${mtime2} } {
	return 1
    } else {
	return 0
    }

}

proc ::feed_reader::get_revision_files {item_dirVar} {

    upvar $item_dirVar item_dir

    set filelist [glob -directory ${item_dir} *]
    set sortedlist [lsort -decreasing -command compare_mtime ${filelist}]
    return ${sortedlist}

}

proc ::feed_reader::get_revision_filename {item_dirVar index} {

    upvar $item_dirVar item_dir

    set filename [lindex [get_revision_files item_dir] ${index}]
    return ${filename}

}


# load latest revision in item_dir
# TODO: fix me
proc ::feed_reader::load_item_from_dir {itemVar item_dirVar} {
    upvar $itemVar item
    upvar $item_dirVar item_dir

    set filename [get_revision_filename item_dir 0]  ;# newest revision
    array set item [::util::readfile ${filename}]
}

proc ::feed_reader::list_feed {feedVar {limit "10"} {offset "0"}} {
    upvar $feedVar feed

    if { [exists_domain $feed(url)] } {
	set domain_dir [get_domain_dir $feed(url)]
	set item_dirs [glob -directory ${domain_dir} *]

	set sortedlist [lsort -decreasing -command compare_mtime ${item_dirs}]

	set first ${offset}
	set last [expr { ${offset} + ${limit} - 1 }]

	set slicelist [lrange ${sortedlist} ${first} ${last}]

	foreach item_dir ${slicelist} {
	    load_item_from_dir item item_dir

	    print_log_entry item
	    unset item
	}
    }
}


proc ::feed_reader::get_logfilelist {sortedlistVar} {

    upvar $sortedlistVar sortedlist

    set log_dir [get_log_dir]

    set logfilelist [glob -directory ${log_dir} *]

    set sortedlist [lsort -decreasing -command compare_mtime ${logfilelist}]

}


proc ::feed_reader::log {{limit "10"} {offset "0"}} {

    get_logfilelist sortedlist

    set first ${offset}
    set last [expr { ${offset} + ${limit} - 1 }]

    set slicelist [lrange ${sortedlist} ${first} ${last}]

    print_log_header

    foreach logfilename ${slicelist} {

        array set item [::util::readfile ${logfilename}]
	print_log_entry item
	unset item

    }

}


proc ::feed_reader::cluster {{limit "10"} {offset "0"} {k ""} {num_iter "3"}} {

    set log_dir [get_log_dir]

    set logfilelist [glob -directory ${log_dir} *]

    set sortedlist [lsort -decreasing -command compare_mtime ${logfilelist}]

    set first ${offset}
    set last [expr { ${offset} + ${limit} - 1 }]

    set slicelist [lrange ${sortedlist} ${first} ${last}]

    #print_log_header

    set contentfilelist [list]
    foreach logfilename ${slicelist} {

        array set item [::util::readfile ${logfilename}]
	lappend contentfilelist [get_content_dir]/$item(contentsha1)

	#print_log_entry item
	unset item

    }

    set cmd "/web/repos/phigita/service-phigita/lib/document_clustering/cc/test_main"
    if { ${k} eq {} } {
	set k [expr { int(log(${limit}) * sqrt(${limit})) }]
    }
    set result [exec ${cmd} ${k} ${num_iter} {*}${contentfilelist}]

    puts ${result}



}


proc ::feed_reader::exists_item {link} {

    return [file isdirectory [get_item_dir link]]

}


proc ::feed_reader::load_item {itemVar urlsha1} {

    upvar $itemVar item

    set urlfilename [get_url_dir]/${urlsha1}
    array set item [::util::readfile $urlfilename]

    load_content item $item(contentsha1)

}

proc ::feed_reader::show_content {contentsha1} {

    load_content item ${contentsha1}
    print_item item
}

proc ::feed_reader::diff_content {contentsha1_old contentsha1_new} {

    load_content old_item ${contentsha1_old}
    load_content new_item ${contentsha1_new}

    puts "* title: [::util::strings::diff $old_item(title) $new_item(title)]"
    puts "* body: [::util::strings::diff $old_item(body) $new_item(body)]"

}


proc ::feed_reader::uses_content {contentsha1} {
    
    # what objects use given content
    # contentsha1_to_urlsha1
    set filename [get_index_dir]/${contentsha1}
    set urlsha1_list [::util::readfile ${filename}]
    foreach urlsha1 ${urlsha1_list} {
	load_item item ${urlsha1}
	print_item item
    }

}


proc ::feed_reader::load_content {itemVar contentsha1} {

    upvar $itemVar item
    set contentfilename [get_content_dir]/${contentsha1}
    array set item [list]
    lassign [::util::readfile $contentfilename] item(title) item(body)

    set contentsha1_to_label_filename [get_contentsha1_to_label_dir]/${contentsha1}
    if { [file exists ${contentsha1_to_label_filename}] } {
	set item(label) [lsearch -inline -all -not [split [::util::readfile $contentsha1_to_label_filename] "\n"] {}]
    }

}

proc ::feed_reader::print_item {itemVar} {
    upvar $itemVar item

    puts "--"
    foreach {key value} [array get item] {
	if { ${value} ne {} } {
	    puts "* ${key}: ${value}"
	}
    }
}


proc ::feed_reader::print_log_header {} {

    puts [format "%10s %13s %40s %40s %24s %3s %3s %s" langclass date contentsha1 urlsha1 domain "" "" title]

}

proc ::feed_reader::print_log_entry {itemVar} {
    upvar $itemVar item

    set domain [::util::domain_from_url $item(link)]

    set is_copy_string ""
    if { [get_value_if item(is_copy_p) 0] } {
	set is_copy_string "(*)"
    }
    set is_revision_string ""
    if { [get_value_if item(is_revision_p) 0] } {
	set is_revision_string "upd"
    }

    puts [format "%10s %13s %40s %40s %24s %3s %3s %s" \
	      [get_value_if item(langclass) "el.utf8"] \
	      $item(date) $item(contentsha1) \
	      $item(urlsha1) \
	      ${domain} \
	      ${is_copy_string} \
	      ${is_revision_string} \
	      $item(title)]

}

proc ::feed_reader::show_item {urlsha1_list} {
    foreach urlsha1 ${urlsha1_list} {
	load_item item ${urlsha1}
	print_item item
	unset item
    }
}

proc ::feed_reader::show_revisions {urlsha1} {
    load_item item ${urlsha1}
    set normalized_link [get_value_if item(normalized_link) $item(link)]
    set item_dir [get_item_dir normalized_link]
    set filelist [get_revision_files item_dir]
    foreach filename ${filelist} {
	puts "[file mtime ${filename}] [file tail ${filename}]"
    }
}

proc ::feed_reader::show_item_from_url {link} {
    
    set urlsha1 [::sha1::sha1 -hex ${link}]
    load_item item ${urlsha1}
    print_item item
}

proc ::feed_reader::incr_value_in_file {filename {increment "1"}} {

    if { [file exists ${filename}] } {

	set count [::util::readfile ${filename}]

    } else {

	set count 0

    }

    set result [incr count ${increment}]

    ::util::writefile ${filename} ${result}

    return ${result}

}

proc ::feed_reader::incr_array_in_file {filename incrementVar} {

    upvar $incrementVar increment

    if { [file exists ${filename}] } {

	array set count [::util::readfile ${filename}]

    } else {

	array set count [list]

    }

    foreach name [array names increment] {
	incr count(${name}) $increment(${name})
    }

    ::util::writefile ${filename} [array get count]

    return [array get count]

}

proc ::feed_reader::write_item {normalized_link feedVar itemVar resync_p} {
    upvar $feedVar feed
    upvar $itemVar item

    # prepare to write
    set content_dir [get_content_dir]
    set index_dir [get_index_dir]
    set item_dir [get_item_dir normalized_link urlsha1]
    set url_dir [get_url_dir]
    set log_dir [get_log_dir]
    set crawler_dir [get_crawler_dir]

    foreach varname {
	content_dir 
	index_dir 
	item_dir 
	url_dir 
	log_dir 
	crawler_dir
    } {
	set dirname [set ${varname}]
	if { ![file isdirectory ${dirname}] } {
	    file mkdir ${dirname}
	}
    }

    set timestamp [clock seconds] 

    set crawlerfilename "${crawler_dir}/url/${urlsha1}"
    close [open ${crawlerfilename} "w"]

    set content [list $item(title) $item(body)]
    set contentsha1 [::sha1::sha1 -hex ${content}]

    set revisionfilename ${item_dir}/${contentsha1}
    if { [file exists ${revisionfilename}] } {
	# revision content is the same as a previous one
	# no need to overwrite the revisionfilename,
	# nor the contentfilename and indexfilename
	#
	# note that if were keeping track of metadata changes
	# then it would make sense to overwrite the logfilename
	# and the urlfilename
	return 0
    }

    if { ${resync_p} } {
	set item(is_revision_p) 1
	set item(first_sync) [get_first_sync_timestamp normalized_link]
	set item(last_sync) ${timestamp}
    }

    set contentfilename ${content_dir}/${contentsha1}
    set indexfilename ${index_dir}/${contentsha1}
    set logfilename ${log_dir}/${urlsha1}
    set urlfilename ${url_dir}/${urlsha1}

    # TODO: each image,attachment,video,etc should get its own content file in the future

    if { [file exists ${contentfilename}] } {

	# we have seen this item before from a different url
	set item(is_copy_p) 1

    } else {

	# save article body to content file
	::util::writefile ${contentfilename} ${content}

    }


    set item(timestamp) ${timestamp}
    set item(urlsha1) ${urlsha1}
    set item(contentsha1) ${contentsha1}


    array unset item body
    set data [array get item]


    # contentsha1 to urlsha1, i.e. which links lead to the same content
    # TODO: consider having simhash
    set fp [open ${indexfilename} "a"]
    puts $fp ${urlsha1}
    close $fp



    # save data to log dir
    ::util::writefile ${logfilename}  ${data}  

    # save data to item-revision dir
    #
    ::util::writefile ${revisionfilename} ${data}

    # save data to url dir
    ::util::writefile ${urlfilename} ${data}


    if { [get_value_if item(date) ""] ne {} } {
	set timeval [clock scan $item(date) -format "%Y%m%dT%H%M"]
	# up to a day difference is fine to account for servers
	# with different timezone
	if { ${timestamp} - ${timeval} > 86400 } {
	    # puts "item(date)=$item(date) is older than a day - updating files' mtime..."
	    file mtime ${item_dir} ${timeval}
	    file mtime ${contentfilename} ${timeval}
	    file mtime ${indexfilename} ${timeval}
	    file mtime ${logfilename} ${timeval}
	    file mtime ${revisionfilename} ${timeval}
	    file mtime ${urlfilename} ${timeval}
	}
    }

    return 1

}


#TODO: we need a way to test feed (before starting to store it)
proc ::feed_reader::test_feed {feedVar {limit "3"} {fetch_item_p "1"}} {
    upvar $feedVar feed

    variable meta
    variable stoptitles

    set errorcode [fetch_feed result feed stoptitles]
    if { ${errorcode} } {
	puts "fetch_feed failed errorcode=$errorcode"
	return
    }

    foreach link $result(links) title_in_feed $result(titles) {
	puts ""
	puts ${title_in_feed}
	puts ${link}
	puts "---"

	if { ${fetch_item_p} } {
	    set errorcode [fetch_item ${link} ${title_in_feed} feed item]
	    if { ${errorcode} } {
		puts "fetch_item failed errorcode=$errorcode link=$link"
		continue
	    }
	    puts "Content:\n$item(body)"
	}

	if { [incr count] == ${limit} } {
	    break
	}

    }

}


proc ::feed_reader::get_first_sync_timestamp {linkVar} {

    upvar $linkVar link

    set item_dir [get_item_dir link urlsha1]
    set revisionfilename [get_revision_filename item_dir end]  ;# oldest revision
    return [file mtime ${revisionfilename}]

}


proc ::feed_reader::get_last_sync_timestamp {linkVar} {

    upvar $linkVar link

    set urlsha1 [get_urlsha1 ${link}]
    set crawler_dir [get_crawler_dir]
    set crawlerfilename "${crawler_dir}/url/${urlsha1}"
    return [file mtime ${crawlerfilename}]

}

proc ::feed_reader::auto_resync_p {feedVar link} {

    upvar $feedVar feed

    set now [clock seconds]
    set first_sync [get_first_sync_timestamp link]

    # do not check for revisions if the item is older than a day (or maxage)

    set maxage [get_value_if feed(check_for_revisions_maxage) "86400"]

    if { ${now} - ${first_sync} < ${maxage} } {

	set last_sync [get_last_sync_timestamp link]

	# check for revisions every hour (default) or given interval

	set interval [get_value_if feed(check_for_revisions_interval) "3600"]

	if { ${now} - ${last_sync} > ${interval} } {
	    return 1
	}

    }

    return 0
}

proc ::feed_reader::sync_feeds {{news_sources ""}} {

    variable stoptitles

    set feeds_dir [get_package_dir]/feed
    set check_fetch_feed_p 0
    if { ${news_sources} eq {} } {
	set news_sources [glob -nocomplain -tails -directory ${feeds_dir} *]
	set check_fetch_feed_p 1
    }

    foreach news_source ${news_sources} {

	set news_source_dir ${feeds_dir}/${news_source}
	set filelist [glob -nocomplain -directory ${news_source_dir} *]
	foreach filename ${filelist} {
	    set feed_name ${news_source}.[file tail ${filename}]
	    array set feed [::util::readfile ${filename}]

	    # TODO: maintain domain in feed spec
	    set domain [::util::domain_from_url $feed(url)]

	    set timestamp [clock seconds]
	    if { ${check_fetch_feed_p} && ![fetch_feed_p ${feed_name} ${timestamp}] } {
		puts "not fetching $feed_name in this round"
		continue
	    }

	    array set stats \
		[list \
		     FETCH_AND_WRITE 0 \
		     NO_FETCH 0 \
		     NO_WRITE 0 \
		     ERROR_FETCH 0 \
		     ERROR_FETCH_FEED 0 \
		     FETCH_AND_WRITE_FEED 0 \
		     NO_WRITE_FEED 0]


	    # set feed_type [get_value_if feed(type) ""] 
	    # if { ${feed_type} eq {rss} } {
	    # set feed(xpath_feed_item) //item
	    # }

	    set errorcode [fetch_feed result feed stoptitles]
	    if { ${errorcode} } {
		puts "fetch_feed failed errorcode=$errorcode feed_name=$feed_name"
		set stats(ERROR_FETCH_FEED) 1
		update_crawler_stats ${timestamp} ${feed_name} stats
		continue
	    }

	    foreach link $result(links) title_in_feed $result(titles) {
		#puts ""
		#puts ${title_in_feed}
		#puts ${link}
		#puts "---"

		# returns FETCH_AND_WRITE, NO_FETCH, and NO_WRITE
		set retcode [fetch_and_write_item ${link} ${title_in_feed} feed]
		incr stats(${retcode})
	    }
	    if { $stats(FETCH_AND_WRITE) > 0 } {
		set stats(FETCH_AND_WRITE_FEED) 1
	    } else {
		set stats(NO_WRITE_FEED) 1
	    }
	    update_crawler_stats ${timestamp} ${feed_name} stats

	    unset feed
	    unset stats

	}

    }
}

# if more than 1/3 of the time we fetch, we write, then fetch_feed_p
proc ::feed_reader::fetch_feed_p {feed_name timestamp {coeff "0.3"}} {

    set crawler_dir [get_crawler_dir]
    set crawler_feed_dir "${crawler_dir}/feed/${feed_name}/"

    foreach format {
	{H-%H}
	{u-%u}
	{md-%m%d}
    } {

	set pretty_timeval [clock format ${timestamp} -format ${format}]
	set crawler_feed_sync_dir ${crawler_feed_dir}/${pretty_timeval}/
	
	if { ![file isdirectory ${crawler_feed_sync_dir}] } {
	    return 1
	}
	
	set crawler_feed_sync_stats ${crawler_feed_dir}/${pretty_timeval}/_stats
	array set count [incr_array_in_file ${crawler_feed_sync_stats} stats]

	if { $count(FETCH_AND_WRITE_FEED) > ${coeff} * ( $count(NO_WRITE_FEED) + $count(ERROR_FETCH_FEED) ) } {
	    return 1
	}

    }

    # if last update more than a week ago then fetch
    # TODO: comment-in when last_sync is maintained in the feed info
    # if { [get_value_if feed(last_sync) "0"] + (7*86400) < ${timestamp} } {
	# return 1
    # }

    # array set count [incr_array_in_file "${crawler_site_dir}/_stats" stats]
    # if { $count(FETCH_AND_WRITE_FEED) / $count(FETCH_FEED) } {
    # return 1
    # }

    return 0

}

proc ::feed_reader::update_crawler_stats {timestamp feed_name statsVar} {

    upvar $statsVar stats

    set crawler_dir [get_crawler_dir]
    set crawler_feed_dir "${crawler_dir}/feed/${feed_name}/"

    foreach format {
	{H-%H}
	{u-%u}
	{md-%m%d}
    } {

	set pretty_timeval [clock format ${timestamp} -format ${format}]
	set crawler_feed_sync_dir ${crawler_feed_dir}/${pretty_timeval}/
	
	if { ![file isdirectory ${crawler_feed_sync_dir}] } {
	    file mkdir ${crawler_feed_sync_dir}
	}
	
	set crawler_feed_sync_stats ${crawler_feed_dir}/${pretty_timeval}/_stats
	incr_array_in_file ${crawler_feed_sync_stats} stats

    }

    incr_array_in_file "${crawler_feed_dir}/_stats" stats

}

proc ::feed_reader::remove_item_from_dir {item_dirVar} {

    upvar $item_dirVar item_dir

    set content_dir [get_content_dir]
    set index_dir [get_index_dir]
    set url_dir [get_url_dir]
    set log_dir [get_log_dir]
    set crawler_dir [get_crawler_dir]
    puts item_dir=$item_dir

    load_item_from_dir item item_dir
    set urlsha1 $item(urlsha1)
    set reversedomain [reversedomain [::util::domain_from_url $item(link)]]


    set crawlerfilename "${crawler_dir}/${urlsha1}"
    set logfilename ${log_dir}/${urlsha1}
    set urlfilename ${url_dir}/${urlsha1}

    catch { file delete ${crawlerfilename} }
    catch { file delete ${logfilename} }
    catch { file delete ${urlfilename} }

    set normalized_link [get_value_if item(normalized_link) $item(link)]
    set item_dir [get_item_dir normalized_link]
    set revision_files [get_revision_files item_dir]
    foreach revisionfilename ${revision_files} {

	set contentsha1 [file tail ${revisionfilename}]
	array set revision [::util::readfile ${revisionfilename}]

	set indexfilename ${index_dir}/${contentsha1}
	set indexfilename_newdata [join [lsearch -not -inline -all [::util::readfile ${indexfilename}] ${urlsha1}] "\n"]

	if { ${indexfilename_newdata} eq {} } {

	    file delete ${indexfilename}
	    set contentfilename ${content_dir}/${contentsha1}
	    file delete ${contentfilename}

	} else {

	    ::util::writefile ${indexfilename} ${indexfilename_newdata}

	}

	file delete ${revisionfilename}

    }

    file delete ${item_dir}

    unset item
}

proc ::feed_reader::remove_feed_items {feedVar} {

    upvar $feedVar feed
    
    set domain_dir [get_domain_dir $feed(url)]

    set item_dirs [glob -directory ${domain_dir}/ *]
    foreach item_dir ${item_dirs} {
	remove_item_from_dir item_dir
    }

    file delete ${domain_dir}


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


    set domain [::util::domain_from_url ${feed_url}]



    set links [${doc} selectNodes {values(//a[@href]/@href)}]

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
	    {[PQR-]{2,}} {T}
	    {(Po|oP|Qo|oQ|Ro|oR)+} {o}
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
	    {P}    {([[:lower:]]+)}
	    {Q}    {([[:upper:]]+)}
	    {R} {([[:alpha:]]+)}
	    {T} {.*}
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
	    set inline_match [lrange [regexp -inline -- ${include_re} ${path}] 1 end]

	    if { ${inline_match} ne {} } {
		
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

	    set re {\(\[\[:[a-z]+:\]\]\+\)}
	    foreach inline_part ${max_inline_match} inline_part2 ${second_best_inline_match} {
		if { ${inline_part2} ne {} && ${inline_part} ne ${inline_part2} } {
		    set inline_part {[[:alpha:]]+}
		}
		# finds and substitutes first match
		regsub -- ${re} ${include_re} ${inline_part} include_re
	    }

	}
	puts "---"
	puts include_re=${include_re}

    } else {

	puts "sorry, could not generate feed, could not figure out url_shape"

    }


    $doc delete

    ########### fetch article

    if { ${include_re} ne {} } {
	set matching_paths [lrange ${paths} 0 9]
	#set matching_paths [lindex ${matching_paths} 0]
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

	    set xpath [$maxnode toXPath]
	    puts xpath=$xpath
	    set ancestors [$maxnode selectNodes [concat ${xpath} / {ancestor::*[@class or @id][1]}]]
	    #set ancestors [$maxnode parentNode]

	    foreach ancestor ${ancestors} {
		set ancestor_tagname [${ancestor} tagName]
		set tagname [${maxnode} tagName]
		set xpath "//${ancestor_tagname}"
		set xpath_list [list]
		foreach att [$ancestor attributes] {
		    if { ${att} ni {id class style} } {
			continue
		    }
		    lappend xpath_list "@${att}=\"[$ancestor getAttribute ${att}]\""
		}
		if { ${xpath_list} ne {} } {
		    append xpath "\[[join ${xpath_list} { and }]\]"
		} else {
		    continue
		}
		
		append xpath "/descendant::${tagname}"
		set xpath_list [list]
		foreach att [$maxnode attributes] {
		    if { ${att} ni {id class style} } {
			continue
		    }
		    lappend xpath_list "@${att}=\"[$maxnode getAttribute ${att}]\""
		}
		if { ${xpath_list} ne {} } {
		    append xpath "\[[join ${xpath_list} { and }]\]"
		}
		set xpath_article_body "returntext(${xpath})"
		puts "xpath_article_body=${xpath_article_body}"
	    }


	    ${doc} delete


	}



    }


}


proc ::feed_reader::bte_helper {resultVar node} {

    upvar $resultVar result

    if { ${node} eq {} || [${node} nodeType] ne {ELEMENT_NODE} } {
	return 0
    }

    set len [string length [$node text]]

    foreach child [${node} childNodes] {
	incr len [expr { [bte_helper result ${child}] / 10 }]
    }

    if { ${len} > $result(maxlen) } {
	set result(maxlen) ${len}
	set result(maxnode) ${node}
    }

    return ${len}

}

# body text extraction
proc ::feed_reader::bte {resultVar doc} {

    upvar $resultVar result

    foreach cleanup_xpath {
	{//head}
	{//script}
	{//style}
	{//link}
	{//iframe}
    } {
	foreach cleanup_node [${doc} selectNodes ${cleanup_xpath}] {
	    ${cleanup_node} delete
	}
    }

    set result(maxlen) 0
    set result(maxnode) {}
    return [bte_helper result [${doc} selectNodes {//body[1]}]]

}
