set dir [file dirname [info script]]

source [file join ${dir} feed-procs.tcl]

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
		       {values(//div[@id="article_content"]/img/@src)}
		       {values(//div[@id="article_content"]//img[@class="pyro-image"]/@src)}
		   }
		   xpath_article_author {returnstring(//div[@class="article_meta"]/span[@class="meta_author"]/a/text())}
		   xpath_article_date {returnstring(//div[@class="article_meta"]/span[@class="meta_date"]/strong/text())}
		   xpath_article_cleanup {
		       {//div[@class="soSialIcons"]}
		       {//div[@class="article_meta"]}
		   }
	       } \
	       inbusiness {
		   url http://www.sigmalive.com/inbusiness/
		   include_re {/inbusiness/.*/[0-9]+}
		   keep_title_from_feed_p 0
		   xpath_article_title {//div[@id="articleContainer"]/h1}
		   xpath_article_body {//div[@id="articleContainer"]/div[@class="content"]/div[1]}
		   xpath_article_image {
		       {values(//div[@class="articleImg"]/div[@class="img"]/img/@src)}
		   }
		   xpath_article_date {substring-after(//div[@id="articleContainer"]/h4/text(),"| ")}
		   xpath_article_cleanup {
		       {//div[@id="articleContainer"]/h4}
		   }
	       } \
	       paideia-news {
		   url http://www.paideia-news.com/
		   include_re {id=[0-9]+&hid=[0-9]+}
		   htmltidy_article_p 1
		   xpath_article_title {//div[@class="main_resource_title_single"]}
		   xpath_article_author {returnstring(//div[@class="main_resource_summ2"]/p/strong/span)}
		   xpath_article_body {//div[@class="main_resource_summ2"]}
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
		   xpath_article_title {//div[@id="il_title"]/h1}
		   xpath_article_body {//div[@id="il_text"]}
		   xpath_article_date {substring-after(//div[@id="il_pub_date"]/div[@class="pubdate"]/text(),": ")}
		   comment {image is via meta og:image}
	       } \
	       24h {
		   url http://www.24h.com.cy/
		   include_re {item/[0-9]+}
		   htmltidy_article_p 1
		   xpath_article_title {//h2[@class="itemTitle"]/a}
		   xpath_article_description {returnstring(//div[@class="itemIntroText"])}
		   xpath_article_body {//div[@class="itemBody"]/div[@class="itemFullText"]}
		   xpath_article_date {returnstring(//div[@class="inner-sidebar-left"]/strong)}
		   xpath_article_author {returnstring(//a[@rel="author"])}
		   xpath_article_image {
		       {values(//span[@class="itemImage"]/a/img/@src)}
		       {values(//div[@class="itemBody"]/span[@class="itemFullText"]/img/@src)}
		   }
		   xpath_article_video {
		       {values(//div[@class="itemBody"]/span[@class="itemFullText"]/iframe/@src)}
		   }
		   xpath_article_tags {values(//div[@class="itemTagsBlock"]/a)}
		   xpath_article_cleanup {
		       {//div[@class="jfbccomments"]}
		   }
		   comment {
		       we have an issue with ads, related links, and other text in the main
		       article body
		   }
	       }]



array set stoptitles [list]
foreach title [split [::util::readfile stoptitles.txt] "\n"] {
    set stoptitles(${title}) 1
}


set argc [llength $argv]
if { $argc == 1 } {
    set feed_name [lindex $argv 0]
    array set feed [dict get $feeds $feed_name]
    test_feed feed stoptitles
} else {
    sync_feeds feeds stoptitles
}
