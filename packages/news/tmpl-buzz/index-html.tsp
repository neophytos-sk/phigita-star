#source [acs_root_dir]/packages/core-platform/tcl/tsp/tmpl-procs.tcl
#source [acs_root_dir]/packages/core-platform/tcl/globalization/localization-procs.tcl

ad_page_contract {
    @author Neophytos Demetriou
} {
    {offset:naturalnum,notnull 0}
    {host:trim,optional ""}
    {tag:trim,optional ""}
    {q:trim,optional ""}
    {order_by:trim "date"}
	{edition:trim ""}
	{topic:trim ""}
    {debug_p:boolean "f"}
}

set base .


if { $offset > 100 } {
    set count 100
    ns_returnmoved [export_vars -no_empty -base ${base} -override [list [list offset ${count}]] {q host tag}]
    return
}


set keywords "Greek, Blogs, Aggregation, Social Media, Tags, Search, Buzz, Video"
set description "Buzz is a \"social media\" aggregator. We monitor, surface, and index Greek Blogs & Feeds continuously throughout the day, so you will see new stories each time you check the page.The selection and placement of stories are determined automatically by a computer program."

set limit 10
set storydata [::db::Set new \
		   -pool newsdb \
		   -select {
		       * 
		       {substr(last_crawl_content,0,275) as last_crawl_content}
		       {date_trunc('second',creation_date) at time zone 'UTC' as creation_date_utc}
		   } \
		   -alias story \
		   -type ::sw::agg::Url \
		   -where [list "buzz_p" "language='el'"] \
		   -order "creation_date desc" \
		   -offset ${offset} \
		   -limit [expr 1+${limit}] \
		   -noinit]


set tsQueryDict [default_text_search_config]
#set tsQueryDict simple


#set enable_google_image_ads_p [expr {rand() * 1.0 > 0.2 ? false : true}]
set enable_google_image_ads_p true
set enable_sidebar_google_ads_p true


set searchQuery $q
set queryTitle ""
set order "creation_date"
switch -exact -- ${order_by} {
    {date} {
        set order "creation_date"
    }
    {rank} {
        set order "rank"
    }
}
set feed_cnt ""
set feed_cnt [util_memoize {
	set o [::db::Set new -pool newsdb -select [list "count(1) as feed_cnt"] -type ::buzz::Feed -where [list "active_p" "buzz_p"  "language='el'"]]
	$o load
	set feed_cnt [[$o head] set feed_cnt]
} 3600]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ${user_id} == 0 } {
    set admin_p f
} else {
    set admin_p [permission::permission_p -object_id ${package_id} -party_id ${user_id} -privilege admin]
}





if { ${topic} ne {} } {
    #    $clusterList lappend where "cluster_sk <@ [ns_dbquotevalue [string map {. _} $topic]]"
    ${storydata} lappend where "classification__tree_sk <@ [ns_dbquotevalue ${topic}]"
    lappend page_subtitle "[mc news.topic.${topic} $topic]"
}



set editionIndex 0
if { ${edition} ne {} } {
    #    $clusterList lappend where "cluster_sk ~ [ns_dbquotevalue "*{1}.[string map {. _} $edition].*"]"
    ${storydata} lappend where "classification__edition_sk = [ns_dbquotevalue ${edition}]"
    lappend page_subtitle "[mc news.edition.${edition} $edition]"
}


set subtitle ""
set page_subtitle ""

set limitTags 25

