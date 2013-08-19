package provide feed_procs 0.1

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri
package require sha1

::xo::lib::require util_procs

namespace eval ::dom::xpathFunc {

    array set mapping [list]

    set dir [file dirname [info script]]
    set mapping_dir [file normalize [file join ${dir} .. data]]

    set filelist [glob -nocomplain -directory ${mapping_dir} *]

    foreach filename ${filelist} {
	set locale [string trimleft [file extension ${filename}] {.}]
	set mapping(${locale}) [::util::readfile ${filename}]
    }

}


proc ::dom::xpathFunc::normalizedate {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] != 4 } {
	error "normalizedate(string): wrong # of args"
    }


    lassign ${args} \
	arg1Typ arg1Value \
	arg2Typ arg2Value


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
    }

    return [list string ${ts_string}]

}


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

    set stoptitles [list]
    foreach title [split [::util::readfile stoptitles.txt] "\n"] {
	lappend stoptitles [trim_title ${title}]
    }
    
    set end_of_text_strings [list]
    foreach end_of_text_string [split [::util::readfile article_body_end_of_text_strings] "\n"] {
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

    set nodes [$doc selectNodes ${xpath_feed_item}]

    set nodes2 [list]
    array set title_for_href [list]
    foreach node $nodes {

	# turn relative urls into absolute urls and canonicalize	
	# TODO: consider using urldecode, problem is decoded string might need to be
	# converted from another encoding, i.e. encoding convertfrom url_decoded_string
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
				 {}]

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


    array set item [list \
			link $link \
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

    if { [catch {set errorcode [fetch_item_helper ${link} ${title_in_feed} feed item]} errmsg] } {

	puts errmsg=$errmsg

	array set item [list \
			    link $link \
			    title $title_in_feed \
			    status failure \
			    errno 1 \
			    errmsg $errmsg]

	return 1 ;# failed with errors
    }

    return $errorcode
}

proc ::feed_reader::get_base_dir {} {
    return {/web/data/crawldb}
}

proc ::feed_reader::get_domain_dir {link} {

    set domain [::util::domain_from_url ${link}]

    set reversehost [join [lreverse [split $domain {.}]] {.}]

    return [get_base_dir]/site/${reversehost}
}

proc ::feed_reader::get_urlsha1 {link} {
    set urlsha1 [::sha1::sha1 -hex ${link}]
    return ${urlsha1}
}

proc ::feed_reader::get_item_dir {link {urlsha1Var ""}} {

    upvar ${urlsha1Var} urlsha1

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

proc ::feed_reader::get_revision_filename {item_dir index} {

    set filelist [glob -directory ${item_dir} *]
    set sortedlist [lsort -decreasing -command compare_mtime ${filelist}]
    set filename [lindex ${filelist} ${index}]
    reeturn ${filename}

}


# load latest revision in item_dir
# TODO: fix me
proc ::feed_reader::load_item_from_dir {itemVar item_dir} {
    upvar $itemVar item

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
	    load_item_from_dir item ${item_dir}

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

    return [file isdirectory [get_item_dir ${link}]]

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

    puts [format "%13s %40s %40s %24s %3s %s" timestamp urlsha1 contentsha1 domain "" title]

}

proc ::feed_reader::print_log_entry {itemVar} {
    upvar $itemVar item

    set domain [::util::domain_from_url $item(link)]

    set is_copy_or_rev_string ""
    if { [get_value_if item(is_copy_p) 0] } {
	append is_copy_or_rev_string "(*)"
    }
    if { [get_value_if item(is_revision_p) 0] } {
	append is_copy_or_rev_string "upd"
    }

    puts [format "%13s %40s %40s %24s %3s %s" $item(date) $item(contentsha1) $item(urlsha1) ${domain} ${is_copy_or_rev_string} $item(title)]
    #puts [list $item(link)]
}

proc ::feed_reader::show_item {urlsha1} {
    load_item item ${urlsha1}
    print_item item
}

proc ::feed_reader::show_item_from_url {link} {
    
    set urlsha1 [::sha1::sha1 -hex ${link}]
    load_item item ${urlsha1}
    print_item item
}

proc ::feed_reader::write_item {link feedVar itemVar resync_p} {
    upvar $feedVar feed
    upvar $itemVar item

    # prepare to write
    set content_dir [get_content_dir]
    set index_dir [get_index_dir]
    set item_dir [get_item_dir ${link} urlsha1]
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


    # save article body to content file
    # TODO: each image,attachment,video,etc should get its own content file in the future
    set content [list $item(title) $item(body)]
    set contentsha1 [::sha1::sha1 -hex ${content}]

    set crawlerfilename "${crawler_dir}/${urlsha1}"
    close [open ${crawlerfilename} "w"]


    #set itemfilename "item/${urlsha1}"
    set revisionfilename ${item_dir}/${contentsha1}

    if { [file exists ${revisionfilename}] } {
	# revision content is the same as a previous one
	# no need to overwrite the revisionfilename,
	# nor the contentfilename and indexfilename
	#
	# note that if were keeping track of metadata changes
	# then it would make sense to overwrite the logfilename
	# and the urlfilename
	return
    }

    set timestamp [clock seconds] 

    if { ${resync_p} } {
	set item(is_revision_p) 1
	set item(first_sync) [get_first_sync_timestamp $item(link)]
	set item(last_sync) ${timestamp}
    }

    set contentfilename ${content_dir}/${contentsha1}
    set indexfilename ${index_dir}/${contentsha1}
    set logfilename ${log_dir}/${urlsha1}
    set urlfilename ${url_dir}/${urlsha1}

    if { [file exists ${contentfilename}] } {
	# we have seen this item before from a different url
	set item(is_copy_p) 1
    } else {
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


proc get_first_sync_timestamp {link} {

    upvar $linkVar link

    set item_dir [get_item_dir ${link} urlsha1]
    set revisionfilename [get_revision_filename ${item_dir} end]  ;# oldest revision
    return [file mtime ${revisionfilename}]

}


proc get_last_sync_timestamp {linkVar} {

    upvar $linkVar link

    set urlsha1 [get_urlsha1 ${link}]
    set crawler_dir [get_crawler_dir]
    set crawlerfilename "${crawler_dir}/${urlsha1}"
    return [file mtime ${crawlerfilename}]

}

proc ::feed_reader::auto_resync_p {feedVar link} {

    upvar $feedVar feed

    set first_sync [get_first_sync_timestamp link]
    set last_sync [get_last_sync_timestamp link]


    # check for revisions every hour but 
    # not for more than a day after the first sync
    if { ${now} - ${last_sync} > 3600 && ${now} - ${first_sync} < 86400 } {
	return 1
    }

    return 0
}

proc ::feed_reader::sync_feeds {feedsVar {feed_names ""}} {

    upvar $feedsVar feeds

    variable stoptitles

    if { ${feed_names} eq {} } {
	set feed_names {
	    philenews
	    sigmalive
	    paideia-news
	    inbusiness
	    ant1iwo
	    24h
	    stockwatch
	    newsit
	    alitheia
	    politis
	    pafosnet
	}
    }

    #haravgi
    foreach feed_name ${feed_names} {

	array set feed [dict get ${feeds} ${feed_name}]

	# set feed_type [get_value_if feed(type) ""] 
	# if { ${feed_type} eq {rss} } {
	# set feed(xpath_feed_item) //item
	# }

	set errorcode [fetch_feed result feed stoptitles]
	if { ${errorcode} } {
	    puts "fetch_feed failed errorcode=$errorcode feed_name=$feed_name"
	    continue
	}

	set can_resync_p [get_value_if feed(check_for_revisions) "0"]

	foreach link $result(links) title_in_feed $result(titles) {
	    #puts ""
	    #puts ${title_in_feed}
	    #puts ${link}
	    #puts "---"

	    #continue
	    
	    # TODO: if it exists and it's the first item in the feed,
	    # fetch it and compare it to stored item to ensure sanity
	    # of feed/article/page
	    set resync_p 0
	    if { ![exists_item ${link}] || ( ${can_resync_p} && [set resync_p [auto_resync feed ${link}]] ) } {

		set errorcode [fetch_item ${link} ${title_in_feed} feed item]
		if { ${errorcode} } {
		    puts "--->>> error ${link}"
		    # incr errorCount
		    continue
		}

		write_item ${link} feed item

		unset item

	    }

	}

	unset feed

    }
}


proc ::feed_reader::resync {feedsVar} {

    upvar $feedsVar feeds

    get_logfilelist sortedlist

    foreach logfilename ${sortedlist} {

	array set old_item [::util::readfile ${logfilename}]
	array set feed [dict get ${feeds} $old_item(feed_name)]

	set errorcode [fetch_item ${link} $old_item(title) feed new_item]
	if { ${errorcode} } {
	    puts "--->>> error ${link}"
	    # write_error_item new_item
	    # incr errorCount
	    continue
	}

	# if distance between old and new item is great, then skip writing
	write_item ${link} feed new_item

	unset old_item
	unset new_item

    }

}


::feed_reader::init
