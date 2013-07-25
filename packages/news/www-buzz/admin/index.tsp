ad_page_contract {
    @author Neophytos Demetriou
} {
    {offset:naturalnum 0}
    host:trim,optional
    {tag:trim,optional ""}
    {q:trim,optional ""}
    {order_by:trim "date"}
	{edition:trim ""}
	{topic:trim ""}
    {debug_p:boolean "f"}
}

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
	set o [::db::Set new -pool newsdb -select [list "count(1) as feed_cnt"] -type ::sw::agg::Url -where [list "feed_p" "buzz_p" "language='el'"]]
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


set base .
set limit 25
set storydata [::db::Set new -pool newsdb -alias story -type ::sw::agg::Url -where [list "buzz_p" "NOT feed_p" "language='el'"] -order "creation_date desc" -offset ${offset} -limit [expr 1+${limit}] -noinit]


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

if { [exists_and_not_null tag] } {
    set base ..
    $storydata lappend where "tags_ts_vector @@ to_tsquery('simple',[ns_dbquotevalue [join $tag &]])"
    #	set q [concat $q $tag]
    set conn [$storydata getConn]
    set related_tags [$conn query "select rule_head from xo.xo__buzz_related_tags where rule_size=[llength $tag] and rule_ts_vector @@ to_tsquery('simple',[ns_dbquotevalue [join ${tag} {&}]]) order by confidence desc limit 5"]
    append queryTitle "$tag - "
    lappend subtitle "<b>Tag:</b> <a href=$tag style=\"color:green\">$tag</a>"
#    set searchQuery [concat "tag=$tag" $searchQuery]
}

if { [exists_and_not_null host] } {
    set no_www_host [regsub -- {^www\.} ${host} {}]
    set url_host_sha1 [ns_sha1 [string tolower ${host}]]
    ${storydata} lappend where "url_host_sha1=[ns_dbquotevalue ${url_host_sha1}]"
    lappend subtitle "<b>Source:</b> <a href=\"http://${host}/\" style=\"color:\#666666;\">http://${no_www_host}</a>"
    append queryTitle " ${no_www_host} - "
}