if { [exists_and_not_null tag] } {
    set base ..
    append keywords ", ${tag}"
    set conn [$storydata getConn]

    set tsTagsQueryDict simple
    set tsTagsQuery [${conn} getvalue "select to_tsquery('${tsTagsQueryDict}',[ns_dbquotevalue [join ${tag} {&}]])"]
    set tsTagsQuery [string trim [string map {{'} { }} $tsTagsQuery]]
    if { $tsTagsQuery ne {} } {


	$storydata unset type

	set tsTagsQuery [ns_dbquotevalue $tsTagsQuery]::tsquery
	set tsLimit [expr { 1 + ${limit} }]
	set tsTableName1 xo.xo__buzz__tags_gist
	set tsTableName2 xo.xo__buzz__tags_index
	if { 1 || $order eq {creation_date} } {

	    set query1 "(select *  from ${tsTableName1} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    set query2 "(select *  from ${tsTableName2} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from (${query1} union all ${query2}) qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from ${query1} qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from ${query2} qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"



	} else {

	    set query1 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],tags_ts_vector,${tsTagsQuery},1|4) as rank from ${tsTableName1} where tags_ts_vector @@ ${tsTagsQuery} order by rank desc limit $tsLimit offset ${offset})"
	    set query2 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],tags_ts_vector,${tsTagsQuery},1|4) as rank  from ${tsTableName2} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector,rank from (${query1} union all ${query2}) qq order by rank desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"

	}
	###$storydata init
	####ns_log notice "tagsTsQuery SQL= [$storydata set sql]"



	### $storydata lappend where "tags_ts_vector @@ $tsQuery"
	#	set q [concat $q $tag]
	set conn [$storydata getConn]
	set related_tags [$conn query "select rule_head from xo.xo__buzz_related_tags where rule_size=[llength $tag] and rule_ts_vector @@ $tsTagsQuery order by confidence desc limit 5"]

	set popularTags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1+[llength [string map {{_} { }} $tag]] and itemset_ts_vector @@ $tsTagsQuery order by occurrence desc limit $limitTags"]


	append queryTitle "$tag - "
	lappend subtitle "<b>Tag:</b> <a href=$tag style=\"color:green\">$tag</a>"
	#    set searchQuery [concat "tag=$tag" $searchQuery]
    } else {
        # do nothing 
    }


} else {

    set conn [$storydata getConn]	
    set popularTags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1 order by occurrence desc limit $limitTags"]
}


### SORT


### Generate Tag Cloud
if { [exists_and_not_null popularTags] } {
    if { $popularTags ne {} } {

	### Generate Tag Cloud

	# Step 1 - Get a list tags, and their frequency

	#set conn [DB_Connection new -pool newsdb -volatile]
	#set popularTags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1 order by occurrence desc limit $limitTags"]

	# Step 2 - Find the Max and Min frequency

	set maxOcc [[lindex $popularTags 0] set occurrence]
	set minOcc [[lindex $popularTags end] set occurrence]

	#Step 3 - Find the difference between max and min, and the distribution

	set diffOcc [expr { $maxOcc - $minOcc }]
	set distOcc [expr { (1.0 + $diffOcc) / 3.0 }]

	# Step 4 - Sort by name

	set tagCloudList [lsort -command [list ::util::__ObjectSlotCompare itemset_tags] $popularTags]

	# Step 5 - Loop over the tags, and output with size

    }
}


if { [exists_and_not_null host] } {
    set no_www_host [regsub -- {^www\.} ${host} {}]
    set url_host_sha1 [ns_sha1 ${host}]
    ${storydata} lappend where "url_host_sha1=[ns_dbquotevalue ${url_host_sha1}]"
    lappend subtitle "<b>Source:</b> <a href=\"http://${host}/\" style=\"color:\#666666;\">http://${no_www_host}</a>"
    append queryTitle " ${no_www_host} - "
}





