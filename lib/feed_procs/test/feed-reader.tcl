#!/usr/bin/tclsh

# TODO: extract comments from article pages

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require feed_procs

#set dir [file dirname [info script]]
#source [file join ${dir} feed-procs.tcl]

set feeds [dict create \
	       philenews {
		   url http://www.philenews.com/
		   include_re {/el-gr/.+/[0-9]+/[0-9]+/}
		   exclude_re {vid=$}
		   xpath_article_body {returntext(//div[@class="article-body"])}
		   xpath_article_author {string(//div[@class="article-author"])}
		   xpath_article_tags {values(//meta[@property="article:section"]/@content)}
		   xpath_article_image {
		       {values(//div[@class="fullarclimg"]/div/a/img/@src)}
		   }
	       } \
	       sigmalive {
		   url http://www.sigmalive.com/
		   include_re {/[0-9]+}
		   exclude_re {/inbusiness/}
		   keep_title_from_feed_p 0
		   xpath_article_title {returnstring(//h2[@class="cat_article_title"]/a)}
		   xpath_article_body {returntext(//div[@id="article_content"])}
		   xpath_article_image {
		       {values(//div[@id="article_content"]/img/@src)}
		       {values(//div[@id="article_content"]//img[@class="pyro-image"]/@src)}
		   }
		   xpath_article_author {returnstring(//div[@class="article_meta"]/span[@class="meta_author"]/a/text())}
		   xpath_article_date {returndate(normalizedate(//div[@class="article_meta"]/span[@class="meta_date"]/strong/text(),"el_GR"),"%B %d, %Y %H:%M","el_GR")}
		   xpath_article_cleanup {
		       {//div[@class="soSialIcons"]}
		       {//div[@class="article_meta"]}
		   }
	       } \
	       inbusiness {
		   url http://www.sigmalive.com/inbusiness/
		   include_re {/inbusiness/.*/[0-9]+}
		   keep_title_from_feed_p 0
		   xpath_article_title {returnstring(//div[@id="articleContainer"]/h1)}
		   xpath_article_body {returntext(//div[@id="articleContainer"]/div[@class="content"]/div[1])}
		   xpath_article_image {
		       {values(//div[@class="articleImg"]/div[@class="img"]/img/@src)}
		   }
		   xpath_article_date {returndate(normalizedate(substring-after(//div[@id="articleContainer"]/h4/text(),"| "),"el_GR"),"%d %B %Y, %H:%M","el_GR")}
		   xpath_article_cleanup {
		       {//div[@id="articleContainer"]/h4}
		   }
		   comment {
		       issue with date, might be due to the fact it uses the word "maios" instead of "maiou"
		       http://www.sigmalive.com/inbusiness/news/rankings/44887
		   }
	       } \
	       paideia-news {
		   url http://www.paideia-news.com/
		   include_re {id=[0-9]+&hid=[0-9]+}
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//div[@class="main_resource_title_single"])}
		   xpath_article_author {returnstring(//div[@class="main_resource_summ2"]/p/strong/span)}
		   xpath_article_body {returntext(//div[@class="main_resource_summ2"])}
		   xpath_article_date {returndate(//div[@class="main_resource_date"],"%Y-%m-%d %H:%M:%S")}
		   xpath_article_image {values(//div[@class="main_resource_img_single"]/img/@src)}
		   xpath_article_cleanup {
		       {//div[@class="main_resource_summ2"]/p/strong/span}
		   }
	       } \
	       ant1iwo {
		   url http://www.ant1iwo.com/
		   include_re {/[0-9]{4}/[0-9]{2}/[0-9]{2}/}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//div[@id="il_title"]/h1)}
		   xpath_article_body {returntext(//div[@id="il_text"])}
		   xpath_article_date {normalizedate(substring-after(//div[@id="il_pub_date"]/div[@class="pubdate"]/text(),": "),"el_GR")}
		   comment {image is via meta og:image}
	       } \
	       24h {
		   url http://www.24h.com.cy/
		   include_re {item/[0-9]+}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//h2[@class="itemTitle"]/a)}
		   xpath_article_description {returnstring(//div[@class="itemBody"]/*[@class="itemIntroText"])}
		   xpath_article_body {returntext(//div[@class="itemBody"]/*[@class="itemFullText"])}
		   xpath_article_date {returndate(//div[@class="inner-sidebar-left"]/strong,"%H:%M, %d/%m/%Y")}
		   xpath_article_author {returnstring(//a[@rel="author"])}
		   xpath_article_image {
		       {values(//span[@class="itemImage"]/a/img/@src)}
		       {values(//div[@class="itemBody"]/*[@class="itemFullText"]/img/@src)}
		   }
		   xpath_article_video {
		       {values(//div[@class="itemBody"]/*[@class="itemFullText"]/iframe/@src)}
		   }
		   xpath_article_tags {values(//div[@class="itemTagsBlock"]/a/text())}
		   xpath_article_cleanup {
		       {//div[@class="jfbccomments"]}
		   }
		   comment {
		       we have an issue with ads, related links, and other text in the main
		       article body
		   }
	       }\
	       stockwatch {
		   url http://www.stockwatch.com.cy/nqcontent.cfm?tt=article&a_id=1
		   include_re {/nqcontent.cfm\?a_name=news_view&ann_id=[0-9]+}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   check_for_revisions 1
		   check_for_revisions_interval_in_secs "7200"
		   xpath_feed_cleanup {
		       {//div[@class="bg-nav"]}
		   }
		   xpath_article_title {substring-before(//title,'- Stockwatch')}
		   xpath_article_body {returntext(//div[@class="text-content"])}
		   xpath_article_date {returndate(substring(substring-after(//h2[@style]/span/span,": "),1,16),"%d/%m/%Y %H:%M")}
		   xpath_article_modified_time {returndate(substring-after(substring-after(//h2[@style]/span/span," / "),": "),"%d/%m/%Y %H:%M")}
		   xpath_article_image {
		       {values(//div[@class="text-content"]/img[@align="left"]/@src)}
		   }
		   xpath_article_attachment {
		       {values(//div[@class="text-content"]/a/img[@class="attachment"]/parent::a/@href)}
		   }
		   xpath_article_cleanup {
		       {//ul[@class="arrow-list"]}
		       {//div[@class="ad-617x98"]}
		   }
		   comment {
		       - og:title
		       - og:description
		       - og:image (not being used - just stockwatch logo for social networks)
		       - TOD0: cleanup article body saying "note: save target as for attachments"
		         ditto for "ektenesteri eidhsh se ligo"
		   }
	       }\
	       newsit {
		   url http://www.newsit.com.cy/
		   include_re {default.php\?pname=Article&art_id=[0-9]+&catid=[0-9]+}
		   htmltidy_feed_p 1
		   xpath_article_title {returnstring(//div[@id="galleryBox_top_new"]/h2)}
		   xpath_article_description {returnstring(//div[@id="adjust-text"]/h2)}
		   xpath_article_body {returntext(//div[@id="adjust-text"]/p)}
		   xpath_article_date {returndate(//div[@class="first_info_00"],"%d.%m.%Y | %H:%M")}
		   xpath_article_modified_time {returndate(substring-after(//div[@class="last_info_00"],":"),"%d.%m.%Y | %H:%M")}
		   xpath_article_image {
		       {values(//div[@id="SelectContainer"]/div[@class="blackImages_00"]/img/@src)}
		   }
		   end_of_text_cleanup_p 1
		   end_of_text_coeff "0"
		   comment {
		       an end_of_text_coeff of zero means always cut that text away
		   }
	       }\
	       alitheia {
		   url http://www.alithia.com.cy/
		   include_re {/item/[0-9]+}
		   xpath_article_title {returnstring(//h2[@class="itemTitle"]/a)}
		   xpath_article_body {returntext(//div[@class="itemBody"]/*[@class="itemIntroText"])}
		   xpath_article_date {returndate(//span[@class="itemDateCreated"],"%A, %e %B %Y %H:%M")}
		   xpath_article_author {returnstring(//a[@rel="author"])}
		   xpath_article_image {
		       {values(//span[@class="itemImage"]/a/img/@src)}
		       {values(//div[@class="itemBody"]/*[@class="itemIntroText"]/img/@src)}
		   }
		   xpath_article_cleanup {
		       {//div[@class="itemImageBlock"]}
		       {//div[@class="shareThisWidget"]}
		   }
		   comment {
		       we have an issue with ads, related links, and other text in the main
		       article body
		       also itemFullText and itemIntroText messed up
		   }
	       } \
	       politis {
		   url http://www.politis.com.cy/
		   include_re {/cgibin/hweb\?-A=[0-9]+&-V=articles}
		   encoding cp1253
		   xpath_article_title {substring-after(//meta[@property="og:title"]/@content," - ")}
		   xpath_article_body {returntext(//td[@width="524"]/descendant::*[local-name()="p" or local-name()="div"])}
		   xpath_article_cleanup {
		       {//td[@width="524"]/descendant::hr[2]/following-sibling::*}
		       {//td[@width="524"]/descendant::hr[1]/preceding-sibling::*}
		       {//td[@width="524"]/descendant::hr[1]/following-sibling::table}
		       {//td[@width="524"]/descendant::p/i[contains(text(),' - ')]}
		       {//td[@width="524"]/descendant::p[@class="viewonpdf"]}
		   }
		   xpath_article_date {returndate(//td[@width="524"]/descendant::p/i[contains(text(),' - ')],"%d/%m/%Y - %H:%M")}
		   comment {
		       cp1253 (windows greek encoding - minor differences with iso8859-7, e.g. tonismeno alpha)
		   }

	       }\
	       ikypros {
		   url http://www.ikypros.com/
		   include_re {/easyconsole.cfm/id/[0-9]{3,}}
		   xpath_feed_cleanup {
		       {//a[@id]}
		       {//h3/a}
		   }
	       } \
	       pafosnet {
		   url http://pafosnet.com/
		   include_re {[[:alnum:]\-]{10,}}
		   exclude_re {/category/|/#}
		   xpath_article_title {returnstring(//head/title)}
		   xpath_article_body {returntext(//div[@id="the_content"])}
		   xpath_article_image {
		       {values(//div[@id="the_image"]/img/@src)}
		       {values(//div[@id="the_content"]/descendant::img/@src)}
		   }
		   xpath_article_video {
		       {values(//div[@id="videos_the_video"]/iframe/@src)}
		   }
		   xpath_article_date {returndate(normalizedate(//span[@class="post_date"],"el_GR"),"%d %B %Y","el_GR")}
		   comment {
		       og:description
		       keywords
		       we need to convert the video src to a video url
		       xpath_article_category {//h2[@class="post_category"]}
		   }
	       } \
	       haravgi {
		   url http://www.haravgi.com.cy/rss/rss.php
		   feed_type "rss"
		   include_re {site-article-[0-9]+-gr.php}
	       } \
	       bankingnews {
		   url http://www.bankingnews.gr/
		   include_re {item/[0-9]+}
		   normalize_link_re {(^.*/item/[0-9]+)-.*$}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   check_for_revisions 1
		   xpath_article_title {returnstring(//h2[@class="itemTitle"])}
		   xpath_article_date {returndate(string(//span[@class="itemDateCreated"]),"%d/%m/%y - %H:%M")}
		   xpath_article_description {returnstring(//div[@class="itemBody"]/*[@class="itemIntroText"])}
		   xpath_article_tags {values(//div[@class="itemCategory"]/a/text())}
		   xpath_article_image {values(//div[@class="itemBody"]/div[@class="itemImageBlock"]/descendant::img/@src)}
		   xpath_article_cleanup {
		       {//div[@class="itemBody"]/div[@class="clr" or @class="moduletabletrapezes"]}
		       {//div[@class="itemBody"]/div[@class="itemImageBlock"]}
		   }
		   xpath_article_body {returntext(//div[@class="itemBody"]/*[@class="itemFullText"])}
	       }]



proc print_usage_info {} {
    upvar argv0 argv0

    array set cmdinfo [list \
			   "sync" "?feed_names?" \
			   "show" "urlsha1" \
			   "show-url" "article_url" \
			   "show-content" "contentsha1" \
			   "uses-content" "contentsha1" \
			   "log" "?limit? ?offset?" \
			   "list" "feed_name ?limit? ?offset?" \
			   "revisions" "urlsha1" \
			   "test" "feed_name ?limit? ?fetch_item_p?" \
			   "remove-feed-items" "feed_name" \
			   "cluster" "?limit? ?offset?" \
			   "label" "axis class contentsha1 ?...?" \
			   "unlabel" "axis class contentsha1 ?...?" \
			   "fex" "?limit? ?offset?" \
			   "TODO:test-article" "article_url" \
			   "TODO:add" "feed_url"]


    foreach cmd [lsort [array names cmdinfo]] {
	puts "Usage: $argv0 ${cmd} $cmdinfo(${cmd})"
    }

}

set argc [llength $argv]
if { ${argc} < 1 } {

    print_usage_info

} else {

    set cmd [lindex $argv 0]

    if { ${cmd} eq {sync} && ${argc} >= 1 } {

	::feed_reader::sync_feeds feeds [lrange ${argv} 1 end]

    } elseif { ${cmd} eq {resync} && ${argc} == 1 } {

	::feed_reader::resync feeds

    } elseif { ${cmd} eq {test} && ${argc} >= 2} {

	set feed_name [lindex ${argv} 1]
	array set feed [dict get $feeds $feed_name]
	::feed_reader::test_feed feed {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {show} && ${argc} == 2 } {

	set urlsha1 [lindex ${argv} 1]
	::feed_reader::show_item ${urlsha1}

    } elseif { ${cmd} eq {revisions} && ${argc} == 2 } {

	set urlsha1 [lindex ${argv} 1]
	::feed_reader::show_revisions ${urlsha1}

    } elseif { ${cmd} eq {show-url} && ${argc} == 2 } {

	set article_url [lindex ${argv} 1]
	::feed_reader::show_item_from_url ${article_url}


    } elseif { ${cmd} eq {show-content} && ${argc} == 2 } {

	set contentsha1 [lindex ${argv} 1]
	::feed_reader::show_content ${contentsha1}

    } elseif { ${cmd} eq {uses-content} && ${argc} == 2 } {

	set contentsha1 [lindex ${argv} 1]
	::feed_reader::uses_content ${contentsha1}	

    } elseif { ${cmd} eq {log} && ${argc} >= 1 } {

	::feed_reader::log {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {list} && ${argc} >= 2 } {

	set feed_name [lindex ${argv} 1]
	array set feed [dict get $feeds $feed_name]
	::feed_reader::list_feed feed {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {remove-feed-items} && ${argc} >= 2 } {

	set feed_name [lindex ${argv} 1]
	array set feed [dict get $feeds $feed_name]
	::feed_reader::remove_feed_items feed

    } elseif { ${cmd} eq {cluster} && ${argc} >= 1 } {

	::feed_reader::cluster {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {label} && ${argc} >= 1 } {

	# label axis class contentsha1 ...
	#
	# e.g. label spam true ae23ff acb673
	# e.g. label important false example123 example456
	# e.g. label topic politics  example742 example888 example923 example443
	# e.g. label edition cyprus  example742 example888 example923 example443

	::feed_reader::label {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {unlabel} && ${argc} >= 1 } {

	# unlabel axis class contentsha1 ...

	::feed_reader::label {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {fex} && ${argc} >= 1 } {

	# TODO: word substrings, isFirstCapital, isLastPunct, isLastColon
	# TODO: word shapes:
	#    Varixella-zoster  Xx-xxx
	#    mRNA              xXXX
	#    CPA1              XXXd
	# hasDigit
	

	::feed_reader::feature_extraction {*}[lrange ${argv} 1 end]

    } else {

	print_usage_info

    }

}