set endRange 222 ;#  144
if { [exists_and_not_null q] } {

	set firstindex [string first {=} ${q}]
	set directive [string tolower [string range ${q} 0 ${firstindex}]]
	set subQuery [string trimleft [string range ${q} ${firstindex} end] { =}]

	if {${directive} eq {tag=} } {
	    throw REDIRECT [export_vars -base ${base}/tag/$subQuery]
	    return
	}

    set q [string map {{(} {} {)} {} : { } ' {} | {} & {} ! {} ~ {}} ${q}]

    set conn [${storydata} getConn]
    set tsQuery [${conn} getvalue "select to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]])"]

    if { ${tsQuery} ne {} } {

	set endRange end
	${storydata} unset type
	${storydata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector,q,rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__buzz_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where url in (select url from (select url, rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__buzz_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where ts_vector @@ q order by $order desc offset ${offset} limit [expr {${limit}+1}]) u)) r on (u.url=r.url)"

	${storydata} lappend select "ts_headline('[default_text_search_config]',last_crawl_content,q,'MaxWords=45, MinWords=35') as last_crawl_content"
	${storydata} lappend select "ts_headline('[default_text_search_config]',title,q) as title"

	${storydata} order "$order desc"
	${storydata} unset offset
	${storydata} unset limit

	#	$storydata init
	#	    ns_log notice [$storydata set sql]
	set start_clicks [clock clicks -milliseconds]
	${storydata} load
	set end_clicks [clock clicks -milliseconds]
	set search_duration [expr {(${end_clicks}-${start_clicks})/1000.0}]

    } else {
	# do nothing, empty set of results
    }
    set queryTitle "${q} - "
    lappend subtitle ${q}
} else {
    ${storydata} load
}

set feedlimit 25
set feeddata [::db::Set new -alias story -pool newsdb -type ::sw::agg::Url -where [list "feed_p" "buzz_p" "language='el'"] -order "last_crawl desc" -limit ${feedlimit} -noinit]
${feeddata} load

set comment {
    [::db::Set new -select {page.title page.url page.score channel.last_crawl} -type [::db::Inner_Join new -lhs [::db::Set new -alias page -type ::sw::agg::Url -where [list "feed_url_sha1 is not null"]] -rhs [::db::Set new -alias channel -type ::sw::agg::Url -where [list "feed_p" "language='el'"]] -join_condition {page.feed_url_sha1=channel.url_sha1}] -order "page.score desc, last_crawl desc" -limit ${feedlimit} -load]
}

set title "${queryTitle} [mc Buzz "Buzz"] - [mc monitor_syndicated_content "Monitor Greek Blogs"] ${page_subtitle}"

set rss_feed_url [export_vars -url -base http://buzz.phigita.net/$base -no_empty -override [list [list output rss]] {q host tag}]




set linkdata [::db::Set new \
		  -noinit \
		  -alias user_bookmark \
		  -select {
		      {bm.*}
		      {first_names || ' ' || cc.last_name as full_name}
		      {cc.screen_name}
		      {cc.user_id}
		      {cc.status}
		  } -type [::db::Inner_Join new -lhs [::db::Set new -type ::sw::agg::Url -alias bm -where [list {cnt_users!=0} {nonnullvalue(max_sharing_start_date)}] -order {max_sharing_start_date desc} -limit $limit] -rhs [::db::Set new -select "status user_id first_names last_name screen_name" -from "users u inner join persons p on (u.user_id=p.person_id)" -alias cc] -join_condition {cc.user_id = bm.max_sharing_user_id}] \
		  -limit 5 \
		  -order {max_sharing_start_date desc} ]

$linkdata load

set blogdata [db::Set new \
		  -type [db::Inner_Join new \
			     -lhs [db::Set new \
				       -alias bl \
				       -select {
					   bs.* 
					   cc.screen_name 
					   {first_names || ' ' || last_name as full_name}
				       } -type [db::Inner_Join new \
						    -lhs [db::Set new \
							      -alias bs \
							      -type ::sw::agg::Blog_Stats \
							      -order "last_shared_entry desc" \
							      -where [list "last_shared_entry is not null"]] \
						    -rhs [db::Set new \
							      -type CC_Users \
							      -alias cc] \
						    -join_condition {bs.user_id = cc.user_id}]] \
			     -rhs [db::Set new \
				       -alias mro \
				       -select {* {substring(content from 0 for 160) as snippet}} \
				       -type ::sw::agg::Most_Recent_Objects \
				       -where [list \
						   "class_id=[Blog_Item set id]" \
						   "root_class_id=[User set id]" \
						   "shared_p"] \
				       -order "sharing_start_date desc"] \
			     -join_condition {bl.user_id=mro.root_object_id}] \
		  -order "sharing_start_date desc" \
		  -limit 5]

$blogdata load



tmpl::master -refreshInterval 900 -title ${title} -context_bar [ad_context_bar]  -rss_feed_url ${rss_feed_url} -searchQuery [ad_decode ${searchQuery} {} {} "${searchQuery}"] -defaultSearchAction "/buzz/admin/" -searchButtonsScript [subst -nocommands -nobackslashes {
    input -type hidden -name order_by -value ${order_by}
    input -type submit -value [mc Search_Buzz "Search Buzz"] -tabindex 2
    input -type submit -value [mc Search_the_Web "Search the Web"] -tabindex 3 -onclick "return searchTheWeb();"
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

b { t "Tools for Buzz administrators: " }
a -href {javascript:function%20txt(str){return%20document.createTextNode(str)}function%20tag(n,c){var%20e=document.createElement(n);e.style.fontFamily='Arial,sans-serif';e.style.color='#000';if(c)e.appendChild(c);return%20e}function%20p(c){return%20tag('p',c)}function%20a(href,desc){e=tag('a',txt(desc));e.href='http://buzz.phigita.net/admin/feed-add?url='+href;e.style.color='#00c';e.style.textDecoration='underline';return%20e}var%20el=tag('div');el.style.zIndex=100000;el.style.position='absolute';el.style.padding='20px';el.style.top='10px';el.style.left='10px';el.style.backgroundColor='#ffffcc';el.style.border='1px%20solid%20#333333';el.style.textAlign='left';var%20ul=tag('ul');var%20found=false;var%20links=document.getElementsByTagName('link');for(var%20i=0,link;link=links[i];i++){var%20type=link.getAttribute('type');var%20rel=link.getAttribute('rel');if(type&&(type=='application/rss+xml'||type=='application/atom+xml')&&rel&&rel=='alternate'){var%20href=link.getAttribute('href');if(!href.match(/^http/)){var%20path=(href.match(/^\//))?%20'/'%20:%20location.pathname;href='http://'+location.hostname+path+href;}var%20title=link.getAttribute('title');ul.appendChild(tag('li',a(href,((title)%20?%20title+'%20-%20'%20:%20'')+href)));found=true;}}if(found){el.appendChild(p(txt('The%20current%20page%20links%20to%20these%20feeds:')));el.appendChild(ul);}else{el.appendChild(p(txt('The%20current%20page%20does%20not%20link%20to%20any%20feeds.')));}var%20close=a('#','Close');close.onclick=function(){el.style.display='none';return%20false;};el.appendChild(p(close));function%20addFeedBox(){document.body.appendChild(el);y=window.scroll(0,0);}void(z=addFeedBox());} -title "Buzz: Show all feeds" {
	t "Buzz: Show all feeds" 
}
t " | "
a -href {javascript:top.location.href='http://buzz.phigita.net/?host='+top.location.href.replace(/^http:\/\/|\/.*$/g,%22%22);} -title "Buzz: Check This" {
	t "Buzz: Check This"
}

    style {
	c {
	    .datebox {white-space:nowrap;color:#666666;border: 1px solid #e0e0e0; font-family:georgia; margin:2;padding:2;float:left;width:60;text-align:center;background:#fff1cc;font-size:10px;}
		.day {font-weight:bold;font-size:16px;}
		.tl {font-size:18px;font-weight:bold;}
		.classificationBar {background:#eeeeee;font: bold 0.75em Verdana, Helvetica, sans-serif;padding:3;margin:1;}
		    .classificationBar a {color:#581C90;}
			.g {color:#666666;font-size:12px;}
			    .pl {
				overflow:hidden;
			    }

			    .tags {
				display:inline;
				font-size:10px;
			    }
			    .tags a {
				color:#063;text-decoration:underline;font-size:11px;margin:0;padding:0;
			    }


			    .pl h1 {margin:0;padding:4;font-size:14px;}
			    .pl ul {list-style-type:none; margin:0; padding:0; }
			    .pl li {
				clear:both;
				margin:10px;padding:2px;
			    }

			    .little {font-size: 10px; color: #666666;}
				.wh {color:#ffffff;}
				    .ni {font-size:1.5em;font-weight:bold;line-height:1.04em;letter-spacing:-0.02em;}
				    a.ni:link {color:#118;}
					a.ni:visited {color:#927;}
					    a.ni:hover {background:#118;color:#fff;}
						.s {padding:5;}
						.host {font-size:0.95em;font-style:normal;color:#468;text-decoration:none;}
						}
					    }

					    style {
						c {
						    #topicTabs {width:550;margin:0; padding:0 0 0 4px;list-style:none; height:19px; background:url(http://www.phigita.net/graphics/news/hr_999.gif) bottom repeat-x;}

						    #topicTabs li {display:inline;cursor:pointer;pointer:hand;font:10px verdana; font-weight:bold; white-space:nowrap; padding-right:3px; padding-bottom:1px; padding-left:3px;margin:0 0 0 4;line-height:19px;border-left: 1px solid #999;}

						    #topicTabs .normalTab {background:url(http://www.phigita.net/graphics/news/bg_nav_cnrr_on.gif) top right no-repeat;color:#333;}

						    #topicTabs .selectedTab {color:#fff; background:#344760 url(http://www.phigita.net/news/graphics/news/bg_nav_cnrr.gif) top right no-repeat;line-height:22px;border-left: 1px solid #344760;}

						    #editionTabs {width:80;padding:0;margin:0 0 0 0;list-style-type:none;}
						    #editionTabs .normalTab {text-decoration:none;color:black;}
						    #editionTabs .tabIndex0 {border-left: 4px solid #a03;}
						    #editionTabs .tabIndex1 {border-left: 4px solid #ffcc00;}
						    #editionTabs .tabIndex2 {border-left: 4px solid #000088;}
						    #editionTabs .tabIndex3 {border-left: 4px solid #008000;}
						    #editionTabs .tabIndex6 {border-left: 4px solid #663399;}
						    #editionTabs .tabIndex5 {border-left: 4px solid #ff6600;}
						    #editionTabs .tabIndex4 {border-left: 4px solid #cc0000;}
						    #editionTabs .tabIndex7 {border-left: 4px solid #669999;}

						    #editionTabs li {cursor:pointer;cursor:hand;border: 1px solid #bbb;padding:2;background:#eee;width:100%;margin:2;color:#888;font: bold 0.75em Verdana, Helvetica, sans-serif;}
						    #editionTabs .selectedTab {color:#ffffff;background:#344760;}
						}
					    }
					    set comment {
						div -style "float:left;width:100;margin:5;padding:2;border-right: 2px solid #efefef;" {
						    div -style "width:90;margin:2;padding:2;" {
							set selectedIndex 0
							set count 1
							set tabList "[export_vars -url -base ${base} -no_empty -override {q host order_by topic}] [mc news.edition.Global Global]"
							foreach {tabType tabTopic} {
							    edition World
							    edition World.Europe.Cyprus
							    edition World.Europe.Greece
							} {
							    if { [string match "${tabTopic}*" [set $tabType]] } {
								set selectedIndex $count
							    }
							    set tabURL [export_vars -url -base ${base} -no_empty -override [list [list $tabType $tabTopic]] {q host order_by topic}]
							    lappend tabList "$tabURL [mc news.${tabType}.$tabTopic [lindex [split $tabTopic .] end]]"
							    incr count
							}
							#		navTabs -cssId editionTabs -selectedIndex $selectedIndex -tabs [join $tabList]
							p
						    }
						}
					    }

					    div -class pl -style "float:left;width:655;" {
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


						ul {
						    set storydate_i 0
						    set imageDir "/var/lib/naviserver/service-phgt-0/data/news/images"
						    foreach story [${storydata} set result] {
							
							array set uri [uri::split [${story} set url]]
							li -style "padding:5 15 5 15;margin-top:10;" {
							    div -class datebox { t -disableOutputEscaping "[lc_time_fmt [$story set creation_date] "%H:%M<br><span class=\"day\">%d</span><br>%b &\#39;%y"] " }
							    div -style "margin-left:75;background:\#ffffff;" {
								if { [${story} set image_file] ne {} } {
								    set imageFile [lindex [$story set image_file] 0]-sample-80x80.jpg
								    if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
									foreach {width height} ${image_size} break
									img -src "/images/[lindex [${story} set image_file] 0]" -width $width -height $height -align left
								    }
								} else {
								    if { [$story set object_list] ne {} } {
									foreach {video_image_url video_image_file} [lindex [$story set object_list] 0] break
									set imageFile ${video_image_file}-sample-80x80.jpg
									if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
									    foreach {width height} ${image_size} break
									    a -href "video/[lindex [split $video_image_url /] end]" {
										img -src "/images/${video_image_file}" -width $width -height $height -align left
									    }
									}
								    }
								}
								if { ${admin_p} } {
								    t "\["
								    a -class fl -href "url-update?buzz_p=&channel_url_sha1=&feed_p=f&url_sha1=[${story} set url_sha1]&return_url=[export_vars -base .. {offset}]" -onclick "return confirm('Are you sure?');" {
									t "NULL"
								    }
								    t "\] "
								    t "\["
								    a -class fl -href "/admin/cache?url_sha1=[$story set url_sha1]" {
									t "CACHE"
								    }
								    t "\] "
								    t "\["
								    a -class fl -href "/admin/classification/classification-list?url=[ns_urlencode [$story set url]]" {
									t "CLASS"
								    }
								    t "\] "
								    t "\["
								    a -class fl -href "/admin/ttext/bte?url=[ns_urlencode [$story set url]]" {
									t "BTE"
								    }
								    t "\] "
								    t "\["
								    a -class fl -href "/admin/ttext/tidy?url=[ns_urlencode [$story set url]]" {
									t "TIDY"
								    }
								    t "\] "
								    t "\["
								    a -class fl -href "/admin/news-item-refetch?url=[ns_urlencode [$story set url]]&return_url=[ns_urlencode [export_vars -base . -no_empty {q host edition topic offset cluster}]]" {
									t "REFETCH"
								    }
								    t "\] "
								    br
								    t "\[ct=[$story set cnt_clickthroughs]\] "
								    if { [exists_and_not_null q] } {
									t "\[ "
									b {
									    t "r="
									    t [$story set rank]
									}
									t " \] "
									br
								    }
								    br
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
								    a -rel nofollow -href "http://buzz.phigita.net/ct?s=[${story} set url_sha1]" -class ni {
									if {[exists_and_not_null q]} {
									    t -disableOutputEscaping [::util::coalesce [string trim [string totitle [${story} set title]]] Untitled]
									} else {
									    t -disableOutputEscaping [::util::coalesce [string trim [string totitle [util::striphtml [string range [${story} set title] 0 100]]]] Untitled]
									}
								    }
								    t " "
								    set no_www_host [regsub -- {^www\.} $uri(host) {}]
								}
								div -class "s" {
								    if {[exists_and_not_null q]} {
									t -disableOutputEscaping [string range [${story} set last_crawl_content] 0 $endRange]
								    } else {
									t [string range [::util::striphtml [${story} set last_crawl_content]] 0 $endRange]
								    }
								}
								div {
								    t -disableOutputEscaping " &nbsp; "
								    img -src http://www.phigita.net/images/theme/azure/bracket.gif
								    t " "
								    a -class host -href ?host=$uri(host) { t ${no_www_host} }

								    set count_tags [llength [$story set tags]]
								    if { $count_tags } {
									div -class tags {
									    t " - "
									    set index_i 1
									    foreach storyTag [$story set tags] {
										set Tag [string map {. "" / ""} "$storyTag"]
										if { $Tag ne {} || [string length $Tag] ==1} {
										    set normalized_tag [string map {{ } {_}} [string totitle $storyTag]]
										    a -href [export_vars -base $base/tag/$normalized_tag -override [list [list host $uri(host)]]] {
											t $Tag
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
							set tmp_offset [expr ${offset}-${limit}]
							if {${tmp_offset}==0} {
							    set override_script {}
							} else {
							    set override_script [list [list offset ${tmp_offset}]]
							}
							a -class wh -href [export_vars  -url -base ${base} -no_empty -override ${override_script} {q host order_by}] {
							    t -disableOutputEscaping "&#171; Newer"
							}
						    }
						    span -class "wh" { t -disableOutputEscaping " (&nbsp;[expr 1+${offset}]&#150;[expr ${offset}+${limit}]&nbsp;) " }
						    if {${size}>${limit}} {
							a -class wh -href [export_vars  -url -base ${base} -no_empty -override {{offset {[expr ${offset}+${limit}]}}} {q host order_by}] {
							    t -disableOutputEscaping "Older &#187;"
							}
						    }
						}

						h1 -class wh -style "background:#344760;" { t -disableOutputEscaping "&nbsp;" }
							br -clear both
						set comment {	
						    t -disableOutputEscaping {
							<script type="text/javascript"><!--
							google_language = 'en';
							google_encoding = 'utf-8';
							google_ad_client = "pub-1374549828513817";
							google_alternate_color = "ffffff";
							google_ad_width = 468;
							google_ad_height = 60;
							google_ad_format = "468x60_as";
							google_ad_type = "image";
							google_ad_channel = "";
							//--></script>
							<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
						    }
						}
					    }


					    div -style "margin-left:700;width:250;padding-left:10;border-left:1px solid #efefef;" {
						div -style "margin:10;" {
						    t \[
						    a -class fl -href [export_vars -url -base .. -no_empty {offset host tag q topic edition cluster}] {
							t "Normal"
						    }
						    t \]
						    t " - "
						    t \[
						    a -class fl -href "feeds" {
							t "Feeds"
						    }
						    t \]
						    t " - "
						    t \[
						    a -class fl -href "feeds-grid" {
							t "FeedsGrid"
						    }
						    t \]
						    t " - "
						    t \[
						    a -class fl -href "classification/" {
							t "Categories"
						    }
						    t \]
						    p
						}
		

						if { [exists_and_not_null q] } {
						    if { ![$storydata emptyset_p] } {
							t "([format "%.2f" ${search_duration}] seconds)"
							p
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

						center { h2 -style "margin-top:0;background:green;padding:5px;color:white;" { t "((Buzz))" } }
						div -class little {

						    t -disableOutputEscaping "Buzz is a \"social media\" aggregator. We monitor, surface, and index $feed_cnt  <b>Greek Blogs</b> continuously throughout the day, so you will see new stories each time you check the page."
						    t "The selection and placement of stories are determined automatically by a computer program."
						    p
						    t "Contact: "	
						    img -src /graphics/53dab96f0fd8087a4110eb0174b4cfbb.png
						    
						    set comment {
							t -disableOutputEscaping "Monitor Greek Blogs -- <b>Buzz</b> may refer to a particularly intense kind of Word of mouth. Word of mouth is the passing of information by verbal means, especially recommendations, but also general information, in an informal, person-to-person manner, rather than by mass media, advertising, organized publication, or traditional marketing."
							br
							a -href "http://en.wikipedia.org/wiki/Word_of_mouth" -style "color:green;" {
							    t "wikipedia: word of mouth"
							}
						    }

}
						p
						div -style "padding:4;" {
						    b { t "See also: " }
						    a -style "padding:4px;font-weight:bold;text-decoration:none;" -href "http://news.phigita.net/" -title [mc News "News in Greek"] {

							set bgcolor aa0033
							foreach char [split [mc News News] ""] {
							    span -style "line-height:1.5em;font-size:14px;border:2px solid \#666666; background:\#${bgcolor};color:\#ffffff;padding:1 2 1 2;margin-left:1px;" { t -disableOutputEscaping $char }
							}
						    }

						    set comment {
							ul -style "list-style-type:none;padding:0;" {
							    li {
								a -style "color:green;font-weight:bold;" -href "http://blogs.phigita.net/" {
								    t "[_ Blogs "Blogs" el]"
								}
								t " (blogs.phigita.net)"
							    }
							    li {
								a -style "color:green;font-weight:bold;" -href "http://remarks.phigita.net/" {
								    t "[_ Remarks "Remarks" el]"
								}
								t " (remarks.phigita.net)"
								br
								br
							    }
							    li {
								a -style "color:green;font-weight:bold;" -href "http://www.technorati.com/" {
								    t "technorati"
								}
							    }
							    li {
								a -style "color:green;font-weight:bold;" -href "http://blogsearch.google.com/" {
								    t "google blog search"
								}
							    }
							}
						    }
						    p

						    if {[info exists related_tags] && $related_tags ne {} } {
							div -style "background:rgb(83%,83%,83%);padding:5;" {
							    b { t "Related Tags" }
							    br
							    ul {
								foreach o $related_tags {
								    li {
									set normalized_tag [string map {{ } {_}} [string totitle [$o set rule_head]]]
									a -href [export_vars -base $base/tag/$normalized_tag] {
									    t [$o set rule_head]
									}
								    }
								}
							    }
							}
						    }

						    p
						    div -style "background:rgb(100%,83%,83%);padding:5;" {
							b { t "Latest Blog Entries" }
							br
							img -src http://www.phigita.net/images/theme/azure/bracket.gif
							t " blogs.phigita.net"
							p
							ul -style "list-style-type:none;padding:0;margin:0;" {
							    foreach o [${blogdata} set result] {
								li {
								    a -href "http://www.phigita.net/~[util::coalesce [${o} set screen_name] [${o} set user_id]]/blog/[${o} set object_id]" {
									t [${o} set title]
								    }
								    t " [mc by.user by] "
								    a -class g -href "http://www.phigita.net/~[util::coalesce [${o} set screen_name] [${o} set user_id]]/" {
									t [${o} set full_name]
								    }
								    span -class xs {
									t -disableOutputEscaping " (&nbsp;~[util::coalesce [${o} set screen_name] [${o} set user_id]]&nbsp;)"
								    }
								    br
								    br
								}
							    }
							}
							i {
							    a -class fl -href "http://blogs.phigita.net/" {
								t "more blog entries..."
							    }
							}
						    }

						    p 
						    div -style "background:rgb(83%,100%,83%);padding:5;" {
							b { t "Latest Remarks" }
							br
							img -src http://www.phigita.net/images/theme/azure/bracket.gif
							t " remarks.phigita.net"
							p
							ul -style "list-style-type:none;padding:0;margin:0;" {
							    foreach o [${linkdata} set result] {
								set x [${o} set cnt_shared]
								set y [expr round(95-log(${x})*log10(${x})*1.61)]
								array set uri [::uri::split [${o} set url]]
								set host [regsub -- {^www\.} $uri(host) {}]
								li {
								    a -href "[$o set url]" {
									t "[$o set title]"
								    }
								    t " ("
								    a -class host -href "http://remarks.phigita.net/?host=$uri(host)" {
									t "${host}"
								    }
								    t ") "
								    span {
									if { [${o} set description] ne {} } {
									    t -disableOutputEscaping " &nbsp; "
									    i { t [${o} set description] }
									}
									t -disableOutputEscaping " &nbsp; "
									a -class "fl nd" -style "background:rgb(${y}%,100%,${y}%);" -href "http://remarks.phigita.net/url?q=[${o} set url_sha1]" {
									    t -disableOutputEscaping "&nbsp;[${o} set cnt_shared]&nbsp;[ad_decode [${o} set cnt_shared] 1 [mc bookmark.singular mark] [mc bookmark.plural marks]]&nbsp;"
									}

									#	    t ", [ad_decode [${o} set cnt_shared] 1 "" "[mc last.male last]"] [mc on.singular on] [lc_time_fmt [${o} set max_sharing_start_date] %Q]"
									t " [ad_decode [${o} set cnt_shared] 1 "" "[mc last.male last]"]"
									t " [mc by.user "by"] "
									a -class g -href "http://www.phigita.net/~[util::coalesce [${o} set screen_name] [${o} set user_id]]/" {
									    t [${o} set full_name]
									}
									span -class xs {
									    t -disableOutputEscaping " (&nbsp;~[util::coalesce [${o} set screen_name] [${o} set user_id]]&nbsp;[getStatusImg [$o set user_id] [$o set status]])"
									}
									br
									br
								    }
								}
							    }
							}
							i {
							    a -class fl -href "http://remarks.phigita.net/" {
								t "more remarks..."
							    }
							}
						    }
						    p
						    div -style "background:rgb(83%,83%,100%);padding:5;" {
							b { t "Blogroll" }
							p
							ul -style "list-style-type:none;padding:0;margin:0;" {
							    set prev_score ""
							    foreach o [${feeddata} set result] {
								array set uri [::uri::split [${o} set url]]
								set host [regsub -- {^www\.} $uri(host) {}]
								li {
								    a -class host -href "?host=$uri(host)" {
									t "${host}"
								    }
								}
							    }
							}
						    }
						    p
						    set disableOutputEscaping {
							<script type="text/javascript"><!--
							google_language = 'en';
							google_encoding = 'utf-8';
							google_ad_client = "pub-1374549828513817";
							google_alternate_color = "ffffff";
							google_ad_width = 125;
							google_ad_height = 125;
							google_ad_format = "125x125_as";
							google_ad_type = "text";
							google_ad_channel = "";
							//--></script>
							<script type="text/javascript"
							src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
							</script>
						    }
						    p
						    div -clear both
						    set disableOutputEscaping {
							<script type="text/javascript"><!--
							google_language = 'en';
							google_encoding = 'utf-8';
							google_ad_client = "pub-1374549828513817";
							google_alternate_color = "ffffff";
							google_ad_width = 160;
							google_ad_height = 600;
							google_ad_format = "160x600_as";
							google_ad_type = "image";
							google_ad_channel = "";
							//--></script>
							<script type="text/javascript"
							src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
							</script>
						    }


						}
					    }
					    br -clear both

					}


					set comment {
					    if { [string equal $date ""] } {
						ad_returnredirect [ad_conn url]?date=[dt_sysdate]
					    }
					}


					set comment {
					    center {
						table -border 0 -cellpadding 1 -cellspacing 0 -bgcolor "#ffff00" -width "75%" {
						    tr {
							td {
							    table -border 0 -cellpadding 6 -cellspacing 0 -width 100% -bgcolor "#ffffcc" {
								tr {
								    td {
				    font -color "#000000" {

					small {
					    strong {
						t "[mc Summary "Summary"]: "
					    } 

					    t [mc Elevator_Pitch.Aggregated_News {
						The news service presents information culled from 
						news sources worldwide and 
						automatically arranged to present the most relevant 
						news first. Topics are updated continuously throughout 
						the day, so you will see new stories each time you 
						check the page.
					    }]

					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}

	ul {
	    li { a -href test/phileleftheros { t "Test 1 -- Phileleftheros" } }
	    li { a -href test/cnn { t "Test 2 -- CNN" } }
	    li { a -href test/yahoo { t "Test 3 -- Associated Press" } }
	}
    }
