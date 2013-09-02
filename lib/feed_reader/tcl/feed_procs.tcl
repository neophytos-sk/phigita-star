namespace eval ::feed_reader {

    array set meta [list]
    array set stoptitles [list]
    array set stopwords [list]

}


proc ::feed_reader::init {} {

    variable meta
    variable stoptitles
    variable stopwords

    read_meta meta

    if { $meta(stoptitles) ne {} } {
	foreach title $meta(stoptitles) {
	    set stoptitles(${title}) 1
	}
    }

    if { $meta(stopwords) ne {} } {
	foreach token $meta(stopwords) {
	    set stopwords(${token}) 1
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
    
    set stopwords [::util::readfile ${conf_dir}/stopwords.txt]

    set end_of_text_strings [list]
    foreach end_of_text_string [split [::util::readfile ${conf_dir}/article_body_end_of_text_strings] "\n"] {
	if { ${end_of_text_string} ne {} } {
	    lappend end_of_text_strings ${end_of_text_string}
	}
    }

    array set meta \
	[list \
	     stoptitles ${stoptitles} \
	     end_of_text_strings ${end_of_text_strings} \
	     stopwords ${stopwords}]

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

    set xpath_feed_item [get_value_if \
			     feed(xpath_feed_item) \
			     {//a[@href]}]

    set feed_type [get_value_if \
		       feed(feed_type) \
		       {html}]

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

    if { ${feed_type} eq {html} } {
	set doc [dom parse -html ${html}]
    } elseif { ${feed_type} in {rss} } {
	set doc [dom parse ${html}]
    }


    foreach cleanup_xpath ${xpath_feed_cleanup} {
	foreach cleanup_node [${doc} selectNodes $cleanup_xpath] {
	    $cleanup_node delete
	}	    
    }

    set link_stoplist [get_value_if feed(link_stoplist) ""]

    set item_nodes [$doc selectNodes ${xpath_feed_item}]

    set nodes2 [list]
    array set title_for_href [list]
    foreach item_node $item_nodes {

	set tagname [$item_node tagName]
	if { ${tagname} eq {a} } {
	    set href [${item_node} @href ""]
	} elseif { ${tagname} eq {item} } {
	    set href [${item_node} selectNodes {string(descendant::link/text())}]
	} else {
	    error "unrecognized item tag"
	}

	# turn relative urls into absolute urls and canonicalize	
	# TODO: consider using urldecode, problem is decoded string might need to be
	# converted from another encoding, i.e. encoding convertfrom url_decoded_string
	set href [::uri::canonicalize [::uri::resolve ${url} ${href}]]

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

	# needed for sorting
	${item_node} setAttribute href ${href}

	if { ${tagname} eq {a} } {
	    set title [get_title stoptitles ${item_node}]
	} elseif { ${tagname} eq {item} } {
	    set title [${item_node} selectNodes {string(//title/text())}]
	}

	if { ![info exists title_for_href(${href})] } {
	    # coalesce title candidate values
	    set title_for_href(${href}) ${title}
	} else {
	    set title_for_href(${href}) [lsearch -inline -not [list ${title} $title_for_href(${href})] {}]
	}


	lappend nodes2 ${item_node}

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
	set result [string trim [${doc} selectNodes "${xpath}"] " \n\r\t"]
    }

}


proc ::feed_reader::get_video_id_from_iframe_src {url} {
    set ref_video_id ""
    foreach {provider re} {
	youtube {//www.youtube.com/embed/([0-9a-zA-Z_\-]+)(?:[?])(?:&?[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\-]*)*$}
    } {
	if { [regexp -- ${re} ${url} __match__ ref_video_id] } {
	    return ${ref_video_id}.${provider}
	}
    }
    return
}


proc ::feed_reader::is_video_url_p {video_url output_video_idVar} {
    upvar $output_video_idVar video_id

    set video_id [get_video_id_from_iframe_src ${video_url}]
    if { ${video_id} ne {} } {
	return 1
    }

    return 0
}


proc ::feed_reader::fetch_item_helper {link title_in_feed feedVar itemVar infoVar} {

    upvar $feedVar feed
    upvar $itemVar item
    upvar $infoVar info

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

    set xpath_article_prefix [get_value_if feed(xpath_article_prefix) ""]

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
				 {values(//iframe[@src]/@src)}]

    ::util::prepend ${xpath_article_prefix} xpath_article_video

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

    array set options [get_value_if feed(http_options) ""]
    set errorcode [::xo::http::fetch html ${link} options info]
    unset options

    if { ${errorcode} } {
	return ${errorcode}
    }

    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_article_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    if { [catch {
	set doc [dom parse -html ${html}]
    } errmsg] } {
	puts errmsg=$errmsg
	return -2 ;# error parsing article html
    }

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
		if { [is_video_url_p ${video_url} video_url_rewritten] } {
		    lappend article_video ${video_url_rewritten}
		}
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
	    if { ${cleanup_node} ne {} } {
		# might have been deleted inside another node
		catch { ${cleanup_node} delete }
	    }
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
		set index 0
	    }
	}
    }

    set article_langclass [get_value_if feed(article_langclass) "el.utf8"]

    if { ${article_langclass} eq {auto} } {
	set article_langclass [::ttext::langclass "$article_title $article_body"]
    }

    set domain [::util::domain_from_url ${link}]

    set body_length [string length ${article_body}]

    array set item [list \
			domain ${domain} \
			link $link \
			langclass $article_langclass \
			title $article_title \
			description $article_description \
			body $article_body \
			body_length ${body_length} \
			tags ${article_tags} \
			author $author_in_article \
			image $article_image \
			video $article_video \
			attachment $article_attachment \
			date $article_date \
			modified_time $article_modified_time]


    $doc delete

    if { ${body_length} == 0 } {
	# puts "--->>> zero-length body"
	return -1 ;# error due to zero-length body
    }

    return 0 ;# no errors
}


proc ::feed_reader::get_cookielist_and_try_again {link title_in_feed feedVar itemVar infoVar} {

    error "not good enough - improve and make it work with handle_redirect_item"

    upvar $feedVar feed
    upvar $itemVar item
    upvar $infoVar info

    if { [get_value_if feed(article_redirect_policy) ""] eq {GET_COOKIELIST_AND_TRY_AGAIN} } {

	set redirect_url [get_value_if info(redirecturl) ""]

	if { ${redirect_url} ne {} } {
	    
	    if { [catch {

		set redirect_retcode [::xo::http::fetch _dummy_ ${redirect_url} "" redirect_info]

	    } errmsg] } {

		puts "--->>> tried redirect but it failed redirect_info=[array get redirect_info] errmsg=$errmsg"

	    } else {

		#redirect succeeded, get the cookielist and try again
		puts "redirect_info=[array get redirect_info]"

	    }

	}

    }

}

proc ::feed_reader::handle_redirect_item {link title_in_feed feedVar itemVar infoVar redirect_count} {
    upvar $feedVar feed
    upvar $itemVar item
    upvar $infoVar info

    if { ${redirect_count} <= 1} {

	set redirect_url $info(redirecturl)

	# 1. mark given link as a redirect item

	set item(urlsha1) [get_urlsha1 ${link}]
	set item(responsecode) $info(responsecode)
	set item(redirect_url) ${redirect_url}

	::persistence::insert_column         \
	    "newsdb"                         \
	    "news_item/by_urlsha1_and_const" \
	    "$item(urlsha1)"                 \
	    "_data_"                         \
	    "[array get item]"

	unset item

	# 2. fetch item at redirect url

	array set item [list]

	return [fetch_item ${redirect_url} ${title_in_feed} feed item info [incr redirect_count]]

    }

    return 1 ;# failure or no redirect
}


proc ::feed_reader::fetch_item {link title_in_feed feedVar itemVar infoVar {redirect_count "0"}} {

    upvar $feedVar feed
    upvar $itemVar item
    upvar $infoVar info

    if { [get_value_if feed(article_link_urlencode_p) "0"] } {
	array set uri [::uri::split ${link}]
	set ue_path [::util::urlencode $uri(path)]
	set ue_link "$uri(scheme)://$uri(host)/${ue_path}"
	if { $uri(query) ne {} } {
	    append ue_link "?$uri(query)"
	}
	set link ${ue_link}
    }

    if { [catch {

	set retcode [fetch_item_helper ${link} ${title_in_feed} feed item info]

    } errmsg] } {

	puts errmsg=$errmsg

	array set item [list \
			    link $link \
			    title $title_in_feed \
			    status failure \
			    errno 1 \
			    errmsg $errmsg]

	return -3 ;# failed with errors
    }

    if { [get_value_if info(responsecode) ""] eq {302} && [get_value_if feed(handle_redirect_item_p) "0"] } {

	return [handle_redirect_item ${link} ${title_in_feed} feed item info ${redirect_count}]

    }

    return ${retcode}
}


namespace eval ::feed_reader {

    array set errorcode_messages {

	-3
	{failed during information extraction from article}

	-2
	{dom parse error for article html}

	-1 
	{zero-length body}

	1 
	{Unsupported protocol. This build of TclCurl has no support for this protocol.}
	
	2 
	{Very early initialization code failed. This is likely to be and internal error or problem.}

	3
	{URL malformat. The syntax was not correct.}

	4
	{URL user malformatted. The user-part of the URL syntax was not correct.}

	5
	{Couldn't resolve proxy. The given proxy host could not be resolved.}

	6
	{Couldn't resolve host. The given remote host was not resolved.}

	7
	{Failed to connect to host or proxy.}

	8
	{FTP weird server reply. The server sent data TclCurl couldn't parse. The given remote server is probably not an OK FTP server.}

	9
	{We were denied access when trying to login to a FTP server or when trying to change working directory to the one given in the URL.}

	10
	{FTP user/password incorrect. Either one or both were not accepted by the server.}

	11
	{FTP weird PASS reply. TclCurl couldn't parse the reply sent to the PASS request.}

	12
	{FTP weird USER reply. TclCurl couldn't parse the reply sent to the USER request.}

	13
	{FTP weird PASV reply, TclCurl couldn't parse the reply sent to the PASV request.}

	14
	{FTP weird 227 format. TclCurl couldn't parse the 227-line the server sent.}

	15
	{FTP can't get host. Couldn't resolve the host IP we got in the 227-line.}

	16
	{FTP can't reconnect. A bad return code on either PASV or EPSV was sent by the FTP server, preventing TclCurl from being able to continue.}

	17
	{FTP couldn't set binary. Couldn't change transfer method to binary.}

	18
	{Partial file. Only a part of the file was transfered, this happens when the server first reports an expected transfer size and then delivers data that doesn't match the given size.}

	19
	{FTP couldn't RETR file, we either got a weird reply to a 'RETR' command or a zero byte transfer.}

	20
	{FTP write error. After a completed file transferm the FTP server did not respond properly.}

	21
	{FTP quote error. A custom 'QUOTE' returned error code 400 or higher from the server.}

	22
	{HTTP not found. The requested page was not found. This return code only appears if --fail is used and the HTTP server returns an error code that is 400 or higher.}

	23
	{Write error. TclCurl couldn't write data to a local filesystem or an error was returned from a write callback.}

	24
	{Malformat user. User name badly specified. Not in use anymore}

	25
	{FTP couldn't STOR file. The server denied the STOR operation, the error buffer will usually have the server explanation.}

	26
	{Read error. There was a problem reading from a local file or an error was returned from the read callback.}

	27
	{Out of memory. A memory allocation request failed. This should never happen unless something weird is going on in your computer.}

	28
	{Operation timeout. The specified time-out period was reached according to the conditions.}

	29
	{FTP couldn't set ASCII. The server returned an unknown reply.}

	30
	{FTP PORT command failed, this usually happens when you haven't specified a good enough address for TclCurl to use.}

	31
	{FTP couldn't use REST. This should never happen is the server is sane.}

	32
	{FTP couldn't use the SIZE command. The command is an extension to the original FTP spec RFC 959, so not all servers support it.}

	33
	{HTTP range error. The server doesn't support or accept range requests.}

	34
	{HTTP post error. Internal post-request generation error.}

	35
	{SSL connect error. The SSL handshaking failed, the error buffer may have a clue to the reason, could be certificates, passwords, ...}

	36
	{FTP bad download resume. Couldn't continue an earlier aborted download, probably because you are trying to resume beyond the file size.}

	37
	{A file given with FILE:// couldn't be read. Did you checked the permissions?}

	38
	{LDAP cannot bind. LDAP bind operation failed.}

	39
	{LDAP search failed.}

	40
	{Library not found. The LDAP library was not found.}

	41
	{A required LDAP function was not found.}

	42
	{Aborted by callback. An application told TclCurl to abort the operation.}

	43
	{Internal error. A function was called with a bad parameter.}

	44
	{Internal error. A function was called in a bad order.}

	45
	{Interface error. A specified outgoing interface could not be used.}

	46
	{Bad password entered. An error was signalled when the password was entered.}

	47
	{Too many redirects. When following redirects, TclCurl hit the maximum amount, set your limit with --maxredirs}

	48
	{Unknown TELNET option specified.}

	49
	{A telnet option string was illegally formatted.}

	50
	{Currently not used.}

	51
	{The remote peer's SSL certificate wasn't ok}

	52
	{The server didn't reply anything, which here is considered an error.}

	53
	{The specified crypto engine wasn't found.}

	54
	{Failed setting the selected SSL crypto engine as default!}

	55
	{Failed sending network data.}

	56
	{Failure with receiving network data.}

	57
	{Share is in use (internal error)}

	58
	{Problem with the local certificate}

	59
	{Couldn't use specified SSL cipher}

	60
	{Problem with the CA cert (path? permission?)}

	61
	{Unrecognized transfer encoding}

    }


}

proc ::feed_reader::translate_error_code {error_code} {

    variable errorcode_messages

    return [get_value_if errorcode_messages(${error_code}) ""]

}

proc ::feed_reader::fetch_and_write_item {timestamp link title_in_feed feedVar} {

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

	set errorcode [fetch_item ${link} ${title_in_feed} feed item info]
	if { ${errorcode} } {

	    set error_message [translate_error_code ${errorcode}]

	    puts "--->>> errorcode=$errorcode error_message=${error_message}"
	    puts "--->>> error ${link}"
	    puts "--->>> info=[array get info]"

	    set urlsha1 [get_urlsha1 ${link}]
	    set errordata [list \
			       errorcode ${errorcode} \
			       link ${link} \
			       urlsha1 ${urlsha1} \
			       http_fetch_info [array get info] \
			       title_in_feed ${title_in_feed} \
			       item [array get item]]


	    ::persistence::insert_column \
		"newsdb" \
		"error_item/by_urlsha1_and_timestamp" \
		"${urlsha1}"\
		"${timestamp}" \
		"${errordata}"

	    set slicelist \
		[::persistence::get_slice \
		     "newsdb" \
		     "error_item/by_urlsha1_and_timestamp" \
		     "[get_urlsha1 ${link}]"]

	    if { [llength ${slicelist}] >= 3 } {

		puts "--->>> marking this item as fetched... (${urlsha1})"

		::persistence::insert_column \
		    "newsdb" \
		    "news_item/by_urlsha1_and_const" \
		    "${urlsha1}" \
		    "_data_" \
		    "${errordata}"

	    }
			       


	    # unset item
	    # unset info
	    return {ERROR_FETCH}
	}

	if { ${normalized_link} ne ${link} } {
	    set item(normalized_link) ${normalized_link}
	}

	if { $item(link) ne ${link} } {
	    set item(original_link) ${link}
	}

	set written_p [write_item ${timestamp} ${normalized_link} feed item ${resync_p}]
	
	#unset item
	#unset info

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

proc ::feed_reader::get_urlsha1 {link} {
    set urlsha1 [::sha1::sha1 -hex ${link}]
    return ${urlsha1}
}


proc ::feed_reader::get_content_dir {} {
    return [get_base_dir]/content_item/by_contentsha1_and_const
}


proc ::feed_reader::get_crawler_dir {} {
    return [get_base_dir]/crawler
}


proc ::feed_reader::get_contentsha1_to_label_dir {} {
    # multiple urls may have the same content
    return [get_base_dir]/contentsha1_to_label
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

proc ::feed_reader::get_feed_files {news_source} {

    set feeds_dir [get_package_dir]/feed    
    set news_source_dir ${feeds_dir}/${news_source}

    set filelist [glob -directory ${news_source_dir} *]
    set sortedlist [lsort -decreasing -command compare_mtime ${filelist}]
    return ${sortedlist}

}




proc ::feed_reader::list_site {domain {offset "0"} {limit "20"}} {

    set slice_predicate [list "lrange" [list "${offset}" "${limit}"]]

    set reversedomain [reversedomain ${domain}]

    set slicelist [::persistence::get_slice         \
		       "newsdb"                     \
		       "news_item/by_site_and_date" \
		       "${reversedomain}"           \
		       "${slice_predicate}"]
    

    foreach filename ${slicelist} {
	array set item [::persistence::get_data ${filename}]
	print_log_entry item
	unset item
    }

}



proc ::feed_reader::get_contentfilelist {sortedlistVar} {

    upvar $sortedlistVar sortedlist

    set content_dir [get_content_dir]

    set contentfilelist [glob -directory ${content_dir} *]

    set sortedlist [lsort -decreasing -command compare_mtime ${contentfilelist}]

}

proc ::feed_reader::list_all {{offset "0"} {limit "20"}} {

    set predicate [list "lrange" [list "${offset}" "${limit}"]]

    set slicelist [::persistence::get_slice          \
		       "newsdb"                      \
		       "news_item/by_const_and_date" \
		       "log"                         \
		       "${predicate}"]

    print_log_header

    foreach logfilename ${slicelist} {

        array set item [::persistence::get_data ${logfilename}]
	print_log_entry item
	unset item

    }

}


proc ::util::tokenize {text} {

    set removeChars_re {[^[:alnum:]]+}
    regsub -all -- ${removeChars_re} ${text} { } text

    return [lsearch -inline -all -not [split [string tolower [::ttext::unaccent utf-8 ${text}]]] {}]
}


proc ::util::recognize_date_format {text {locales {en_US el_GR}} {normalize_text_p 1}} {

    regsub -all -- {[^[:alnum:]\:]} ${text} { } stripped_text

    foreach locale ${locales} {

	set normalized_text $stripped_text

	if { ${normalize_text_p} } {
	    ::dom::xpathFunc::normalizedate_helper normalized_text ${locale}
	}
	
	foreach date_format {
	    "%Y %N %d"
	    "%d %N %Y"
	    "%N %d %Y"
	    "%d %B %Y"
	    "%d %b %Y"
	    "%A %d %B %Y"
	    "%a %d %B %Y"
	} {
	    foreach time_format {
		""
		" %H:%M"
		" %k:%m"
		" %l:%m"
		" %l:%m"
		" %H:%M:%S"
		" %k:%m:%S"
		" %l:%m:%S"
		" %l:%m:%S"
	    } {
		foreach ampm_format {
		    ""
		    " %p"
		    " %P"
		} {

		    set format "${date_format}${time_format}${ampm_format}"
		    
		    if { ![catch { set timeval [clock scan ${normalized_text} -format ${format} -locale ${locale}] } errmsg] } {
			return [list ${format} ${locale} ${timeval}]
		    }
		}
	    }
	}
    }
}

proc ::util::tokenize_date {text} {

    set tokens [list]

    set len [string length ${text}]

    if { ${len} < 40 } {

	set tokens [::util::tokenize ${text}]

	set recognizer_result [::util::recognize_date_format ${text} timeval]
	if { ${recognizer_result} ne {} } {

	    lassign ${recognizer_result} format locale timeval

	    set tokens \
		[concat ${tokens} \
		     [clock format ${timeval} \
			  -format "%a %A %b %B %p %P" \
			  -locale ${locale}]]

	    # puts "matched_date format=${format} = tokens=${tokens}"
			
	    return ${tokens}
	}

    }
    
    return ${tokens}
}


proc ::feed_reader::search {keywords {offset "0"} {limit "20"} {callback ""}} {


    set first ${offset}

    set last "end"
    if { ${limit} ne {} } {
	set last [expr { ${offset} + ${limit} - 1 }]
    }

    set multirow \
	[::persistence::get_multirow \
	     "newsdb" \
	     "content_item/by_contentsha1_and_const"]

    puts [format "%40s %s" contentsha1 title]

    foreach contentdir ${multirow} {

	set contentsha1 [file tail ${contentdir}]

	#puts ${contentsha1}


	load_content item ${contentsha1}

	set tokens_title [::util::tokenize $item(title)] 
	set tokens_body [::util::tokenize $item(body)] 
	set tokens_keywords [::util::tokenize $keywords]

	set not_found \
	    [ldifference \
		 ${tokens_keywords} \
		 [concat \
		      ${tokens_title} \
		      ${tokens_body}]]

	if { ${not_found} eq {} } {
	    if { [incr num_found] <= 1 + ${last} } {
		if { ${num_found} > ${first} } {
		    if { ${first} > 0 } {
			puts ""
		    }

		    puts "${contentsha1} $item(title)"

		    if { $callback ne {} } {
			lassign ${callback} cmd args
			search_callback=${cmd} ${contentsha1} {*}${args}
		    }

		} else {
		    if { ${first} > 0 } {
			puts -nonewline "."
		    }
		}
	    } else {
		break
	    }
	}
	unset item

    }



}

proc ::feed_reader::search_callback=label_menu {contentsha1 axis label} {

    set menulabels [classifier::get_label_names ${axis}]
    set menuindex 0
    foreach menulabel ${menulabels} {
	puts "${menuindex}. ${menulabel}"
	incr menuindex
    }
    
    puts "--->>> please enter 'y' to classify it in ${label} or 'n' to skip this item"
    set selection [gets stdin 2]
    puts "your selection is ${selection}"

}

proc ::feed_reader::confirm {} {

    while { [set reply [gets stdin]] ni {y n yes no t f true false 0 1} } {
    }

    return [::util::boolean ${reply}]

}


proc ::feed_reader::search_callback=label_content {contentsha1 axis label} {

    ::persistence::get_column \
	"newsdb"\
	"content_item/by_contentsha1_and_const" \
	"${contentsha1}" \
	"_data_" \
	"column_data"

    ::naivebayes::wordcount_helper count column_data true ;# filter_stopwords
    ::naivebayes::print_words [::naivebayes::wordcount_topN count 40]

    if { [confirm] } {

	::persistence::insert_column \
	    "newsdb" \
	    "classifier/${axis}" \
	    "${label}" \
	    "${contentsha1}" \
	    ""

    }

}


proc ::feed_reader::label_interactive {axis label keywords {offset "0"} {limit "20"}} {
puts axis=$axis
puts label=$label
puts keywords=$keywords
puts offset=$offset
puts limit=$limit

    set callback [list "label_menu" [list ${axis} ${label}]]

    search ${keywords} ${offset} ${limit} ${callback}

}


proc ::feed_reader::label_batch {axis label keywords {offset "0"} {limit "20"}} {
puts axis=$axis
puts label=$label
puts keywords=$keywords
puts offset=$offset
puts limit=$limit

    set callback [list "label_content" [list ${axis} ${label}]]

    search ${keywords} ${offset} ${limit} ${callback}

}



proc ::feed_reader::cluster {{offset "0"} {limit "10"} {k ""} {num_iter "3"}} {

    set slice_predicate [list "lrange" [list "${offset}" "${limit}"]]

    set slicelist [::persistence::get_slice \
		       "newsdb" \
		       "news_item/by_const_and_date" \
		       "log" \
		       "${slice_predicate}"]


    set contentfilelist [list]
    foreach logfilename ${slicelist} {

        array set item [::util::readfile ${logfilename}]
	lappend contentfilelist [get_content_dir]/$item(contentsha1)/_data_

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

    set urlsha1 [get_urlsha1 ${link}]

    return [::persistence::exists_column_p \
		"newsdb" \
		"news_item/by_urlsha1_and_const" \
		"${urlsha1}" \
		"_data_"]

}


proc ::feed_reader::load_item {itemVar urlsha1} {

    upvar $itemVar item

    ::persistence::get_column            \
	"newsdb"                         \
	"news_item/by_urlsha1_and_const" \
	"${urlsha1}"                     \
	"_data_"                         \
	"column_data"

    array set item ${column_data}

    load_content item $item(contentsha1)

}

proc ::feed_reader::show_content {contentsha1_list} {

    foreach contentsha1 ${contentsha1_list} {
        load_content item ${contentsha1}
        print_item item
        unset item
    }
}


proc ::feed_reader::classify_content {axis contentsha1_list} {

    foreach contentsha1 ${contentsha1_list} {

	::persistence::get_column \
	    "newsdb" \
	    "content_item/by_contentsha1_and_const" \
	    "${contentsha1}" \
	    "_data_" \
	    "content"

	classifier::classify ${axis} content

    }


}


proc ::feed_reader::diff_content {contentsha1_old contentsha1_new} {

    load_content old_item ${contentsha1_old}
    load_content new_item ${contentsha1_new}

    puts "* title: [::util::strings::diff $old_item(title) $new_item(title)]"
    puts "* body: [::util::strings::diff $old_item(body) $new_item(body)]"

}


proc ::feed_reader::uses_content {contentsha1_list} {
    
    # what objects use given content
    # contentsha1_to_urlsha1
    foreach contentsha1 ${contentsha1_list} {

	set slicelist [::persistence::get_slice_names \
			   "newsdb" \
			   "index/contentsha1_to_urlsha1" \
			   "${contentsha1}"]

        foreach urlsha1 ${slicelist} {
            load_item item ${urlsha1}
            print_item item
        }
    }

}


proc ::feed_reader::load_content {itemVar contentsha1 {include_labels_p "1"}} {

    upvar $itemVar item

    ::persistence::get_column \
	"newsdb" \
	"content_item/by_contentsha1_and_const" \
	"${contentsha1}" \
	"_data_" \
	"column_data"

    lassign ${column_data} item(title) item(body)


    # set contentfilename [get_content_dir]/${contentsha1}
    # array set item [list]
    # lassign [::util::readfile $contentfilename] item(title) item(body)

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


proc ::util::pretty_length {chars} {

    if { ${chars} eq {} } {
	return
    }

    set result [list]

    foreach {length suffix} {
        1000000000 G
        1000000    M
        1000       k
    } {

        if { ${chars} >= ${length} } {
            set howmany [expr { ${chars} / double(${length}) }]
            set result [format "%5.1f%s" ${howmany} ${suffix}]
	    break
        }

    }

    set length 1000
    set suffix k
    set howmany [expr { ${chars} / double(${length}) }]
    set result [format "%5.1f%s" ${howmany} ${suffix}]

    return ${result}

}


proc ::feed_reader::print_log_header {} {

    puts [format "%2s %13s %40s %6s %20s %3s %3s %10s %s" lc date urlsha1 len domain "" "" topic title]

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


    load_content item $item(contentsha1)
    set content [concat $item(title) $item(body)]
    set topic [classifier::classify el.utf8.topic content]


    set lang [lindex [split [get_value_if item(langclass) "el.utf8"] {.}] 0]
    puts [format "%2s %13s %40s %6s %20s %3s %3s %10s %s" \
	      ${lang} \
	      $item(date) \
	      $item(urlsha1) \
	      [::util::pretty_length [get_value_if item(body_length) ""]] \
	      ${domain} \
	      ${is_copy_string} \
	      ${is_revision_string} \
	      ${topic} \
	      $item(title)]

}

proc ::feed_reader::show_item {urlsha1_list} {
    foreach urlsha1 ${urlsha1_list} {
	load_item item ${urlsha1}
	print_item item

	if { $item(langclass) eq {el.utf8} } {

	    set content [concat $item(title) $item(body)]
	    set item(el.utf8.topic) [classifier::classify el.utf8.topic content]

	    puts $item(el.utf8.topic)
	}


	unset item
    }
}

proc ::feed_reader::classify {axis urlsha1_list} {
    set contentsha1_list [list]
    foreach urlsha1 ${urlsha1_list} {
	load_item item ${urlsha1}
	lappend contentsha1_list $item(contentsha1)
	unset item
    }

}


proc ::feed_reader::show_revisions {urlsha1} {

    set slicelist [::persistence::get_slice       \
		       "newsdb"                   \
		       "news_item/by_urlsha1_and_contentsha1" \
		       "${urlsha1}"]

    foreach {filename} ${slicelist} {
	set timestamp [file mtime ${filename}]
	set column_name [file tail ${filename}]
	puts "${timestamp} ${column_name}"
    }

}

proc ::feed_reader::show_item_from_url {link} {
    
    set urlsha1 [::sha1::sha1 -hex ${link}]
    load_item item ${urlsha1}
    print_item item
}

proc ::feed_reader::write_item {timestamp normalized_link feedVar itemVar resync_p} {
    upvar $feedVar feed
    upvar $itemVar item

    #set timestamp [clock seconds]
    set timestamp_datetime [clock format ${timestamp} -format "%Y%m%dT%H%M"]
    set urlsha1 [::sha1::sha1 -hex $normalized_link]

    ::persistence::insert_column         \
	"crawldb"                        \
	"sync_info/by_urlsha1_and_const" \
	"${urlsha1}"                     \
	"${timestamp_datetime}"          \
	""


    set content [list $item(title) $item(body)]
    set contentsha1 [::sha1::sha1 -hex ${content}]

    set exists_revision_p \
	[::persistence::exists_column_p \
	     "newsdb"                   \
	     "news_item/by_urlsha1_and_contentsha1" \
	     "${urlsha1}"               \
	     "${contentsha1}"]


    if { ${exists_revision_p} } {
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

    # TODO: each image,attachment,video,etc should get its own content file in the future


    set contentfilename \
	[::persistence::get_column                   \
	     "newsdb"                                \
	     "content_item/by_contentsha1_and_const" \
	     "${contentsha1}"                        \
	     "_data_"]

    if { [::persistence::exists_data_p ${contentfilename}] } {

        # we have seen this item before from a different url
        set item(is_copy_p) 1

    } else {

	::persistence::set_data ${contentfilename} ${content}

    }


    set item(timestamp) ${timestamp}
    set item(urlsha1) ${urlsha1}
    set item(contentsha1) ${contentsha1}

    set reversedomain [reversedomain [::util::domain_from_url ${normalized_link}]]


    array unset item body




    set item(sort_date) ""

    if { [get_value_if item(date) ""] ne {} } {

        lassign [split $item(date) {T}] date time

        if { ${time} ne {0000} } {

            # up to 15mins difference in time it is considered to be
	    # fine to take into account servers at different timezones
	    #
	    # abs is to account for news sources that set a time in the
	    # future be it due to timezone difference or deliberately
	    #

	    set timeval [clock scan $item(date) -format "%Y%m%dT%H%M"]

            if { ${timestamp} - ${timeval} > 900 } {

		set item(sort_date) $item(date)
                # puts "item(date)=$item(date) is older than 15 mins - using that date for sorting..."

            }

	    # otherwise, including item(date) in the future,
	    # use computed date for sorting


        } else {

	    # if time eq {0000} and
	    set timestamp_date [lindex [split ${timestamp_datetime} {.}] 0]
	    if { ${date} ne ${timestamp_date} } {

		set item(sort_date) $item(date)

	    } else {

		# use computed date for sorting

	    }

	}

    } else {

	# use computed date for sorting

    }

    if { $item(sort_date) eq {} } {
	set item(sort_date) ${timestamp_datetime}
    }



    set data [array get item]


    # contentsha1 to urlsha1, i.e. which links lead to the same content
    # TODO: consider having simhash

    ::persistence::insert_column \
	"newsdb" \
	"index/contentsha1_to_urlsha1" \
	"${contentsha1}" \
	"${urlsha1}" \
	""

    ::persistence::insert_column         \
	"newsdb"                         \
	"news_item/by_urlsha1_and_const" \
	"${urlsha1}"                     \
	"_data_"                         \
	"${data}"


    set slicelist \
	[::persistence::get_slice       \
	     "newsdb"                   \
	     "index/urlsha1_to_date_sk" \
	     "${urlsha1}"]

    # there should only be one column
    # but since this is still under development
    # we might have missed some and thus
    # why the need for the loop

    foreach filename ${slicelist} {

	set column_name [::persistence::get_name ${filename}]

	::persistence::delete_data ${filename}

	::persistence::delete_column      \
	    "newsdb"                      \
	    "news_item/by_const_and_date" \
	    "log"                         \
	    "${column_name}"

	::persistence::delete_column       \
	    "newsdb"                       \
	    "news_item/by_site_and_date"   \
	    "${reversedomain}"             \
	    "${column_name}"

    }

    ::persistence::insert_column      \
	"newsdb"                      \
	"news_item/by_const_and_date" \
	"log"                         \
	"$item(sort_date).${urlsha1}" \
	"${data}"


    ::persistence::insert_column       \
	"newsdb"                       \
	"news_item/by_site_and_date"   \
	"${reversedomain}"             \
	"$item(sort_date).${urlsha1}"  \
	"${data}"

    ::persistence::insert_column \
	"newsdb" \
	"index/urlsha1_to_date_sk" \
	"${urlsha1}" \
	"$item(sort_date).${urlsha1}" \
	""

    ::persistence::insert_column   \
	"newsdb"                   \
	"news_item/by_urlsha1_and_contentsha1" \
	"${urlsha1}"               \
	"${contentsha1}"           \
	"${data}"



    return 1

}

proc ::feed_reader::resync_item {filename} {

    array set item [::persistence::get_data ${filename}]

    set domain [get_value_if item(domain) ""]
    if { ${domain} eq {} } {
	set domain [::util::domain_from_url $item(link)]
	set item(domain) ${domain}
    }


    puts domain=${domain}

    set feed_dir [get_package_dir]/feed/${domain}
    set feedfilename [lindex [glob -directory ${feed_dir} *] 0]
    array set feed [::util::readfile ${feedfilename}]

    set title_in_feed [get_value_if item(title) ""]

    if { ${title_in_feed} eq {} } {
	#most likely an error item
	set errorcode [get_value_if item(errorcode) ""]
	if { ${errorcode} ne {} } {
	    return
	} else {
	    puts "----->>>>> no title and no errorcode - strange"
	}
    }

    set errorcode [fetch_item $item(link) ${title_in_feed} feed new_item info]

    if { !${errorcode} } {

	set item(body) $new_item(body)
	set item(video) [get_value_if new_item(video)]
	set item(feed) [file tail $feedfilename]
	if { [get_value_if item(timestamp) ""] eq {} } {
	    set item(timestamp) [file mtime ${filename}]
	}

	remove_item $filename

	# resync_p is different than what we are doing here
	# it is meant for checking for revisions
	#

	set normalized_link [get_value_if item(normalized_link) $item(link)]
	set resync_p [get_value_if item(is_revision_p) 0]


	write_item $item(timestamp) ${normalized_link} feed item ${resync_p}

	puts [format "%40s %s" $item(urlsha1) $item(link)]

    }


}

proc ::feed_reader::resync {} {

    set multirow_slicelists \
	[::persistence::get_multirow_slice \
	     "newsdb" \
	     "news_item/by_urlsha1_and_const"]


    foreach slicelist ${multirow_slicelists} {

	foreach filename ${slicelist} {
	    # even though we expect slicelist to have just one item
	    # we still use the inner forearch to denote the structure
	    # of the multirow_slicelists
	    resync_item ${filename}
	}
	#if { [incr x] == 10 } break
    }

}


proc ::feed_reader::sync_feeds {{news_sources ""} {debug_p "0"}} {

    variable stoptitles

    set feeds_dir [get_package_dir]/feed
    set check_fetch_feed_p 0
    if { ${news_sources} eq {} } {
        set news_sources [glob -nocomplain -tails -directory ${feeds_dir} *]
        set check_fetch_feed_p 1
    }

    set round [clock seconds]

    array set round_stats [list round_timestamp ${round}]

    progress_init [llength ${news_sources}]

    set cur 0
    foreach news_source ${news_sources} {

        set news_source_dir ${feeds_dir}/${news_source}

        set filelist [glob -nocomplain -directory ${news_source_dir} *]

        foreach filename ${filelist} {

            #set feed_name ${news_source}/[file tail ${filename}]
            set feed_name [file tail ${filename}]

            array set feed [::util::readfile ${filename}]

            # TODO: maintain domain in feed spec
            set domain [::util::domain_from_url $feed(url)]

            set timestamp [clock seconds]
            if { ${check_fetch_feed_p} && ![fetch_feed_p ${feed_name} ${timestamp}] } {
                incr round_stats(SKIP_FEED) 
                #puts "not fetching $feed_name in this round ${round}\n\n"
                unset feed
                continue
            }

            array set stats \
                [list \
                     FETCH_AND_WRITE 0 \
                     NO_FETCH 0 \
                     NO_WRITE 0 \
                     ERROR_FETCH 0 \
                     FETCH_FEED 0 \
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

                update_round_stats ${feed_name} stats round_stats

                unset feed

                continue
            }
            set stats(FETCH_FEED) 1

            foreach link $result(links) title_in_feed $result(titles) {

                # returns FETCH_AND_WRITE, NO_FETCH, and NO_WRITE
                set retcode [fetch_and_write_item ${timestamp} ${link} ${title_in_feed} feed]
                incr stats(${retcode})
            }

            if { $stats(FETCH_AND_WRITE) > 0 } {
                set stats(FETCH_AND_WRITE_FEED) 1
            } else {
                set stats(NO_WRITE_FEED) 1
            }

            if { ${debug_p} } {
                print_sync_stats ${feed_name} stats
            }

            update_crawler_stats ${timestamp} ${feed_name} stats

            update_round_stats ${feed_name} stats round_stats

            unset feed
            unset stats

        }
        
        progress_tick [incr cur]

    }

    ::persistence::insert_column              \
	"crawldb"                             \
	"round_stats/by_timestamp_and_const"  \
	"${round}"                            \
	"_data_"                              \
	"[array get round_stats]"

    print_round_stats round_stats

    unset round_stats

}



#TODO: we need a way to test feed (before starting to store it)
proc ::feed_reader::test_feed {news_source {limit "3"} {fetch_item_p "1"}} {

    variable meta
    variable stoptitles

    set feed_files [get_feed_files ${news_source}]
    foreach feed_file ${feed_files} {

        array set feed [::util::readfile ${feed_file}]

        set errorcode [fetch_feed result feed stoptitles]
        if { ${errorcode} } {
            puts "fetch_feed failed errorcode=$errorcode"
            unset feed
            continue
        }

        foreach link $result(links) title_in_feed $result(titles) {

                if { [incr count] == 1 + ${limit} } {
                    break
                }

                puts ""
                puts ${title_in_feed}
                puts ${link}
                puts "---"


                if { ${fetch_item_p} } {
                    set errorcode [fetch_item ${link} ${title_in_feed} feed item info]
                    if { ${errorcode} } {
                        puts "fetch_item failed errorcode=$errorcode link=$link"
			puts "info=[array get info]"
                        continue
                    }
                    print_item item 
                }
		unset item
		unset info

        }

        unset feed
    }

}


proc ::feed_reader::test_article {news_source feed_name link} {

    set feed_file [get_package_dir]/feed/${news_source}/${feed_name}

    array set feed [::util::readfile ${feed_file}]

    set title_in_feed ""
    set retcode [fetch_item ${link} ${title_in_feed} feed item info]

    print_item item
    
    puts "retcode=$retcode"
    puts "info=[array get info]"
}


proc ::feed_reader::remove_item {filename} {

    puts "remove_item ${filename}"

    array set item [::persistence::get_data ${filename}]

    if { ![info exists item(sort_date)] } {
	set timestamp [get_value_if item(timestamp) ""]
	if { ${timestamp} eq {} } {
	    set timestamp [file mtime ${filename}]
	}
	set item(sort_date) [clock format ${timestamp} -format "%Y%m%dT%H%M"]
    }


    set urlsha1 $item(urlsha1)

    set reversedomain [reversedomain [::util::domain_from_url $item(link)]]

    ::persistence::delete_slice               \
	     "crawldb"                        \
	     "sync_info/by_urlsha1_and_const" \
	     "${urlsha1}"

    # the following we use to determine whether 
    # an item is already downloaded or not
    ::persistence::delete_slice                  \
		"newsdb"                         \
		"news_item/by_urlsha1_and_const" \
		"${urlsha1}"


    set contentslicelist                            \
	[::persistence::delete_slice                \
	     "newsdb"                               \
	     "news_item/by_urlsha1_and_contentsha1" \
	     "${urlsha1}"]

    foreach contentfilename ${contentslicelist} {    

	set contentsha1 \
	    [::persistence::get_name ${contentfilename}]

	set cf_variant "index/contentsha1_to_urlsha1"

	::persistence::delete_column  \
	    "newsdb"                  \
	    "${cf_variant}"           \
	    "${contentsha1}"          \
	    "${urlsha1}"

	set deleted_row_p \
	    [::persistence::delete_row_if \
		 "newsdb"                 \
		 "${cf_variant}"          \
		 "${contentsha1}"]

	if { ${deleted_row_p} } {


	    # no more references for this content
	    # delete it so that we won't get any 
	    # is_copy_p set to true because of it

	    set cf_variant2 "content_item/by_contentsha1_and_const"

	    ::persistence::delete_column  \
		"newsdb"                  \
		"${cf_variant2}"          \
		"${contentsha1}"          \
		"_data_"

	    ::persistence::delete_row \
		"newsdb"              \
		"${cf_variant2}"      \
		"${contentsha1}"


	    set indexslicelist \
		[::persistence::delete_slice \
		     "newsdb" \
		     "index/contentsha1_to_label" \
		     "${contentsha1}"]

	    foreach indexfilename ${indexslicelist} {
		set composite_key [::persistence::get_name ${filename}]

		lassign [split ${composite_key} {-}] axis label

		::persistence::delete_column \
		    "newsdb" \
		    "classifier/${axis}" \
		    "${label}" \
		    "${contentsha1}"
		
	    }


	}

    }

    ::persistence::delete_column      \
	"newsdb"                      \
	"news_item/by_const_and_date" \
	"log"                         \
	"$item(sort_date).${urlsha1}"

    ::persistence::delete_column       \
	"newsdb"                       \
	"news_item/by_site_and_date"   \
	"${reversedomain}"             \
	"$item(sort_date).${urlsha1}"

    ::persistence::delete_column \
	"newsdb" \
	"index/urlsha1_to_date_sk" \
	"${urlsha1}" \
	"$item(sort_date).${urlsha1}"

    ::persistence::delete_slice   \
	"newsdb"                   \
	"news_item/by_urlsha1_and_contentsha1" \
	"${urlsha1}"


}

proc predicate=custom_composite_in {slicelistVar urlsha1_list} {
    upvar $slicelistVar slicelist

    set result [list]
    foreach filename $slicelist {
	set composite_key [file tail ${filename}]
	set urlsha1 [lindex [split ${composite_key} {.}] 1]
	if { ${urlsha1} in ${urlsha1_list} } {
	    lappend result ${filename}
	}

    }

    set slicelist ${result}
}

proc ::feed_reader::remove_feed_items {domain {urlsha1_list ""}} {

    set reversedomain [reversedomain ${domain}]

    set delete_domain_p 1

    set slice_predicate ""
    if { ${urlsha1_list} ne {} } {
	set slice_predicate [list "custom_composite_in" [list ${urlsha1_list}]]
    }

    set slicelist [::persistence::get_slice         \
		       "newsdb"                     \
		       "news_item/by_site_and_date" \
		       "${reversedomain}"           \
		       "${slice_predicate}"]


    foreach filename ${slicelist} {
	remove_item ${filename}
    }

    if { ${delete_domain_p} } {

	set domain_dir                        \
	    [::persistence::get_row           \
		 "newsdb"                     \
		 "news_item/by_site_and_date" \
		 "${domain}"]

	::persistence::delete_data ${domain_dir}

    }


}

