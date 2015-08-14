package require util_procs


# using textalign::adjust command
package require algo

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

    if { [info exists feed(domain)] } {
        set domain $feed(domain)
    } else {
        set domain [url domain ${url}]
    }

    set xpath_feed_item [value_if \
        feed(xpath_feed_item) \
        {//a[@href]}]

    set feed_type [value_if \
        feed(feed_type) \
        {html}]

    set htmltidy_feed_p [value_if \
        feed(htmltidy_feed_p) \
        0]

    set xpath_feed_cleanup [value_if \
        feed(xpath_feed_cleanup) \
        {}]

    set encoding {utf-8}
    if { [info exists feed(encoding)] } {
        set encoding $feed(encoding)
    }

    set errorcode [web cache_fetch html $url]
    if { ${errorcode} } {
        puts "error fetching feed: errocode=$errorcode"
        return $errorcode
    }

    if { ${html} eq {} } {
        puts "empty html while fetching feed"
        return -4  ;# empty html while fetching feed
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

    if { [string length $html] < 10000 } {
        puts "url = $url"
        puts "html = $html"
    }

    foreach cleanup_xpath ${xpath_feed_cleanup} {
        foreach cleanup_node [${doc} selectNodes $cleanup_xpath] {
            catch { $cleanup_node delete }
        }	    
    }

    set link_stoplist [value_if feed(link_stoplist) ""]

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
        # set href [::uri::canonicalize [::uri::resolve ${url} ${href}]]


        if { ${link_stoplist} ne {} && ${href} in ${link_stoplist} } {
            continue
        }


        if { ![url_pass_p feed $href] } {
            continue
        }

        set canonical_url [url normalize [url resolve $feed(url) $href]]

        ${item_node} setAttribute href ${canonical_url}

        if { ${tagname} eq {a} } {
            set title [get_title stoptitles ${item_node}]
        } elseif { ${tagname} eq {item} } {
            set title [${item_node} selectNodes {string(//title/text())}]
        }

        if { ![info exists title_for_href(${canonical_url})] } {
        # coalesce title candidate values
            set title_for_href(${canonical_url}) ${title}
        } else {
            set title_for_href(${canonical_url}) [coalesce ${title} $title_for_href(${canonical_url})]
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

    # puts "$resultVar=$result"
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

    set encoding [value_if feed(encoding) utf-8]

    set htmltidy_article_p [value_if \
        feed(htmltidy_article_p) \
        0]

    set keep_title_from_feed_p [value_if \
        feed(keep_title_from_feed_p) \
        0]

        # {//meta[@property="og:title"]}

    set xpath_article_prefix [value_if feed(xpath_article_prefix) ""]

    set xpath_article_title [value_if \
        feed(xpath_article_title) \
        {string(//meta[@property="og:title"]/@content)}]

    set xpath_article_body [value_if \
        feed(xpath_article_body) \
        {}]

    set xpath_article_cleanup [value_if \
        feed(xpath_article_cleanup) \
        {}]

    set xpath_article_author [value_if \
        feed(xpath_article_author) \
        {}]

    set xpath_article_image [value_if \
        feed(xpath_article_image) \
        {string(//meta[@property="og:image"]/@content)}]

    set xpath_article_video [value_if \
        feed(xpath_article_video) \
        {values(//iframe[@src]/@src)}]

    ::util::prepend ${xpath_article_prefix} xpath_article_video

    set xpath_article_attachment [value_if \
        feed(xpath_article_attachment) \
        {}]

    set xpath_article_description [value_if \
        feed(xpath_article_description) \
        {string(//meta[@property="og:description"]/@content)}]


    set xpath_article_date [value_if \
        feed(xpath_article_date) \
        {returndate(string(//meta[@property="article:published_time"]/@content),"%Y-%m-%d %H:%M")}]

    set xpath_article_modified_time [value_if \
        feed(xpath_article_modified_time) \
        {returndate(string(//meta[@property="article:modified_time"]/@content),"%Y-%m-%d %H:%M")}]


    set xpath_article_tags [value_if \
        feed(xpath_article_tags) \
        {string(//meta[@property="og:keywords"]/@content)}]


    set html ""

    array set options [value_if feed(http_options) ""]
    set errorcode [web cache_fetch html ${link} options info]
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

        set image_stoplist [value_if feed(image_stoplist) ""]

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

    if { [value_if feed(end_of_text_cleanup_p) "0"] } {
    # if end_of_string is found after the 1/3 of the article body
    # then drop text beyond that point
    #

    set end_of_text_cleanup_coeff [value_if feed(end_of_text_cleanup_coeff) "0.3"]
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

    set article_langclass [value_if feed(article_langclass) "auto"]

    if { ${article_langclass} eq {auto} } {
        set article_langclass [lindex [::ttext::langclass "$article_title $article_body"] 0]
    }

    set domain [url domain ${link}]

    set body_length [string length ${article_body}]

    array set item [list \
        domain ${domain} \
        reversedomain [reversedotted $domain] \
        url $link \
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

    set allow_empty_body_p [value_if feed(allow_empty_body_p) 0]
    if { ${body_length} == 0 && !${allow_empty_body_p} } {
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

    if { [value_if feed(article_redirect_policy) ""] eq {GET_COOKIELIST_AND_TRY_AGAIN} } {
        set redirect_url [value_if info(redirecturl) ""]
        if { ${redirect_url} ne {} } {
            if { [catch {
                set redirect_retcode [web cache_fetch _dummy_ ${redirect_url} "" redirect_info]
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

        ::persistence::__ins_column       \
            "newsdb"                         \
            "news_item.by_urlsha1_and_const" \
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

    if { [value_if feed(article_link_urlencode_p) "0"] } {
        array set uri [url split ${link}]
        set ue_path [url encode $uri(path)]
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

    if { [value_if info(responsecode) ""] eq {302} && [value_if feed(handle_redirect_item_p) "0"] } {

        return -4 ;# redirect item
        # TODO: move redirect handling to curl/webdb
        return [handle_redirect_item ${link} ${title_in_feed} feed item info ${redirect_count}]

    }

    return ${retcode}
}

proc ::feed_reader::translate_error_code {error_code} {

    return [value_if ::curl::errorcode_messages(${error_code}) ""]

}

proc ::feed_reader::fetch_and_write_item {timestamp link title_in_feed feedVar} {

    upvar $feedVar feed

    # log link=$link

    set normalize_link_re [value_if feed(normalize_link_re) ""]
    if { ${normalize_link_re} ne {} } {
        regexp -- ${normalize_link_re} ${link} whole normalized_link
    } else {
        set normalized_link ${link}
    }

    # TODO: if it exists and it's the first item in the feed,
    # fetch it and compare it to stored item to ensure sanity
    # of feed/article/page

    set can_resync_p [value_if feed(check_for_revisions) "0"]

    set resync_p 0
    if { 
        ![exists_item ${normalized_link}] 
        || ( ${can_resync_p} && [set resync_p [auto_resync_p feed ${normalized_link}]] ) 
    } {

        # log resync_p=$resync_p

        set errorcode [fetch_item ${link} ${title_in_feed} feed item info]
        if { ${errorcode} } {

            set error_message [translate_error_code ${errorcode}]

            puts "--->>> errorcode=$errorcode error_message=${error_message}"
            puts "--->>> error ${link}"
            puts "--->>> info=[array get info]"

            set urlsha1 [get_urlsha1 ${link}]

            array set error_item [list \
                errorcode       ${errorcode}      \
                url             ${link}           \
                urlsha1         ${urlsha1}        \
                urlsha1_timestamp [list $urlsha1 $timestamp] \
                http_fetch_info [array get info]  \
                title_in_feed   ${title_in_feed}  \
                item            [array get item]]


            ::newsdb::error_item_t insert error_item

            if {0} {
                ::persistence::fs::__ins_column \
                    "newsdb" \
                    "error_item.by_urlsha1_and_timestamp" \
                    "${urlsha1}"\
                    "${timestamp}" \
                    "${errordata}"
            }

            set where_clause [list [list urlsha1 = $urlsha1]]
            set slicelist [::newsdb::error_item_t find $where_clause]

            if {0} {
                set slicelist [::persistence::__get_slice \
                    "newsdb" \
                    "error_item/by_urlsha1_and_timestamp" \
                    "[get_urlsha1 ${link}]"]
            }

            if { [llength ${slicelist}] >= 3 } {

                puts "--->>> TODO: marking this item as fetched... (${urlsha1})"

                if {0} {
                    ::persistence::fs::__ins_column \
                        "newsdb" \
                        "news_item.by_urlsha1_and_const" \
                        "${urlsha1}" \
                        "_data_" \
                        "${errordata}"
                }

            }



            # unset item
            # unset info
            return {ERROR_FETCH}
        }

        if { ${normalized_link} ne ${link} } {
            set item(normalized_link) ${normalized_link}
        }

        if { $item(url) ne ${link} } {
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
    return {/web/data/mystore/newsdb}
}

proc ::feed_reader::get_urlsha1 {link} {
    set urlsha1 [::sha1::sha1 -hex ${link}]
    return ${urlsha1}
}

proc ::feed_reader::get_crawler_dir {} {
    return [get_base_dir]/crawler
}


proc ::feed_reader::get_contentsha1_to_label_dir {} {
    # multiple urls may have the same content
    return [get_base_dir]/contentsha1_to_label
}




proc ::feed_reader::compare_mtime {file_or_dir1 file_or_dir2} {

    set mtime1 [::persistence::get_mtime $file_or_dir1]
    set mtime2 [::persistence::get_mtime $file_or_dir2]

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


proc ::feed_reader::rm {args} {

    # parse args
    #
    getopt::init {
        {domain ""  {__arg_domain domain}}
        {lang   ""  {__arg_lang   lang}}
        {urlsha1 "" {__arg_urlsha1 urlsha1}}
        {contentsha1 "" {__arg_contentsha1 contentsha1}}
        {url "" {__arg_url url}}
    }
    set args [getopt::getopt $args]

    assert { !(exists("urlsha1") && exists("url")) }

    set where_clause [list]

    if { exists("__arg_lang") } {
        lappend where_clause [list langclass = $lang ]
    }

    if { exists("__arg_domain") } {
        set reversedomain [reversedotted $domain]
        lappend where_clause [list reversedomain = $reversedomain]
    }

    if { exists("__arg_urlsha1") } {
        lappend where_clause [list urlsha1 = $urlsha1]
    }

    puts where_clause=$where_clause

    set slicelist [::newsdb::news_item_t find $where_clause]

    foreach oid $slicelist {
        #log "rm oid=$oid"
        ::newsdb::news_item_t delete $oid
    }

}

proc ::feed_reader::ls {args} {

    # parse args
    #
    getopt::init {
        {offset ""  {__arg_offset offset}}
        {limit  ""  {__arg_limit  limit}}
        {domain ""  {__arg_domain domain}}
        {lang   ""  {__arg_lang   lang}}
        {since  ""  {__arg_since  since_date}}
        {long   "l" {__arg_long_listing}}
    }
    getopt::getopt $args

    set stty [join [map it [split [exec stty -a] {;}] { list [lindex $it 0] [lrange $it 1 end] }]]
    set rows [keylget stty rows]
    set cols [keylget stty columns]

    # defaults
    #
    set_if offset 0
    set_if limit [expr { $rows - 5 }]
    #set_if limit [expr { $offset + 20 }]

    # validation checks
    #
    assert { vcheck("offset","integer") }
    assert { vcheck("limit","integer") }
    assert { vcheck_if("lang","langclass") }

    set where_clause [list]

    if { exists("__arg_lang") } {
        lappend where_clause [list langclass = $lang]
    }

    if { exists("__arg_domain") } {
        set reversedomain [reversedotted $domain]
        lappend where_clause [list reversedomain = $reversedomain]
    }

    # TODO: sort and get range for each filter, e.g. by_langclass
    # in order to avoid returning huge result sets in between
    # processing and the final sorting and range selection. 
    #
    # lappend predicate [list "lrange" [list $offset $limit]]

    array set options [list]
    set options(order_by) "sort_date decreasing"
    #set options(order_by) "timestamp decreasing integer"
    set options(offset) $offset
    set options(limit) $limit
    set options(expand_fn) "latest_mtime"

    set slicelist [::newsdb::news_item_t find $where_clause options]

    if { exists("__arg_long_listing") } {
        print_log_header
    } else {
        print_short_log_header
    }

    foreach oid $slicelist {
        set data [::newsdb::news_item_t get $oid]

        array set item $data
        if { exists("__arg_long_listing") } {
            print_log_entry item context
        } else {
            print_short_log_entry item context 
        }
        unset item
    }

    print_log_footer context

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

proc ::util::tokenize {text} {

    set removeChars_re {[^[:alnum:]]+}
    regsub -all -- ${removeChars_re} ${text} { } text

    return [lsearch -inline -all -not [split [string tolower [::ttext::unaccent utf-8 ${text}]]] {}]
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

    if { 1 } {
        set multirow \
            [::persistence::get_multirow \
                 "newsdb" \
                 "content_item.by_contentsha1_and_const"]
    } else {
        set filelist \
            [::persistence::__get_slice \
             "newsdb" \
             "news_item.by_const_and_date" \
             "log"]

    }


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


proc ::feed_reader::confirm {} {

    while { [set reply [gets stdin]] ni {y n yes no t f true false 0 1} } {
    }

    return [::util::boolean ${reply}]

}

proc ::feed_reader::read_integer_between {from to msg} {

    puts $msg
    while { 
	   [set sel [gets stdin]] 
	   && ![string is integer ${sel}] 
	   && ${sel} != -1 
	   && ${sel}< ${from} 
	   && ${sel} > ${to}  
       } {
	puts $msg
    }

    if { ${sel} != {-1} } {
	return ${sel}
    }

    return ""

}

proc ::feed_reader::search_callback=label_content {contentsha1 axis label {need_confirm_p "1"}} {

    ::persistence::__get_column \
        "newsdb"\
        "content_item.by_contentsha1_and_const" \
        "${contentsha1}" \
        "_data_" \
        "column_data"

    if { ${label} eq {} || ${need_confirm_p} } {
        set content [join ${column_data}]
        ::naivebayes::wordcount_helper count content true ;# filter_stopwords
        ::naivebayes::print_words [::naivebayes::wordcount_topN count 40]

        set max_category [classifier::classify ${axis} content]

        puts ""
    }

    if { ${label} eq {} } {
        set labels [classifier::get_training_labels ${axis}]
        set num_labels [llength ${labels}]
        set index 0
        foreach label ${labels} {

            if { 
                ${num_labels} > 10 
                && [string first {/} ${label}] != -1 
                && ![string match ${max_category}* ${label}] 
            } {

            # do nothing

            } else {

                set preferred ""
                if { ${label} eq ${max_category} } {
                    set preferred {(*)}
                }

                puts [format "%10s %-40s" "${preferred} ${index}." ${label}]

            }

            incr index

        }

        set selection [read_integer_between 0 $num_labels "--->>> your choice (-1 to skip):"]
        if { ${selection} ne {} } {
            set label [lindex ${labels} ${selection}]
            puts "your selection: ${label}"
            set need_confirm_p 0
        } else {
            return
        }
        puts ""
    }

    if { !${need_confirm_p} || [confirm] } {

        ::persistence::fs::__ins_column \
            "newsdb" \
            "train_item" \
            "${axis}" \
            "${label}/${contentsha1}" \
            ""

    }

}



proc ::feed_reader::search_callback=unlabel_content {contentsha1 axis label {need_confirm_p "1"}} {

    if { ${label} eq {} } {
        error "unlabel_content: empty label name"
    }

    ::persistence::__get_column \
        "newsdb"\
        "content_item.by_contentsha1_and_const" \
        "${contentsha1}" \
        "_data_" \
        "column_data"

    if { ${need_confirm_p} } {
        set content [join ${column_data}]
        ::naivebayes::wordcount_helper count content true ;# filter_stopwords
        ::naivebayes::print_words [::naivebayes::wordcount_topN count 40]

        set max_category [classifier::classify ${axis} content]

        puts ""
    }

    if { !${need_confirm_p} || [confirm] } {

        ::persistence::delete_column \
            "newsdb" \
            "train_item" \
            "${axis}" \
            "${label}/${contentsha1}" \
            ""

    }

}


proc ::feed_reader::assert_dir {dir msg} {
    if { ![file isdirectory ${dir}] } {
	error ${msg}
    }
}

proc ::feed_reader::label_batch {axis label keywords {offset "0"} {limit "5"}} {
puts axis=$axis
puts label=$label
puts keywords=$keywords
puts offset=$offset
puts limit=$limit

    assert_dir [get_base_dir]/train_item/${axis}/+/${label} "no such label ${axis}/${label}"

    set callback [list "label_content" [list ${axis} ${label} "0"]]

    search ${keywords} ${offset} ${limit} ${callback}

}


proc ::feed_reader::label_interactive {axis label keywords {offset "0"} {limit "5"}} {

    assert_dir [get_base_dir]/train_item/${axis}/+/${label} "no such label ${axis}/${label}"

puts axis=$axis
puts label=$label
puts keywords=$keywords
puts offset=$offset
puts limit=$limit

    set callback [list "label_content" [list ${axis} ${label}]]

    search ${keywords} ${offset} ${limit} ${callback}

}

proc ::feed_reader::unlabel_interactive {axis label keywords {offset "0"} {limit "5"}} {

    assert_dir [get_base_dir]/train_item/${axis}/+/${label} "no such label ${axis}/${label}"

puts axis=$axis
puts label=$label
puts keywords=$keywords
puts offset=$offset
puts limit=$limit

    set callback [list "unlabel_content" [list ${axis} ${label}]]

    # TODO: search_label ${axis} ${label} ${keywords} ${offset} ${limit} ${callback}
    search ${keywords} ${offset} ${limit} ${callback}

}



proc ::feed_reader::cluster {{offset "0"} {limit "10"} {k ""} {num_iter "3"}} {

    set slicelist [::newsdb::news_item_t find_by_axis sort_date]
    ::persistence::fs::predicate=lrange slicelist $offset $limit

    set contentfilelist [list]
    foreach oid ${slicelist} {

        array set item [list]

        array set item [::newsdb::news_item_t get $oid]

        set contentfilename \
            [::persistence::get_filename \
                [::newsdb::content_item_t find_by_id $item(contentsha1)]]

        lappend contentfilelist ${contentfilename}

        #print_log_entry item
        unset item

    }

    set dir [file dirname [info script]]
    set cmd [file join $dir "../../../lib/document_clustering/cc/test_main"]
    if { ${k} eq {} } {
        set k [expr { int(log(${limit}) * sqrt(${limit})) }]
    }
    set result [exec ${cmd} ${k} ${num_iter} {*}${contentfilelist}]

    puts ${result}

}


proc ::feed_reader::exists_item {link} {
    set urlsha1 [get_urlsha1 ${link}]
    set where_clause [list [list urlsha1 = $urlsha1]]
    array set options [list expand_fn "latest_mtime"]
    set oid [::newsdb::news_item_t 0or1row $where_clause options]
    return [expr { $oid ne {} }]
}


proc ::feed_reader::load_item {itemVar urlsha1} {

    upvar $itemVar item

    set where_clause [list]
    lappend where_clause [list urlsha1 = $urlsha1]
    #lappend where_clause [list rank($urlsha1,contentsha1) = latest_mtime()]

    array set options [list]
    #set options(where) $where_clause

    ##
    # * The primary key for ::newsdb::news_item_t is a composite that
    #   consists of the values of urlsha1 and the contentsha1 attributes.
    #
    # * urlsha1 is associated with many contentsha1 values (one_to_many),
    #   yet we deal (usually) with the latest revision except when we 
    #   explicitly ask for the revisions of an item.
    #
    # * There are alternative ways to model our data. In fact, we already
    #   have ::newsdb::content_item_t, though it would complicate keeping
    #   the data in a single host when the data is distributed. Eventhough,
    #   it is just a hypothetical for now, still we try to keep some
    #   flexibility for accomplishing this kind of stuff.
    #
    # * In this particular case, we want to group by urlsha1 and select
    #   the revision with the latest_mtime. The point is we can do this 
    #   before we even look at the actual data, only by checking the 
    #   values of the pk attributes (the ones that compose the pk,
    #   in this case, urlsha1 and contentsha1) in a given OID.
    #

    set options(expand_fn) {latest_mtime}

    set oid [::newsdb::news_item_t 1row $where_clause options]
    array set item [::newsdb::news_item_t get $oid]

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

        load_content item ${contentsha1}
	    set content [concat $item(title) $item(body)]
        puts [classifier::classify ${axis} content]
        unset item

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

        set where_clause [list [list contentsha1 = $contentsha1]]
        set slicelist [::newsdb::news_item_t 0or1row $where_clause]

        foreach filename ${slicelist} {
            set urlsha1 [::persistence::get_name $filename]
            load_item item ${urlsha1}
            print_item item
        }
    }

}


proc ::feed_reader::load_content {itemVar contentsha1 {include_labels_p "1"}} {

    upvar $itemVar item

    set where_clause [list [list contentsha1 = $contentsha1]]
    set oid [::newsdb::content_item_t 0or1row $where_clause]
    set data [::newsdb::content_item_t get $oid]
    array set item $data

    if {0} {
        set contentsha1_to_label_filename [get_contentsha1_to_label_dir]/${contentsha1}
        if { [file exists ${contentsha1_to_label_filename}] } {
            set item(label) [lsearch -inline -all -not [split [::util::readfile $contentsha1_to_label_filename] "\n"] {}]
        }
    }

}

proc ::feed_reader::print_item {itemVar {exclude_keys ""}} {
    upvar $itemVar item

    puts "--"
    foreach {key value} [array get item] {
        if { $key ni $exclude_keys } {
            if { ${value} ne {} } {
                if { $key eq {body} } {
                    puts "* ${key}: [::textalign::adjust ${value} 80]"
                } else {
                    puts "* ${key}: ${value}"
                }
            }
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
    puts [format "%2s %40s %6s %-14s %30s %10s %3s %3s %-60s %20s" lc urlsha1 len topic subtopic edition "" "" title domain]
}

proc ::feed_reader::print_short_log_header {} {
    puts [format "%15s %3s %3s %-60s %20s" date cpy rev title domain]
}

proc ::feed_reader::print_log_footer {contextVar} {

    upvar $contextVar context

    set from_date [value_if context(from_date) ""]
    set to_date [value_if context(to_date) ""]
    if { ${from_date} ne {} } {
	puts ""
	puts "- date from ${from_date} to ${to_date}"
    }


}


proc ::feed_reader::print_log_entry {itemVar {contextVar ""}} {
    upvar $itemVar item

    if { ${contextVar} ne {} } {
        upvar ${contextVar} context
    }

    set domain [url domain $item(url)]

    set is_copy_string ""
    if { [string is true -strict [value_if item(is_copy_p) 0]] } {
        set is_copy_string "(*)"
    }
    set is_revision_string ""
    if { [string is true -strict [value_if item(is_revision_p) 0]] } {
        set is_revision_string "upd"
    }

    set topic ""
    set subtopic ""
    set edition ""
    if {0} {
        load_content item $item(contentsha1)

        set content ""
        set topic_and_subtopic ""
        set edition ""
        if { [classifier::is_enabled_p "el.topic"] && [classifier::is_enabled_p "el.edition"] } {
            set content [concat $item(title) $item(body)]
            set topic_and_subtopic [classifier::classify "el.topic" content]
            set edition [classifier::classify "el.edition" content]
        }

        lassign [split ${topic_and_subtopic} {/}] topic subtopic
    }

    set domain_prefix "${domain} -- "
    set num_spaces [string length ${domain_prefix}]

    set title $item(title)
    set title_first_line [string range ${title} 0 59]
    set title_second_line [string range ${title} 60 end]


    if { ![info exists context(to_date)] } {
        set context(to_date) $item(sort_date)
    }
    set context(from_date) $item(sort_date)

    set lang [lindex [split [value_if item(langclass) "el.utf8"] {.}] 0]
    puts [format "%2s %40s %6s %-14s %30s %10s %3s %3s %-60s %20s" \
        ${lang} \
        $item(urlsha1) \
        [::util::pretty_length [value_if item(body_length) ""]] \
        ${topic} \
        ${subtopic} \
        ${edition} \
        ${is_copy_string} \
        ${is_revision_string} \
        ${title_first_line} \
        ${domain}]

}

proc ::feed_reader::print_short_log_entry {itemVar {contextVar ""}} {
    upvar $itemVar item

    if { ${contextVar} ne {} } {
        upvar ${contextVar} context
    }

    set domain [url domain $item(url)]

    set is_copy_string ""
    if { [string is true -strict [value_if item(is_copy_p) 0]] } {
        set is_copy_string "(*)"
    }
    set is_revision_string ""
    if { [string is true -strict [value_if item(is_revision_p) 0]] } {
        set is_revision_string "upd"
    }


    if {0} {
        #load_content content_item $item(contentsha1)
        set content ""
        set topic_and_subtopic ""
        set edition ""
        if { [classifier::is_enabled_p el/topic] && [classifier::is_enabled_p el/edition] } {
            set content [concat $item(title) $item(body)]
            set topic_and_subtopic [classifier::classify el/topic content]
            set edition [classifier::classify el/edition content]
        }
        lassign [split ${topic_and_subtopic} {/}] topic subtopic
    }


    set domain_prefix "${domain} -- "
    set num_spaces [string length ${domain_prefix}]

    set title $item(title)
    set title_first_line [string range ${title} 0 59]
    set title_second_line [string range ${title} 60 end]


    if { ![info exists context(to_date)] } {
        set context(to_date) $item(sort_date)
    }
    set context(from_date) $item(sort_date)

    set lang [lindex [split [value_if item(langclass) "el.utf8"] {.}] 0]

    puts [format "%15s %3s %3s %-60s %20s" \
        $item(sort_date) \
        ${is_copy_string} \
        ${is_revision_string} \
        ${title_first_line} \
        ${domain}]

}


proc ::feed_reader::show_item {urlsha1_list} {
    foreach urlsha1 ${urlsha1_list} {
        load_item item ${urlsha1}
        print_item item

        if { $item(langclass) eq {el.utf8} } {

            set content [concat $item(title) $item(body)]
            set item(el/topic) [classifier::classify el/topic content]

            puts $item(el/topic)
        }


        unset item
    }
}

proc ::feed_reader::classify {axis urlsha1_list} {
    set contentsha1_list [list]
    foreach urlsha1 ${urlsha1_list} {
        load_item item ${urlsha1}
        # lappend contentsha1_list $item(contentsha1)
        classify_content $axis $item(contentsha1)
        unset item
    }

}


proc ::feed_reader::show_revisions {urlsha1} {


    #set where_clause [list [list urlsha1 = $urlsha1]]
    #set slicelist [::newsdb::item_revision_t find $where_clause]
    #puts $slicelist

    set slicelist [::persistence::get_supercolumn_slice \
        "newsdb"                                        \
        "news_item.by_urlsha1_and_contentsha1"          \
        "__default_row__"                               \
        "${urlsha1}"]

    foreach {filename} ${slicelist} {
        set timestamp [persistence::get_mtime ${filename}]
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

    array set sync_info_item [list \
        urlsha1 $urlsha1 \
        datetime $timestamp_datetime \
        datetime_urlsha1 [list $timestamp_datetime $urlsha1]]

    ::crawldb::sync_info_t insert sync_info_item

    set content [list $item(title) $item(body)]
    set contentsha1 [::sha1::sha1 -hex ${content}]

    set where_clause [list]
    lappend where_clause [list contentsha1 = $contentsha1]
    lappend where_clause [list urlsha1 = $urlsha1]
    set news_item_oid [::newsdb::news_item_t find $where_clause]


    if { $news_item_oid ne {} } {
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

    # TODO: query for news_item_t with the given contentsha1
    # as we might have deleted the news_item, in that case,
    # it is not a copy, which is the purpose behind this query
    set where_clause [list [list contentsha1 = $contentsha1]]
    set content_item_oid [::newsdb::content_item_t 0or1row $where_clause]

    if { $content_item_oid ne {} } {
        # we have seen this item before from a different url
        set item(is_copy_p) 1
    } else {

        array set content_item [list \
            contentsha1 $contentsha1 \
            title $item(title)       \
            body $item(body)]

        #assert { $content_item(title) ne {} } 

        ::newsdb::content_item_t insert content_item
    }


    set item(timestamp) ${timestamp}
    set item(urlsha1) ${urlsha1}
    set item(contentsha1) ${contentsha1}

    set reversedomain [reversedotted [url domain ${normalized_link}]]


    array unset item body




    set item(sort_date) ""

    if { [value_if item(date) ""] ne {} } {

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
            if { ${date} < ${timestamp_date} } {

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

    ::newsdb::news_item_t insert item

     return 1
}

proc ::feed_reader::resync_item {oid} {

    array set item [::persistence::get ${oid}]

    set domain [value_if item(domain) ""]
    if { ${domain} eq {} } {
        set domain [url domain $item(url)]
        set item(domain) ${domain}
    }


    puts domain=${domain}

    set feed_dir [get_package_dir]/feed/${domain}
    set feedfilename [lindex [glob -directory ${feed_dir} *] 0]
    array set feed [::util::readfile ${feedfilename}]

    set title_in_feed [value_if item(title) ""]

    if { ${title_in_feed} eq {} } {
    #most likely an error item
        set errorcode [value_if item(errorcode) ""]
        if { ${errorcode} ne {} } {
            return
        } else {
            puts "----->>>>> no title and no errorcode - strange"
        }
    }

    set errorcode [fetch_item $item(url) ${title_in_feed} feed new_item info]

    if { !${errorcode} } {

        set item(body) $new_item(body)
        set item(video) [value_if new_item(video)]
        set item(feed) [file tail $feedfilename]
        if { [value_if item(timestamp) ""] eq {} } {
            set item(timestamp) [::persistence::get_mtime ${oid}]
        }

        remove_item $oid

        # resync_p is different than what we are doing here
        # it is meant for checking for revisions
        #

        set normalized_link [value_if item(normalized_link) $item(url)]
        set resync_p [value_if item(is_revision_p) 0]


        write_item $item(timestamp) ${normalized_link} feed item ${resync_p}

        puts [format "%40s %s" $item(urlsha1) $item(url)]

    }


}

proc ::feed_reader::resync {} {

    set multirow_slicelists \
	[::persistence::get_multirow_slice \
	     "newsdb" \
	     "news_item.by_urlsha1_and_const"]


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

            array set feed {
                url ""
                url_fmt ""
                include_inurl ""
                exclude_inurl ""
                include_re ""
                exclude_re ""
                encoding "utf-8"
                htmltidy_feed_p "0"
                htmltidy_article_p "0"
                xpath_article_title ""
                xpath_article_body ""
                xpath_article_image ""
                xpath_article_date ""
                xpath_article_modified_time ""
            }

            #set feed_name ${news_source}/[file tail ${filename}]
            set feed_name [file tail ${filename}]

            array set feed [::util::readfile ${filename}]

            # TODO: maintain domain in feed spec
            set domain [url domain $feed(url)]

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


            # set feed_type [value_if feed(type) ""] 
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

    ::persistence::fs::__ins_column              \
        "crawldb"                             \
        "round_stats.by_timestamp_and_const"  \
        "${round}"                            \
        "_data_"                              \
	"[array get round_stats]"

    print_round_stats round_stats

    unset round_stats

}


proc ::feed_reader::curl {url} {
    set errorcode [web cache_fetch html $url]
    if { ${errorcode} } {
        puts "error fetching $url"
        return $errorcode
    }

    puts "html=[string range $html 0 1000]"
    
}


#TODO: we need a way to test feed (before starting to store it)
proc ::feed_reader::test_feed {news_source {limit "3"} {fetch_item_p "1"} {exclude_keys ""}} {

    variable meta
    variable stoptitles

    set feed_files [get_feed_files ${news_source}]
    foreach feed_file ${feed_files} {

        puts "feed_file=$feed_file"

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

                puts "==="
                puts "title in feed: ${title_in_feed}"
                puts "link in feed: ${link}"
                puts "---"


                if { ${fetch_item_p} } {
                    set errorcode [fetch_item ${link} ${title_in_feed} feed item info]
                    if { ${errorcode} } {
                        puts "fetch_item failed errorcode=$errorcode link=$link"
                        puts "info=[array get info]"
                        continue
                    }
                    #puts $item(date)
                    print_item item $exclude_keys
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

proc ::feed_reader::url_pass_p {feedVar href} {
    upvar $feedVar feed

    if { $href eq {} } {
        return false
    }

    set href_lowercase [string tolower $href]

    if { 0 == [string first "javascript:" $href_lowercase] } {
        return false
    }

    # drop hrefs that do not exclude all exclude_inurl strings
    if { $feed(exclude_inurl) ne {} } {
        # expects exclude strings to be in lowercase
        set skip_p 0
        foreach str $feed(exclude_inurl) {
            if { -1 != [string first $str $href_lowercase] } {
                set skip_p 1
                break
            }
        }
        if { $skip_p } {
            return false
        }
    }

    # drop hrefs that do not include all include_inurl strings
    if { $feed(include_inurl) ne {} } {
        # expects include strings to be in lowercase
        set skip_p 0
        foreach str $feed(include_inurl) {
            if { -1 == [string first $str $href_lowercase] } {
                set skip_p 1
                break
            }
        }
        if { $skip_p } {
            return false
        }
    }

    # normalize and resolve (wrt to feed url) the given href
    set canonical_url [url normalize [url resolve $feed(url) $href]]

    # drop urls that do not match the url_fmt
    if { $feed(url_fmt) ne {} } {
        if { ![url match $feed(url_fmt) $canonical_url] } {
            return false
        }
    }

    if { $feed(include_re) ne {} } {
        if { ![regexp -- $feed(include_re) $canonical_url] } {
            return false
        }
    }

    if { $feed(exclude_re) ne {} } {
        if { [regexp -- $feed(exclude_re) $canonical_url] } {
            return false
        }
    }

    # drop urls from other domains
    set domain [url domain $feed(url)]
    if { ${domain} ne [url domain ${canonical_url}] } {
        return false
    }

    return true
}

