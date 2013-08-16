#!/usr/bin/tclsh

# TODO: extract comments from article pages

set dir [file dirname [info script]]

source [file join ${dir} feed-procs.tcl]

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
		   xpath_article_date {returndate(//div[@class="article_meta"]/span[@class="meta_date"]/strong,"%B %d, %Y %H:%M","el_GR")}
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
		   xpath_article_date {returndate(substring-after(//div[@id="articleContainer"]/h4/text(),"| "),"%d %B %Y, %H:%M","el_GR")}
		   xpath_article_cleanup {
		       {//div[@id="articleContainer"]/h4}
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
	       haravgi {
		   url http://www.haravgi.com.cy/rss/rss.php
		   feed_type "rss"
		   include_re {site-article-[0-9]+-gr.php}
	       } \
	       ant1iwo {
		   url http://www.ant1iwo.com/
		   include_re {/[0-9]{4}/[0-9]{2}/[0-9]{2}/}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//div[@id="il_title"]/h1)}
		   xpath_article_body {returntext(//div[@id="il_text"])}
		   xpath_article_date {substring-after(//div[@id="il_pub_date"]/div[@class="pubdate"]/text(),": ")}
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
		   encoding iso8859-7
		   xpath_article_title {substring-after(//meta[@property="og:title"]/@content," - ")}
		   xpath_article_body {returntext(//td[@width="524"]/descendant::*[local-name()="p" or local-name()="div"])}
		   xpath_article_cleanup {
		       {//td[@width="524"]/descendant::hr[2]/following-sibling::*}
		       {//td[@width="524"]/descendant::hr[1]/preceding-sibling::*}
		       {//td[@width="524"]/descendant::hr[1]/following-sibling::table}
		       {//td[@width="524"]/descendant::p/i[contains(text(),' - ')]}
		   }
		   xpath_article_date {returndate(//td[@width="524"]/descendant::p/i[contains(text(),' - ')],"%d/%m/%Y - %H:%M")}

	       }\
	       ikypros {
		   url http://www.ikypros.com/
		   include_re {/easyconsole.cfm/id/[0-9]{3,}}
		   xpath_feed_cleanup {
		       {//a[@id]}
		       {//h3/a}
		   }
	       }]



set argc [llength $argv]
if { $argc == 1 } {
    set feed_name [lindex $argv 0]
    array set feed [dict get $feeds $feed_name]
    ::feed_reader::test_feed feed
} else {
    ::feed_reader::sync_feeds feeds
}