if { [exists_and_not_null q] } {

	set firstindex [string first {=} ${q}]
	set directive [string tolower [string range ${q} 0 ${firstindex}]]
	set subQuery [string trimleft [string range ${q} ${firstindex} end] { =}]

	if {${directive} eq {tag=} } {
	    throw REDIRECT [export_vars -base ${base}/tag/$subQuery]
	    return
	}

	set q [string map {- { } {(} {} {)} {} : { } ' {} {/} {} | {} & {} ! {} ~ {}} ${q}]

	set conn [${storydata} getConn]
	set tsQuery [${conn} getvalue "select to_tsquery('${tsQueryDict}',[ns_dbquotevalue [join ${q} {&}]])"]
	set tsQuery [string trim [string map {{'} { }} $tsQuery]]

	set tsQuery [ns_dbquotevalue ${tsQuery}]::tsquery
	set numnode [${conn} getvalue "select numnode(${tsQuery})"]
	###ns_log notice "buzz: numnode=$numnode tsQuery=$tsQuery"

	if { ${tsQuery} ne {} && ${numnode} > 0} {


	set tsTableName xo.xo__buzz_in_greek
	#set tsTableName xo.xo__buzz_in_greek_static

	
	#set tsQuery [string map {' { } {|} {&}} [string trim ${tsQuery}]]

	#	set tsQuery [regsub -all -- {([\|] [^ ] )} __dummy__ {}]


	### HERE: replace with ::db::Union_All
						 

	set endRange end
	${storydata} unset type

	set tsLimit [expr { 1 + ${limit} }]
	set tsTableName1 xo.xo__buzz_in_greek
	set tsTableName2 xo.xo__buzz__text_index
	if { $order eq {creation_date} } {

	    set query1 "(select *  from ${tsTableName1} where ts_vector @@ ${tsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    set query2 "(select *  from ${tsTableName2} where ts_vector @@ ${tsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector from (${query1} union all ${query2}) qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector from ${query1} qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector from ${query2} qq order by qq.creation_date desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"



	} else {

	    set query1 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,${tsQuery},1|4) as rank from ${tsTableName1} where ts_vector @@ ${tsQuery} order by rank desc limit $tsLimit offset ${offset})"
	    set query2 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,${tsQuery},1|4) as rank  from ${tsTableName2} where ts_vector @@ ${tsQuery} order by creation_date desc limit $tsLimit offset ${offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector,rank from (${query1} union all ${query2}) qq order by rank desc offset ${offset} limit ${tsLimit}) r on (u.url=r.url)"

	}

	${storydata} lappend select "ts_headline('[default_text_search_config]',last_crawl_content,$tsQuery,'MaxWords=45, MinWords=35') as last_crawl_content"
	${storydata} lappend select "ts_headline('[default_text_search_config]',title,$tsQuery) as title"

	${storydata} order "$order desc"
	#	${storydata} unset offset
	#${storydata} unset limit

	### $storydata init
	### ns_log notice [$storydata set sql]
	set start_clicks [clock clicks -milliseconds]
	${storydata} load
	set end_clicks [clock clicks -milliseconds]
	set search_duration [expr {(${end_clicks}-${start_clicks})/1000.0}]


	set refine_query [::ttext::unac utf-8 [string map {{(} {} {)} {} : { } {/} {} ' {} | {} & {} ! {} ~ {}} ${q}]]

	set tsRefineQuery [${conn} getvalue "select to_tsquery('${tsQueryDict}',[ns_dbquotevalue [join ${refine_query} {&}]])"]

	if { $tsRefineQuery ne {} } {
	    set refine_search_tags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1+[llength [string map {{_} { }} $q]] and itemset_ts_vector @@ [ns_dbquotevalue $tsRefineQuery]::tsquery order by occurrence desc limit 3"]
	}
	
	
    } else {
	# do nothing, empty set of results
	set search_duration 0 
    }
	set queryTitle "${q} - "
	lappend subtitle "Searched for <i>${q}</i> in [format "%.2f" ${search_duration}] seconds"


} else {
    ${storydata} load
}












set comment {
	set feedlimit 10
	set feeddata [::db::Set new -alias story -pool newsdb -type ::buzz::Feed -where [list "active_p" "feed_p" "buzz_p" "language='el'"] -order "last_crawl desc" -limit ${feedlimit} -noinit]
	${feeddata} load
}

set comment {
    [::db::Set new -select {page.title page.url page.score channel.last_crawl} -type [::db::Inner_Join new -lhs [::db::Set new -alias page -type ::sw::agg::Url -where [list "feed_url_sha1 is not null"]] -rhs [::db::Set new -alias channel -type ::sw::agg::Url -where [list "feed_p" "language='el'"]] -join_condition {page.feed_url_sha1=channel.url_sha1}] -order "page.score desc, last_crawl desc" -limit ${feedlimit} -load]
}

set title "${queryTitle} [mc Buzz "Buzz"] - [mc monitor_syndicated_content "Greek Blogs"] ${page_subtitle}"

set rss_feed_url [export_vars -url -base http://buzz.phigita.net/$base -no_empty -override [list [list output rss]] {q host tag}]





















tmpl::master -docStyleId doc3 -docStyleClass z-t2 -meta_description $description -meta_keywords $keywords -refreshInterval 900 -title ${title}  -rss_feed_url ${rss_feed_url} -searchQuery [ad_decode ${searchQuery} {} {} "${searchQuery}"] -defaultSearchAction "." -searchButtonsScript [subst -nocommands -nobackslashes {
	center {
	    if { ![string equal $order_by date] } {
		input -type hidden -name order_by -value ${order_by}
	    }
	    input -type submit -value [mc Search_Buzz "Search Buzz"] -tabindex 2
	    input -type submit -value [mc Search_the_Web "Search the Web"] -tabindex 3 -onclick "return searchTheWeb();"
	}
}] {

    script -language javascript {
	c {
	    function searchTheWeb(){
		var sf=document.createElement('form');
		var q=document.createElement('input');
		sf.style.cssText='display:none;';
		sf.setAttribute('action','http://www.phigita.net/search/');
		sf.setAttribute('method','GET');
		q.setAttribute('name','q');
		q.setAttribute('type','text');
		q.value=document.getElementById('sf').q.value;
		document.body.appendChild(sf);
		sf.appendChild(q);
		sf.submit();
		return false;			
	    }
	}
    } 





if { $order_by eq {date} } {
	set order_by ""
}

    style {
	c {
                .o {
                        font-family: verdana, sans-serif;
                        font-size: 10px;
                        font-weight:bold;
                        text-decoration:none;
                        color: white;
                        background-color: #F60;
                        border:1px solid;
                        border-color: #FC9 #630 #330 #F96;
                        padding:0px 3px 0px 3px;
                        margin:0px;
                    }
	.z-itm {padding:5;border-bottom:1px solid #DDDDDD;}
	.last {border:none !important;}
	#place .event-title {display: block;font-size: 14px;font-weight: bold;margin-bottom: 2px;}
	#place a {color:#3A64C3;text-decoration:none;}
	#place a:hover {color:#2565F7;text-decoration:underline;}
	.interval {color:#006789;;font-size:10px;}
	.action {margin-right:5;padding:2;font-weight:bold;height:16px;margin:2px;float:right;font-family:sans-serif;font-size:14px;}
	    .tl {color:#999999;}
	.s {font-size:12px;padding:2;}
	.datebox {top: 0.8em;left: 0;margin: 0;padding: 0;list-style: none;text-align:center;color:#666666; font-family:georgia; margin:2;padding:2;float:left;width:60;font-size:10px;background: url(http://www.phigita.net/graphics/shade-news.gif) no-repeat;}
		.day {font-weight:bold;font-size:16px;}
	    .g {color:#666666;font-weight:bold;}
			    .occ {font-size:10px;font-style:italic;}

            .tagCloud {padding:5 0 5 0;margin:10 0 10 0;list-style-type:none;text-align:center;list-style-image:none;display:inline;}
            .tagCloud li {display:inline;padding:0;margin:0;font-weight:bold;line-height:1.75em;}
            .tagCloud li a {color:#4261DF;}

                .tagCloud a.s0 { font-size: 0.9em; }
                .tagCloud a.s1 { font-size: 1.2em; }
                .tagCloud a.s2 { font-size: 1.4em; }
                .tagCloud a.s3 { font-size: 1.7em; }
                .tagCloud a.s4 { font-size: 2.1em; }



		.tags {display:inline;font-size:10px;}
		.tags a {color:#063;text-decoration:underline;font-size:11px;margin:0;padding:0;}

		    .pl { background:#fcfcfc; overflow:hidden;word-wrap: break-word;}
	      .pl h2 {margin:0;padding:3;font-size:16px;font-weight:bold;}
	      .pl ul {margin:2;padding:0;list-style-type:none;}
	      .pl li {margin:2px;padding:2px;}

	    .cb {
		background:#eeeeee;
		font: bold 0.75em Verdana, Helvetica, sans-serif;
		padding:3;
		margin:1;
	    }
	    .cb a {
		color:#581C90;
	    }
	      .z-cl {
		  margin:0px;
		  padding:0px;
	      }
	      .z-cl .z-cl-clip-region {
		  margin:0px auto;
		  overflow:hidden;
	      }
	      .z-cl ul {
		  list-style-image:none;
		  list-style-position:outside;
		  list-style-type:disc;
	      }
	      .z-cl ul.z-cl-list {
		  width:10000000px;
		  z-index:1; 
	      }
	      .z-cl .z-cl-list li {
		  float:left;
		  list-style:none;
		  overflow:hidden;
	      }

	      .z-cl { 
		    padding:0px;
		    -moz-border-radius:6px;
	      }
	      .z-cl ul.z-cl-list { 
		    margin:0px;
		    padding:0px;
		    line-height:0px;
	      }
	      .z-cl .z-cl-list li { 
		  background-color:#ffffff;
		  text-align:center;
		  margin:0px;
		  padding:0px;
		  margin:4px;
		  width:90px;
		  height:115px;
		  /*margin-left: auto;*/ /* for testing IE auto issue */
	      }


	      .z-cl-status {
		  z-index:3;
		  font-size:10px;
		  padding:0;
		  position:absolute;
		  top:5px;
		  right:24px;
	      }
	      .z-cl-status span {
		  color:#999999;
		  cursor:pointer;
		  padding:0 2 0 2;
		  margin:1;
	      }
	      .z-cl-prev {
		  background-color:rgb(219, 210, 243);
		  color:#999999;
		  cursor:pointer;
		  z-index:3;
		  font-size:14px;
		  font-weight:bold;
		  padding:0 5 0 5;
		  position:absolute;
		  top:3px;
		  right:62px;
	      }
	      .z-cl-next {
		  background-color:rgb(219, 210, 243);
		  color:#49188F;
		  cursor:pointer;
		  z-index:3;
		  font-size:14px;
		  font-weight:bold;
		  padding:0 5 0 5;
		  position:absolute;
		  top:3px;
		  right:5px;
	      }

			p.video {
			    color:#949494;
			    font-size:10px;
			    font-weight:normal;
			    line-height:11px;
			    margin:0pt;
			    padding:0pt 12px 0pt 0pt;
			}
			p.video a {
			    color:#004276;
			    text-decoration:none;
			}

	#aboutbuzz {border:1px solid #FBD499;overflow:hidden;padding:5px 5px 10px;}


		    .ni {font-size:1.2em;font-weight:bold;line-height:1.04em;letter-spacing:-0.02em;}
		    a.ni:link {color:#118;}
			a.ni:visited {color:#927;}
			    a.ni:hover {background:#118;color:#fff;}
				.st {padding:5;}
				.host {font-size:0.95em;font-style:normal;color:#468;text-decoration:none;}
				}
			    }



	div -id "bd" {
	    div -id "z-main" {
		div -class "z-b" {
		    div -class "z-gc" {
			div -class "z-u first" {
			    div -class pl {
				div -style "float:right;padding:3;" {
				    set size [llength [${storydata} set result]]
				    if {${offset} > 0} {
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag ${base}] -no_empty {q host order_by topic edition cluster}] {
					    t -disableOutputEscaping "Latest Headlines"
					}
					t -disableOutputEscaping " &nbsp; "
					set tmp_offset [expr ${offset}-${limit}]
					if {${tmp_offset}==0} {
					    set override_script {}
					} else {
					    set override_script [list [list offset ${tmp_offset}]]
					}
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag ${base}] -no_empty -override ${override_script} {q host order_by}] {
					    t -disableOutputEscaping "&#171; Newer"
					}
				    } else {
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag ${base}] -no_empty {q host order_by topic edition cluster}] {
					    t -disableOutputEscaping "Refresh"
					}
				    }
				    span  -style "color:#D2501E;" { t -disableOutputEscaping " (&nbsp;[expr 1+${offset}]&#150;[expr ${offset}+${limit}]&nbsp;) " }
				    if {${size}>${limit} && ${offset} < 100} {
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag $base] -no_empty -override {{offset {[expr ${offset}+${limit}]}}} {q host order_by}] {
					    t -disableOutputEscaping "Older &#187;"
					}
				    }
				}
				h2 -style "background-color:#FFEAC0;color:#D2501E;border-style:solid none none;border-width:1px;border-color:#F29F3E;" {	
				    t "Stories"
				}
				
				set selectedIndex 0
				set count 1
				set tabList "[export_vars -url -base ${base} -no_empty -override {q host order_by edition}] [mc news.topic.All All]"
				foreach {tabType tabTopic} {
				    topic Politics
				    topic Economy
				    topic Society
				    topic Culture
				    topic Science
				    topic Technology
				    topic Health
				    topic Sports
				} {
				    if { [string match "${tabTopic}*" [set $tabType]] } {
					set selectedIndex $count
				    }
				    set tabURL [export_vars -url -base ${base} -no_empty -override [list [list $tabType $tabTopic]] {q host order_by edition}]
				    lappend tabList "$tabURL [mc news.${tabType}.$tabTopic [lindex [split $tabTopic .] end]]"
				    incr count
				}

				#		navTabs -cssId topicTabs -selectedIndex $selectedIndex -tabs [join $tabList]
				#		div -class wh -style "background:#344760;" { t -disableOutputEscaping "&nbsp;" }
				br -clear both
				if {[exists_and_not_null heading]} {
				    h3 -style "display:inline;" { t $heading }
				    br
				}

				if {[exists_and_not_null subtitle]} {
				    t -disableOutputEscaping " ( [join ${subtitle} {; }] <a href=\"$base\" class=\"fl nd\">\[clear\]</a> ) "
				}
				a -href ${rss_feed_url} -title "RSS" -class "o" {
				    t "RSS"
				}
				p
				if {[info exists related_tags] && $related_tags ne {} } {
				    ### background-color:#FFEAC0;
				    div -style "margin:15 0 15 0;" {
					t "Recommended tags related to: "
					b { t "$tag" }
					div -style "margin-top:6px;" {
					    foreach o $related_tags {
						set recommendedTag [concat $tag [$o set rule_head]]
						set normalized_tag [string map {{ } {_}} [string totitle $recommendedTag]]
						a -href [export_vars -base $base/tag/$normalized_tag] -style "font-size:11;" {
						    t [string tolower $recommendedTag]
						}
						t -disableOutputEscaping " &nbsp; "
					    }
					}
				    }
				    p
				}
				set LINK_UNITS_DISABLE {
				    t -disableOutputEscaping {
					<script type="text/javascript"><!--
					google_ad_client = "pub-1374549828513817";
					/* Buzz @ phigita.net, 468x15, LU 17/3/2008 */
					google_ad_slot = "1213584798";
					google_ad_width = 468;
					google_ad_height = 15;
					//-->
					</script>
					<script type="text/javascript"
					src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
					</script>
				    }
				}
				if { [exists_and_not_null refine_search_tags] } {
				    div -style "margin:15 0 15 0;" { 
					t "Searches related to: "
					b { t "$q" }
					div -style "margin-top:6px;" {
					    foreach o $refine_search_tags {
						set queryRefinement [string trim [$o set itemset_tags]]
						a -href [export_vars -base $base -override [list [list q $queryRefinement]] {host}] {
						    set count 0
						    foreach word [split $queryRefinement] {
							if { $count != 0 } { t " " }
							if { [lsearch $word $refine_query] } {
							    t -disableOutputEscaping "<b>$word</b>"
							} else {
							    t $word
							}
							incr count
						    }
						}
						t -disableOutputEscaping " &nbsp; "
					    }
					}
				    }
				}
				p




				div {
				    set count 0
				    set storydate_i 0
				    foreach story [${storydata} set result] {
					incr count
					array set uri [uri::split [${story} set url]]
					div -style "clear:both;padding:5 15 5 15;margin-top:10;" {
					    div -class datebox { t -disableOutputEscaping "[lc_time_fmt [$story set creation_date_utc] "%H:%M<br><span class=\"day\">%d</span><br>%b &\#39;%y"] " }
					    div -style "margin-left:75;" {
						if { [${story} set image_file] ne {} } {
						    set imageFile [lindex [$story set image_file] 0]-sample-80x80.jpg
							set imageDir [web_root_dir]/data/news/images/[string range $imageFile 0 1]
						    if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
							foreach {width height} ${image_size} break
							set story_image_file [lindex [$story set image_file] 0]
							set imageHost [::util::getStaticHost $story_image_file "i" "-buzz"]
							img -src "${imageHost}/${story_image_file}" -width $width -height $height -align left
						    }
						} else {
						    if { [$story set object_list] ne {} } {
							lassign [lindex [$story set object_list] 0]  video_id video_image_file
							set imageFile ${video_image_file}-sample-80x80.jpg
							set imageDir [web_root_dir]/data/news/images/[string range $imageFile 0 1]
							if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
							    foreach {width height} ${image_size} break
							    set imageHost [::util::getStaticHost $video_image_file "i" "-buzz"]
							    a -href "/video/${video_id}" {
								img -src "${imageHost}/${video_image_file}" -alt {[video]} -width $width -height $height -align left
							    }
							}
						    }
						}
						if { $debug_p && ${admin_p} } {
						    t [$story set image_file]
						    t "\["
						    a -class fl -href "admin/url-update?buzz_p=&url_sha1=[${story} set url_sha1]&return_url=[export_vars -base .. {offset}]" -onclick "return confirm('Are you sure?');" {
							t "null"
						    }
						    t "\] "
						    t "\["
						    a -class fl -href "admin/cache?url_sha1=[${story} set url_sha1]&return_url=[export_vars -base .. {offset}]"  {
							t "cache"
						    }
						    t "\] "
						    t "\["
						    a -class fl -href "/admin/classification-list?url=[ns_urlencode [$story set url]]" {
							t "classification"
						    }
						    t "\] "

						}
						set comment {
						    span -class classificationBar {
							if { [$story set classification__edition_sk] ne {} } {
							    a -class editionLink -href "[export_vars -url -base $base -no_empty -override [list [list edition [$story set classification__edition_sk]]] {topic}]" {
								t [mc news.edition.[$story set classification__edition_sk] [lindex [split [$story set classification__edition_sk] .] end]]
							    }
							}
							if { [$story set classification__edition_sk] ne {} && [$story set classification__tree_sk] ne {} } {
							    t ": "
							}
							if { [$story set classification__tree_sk] ne {} } {
							    set sk ""
							    foreach sk_part [split [$story set classification__tree_sk] .] {
								lappend sk $sk_part
								a -class topicLink -href "[export_vars -url -base $base -no_empty -override [list [list edition [$story set classification__edition_sk]] [list topic [join $sk .]]]]" {

								    t [mc news.topic.[join $sk .] $sk_part]
								}
								if { [join $sk .] ne [$story set classification__tree_sk] } {
								    t " . "
								}
							    }
							}
						    }
						}

						div {
						    a -rel nofollow -href "${base}/ct?s=[${story} set url_sha1]" -target _blank -class ni {
							if {[exists_and_not_null q]} {
							    t -disableOutputEscaping [::util::coalesce [string trim [string totitle [${story} set title]]] Untitled]
							} else {
							    t -disableOutputEscaping [::util::coalesce [string trim [string totitle [util::striphtml [string range [${story} set title] 0 100]]]] Untitled]
							}
						    }
						    t " "

						    ### Video Icon
						    if { [$story set object_list] ne {} } {
							lassign [lindex [$story set object_list] 0] video_id video_image_file
							a -href "/video/${video_id}" -style "text-decoration:none;border:0;" {
							    img -src "http://www.phigita.net/graphics/icon_video.gif" -width 19 -height 12 -border 0 -alt {[video]} 
							}
						    }

						    set no_www_host [regsub -- {^www\.} $uri(host) {}]
						}
						div -class "st" {
						    if {[exists_and_not_null q]} {
							t -disableOutputEscaping [${story} set last_crawl_content]
						    } else {
							if { [catch { t [::util::striphtml [${story} set last_crawl_content]] } errmsg] } {
							    ns_log notice "BUZZ ERROR: url=[ns_conn url] query=[ns_conn query] story=[$story set url]"
							}
						    }
						}
						div {
						    t -disableOutputEscaping " &nbsp; "
						    img -src http://www.phigita.net/graphics/theme/azure/bracket.gif
						    t " "
						    a -class host -href ${base}?host=$uri(host) { t ${no_www_host} }
						    set count_tags [llength [$story set tags]]
						    if { $count_tags } {
							div -class tags {
							    t " - "
							    set index_i 1
							    foreach storyTag [$story set tags] {
								set Tag [string map {/ "_"} "$storyTag"]
								if { $Tag ne {} || [string length $Tag] ==1} {
								    set normalized_tag [string trim [regsub -all -- {(_){2,}} [string map {{ } {_} {!} {_} {/} {} {:} {_} {-} {_} {;} {_} {&} {_}} [string totitle [::util::dequotehtml $storyTag]]] {_}] { _}]

								    #a -href [export_vars -base $base/tag/$normalized_tag -override [list [list host $uri(host)]]]
								    a -href [export_vars -base $base/tag/$normalized_tag] {
									t [::util::dequotehtml $Tag]
								    }
								}
								if { $count_tags != $index_i } {
								    t ", "
								}
								incr index_i
							    }
							}
						    }
						}
					    }
					}
					if {[incr storydate_i]==${limit}} break
				    }
				}
				div -style "float:right;" {
				    set size [llength [${storydata} set result]]
				    if {${offset} > 0} {
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag ${base}] -no_empty {q host order_by topic edition cluster}] {
					    t -disableOutputEscaping "Latest Headlines"
					}
					t -disableOutputEscaping " &nbsp; "
					set tmp_offset [expr ${offset}-${limit}]
					if {${tmp_offset}==0} {
					    set override_script {}
					} else {
					    set override_script [list [list offset ${tmp_offset}]]
					}
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag ${base}] -no_empty -override ${override_script} {q host order_by}] {
					    t -disableOutputEscaping "&#171; Newer"
					}
				    }
				    span  -style "color:#D2501E;" { t -disableOutputEscaping " (&nbsp;[expr 1+${offset}]&#150;[expr ${offset}+${limit}]&nbsp;) " }
				    if {${size}>${limit} && ${offset} < 100} {
					a -style "color:#D2501E;" -href [export_vars  -url -base [::util::coalesce $tag $base] -no_empty -override {{offset {[expr ${offset}+${limit}]}}} {q host order_by}] {
					    t -disableOutputEscaping "Older &#187;"
					}
				    }
				}
				h2 -style "background:#FFEAC0;" { t -disableOutputEscaping "&nbsp;" }
			    }
			}
			div -class "z-u" -style "overflow:hidden;" {		    
			    if { [exists_and_not_null q] } {
				if { ![$storydata emptyset_p] } {
				    b { t "order by: " }
				    if { $order_by eq {rank} } {
					set override_script [list [list order_by date]]
					a -href [export_vars  -url -base ${base} -no_empty -override ${override_script} {offset q}] {
					    t "date"
					}
					t " | "
					t "relevance"
				    } else {
					t "date"
					t " | "
					set override_script [list [list order_by rank]]
					a -href [export_vars  -url -base ${base} -no_empty -override ${override_script} {offset q}] {
					    t "relevance"
					}
				    }
				}
			    }
			    div -class pl { 
				center {
				    h2 -style "background-color:#FFEAC0;color:#D2501E;border-style:solid solid none;border-width:1px 1px medium;border-color:#F29F3E rgb(251, 212, 153) rgb(251, 212, 153);" {	
					t "(( Buzz ))"
				    }
				}
				div -id aboutbuzz {
				    
				    t -disableOutputEscaping "Buzz is a \"social media\" aggregator. We monitor, surface, and index $feed_cnt  <b>Greek Blogs</b> continuously throughout the day, so you will see new stories each time you check the page."
				    t "The selection and placement of stories are determined automatically by a computer program."

				    if { $admin_p } {
					div -style "margin:10;" {
					    t "\["
					    a -class fl -href "[export_vars -no_empty -base admin/ {q host tag}]" {
						t "Admin"
					    }
					    t "\]"
					}
				    }
				}
			    }
			    p
			    ::xo::ns::include [acs_root_dir]/packages/news/tmpl-buzz/includelet-latest-video-buzz.tcl
				p
			    div  -class pl {
				if { [info exists popularTags] && $popularTags ne {} } {
				    h2 -style "border-style:solid solid none;border-width:1px 1px medium;border-color:#dddddd #dddddd #dddddd;position:relative;" {
					t "Popular Tags" 
					if { [info exists related_tags] } {
					    t " in "
					    i { t "[string map {{_} { }} $tag]" }
					}
				    }
				    div -style "background-color:#f2f2f2;border:1px solid #dddddd;overflow:hidden;padding:0;text-align:center;display:block;width:100%;" {
					ul -class tagCloud {
					    foreach o $tagCloudList {
						set occ [$o set occurrence]
						set tagClass "s[expr { int(double($occ - $minOcc)/double($distOcc)) }]"
						li {
						    set targetTag [::util::ldiff [string map {{/} { } {:} { } {-} { } {;} { } {&} { }} [$o set itemset_tags]] [string tolower [string map {{_} { }} $tag]]]
						    #set targetTag [string map {{/} { } {:} { } {-} { } {;} { } {&} { }} [$o set itemset_tags]]
						    set normalizedTag [string map {{ } {_}} [string trim [string totitle $targetTag]]]
						    a -class $tagClass -href [export_vars -base $base/tag/$normalizedTag] {
							t [string trim $targetTag]
						    }
						    t -disableOutputEscaping " &nbsp; "
						    #span -class occ { t "([$o set occurrence])" }
						}
					    }
					}
				    }
				}
				div -style "border-style:none solid solid;border-width:medium 1px 1px;border-color:#dddddd #dddddd #dddddd;font-weight:normal;" {
				    div -style "padding:5;" {
					a -class fl -href ${base}/tag/ {
					    t "more tags..."
					}
				    }
				}
			    }
			    p
			    ::xo::ns::include [acs_root_dir]/packages/blogger/tmpl/includelet-latest-blog-entries.tcl -set title "Blogs // phigita.net" -set show_action_p false
			    p 
			    ::xo::ns::include [acs_root_dir]/packages/bookmarks/tmpl-global/includelet-recent-shared-links.tcl -set title "Remarks // phigita.net" -set show_action_p false
			    p
			    ::xo::ns::source [acs_root_dir]/packages/calendar/tmpl-global/includelet-upcoming-events.tcl
			}
		    }
		}
	    }


	    div -class "z-b" {
		#<!-- YOUR NAVIGATION GOES HERE -->
		b { t "Send Feedback: " }
		br
		img -src /graphics/53dab96f0fd8087a4110eb0174b4cfbb.png
		p
		if { $enable_sidebar_google_ads_p } {
		    ::xo::google::adsense::slot 5007329934 125 125
		    p
		    ::xo::google::adsense::slot 1846564854 160 600
		}
	    }
	}
			}




