#!/usr/bin/tclsh




# 3ekina prota thn konsola os e3hs: LANG=el_GR.utf-8 konsole
# use this instead:wget --save-cookies=- -C on -nv -S -s -O - ${url}


#package require TclCurl
#package require sha1
#package require tdom
#package require XOTcl ;# namespace import -force ::xotcl::*


::xotcl::THREAD ::crawler {


    namespace eval ::aggregator {;}
    proc ::aggregator::startCrawler {} {

	#ns_proxy config exec_proxy -maxslaves 10 -maxruns 1000
	#set exec_handle [ns_proxy get exec_proxy]
	#$exec_handle {ns_log notice "[pid]"}

	while {1} {
	    if { [catch {::aggregator::refresh_aux} errmsg] } {
		ns_log notice "aggregation errmsg=$errmsg"
	    }
	    after 60000
	}

	#ns_proxy cleanup

    }

    proc ::aggregator::update_crawl_interval { input_url_o interval_increment msg } {

	## ns_log notice $msg

	${input_url_o} configure -mixin ::db::Object -set pool newsdb -set type ::buzz::Feed -pathexp {} -init

	set quoted_interval [ns_dbquotevalue $interval_increment]
	set quoted_url [ns_dbquotevalue [${input_url_o} set url]]

	[${input_url_o} getConn] do [subst {
	    update [${input_url_o} info.db.table] set
	        last_crawl=[ns_dbquotevalue [::util::sysdate]]
	       ,crawl_interval=coalesce(crawl_interval,${quoted_interval})::interval+${quoted_interval}::interval
	    where url=${quoted_url}
	}]
    }

    proc ::aggregator::refresh_aux {} {

	ns_log notice "START aggregator"

	if {[catch {
	    set last [::util::coalesce [::memoize::cache get BOW:LastTimeInSeconds] 0]
	    set now [clock seconds]

	    if {0} {
		if { $now - $last > [expr {12*3600}] } {
		    exec -- /bin/sh -c "[acs_root_dir]/packages/news/bin/tc-run.sh || exit 0" 2> /dev/null
		    exec -- /bin/sh -c "[acs_root_dir]/packages/news/bin/tc-rainbow.sh || exit 0" 2> /dev/null &
		    #	    exec -- /bin/sh -c "[acs_root_dir]/packages/news/bin/tc-crossbow.sh || exit 0" 2> /dev/null &
		    ::memoize::cache set BOW:LastTimeInSeconds $now
		    ns_log notice "BOW: READY"
		}
	    }

	} errmsg]} {
	    ns_log notice "tc-run.sh failed to start..."
	}


	set start_time [clock seconds]

	set o [::db::Set __FeedData -pool newsdb -select "use_feed_body_p guard classification__tree_sk classification__edition_sk train_topic_p train_edition_p url url_sha1 url_host_sha1 last_crawl_sha1 language buzz_p" -type ::buzz::Feed -where [list "(crawl_interval is null or last_crawl is null or last_crawl + crawl_interval < current_timestamp)" "active_p" "(language is null or language='el')"] -order "language desc, last_crawl" -limit 250 -load]

	set o1 [::uri::Request __Request1]
	set o2 [::uri::Request __Request2]
	set o3 [::sw::agg::Url __Url1 -mixin ::db::Object -pool newsdb]
	${o1} feed_p yes
	${o2} feed_p no
	set count 0
	set errcount 0
	set errlist ""
	set language_el 0
	set language_en 0
	foreach input_url_o [${o} set result] {

	    set use_feed_body_p [$input_url_o set use_feed_body_p]

	    set list_of_effective_links [list]

	    if { [$input_url_o set classification__tree_sk] ne {} } {
		set classification__tree_sk [$input_url_o set classification__tree_sk]
	    } else {
		# BELOW: query rainbow for the classification__tree_sk
		set classification__tree_sk ""
	    }

	    if { [$input_url_o set classification__edition_sk] ne {} } {
		set classification__edition_sk [$input_url_o set classification__edition_sk]
	    } else {
		# BELOW: query rainbow for the classification__edition_sk
		set classification__edition_sk ""
	    }

	    if { [array exists guard] } {
		unset guard
	    }
	    set input_url [${input_url_o} set url]
	    ns_log notice "Fetching: ${input_url}"
	    array set guard [$input_url_o set guard]

	    #${input_url_o} volatile

	    array set t_input_uri [::uri::split ${input_url}]
	    #	set t_input_uri_path $t_input_uri(path)
	    #	set t_input_uri_parent [string range ${t_input_uri_path} 0 [string last {/} ${t_input_uri_path}]]



	    if {[${o1} exists dom_obj]} { ${o1} unset dom_obj }
	    ${o1} configure -url ${input_url}
	    #ns_log notice "before perform: $input_url"
	    if {[catch { ${o1} perform } errmsg]} {
		::aggregator::update_crawl_interval $input_url_o "2 hours" "feed perform errmsg $errmsg"
		continue
	    }
	    #ns_log notice "after perform: $input_url"
	    if {[$o1 set response_code] != 200} {
		::aggregator::update_crawl_interval $input_url_o "30 minutes" "::aggregator::refresh:: Response Code [$o1 set response_code] - input_url=$input_url - input_url_o=$input_url_o"
		continue
	    }

	    if {![${o1} exists dom_obj]} {
		::aggregator::update_crawl_interval $input_url_o "10 minutes" "::aggregator::refresh:: No dom_obj - input_url=${input_url}"
		continue
	    }

	    if {[${o1} url] ne [${o1} effective_url] } {
		# update o1's url
		ns_log notice "Buzz (redirect): [$o1 url] -> [$o1 effective_url]"
		::aggregator::update_crawl_interval $input_url_o "10 minutes" "Buzz (redirect): [$o1 url] -> [$o1 effective_url]"
		continue
	    }


	    set r [lindex [[${o1} dom_obj] documentElement] 0]

	    if { ${r} eq {} } {
		ns_log notice "aggregator::refresh: No document element - input_url=${input_url}"
		continue
	    }

	    set type ""
	    set nodes ""
	    array unset info
	    switch -exact -- [${r} nodeName] {
		html {
		    ### HERE: needed for news
		    continue

		    #HTML
		    set type html
		    set channel_title ""
		    set channel_link ""
		    set channel_desc ""
		    set nodes [${r} selectNodes {//*[local-name()='a' or local-name()='A']}]
		    foreach e ${nodes} {

			set href [string trim [::util::coalesce [${e} getAttribute href ""] [${e} getAttribute HREF ""]]]
			if { ${href} eq {} || [string equal -length 11 javascript: [string tolower ${href}]]} {
			    # ${e} hasAttribute onclick
			    continue
			}
			set info(${e},link) [uri::resolve [::util::coalesce [${o1} set effective_url] ${input_url}] ${href}]
			#ns_log notice "${input_url} +++++ $info(${e},link) ====> $info(${e},link)"
			set info(${e},title) [string trim [string range [${e} asText] 0 255]]
			set info(${e},description) ""
			set info(${e},enclosure) ""
			set info(${e},tags) ""
			set info(${e},images) ""
			set info(${e},objects) ""
		    }
		}
		rdf:RDF -
		channel -
		rss {
		    #RSS
		    set type rss
		    set channel_title [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='title'])}]
		    set channel_link  [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='link'])}]
		    set channel_desc  [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='description'])}]
		    set nodes [${r} selectNodes {//*[local-name()='item']}]
		    foreach e ${nodes} {
			set info(${e},title) [${e} selectNodes {returnstring(*[local-name()='title'])}]
			set info(${e},link)  [${e} selectNodes {returnstring(*[local-name()='link'])}]
			set info(${e},description)  [${e} selectNodes {returnstring(*[local-name()='description'])}]
			set info(${e},enclosure)  [${e} selectNodes {returnstring(*[local-name()='enclosure'])}]
			set info(${e},tags) ""
			set info(${e},images) ""
			foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
			    set tag [string trim [string map {"\[" {} "\]" {} "<" {} ">" {}} [ns_striphtml [$tagNode text]]]]
			    if { $tag ne {} } {
				lappend info(${e},tags) $tag
			    }
			}
			set info(${e},images) [::util::map "::util::wgetFile news/images" [::xo::fun::filter [::util::getImageList $info(${e},description)] x {![string match http://ad.doubleclick.net/* $x] && ![string match http://stats.wordpress.com/* $x]}]]
			set info(${e},objects) ""
		    }
		}
		feed {
		    #Atom
		    set type atom
		    set channel_title [${r} selectNodes {returnstring(//*[local-name()='feed']/*[local-name()='title'])}]
		    set channel_link  [${r} selectNodes {values(//*[local-name()='feed']/*[local-name()='link' and @rel='alternate' and @type='text/html']/@href)}]
		    set channel_desc  [${r} selectNodes {returnstring(//*[local-name()='feed']/*[local-name()='tagline'])}]
		    set nodes [${r} selectNodes {//*[local-name()='entry']}]
		    foreach e ${nodes} {
			set info(${e},title) [${e} selectNodes {returnstring(*[local-name()='title'])}]
			set info(${e},link)  [${e} selectNodes {values(*[local-name()='link' and @rel='alternate' and @type='text/html']/@href)}]
			set info(${e},description)  [${e} selectNodes {returnstring(*[local-name()='summary' or local-name()='content'])}]
			set info(${e},enclosure)  [${e} selectNodes {values(*[local-name()='link' and @rel='enclosure']/@url)}]
			set info(${e},tags) ""
			set info(${e},images) ""
			foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
			    set tag [string trim [$tagNode getAttribute term ""]]
			    if { $tag ne {} } {
				lappend info(${e},tags) $tag
			    }
			}
			set info(${e},images) [::util::map "::util::wgetFile news/images" [::xo::fun::filter [::util::getImageList $info(${e},description)] x {![string match http://ad.doubleclick.net/* $x]}]]
			set info(${e},objects) ""
		    }
		}
		default {
		    ### HERE: needed for news
		    continue
		    set r [lindex [[${o1} dom_obj] selectNodes {//*[local-name()='html' or local-name()='HTML']}] 0]
		    if { ${r} eq {} } {
			set r [[${o1} dom_obj] selectNodes {//*[local-name()='body' or local-name()='BODY']}]
			if { ${r} eq {} } {
			    ns_log notice "aggregator::refresh - not a feed (default): ${input_url}"
			    continue
			}
		    }
		    set type html
		    set channel_title ""
		    set channel_link ""
		    set channel_desc ""
		    set nodes [${r} selectNodes {//*[local-name()='a' or local-name()='A']}]
		    foreach e ${nodes} {

			set href [string trim [::util::coalesce [${e} getAttribute href ""] [${e} getAttribute HREF ""]]]
			if { ${href} eq {} || [string equal -length 11 javascript: [string tolower ${href}]] } {
			    #${e} hasAttribute onclick
			    continue
			}
			set info(${e},link) [uri::resolve [::util::coalesce [${o1} set effective_url] ${input_url}] ${href}]
			#ns_log notice "${input_url} +++++ $info(${e},link) ====> $info(${e},link)"
			set info(${e},title) [string trim [${e} asText]]
			set info(${e},description) ""
			set info(${e},enclosure) ""
			set info(${e},tags) ""
			set info(${e},images) ""
			set info(${e},objects) ""
		    }
		}
	    }

	    #	puts "================================================="
	    #	puts "Feed Title: ${channel_title}"
	    #	puts "Feed Link:  ${channel_link}"
	    #	puts "Feed LSHA1: [ns_sha1 ${channel_link}]"
	    #	puts "Feed Desc.: ${channel_desc}"
	    #	puts "Feed Type:  ${type}"
	    #	puts "Feed Encoding: [${o1} set encoding]"
	    #	puts "Feed Language (guess): [${o1} set language]"

	    #	ns_write ${channel_title}\n${channel_link}\n\n


	    array unset link2node
	    set list_of_links ""
	    foreach e ${nodes} {
		if { [info exists info(${e},link)] && [info exists info(${e},title)] } {
		    if { [string trim $info(${e},title)] eq {} } {
			set info(${e},title) "..."
			#continue
		    }

		    # Guard Condition for targetURL
		    set targetTitle $info(${e},title)
		    set targetNode $e
		    #		set targetURL $url
		    set targetURL $info(${e},link)
		    if { [info exists guard(targetURL)] } {
			if { ![expr $guard(targetURL)] } {
			    #ns_log notice "Guard: Skipping $targetURL"
			    continue
			}
		    }
		    if { [info exists guard(targetTitle)] } {
			if { ![expr $guard(targetTitle)] } {
			    #ns_log notice "Guard: Skipping $targetURL"
			    continue
			}
			set info(${e},title) $targetTitle
		    }


		    # Make sure it has not already been fetched... 
		    # usuallly the link with the title comes first
		    if { ![info exists link2node([string tolower $info(${e},link)])] } {
			set link2node([string tolower $info(${e},link)]) ${e}
			lappend list_of_links $info(${e},link)
		    }
		}
	    }
	    set list_of_links [lsort ${list_of_links}]

	    set feed_prev_crawl_sha1 [${input_url_o} set last_crawl_sha1]
	    set feed_last_crawl_sha1 [ns_sha1 ${list_of_links}]
	    ${input_url_o} configure -mixin ::db::Object -set pool newsdb -set type ::buzz::Feed -pathexp {} -init


	    if { ${feed_last_crawl_sha1} eq ${feed_prev_crawl_sha1} } {
		# ns_log notice "list_of_links=$list_of_links"
	    } else {

		foreach e [lreverse ${nodes}] {
		    if { ![exists_and_not_null info(${e},link)] } continue
		    if { ![info exists link2node([string tolower $info(${e},link)])] } continue
		    if { $link2node([string tolower $info(${e},link)]) ne ${e} } continue
		    incr count

		    set url [string trim [regsub -- {\&?(PHPSESSID|sid)=[a-zA-Z0-9]{32}} $info(${e},link) {}] { ?}]
		    
		    if {[${o2} exists dom_obj]} { ${o2} unset dom_obj }
		    if {{} eq ${url}} continue;



		    if { 0 && [string match {http://feeds.feedburner.com/*} $url] } {
			ns_log notice "Skipping Item URL - ${url}"
			continue
		    }



		    # check if it has already been added to the database
		    db::One oTemp1 -pool newsdb -select channel_url_sha1 -type ::sw::agg::Url -where [list url=[ns_dbquotevalue ${url}]]
		    if {[oTemp1 exists_p]} {
			#ns_log notice "aggregator exists_p $url"
			continue
		    }

		    ns_log notice "Fetching Item URL - ${url}"

		    ${o2} configure -url ${url}
		    if {[catch {${o2} perform} errmsg]} {
			ns_log notice "error fetching item url $url"
			continue
		    }
		    if {![${o2} exists dom_obj]} {
			ns_log notice "no dom object for item url $url"
			continue
		    }

		    db::One oTemp1 -pool newsdb -select channel_url_sha1 -type ::sw::agg::Url -where [list url=[ns_dbquotevalue [$o2 set effective_url]]]
		    if {[oTemp1 exists_p]} {
			ns_log notice "aggregator exists_p $url"
			continue
		    }


		    array set uri [uri::split [util::coalesce [${o2} set effective_url] ${url}]]
		    set url_host_sha1 [ns_sha1 $uri(host)]
		    set last_crawl_sha1 [ns_sha1 [${o2} set response_text]]



		    db::Set oTemp2 -pool newsdb -select 1 -type ::sw::agg::Url -where [list "url_host_sha1=[ns_dbquotevalue ${url_host_sha1}]" "last_crawl_sha1=[ns_dbquotevalue ${last_crawl_sha1}]"] -limit 1
		    oTemp2 set result ""
		    oTemp2 load


		    set imageFile $info(${e},images)
		    set buzz_p [${input_url_o} set buzz_p]
		    set channel_url_sha1 [${input_url_o} set url_sha1]
		    set last_crawl_content [${o2} set response_text]

		    if { $imageFile eq {} } {
			if { [string match {*.blogspot.com} $uri(host)] } {
			    set docId [$o2 dom_obj]
			    set imageNodes [$docId selectNodes {//*[local-name()='img' and starts-with(@id,'BLOGGER_PHOTO_ID') ]}]
			    foreach imageNode $imageNodes {
				set imageURL [$imageNode getAttribute src ""]
				set imageURL [uri::resolve [::util::coalesce [${o2} set effective_url] ${url}] $imageURL]
				set imageFile [::util::wgetFile news/images $imageURL]
			    }
			}
		    }
		    

		    if { ![info exists sha1_to_link(${last_crawl_sha1})] && [oTemp2 emptyset_p]} {
			set sha1_to_link(${last_crawl_sha1}) [util::coalesce [${o2} set effective_url] ${url}]


			if { [info exists guard(imageURL)] && [$o2 exists dom_obj] } {
			    set targetDocumentRoot [[$o2 dom_obj] documentElement]
			    set imageNodes [${targetDocumentRoot} selectNodes {//*[local-name()='img' or local-name()='IMG']}]
			    foreach imageNode $imageNodes {
				set imageURL [$imageNode getAttribute src ""]
				###
				if { $imageURL ne {} } {
				    set imageURL  [uri::resolve [::util::coalesce [${o2} set effective_url] ${url}] $imageURL]
				    if { ![expr $guard(imageURL)] } {
					ns_log notice "Guard: Skipping $targetURL"
					continue
				    } else {

					set imageFile [::util::wgetFile news/images $imageURL]
					if { $imageFile ne {} } {
					    break
					} else {
					    ns_log notice "imageURL=${imageURL} imageFile=${imageFile}"
					}



				    }
				}
				###
			    }
			}
		    } else {
			#ns_log notice "buzz_p=null, emptyset_p=[oTemp2 emptyset_p]"
			if { !([$input_url_o set buzz_p] && $imageFile ne {}) } {
			    set buzz_p ""
			    set channel_url_sha1 ""
			    set last_crawl_content ""
			}
		    }

		    set endIndex [string first "\n" $info(${e},title)]
		    if { ${endIndex} == -1 } {
			set endIndex end
		    }
		    set clean_title [string trimleft [string range [string trim $info(${e},title)] 0 ${endIndex}] "-\\"]
		    set tags $info(${e},tags)

		    if { $use_feed_body_p } {
			set last_crawl_content [::util::html2text $info(${e},description)]
		    }

		    # -description  ::util::striphtml $info(${e},description)
		    ${o3} configure \
			-url_sha1 [ns_sha1 [util::coalesce [${o2} set effective_url] ${url}]] \
			-url_host_sha1 ${url_host_sha1} \
			-url [util::coalesce [${o2} set effective_url] ${url}] \
			-title [string map {' ""} ${clean_title}] \
			-description "" \
			-last_crawl_content [string trim [string map {' ""} ${last_crawl_content}] "-\\"] \
			-channel_url_sha1 ${channel_url_sha1} \
			-buzz_p ${buzz_p} \
			-language [${o1} set language] \
			-last_crawl [ns_dbquotevalue [::util::sysdate]] \
			-last_crawl_sha1 ${last_crawl_sha1} \
			-crawl_interval "1 month" \
			-creation_user "0" \
			-modifying_user "0" \
			-creation_ip "127.0.0.1" \
			-modifying_ip "127.0.0.1" \
			-classification__tree_sk $classification__tree_sk \
			-classification__edition_sk $classification__edition_sk \
			-train_topic_p [$input_url_o set train_topic_p] \
			-train_edition_p [$input_url_o set train_edition_p] \
			-image_file $imageFile \

		    $o3 set tags [::ttext::unac utf-8 $tags]

		    $o3 set anchor_list ""
		    $o3 set object_list ""

		    ### GET VIDEO & OBJECTS
		    if { [$o2 set maxNode] ne {} } {
			set maxNodeHTML [[[$o2 set maxNode] parentNode] asHTML]
			$o3 set anchor_list [::util::getAnchorList $maxNodeHTML]
			set video_list [::util::filter ::xo::buzz::video_p [::util::getObjectList $maxNodeHTML]]

			foreach video_url $video_list {
			    set video_id [::xo::buzz::getVideoID $video_url]
			    lassign [::xo::buzz::getVideo $video_id] found_p vo

			    if { $found_p } {
				set video_jic_sql [subst {
				    update xo.xo__video set 
				    cnt_references=cnt_references+1
				    ,last_update=CURRENT_TIMESTAMP 
				    where ref_video_id=[ns_dbquotevalue $video_id]
				}]

				if {[catch {[$o3 getConn] do ${video_jic_sql}} errmsg]} {
				    ns_log notice "video update cnt_references and last_update // errmsg=$errmsg video_jic_sql=$video_jic_sql"
				}
				ns_log notice video_id=$video_id
				$o3 lappend object_list [list $video_id [$vo set thumbnail_sha1] [$vo set thumbnail_width] [$vo set thumbnail_height]]
			    }
			}
		    }

		    # tries to avoid the association between an advertisement and an html page
		    if {${type} eq {html} && [${o2} set effective_url] ne {}} {
			array set t_uri [::uri::split ${url}]
			array set t_effective_uri [::uri::split [${o2} set effective_url]]
			

			#		    set t_effective_uri_path $t_effective_uri(path)
			#		    set t_effective_uri_parent [string range ${t_effective_uri_path} 0 [string last {/} ${t_effective_uri_path}]]


			if {$t_uri(host) ne $t_effective_uri(host) 
			    || ($t_effective_uri(host) ne $t_input_uri(host) && $t_input_uri(host) ne {news.phigita.net}) } {
			    ${o3} set channel_url_sha1 ""
			    ${o3} set buzz_p ""
			}
		    }

		    set jic_sql [subst {
			update [${o3} info.db.table] set
			last_crawl=[ns_dbquotevalue [::util::sysdate]]
			,last_crawl_sha1=[${o3} quoted last_crawl_sha1]
			,classification__tree_sk=coalesce(classification__tree_sk,[ns_dbquotevalue $classification__tree_sk])
			,classification__edition_sk=coalesce(classification__edition_sk,[ns_dbquotevalue $classification__edition_sk])
			,train_topic_p=train_topic_p OR [$input_url_o quoted train_topic_p]
			,train_edition_p=train_edition_p OR [$input_url_o quoted train_edition_p]
			where url=[${o3} quoted url]
		    }]
		    if { [catch {${o3} do self-insert ${jic_sql}} errmsg] } {
			continue
		    }


		    lappend list_of_effective_links [$o3 set url]



		    ### Index Tags
		    if { $tags ne {} } {

			### BUZZ TAGS

			set tagsTableName xo.xo__buzz__tags_gist
			set index_jic_sql [subst {
			    update ${tagsTableName} set 
			    tags_ts_vector=(select to_tsvector('simple',tags)||to_tsvector('[default_text_search_config]',tags) 
				       from xo.xo__sw__agg__url 
				       where url=[${o3} quoted url]) 
			    where url=[${o3} quoted url];
			}]

			set index_sql [subst {
			    select xo__insert_dml(
						  [ns_dbquotevalue [subst {
						      insert into ${tagsTableName} (
										      url
										      ,creation_date
										      ,tags_ts_vector
										      ) select 
						      url
						      ,creation_date
						      ,to_tsvector('simple',coalesce(tags,''))||to_tsvector('[default_text_search_config]',coalesce(tags,'')) 
						      from xo.xo__sw__agg__url 
						      where url=[${o3} quoted url];
						  }]],
						  [ns_dbquotevalue ${index_jic_sql}]
						  );
			}]

			[${o3} getConn] pl ${index_sql}


		    }


		    if { [${o3} language] ne {el} } {
			ns_log notice "language != el // url=[$o2 set url]"
		    }

		    # Text Indexer
		    if { [${o3} last_crawl_content] ne {} && [${o3} buzz_p] ne {} } {

			set searchTableName ""
			if { [${o3} buzz_p] } {
			    # Buzz
			    set searchTableName xo.xo__buzz_in_greek 
			} else {
			    # News
			    set searchTableName xo.xo__news_in_greek 
			}

			set index_jic_sql [subst {
			    update ${searchTableName} set 
			    ts_vector=(select to_tsvector('simple',coalesce(tags,'')) || to_tsvector('[default_text_search_config]',coalesce(title,'') || ' ' || coalesce(last_crawl_content,'') || ' ' || coalesce(tags,'')) 
				       from xo.xo__sw__agg__url 
				       where url=[${o3} quoted url]) 
			    where url=[${o3} quoted url];
			}]

			set index_sql [subst {
			    select xo__insert_dml(
						  [ns_dbquotevalue [subst {
						      insert into ${searchTableName} (
										      url
										      ,creation_date
										      ,ts_vector
										      ) select 
						      url
						      ,creation_date
						      ,to_tsvector('simple',coalesce(tags,'')) || to_tsvector('[default_text_search_config]',coalesce(title,'') || ' ' || coalesce(last_crawl_content,'') || ' ' || coalesce(tags,'')) 
						      from xo.xo__sw__agg__url 
						      where url=[${o3} quoted url];
						  }]],
						  [ns_dbquotevalue ${index_jic_sql}]
						  );
			}]

			[${o3} getConn] pl ${index_sql}


			# Machine Learning: Automatic Classification
			if { $buzz_p eq {f} } {
			    set ts_vector [[${o3} getConn] getvalue "select ts_vector from [::util::decode $buzz_p f xo.xo__news_in_greek t xo.xo__buzz_in_greek] where url=[$o3 quoted url]"]

			    set ml__classification__tree_sk [::bow::getClassTreeSk [::bow::getExpandedVector $ts_vector] 1821]
			    set ml__classification__edition_sk [::bow::getClassTreeSk [::bow::getExpandedVector $ts_vector] 1822]

			    set ml_train_topic_p [expr { [$input_url_o set train_topic_p] && [string equal $ml__classification__tree_sk $classification__tree_sk] }]
			    set ml_train_edition_p [expr { [$input_url_o set train_edition_p] && [string equal $ml__classification__edition_sk $classification__edition_sk] }]

			    [$o3 getConn] do "update xo.xo__sw__agg__url set classification__tree_sk=[ns_dbquotevalue [::util::coalesce $ml__classification__tree_sk $classification__tree_sk]], train_topic_p=[ns_dbquotevalue $ml_train_topic_p], classification__edition_sk=[ns_dbquotevalue [::util::coalesce $ml__classification__edition_sk $classification__edition_sk]], train_edition_p=[ns_dbquotevalue $ml_train_edition_p] where url=[$o3 quoted url]"


			    ############# HERE #########################
			    set COMMENT {
				if { $classification__tree_sk eq {} || [string match ${classification__tree_sk}.* ${ml__classification__tree_sk}]} {
				    [$o3 getConn] do "update xo.xo__sw__agg__url set classification__tree_sk=[ns_dbquotevalue $ml__classification__tree_sk], train_topic_p=[ns_dbquotevalue $ml_train_topic_p] where url=[$o3 quoted url]"
				}

				if { $ml__classification__edition_sk ne {} } {
				    if { $classification__edition_sk eq {} } {
					[$o3 getConn] do "update xo.xo__sw__agg__url set classification__edition_sk=[ns_dbquotevalue $ml__classification__edition_sk], train_topic_p=[ns_dbquotevalue $ml_train_topic_p] where url=[$o3 quoted url]"
				    }
				}
			    }


			}
		    }

		}
	    }

	    set list_of_effective_links [lsort $list_of_effective_links]
	    set last_crawl_sha1 [ns_sha1 ${list_of_effective_links}]
	    ${input_url_o} configure -mixin ::db::Object -set pool newsdb -set type ::buzz::Feed -pathexp {} -init

	    [${input_url_o} getConn] do [subst {
		update [${input_url_o} info.db.table] set
	        language=case when language is null then [ns_dbquotevalue [${o1} set language]] else language end
		,last_crawl=[ns_dbquotevalue [::util::sysdate]]
		,last_crawl_sha1=[ns_dbquotevalue ${feed_last_crawl_sha1}]
		,crawl_interval=case when last_crawl_sha1=[ns_dbquotevalue ${feed_last_crawl_sha1}] then coalesce(crawl_interval,'16 minutes')::interval+'16 minutes'::interval else (coalesce(crawl_interval,'16 minutes')::interval+'16 minutes'::interval)/90 end
		where url=[ns_dbquotevalue ${input_url}]
	    }]

	}

	set end_time [clock seconds]
	ns_log notice "END aggregator refresh: time=[expr ${end_time}-${start_time}]"

	set comment {
	    ns_log notice "blogger::aggregate_feeds
        Time: [expr ${end_time}-${start_time}] seconds
        Count:${count}
        Errcount:$errcount
        Errlist:$errlist
        Greek: ${language_el}
        English: ${language_en}"
	}


    }

    
} -persistent 1
