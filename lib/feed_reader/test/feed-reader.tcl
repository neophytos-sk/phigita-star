#!/usr/bin/tclsh

# TODO: extract comments from article pages

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require feed_reader

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
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
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
		   include_re {/easyconsole.cfm/id/[0-9]{4,}}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_feed_cleanup {
		       {//a[@id]}
		       {//h3/a}
		   }
		   xpath_article_date {returndate(normalizedate(//span[@class="dateRed"],"el_GR"),"%d %B %Y %H:%M","el_GR")}
		   xpath_article_description {string(//meta[@name="Description"]/@content)}
		   xpath_article_tags {}
		   xpath_article_body {returntext(//div[@class="newsArticleBox"])}
		   xpath_article_cleanup {
		       {//div[@class="articleGreyContainer"]}
		       {//div[@class="articleImgContainer"]}
		   }
		   link_stoplist {
		       http://www.ikypros.com/easyconsole.cfm/id/9809
		       http://www.ikypros.com/easyconsole.cfm/id/67573
		   }
		   image_stoplist {
		       http://www.ikypros.com/assets/image/imageoriginal/img-logo-ikypros.png
		       http://www.ikypros.com/images/galleryLeftArrow.gif
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
		   xpath_article_image {
		       {values(//div[@class="itemBody"]/div[@class="itemImageBlock"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//div[@class="itemBody"]/div[@class="clr" or @class="moduletabletrapezes"]}
		       {//div[@class="itemBody"]/div[@class="itemImageBlock"]}
		   }
		   xpath_article_body {returntext(//div[@class="itemBody"]/*[@class="itemFullText"])}
	       } \
	       cyprus-mail {
		   url http://cyprus-mail.com/
		   include_re {/[0-9]{4}/[0-9]{2}/[0-9]{2}/[[:alnum:]\-]+/$}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   article_langclass {en.utf8}
		   xpath_article_title {returnstring(//h1[@class="entry-title"])}
		   xpath_article_date {returndate(//div[@id="entry-post"]/descendant::span[@class="meta-time"],"%B %d, %Y")}
		   xpath_article_tags {values(//div[@class="entry-tags"]/a[@rel="tag"]/text())}
		   xpath_article_image {
		       {values(//div[@class="entry-thumb"]/a/img/@src)}
		   }
		   xpath_article_cleanup {
		       {//div[@itemprop="articleBody"]/p/em[1]}
		       {//div[@class="printfriendly pf-alignright"]}
		       {//div[@class="zilla-share"]}
		       {//div[@class="kindleWidget kindleLight"]}
		   }
		   xpath_article_body {returntext(//div[@itemprop="articleBody"])}
		   comment {
		       xpath_article_category {//span[@class="category-item"]/a/text()}
		   }
	       } \
	       maxhnews {
		   url http://www.maxhnews.com/
		   include_re {/content/[0-9]+}
		   htmltidy_feed_p 0
		   htmltidy_article_p 0
		   xpath_article_title {returnstring(//div[@id="title"]/h1)}
		   xpath_article_date {returndate(substring-after(//div[@id="article-dates"]/br/preceding-sibling::text(),":"),"%Y-%m-%d %H:%M:%S")}
		   xpath_article_modified_time {returndate(substring-after(//div[@id="article-dates"]/br/following-sibling::text(),":"),"%Y-%m-%d %H:%M:%S")}
		   xpath_article_description {}
		   xpath_article_image {
		       {values(//div[@id="images-container"]/a/img/@src)}
		   }
		   xpath_article_cleanup {
		       {//div[@id="images-container"]}
		   }
		   xpath_article_body {returntext(//div[@id="description"])}
	       }\
	       volkan {
		   url http://www.volkangazetesi.net/
		   include_re {[0-9]{3,}.html$}
		   article_langclass {tr.utf8}
		   xpath_article_title {returnstring(//div[@class="haber-detay"]/h1[1])}
		   xpath_article_date {returndate(//div[@class="haber-detay"]/b/em[1],"%d.%m.%Y %H:%M")}
		   xpath_article_body {returntext(//div[@class="haber-detay"])}
		   xpath_article_image {
		       {string(//meta[@property="og:image"]/@content)}
		       {values(//div[@class="haber-detay"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//div[@class="haber-detay"]/h1[1]}
		       {//div[@class="haber-detay"]/span[1]}
		       {//div[@class="haber-detay"]/div[@class="haber-detay-paylas"]}
		       {//div[@class="haber-detay"]/b/em[1]}
		       {//div[@class="haber-detay"]/b[1]}
		   }
	       } \
	       cna0 {
		   url "http://www.cna.org.cy/applications/NewsManager/announcements2.asp"
		   include_re {/applications/NewsManager/announcements2.asp\?ItemID=[0-9]+&rcid=[0-9]+&pcid=[0-9]+&cid=[0-9]+}
		   article_langclass {auto}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//span[@class="pagetitle"]/strong)}
		   xpath_article_body {returntext(//body/table[1]/descendant::td[@valign="top"])}
		   xpath_article_image {
		       {values(//td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//span[@class="pagetitle"]/strong}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna1 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=1&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna2 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=2&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna3 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=3&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna4 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=4&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna5 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=5&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       cna6 {
		   url "http://www.cna.org.cy/m_titles.asp?a=1&b=6&c=4"
		   include_re {webnews.asp\?a=[[:alnum:]]{32}}
		   xpath_article_title {returnstring(substring-before(//title,"|"))}
		   xpath_article_body {returntext(//span[@class="pagetext"])}
		   xpath_article_image {
		       {values(/html/body/table[4]/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/center/img/@src)}
		       {values(//body/table[1]/descendant::td[@valign="top"]/descendant::img/@src)}
		   }
		   xpath_article_cleanup {
		       {//font[@color="RED"]/following-sibling::*}
		       {//font[@color="RED"]/following-sibling::text()}
		       {//font[@color="RED"]}
		   }
		   xpath_article_date {returndate(//span[@class="pagetitle"]/font[2]/following-sibling::text(),"%d/%N/%Y %H:%M")}
	       }\
	       financialmirror {
		   url "http://www.financialmirror.com/"
		   include_re {news-details.php\?nid=[0-9]+$}
		   article_langclass {en.utf8}
		   xpath_article_title {returnstring(//div[@class="newsDatePanel"]/h1)}
		   xpath_article_date {returndate(//div[@class="newsDatePanel"]/div[@class="newsDate"],"%d %B, %Y")}
		   xpath_article_body {returntext(//div[@class="newsCntrDetail"])}
		   xpath_article_tags {values(//div[@class="catName"]/text())}
		   xpath_article_image {
		       {values(//div[@class="newsCntrDetail"]/descendant::img/@src)}
		   }
	       }\
	       incyprus {
		   url "http://www.incyprus.com.cy/"
		   include_re {/en-gb/[^/]+/[0-9]+/[0-9]+/}
		   article_langclass {en.utf8}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//div[@class="ArticleCategories_T"]/descendant::h1[1])}
		   xpath_article_date {returndate(//div[@class="ArticleCategories_Date"],"%d %B %Y %H:%M")}
		   xpath_article_modified_time {}
		   xpath_article_image {
		       {values(//div[@class="ArticleCategories_Img"]/img/@src)}
		   }
		   xpath_article_body {returntext(//div[@class="ArticleCategories_BODY"])}
		   comment {
		       meta modified_time not trustworth (does not include AM/PM) mismatch between body and meta info
		   }
	       }\
	       elita {
		   url "http://www.elita.com.cy/"
		   include_re {el-gr/[^/]+/[0-9]+/[0-9]+/[[:alnum:]\-]+}
		   exclude_re {el-gr/oi-eidikoi-mas/}
		   article_langclass {el.utf8}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//h1[@class="Full ArtclTTL"])}
		   xpath_article_image {
		       {values(//div[@class="Full ArtclImg gallery"]/descendant::img/@src)}
		   }
		   xpath_article_body {returntext(//div[@class="Full ArtclSUbTtl"])}
		   comment {
		       meta published_time modified_time not trustworthy (does not include AM/PM) but better than date shown in article
		   }
	       }\
	       cosmopolitan.com.cy {
		   url "http://www.cosmopolitan.com.cy/"
		   include_re {el-gr/[^/]+/[0-9]+/[0-9]+/[[:alnum:]\-]+}
		   exclude_re {el-gr/oi-eidikoi-mas/}
		   article_langclass {el.utf8}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//*[@class="CosmoSingle_T"])}
		   xpath_article_image {
		       {values(//div[@class="CosmoSingle_IMG gallery"]/descendant::img/@src)}
		   }
		   xpath_article_body {returntext(//div[@class="CosmoSingle_TXT"])}
		   xpath_article_date {}
		   xpath_article_modified_time {}
		   xpath_article_tags {}
		   comment {
		       meta published_time modified_time not trustworthy (does not include AM/PM) but better than date shown in article
		   }
	       }\
	       sfera {
		   url "http://www.sfera.com.cy/el-gr/News"
		   include_re {el-gr/[^/]+/[0-9]+/[0-9]+/[[:alnum:]\-]+}
		   exclude_re {el-gr/enter-and-win/}
		   article_langclass {el.utf8}
		   htmltidy_feed_p 1
		   htmltidy_article_p 1
		   xpath_article_title {returnstring(//div[@class="producerName"])}
		   xpath_article_body {returntext(//div[@class="producerTXT"])}
		   xpath_article_image {
		       {values(//div[@class="producerIMG"]/descendant::img/@src)}
		   }
	       }\
	       empty {
		   url ""
		   feed_type {}
		   encoding {}
		   include_re {/[0-9]{4}/[0-9]{2}/[0-9]{2}/[[:alnum:]\-]+$}
		   exclude_re {}
		   normalize_link_re {}
		   htmltidy_feed_p 0
		   htmltidy_article_p 0
		   check_for_revisions 0
		   keep_title_from_feed_p 0
		   article_langclass {auto}
		   xpath_feed_cleanup {
		   }
		   xpath_article_title {returnstring()}
		   xpath_article_date {returndate()}
		   xpath_article_modified_time {returndate()}
		   xpath_article_description {returnstring()}
		   xpath_article_tags {values()}
		   xpath_article_image {
		       {values()}
		   }
		   xpath_article_attachment {
		       {values()}
		   }
		   xpath_article_cleanup {
		   }
		   xpath_article_body {returntext()}
		   xpath_article_video {
		       {values()}
		   }
		   xpath_article_author {string()}
		   end_of_text_cleanup_p 0
		   end_of_text_coeff "0.33"
		   comment {
		   }
	       }]



proc print_usage_info {} {
    upvar argv0 argv0

    array set cmdinfo [list \
			   "sync" "?feed_names?" \
			   "show" "urlsha1 ?...?" \
			   "show-url" "article_url" \
			   "show-content" "contentsha1" \
			   "uses-content" "contentsha1" \
			   "diff-content" "contentsha1_old contentsha1_new" \
			   "log" "?limit? ?offset?" \
			   "list" "feed_name ?limit? ?offset?" \
			   "revisions" "urlsha1" \
			   "register-axis" "axis_name" \
			   "register-label" "axis_name label_name" \
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

    } elseif { ${cmd} eq {show} && ${argc} >= 2 } {

	set urlsha1_list [lrange ${argv} 1 end]
	::feed_reader::show_item ${urlsha1_list}

    } elseif { ${cmd} eq {revisions} && ${argc} == 2 } {

	set urlsha1 [lindex ${argv} 1]
	::feed_reader::show_revisions ${urlsha1}

    } elseif { ${cmd} eq {register-axis} && ${argc} == 2 } {

	set axis [lindex ${argv} 1]
	::feed_reader::classifier::register_axis ${axis}
	
    } elseif { ${cmd} eq {register-label} && ${argc} == 3 } {

	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
	::feed_reader::classifier::register_label ${axis} ${label}

    } elseif { ${cmd} eq {show-url} && ${argc} == 2 } {

	set article_url [lindex ${argv} 1]
	::feed_reader::show_item_from_url ${article_url}


    } elseif { ${cmd} eq {show-content} && ${argc} == 2 } {

	set contentsha1 [lindex ${argv} 1]
	::feed_reader::show_content ${contentsha1}

    } elseif { ${cmd} eq {diff-content} && ${argc} == 3 } {

	set contentsha1_old [lindex ${argv} 1]
	set contentsha1_new [lindex ${argv} 2]
	::feed_reader::diff_content ${contentsha1_old} ${contentsha1_new}

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
	# e.g. label priority important example123 example456
	# e.g. label topic politics  example742 example888 example923 example443
	# e.g. label edition cyprus  example742 example888 example923 example443
	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
	set contentsha1_list [lrange ${argv} 3 end]
	::feed_reader::classifier::label ${axis} ${label} ${contentsha1_list}

    } elseif { ${cmd} eq {unlabel} && ${argc} >= 1 } {

	# unlabel axis class contentsha1 ...

	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
	set contentsha1_list [lrange ${argv} 3 end]
	::feed_reader::classifier::unlabel ${axis} ${label} ${contentsha1_list}

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
