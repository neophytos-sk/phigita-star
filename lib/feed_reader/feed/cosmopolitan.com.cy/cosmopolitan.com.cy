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
