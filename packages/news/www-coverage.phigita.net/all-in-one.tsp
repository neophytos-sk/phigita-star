ad_page_contract {
    @author Neophytos Demetriou
} {
    {offset:naturalnum 0}
    host:trim,optional
    {q:trim,optional ""}
    {order_by:trim ""}
    {topic:trim,optional ""}
    {edition:trim,optional ""}
    {cluster:trim,optional ""}
    {debug_p:boolean "0"}
}



set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ${user_id} == 0 } {
    set admin_p f
} else {
    set admin_p [permission::permission_p -object_id ${package_id} -party_id ${user_id} -privilege admin]
}


set base .
set limit 10
set perTopicLimit 3
set imageDir "/var/lib/naviserver/service-phgt-0/data/news/images"

set fromList ""
set count 0
foreach topicString { Politics Society Economy Business Sports.Soccer Sports.Basketball Culture Technology Law Science Health Nature Lifestyle} {
    lappend fromList "select * from (select *,$count as sk from xo.xo__clustering__class _topic_$count where live_p and topic_sk <@ [ns_dbquotevalue $topicString] order by cnt_documents desc limit $perTopicLimit) topic_$count"
    incr count
	set portlet($topicString) ""
}
set clusterList [::db::Set new \
		     -pool newsdb \
		     -from "([join $fromList " union "]) allClusters" \
		     -order "sk,cnt_documents desc"]

ns_log notice [$clusterList set sql]

set rss_feed_url [export_vars -url -base http://news.phigita.net/$base -no_empty -override [list [list output rss]] {q edition topic host}]

set subtitle ""
set page_subtitle ""













set editionIndex 0
if { ${edition} ne {} } {
    $clusterList lappend where "cluster_sk ~ [ns_dbquotevalue "*{1}.[string map {. _} $edition].*"]"
    ${newsdata} lappend where "classification__edition_sk = [ns_dbquotevalue ${edition}]"
    lappend page_subtitle "[mc news.edition.${edition} [lindex [split $edition .] end]]"
    lappend subtitle [mc news.edition.$edition [lindex [split $edition .] end]]
} else {
#    $clusterList order "cnt_documents/nlevel_edition_sk desc"
}

if { ${topic} ne {} } {
    $clusterList lappend where "cluster_sk <@ [ns_dbquotevalue [string map {. _} $topic]]"
    ${newsdata} lappend where "classification__tree_sk <@ [ns_dbquotevalue ${topic}]"
    lappend page_subtitle "[mc news.topic.${topic} $topic]"
    lappend subtitle [mc news.topic.$topic [lindex [split $topic] 0]]
}

set endRange 222 ;# 144


set title "[mc News "News in Greek"][util::decode ${page_subtitle} "" "" " - "][join ${page_subtitle} " - "] - \"All-in-One\""



set now_minus_24hours [expr {([clock seconds] - 86400)}]

tmpl::master -refreshInterval 1800 -title ${title} -context_bar [ad_context_bar "All-in-One"] -rss_feed_url ${rss_feed_url} -searchQuery [ad_decode ${q} {} {} "${q}"] -defaultSearchAction [export_vars -url -base $base] -searchButtonsScript [subst -nocommands -nobackslashes {
    input -type hidden -name order_by -value "${order_by}"
    input -type hidden -name topic -value "${topic}"
    input -type submit -value [mc Search_News "Search News"] -tabindex 2
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
    ::xo::html::add_style {
	    .popular {width:200;}
	    .popular li {width:200;float:left;}
	    .popular a  {color:#009;font-weight:bold;}
		.cluster {padding:0;margin:10 0 0 0;width:100%;font-size:12px;background:grey;}
		.topicGroup0 {width:45%;float:left;padding:0;margin:0 0 0 0;clear:both;}
		.topicGroup1 {width:45%;float:left;padding:0;margin:0 0 0 15;}
	    .clusterTopic {color:black;font-size:16px;font-weight:bold;}
	    .clusterHeadOld {text-decoration:none;font-weight:bold;font-size:16px;color:#cc6600;}
	    .clusterHeadOld:hover {background:#ffffcc;}
            .clusterHead {color:#009;font-weight:bold;font-size:14px;}
	    .clusterMember {color:green;}
	    .clusterRelated {color:green;font-weight:bold;}
	    .cluster li {padding:10;}
	    .pl {
		overflow:hidden;
	    }
	    .pl h1 {margin:0;padding:4;font-size:100%;}
	    .pl ul {list-style-type: none; margin:0;padding:0;}
	    .pl li {
		clear:both;
		margin:2px;padding:2px;
	    }
	    .classificationBar {
		background:#eeeeee;
		font: bold 0.75em Verdana, Helvetica, sans-serif;
		padding:3;
		margin:1;
	    }
	    .classificationBar a {
		color:#581C90;
	    }
	    .little {font-size: x-small; color: gray;}
	    .wh {color:#ffffff;}
                .ni {color:#009;font-weight:bold;}
		    .s {font-size:80%;}
		    .tabdata a {background:#eeeeee;display:inline;text-decoration: none;
			font: bold 0.65em Verdana, Helvetica, sans-serif;
			text-transform: none;
			text-align: center;}
		    .tabdata .selectedtab { 
			text-transform:none; 
			font: bold 0.65em Verdana, Helvetica, sans-serif; 
			display:inline;
		    }
    }




#	        img -src http://www.phigita.net/graphics/testing.gif



		array set background [list Politics \#aa0033 Economy \#008000 Business \#888000 Society \#ffcc00 Sports \#ff6600 Technology \#cc0000 Culture \#663399 Health \#669999 Lifestyle \#669999 Nature \#669999 Science \#ff0066 Law #999000] 

set count_topic 0
set prev_topic_sk ""
set prev_topic_sk_part ""
set timeNode [tmpl::div -align right]

tmpl::memoize -key "News.All-in-One.Language([ad_conn language])" -timeout 300 {

    $clusterList load

    ::memoize::cache set News.All-in-One.Time [ns_time]

    div -class cluster {
	    set count 0
	    foreach cluster [$clusterList set result] {
		
		array set uri [uri::split [$cluster set head_url]]
		set clusterHost [regsub -- {^www\.} $uri(host) {}]
		
		set clusterImageHost ""
		if { [$cluster set head_url] ne [$cluster set image_url] } {
		    array set uri [uri::split [$cluster set image_url]]
		    set clusterImageHost [regsub -- {^www\.} $uri(host) {}]
		}
		
		set clusterURL [export_vars \
				    -url \
				    -no_empty \
				    -base $base \
				    -override [list [list cluster [ns_sha1 [$cluster set head_url]]]] \
				    {topic edition}]
		
		
		set cluster_sk_parts [split [$cluster set cluster_sk] .]

	set topic_sk [$cluster set topic_sk]
	set edition_sk [$cluster set edition_sk]

		set topic_sk_top [lindex [split $topic_sk .] 0]
		set edition_sk_part [lindex [split $edition_sk .] end]
		set topic_sk_end [lindex [split $topic_sk .] end]
		
		if { $topic_sk ne $prev_topic_sk && ([info exists portlet($topic_sk)] || $topic_sk_top ne $prev_topic_sk_top)} {
		    set prev_topic_sk $topic_sk
		    set prev_topic_sk_top $topic_sk_top
		    if { $count_topic % 2 == 0 } {
			div -clear both
		    }
		    set node [tmpl::div -class topicGroup[expr {$count_topic %2}] {
			div -style "padding:5;margin:15 0 0 0;background:#eeeeee;border-top:2px solid $background($topic_sk_top);" {
			    if {[info exists portlet($topic_sk)]} {
				set topic_sk_parts [split $topic_sk .]
				set topic_sk_target $topic_sk
			    } else {
				set topic_sk_parts $topic_sk_top
				set topic_sk_target $topic_sk_top
			    }

			    set topic_sk_current ""
			    foreach topic_sk_part $topic_sk_parts {
				set topic_sk_current [join "$topic_sk_current $topic_sk_part" .]
				a -class clusterTopic -href [export_vars -url -base $base -override [list [list topic $topic_sk_current]]] { t -disableOutputEscaping "[mc news.topic.$topic_sk_current $topic_sk_part]&nbsp;[ad_decode $topic_sk_current $topic_sk_target "&raquo;" ""]" }
				if { ![string equal $topic_sk_target $topic_sk_current] } {
				    t " / "
				}
			    }
			}
			br
		    }]
		    incr count_topic
		}
		$node appendFromScript {
		    div {
			if { [$cluster set image_file] ne {} } {
			    set imageFile [lindex [$cluster set image_file] 0]-sample-80x80.jpg
			    if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
				foreach {width height} ${image_size} break
				a -href "ct?s=[ns_sha1 [$cluster set image_url]]" {
				    img -src "images/[lindex [$cluster set image_file] 0]" -width $width -height $height -border 1 -align right
				}
			    }
			}
			span -class classificationBar {
			    a -class editionLink -href "[export_vars -url -base $base -no_empty -override [list [list edition $edition_sk]] {topic}]" {
				t [mc news.edition.$edition_sk $edition_sk_part]
			    }
			    t ": "
			    a -class topicLink -href "[export_vars -url -base $base -no_empty -override [list [list edition $edition_sk] [list topic $topic_sk]]]" {
				t [mc news.topic.$topic_sk $topic_sk_end]
			    }
			}
			a -class clusterHead -href "ct?s=[ns_sha1 [$cluster set head_url]]" -title [$cluster set head_title] {
			    t [::textutil::adjust [$cluster set head_title] -length 11 -strictlength t]
			}
			t -disableOutputEscaping " &nbsp; "
			t [string range [$cluster set head_summary] 0 222]
			br
			a -class clusterMember -href ct?s=[ns_sha1 [$cluster set head_url]] {
			    t $clusterHost
			}
			if { $clusterImageHost ne {} } {
			    t -disableOutputEscaping " - "
			    a -class clusterMember -href ct?s=[ns_sha1 [$cluster set image_url]] {
				t $clusterImageHost
			    }
			}
			t -disableOutputEscaping " - "
			a -class clusterRelated -href $clusterURL -title [$cluster set head_title] {
			    t -disableOutputEscaping "[format [mc News.all_related_fmtstr "all&nbsp;%s&nbsp;related"] [$cluster set cnt_documents]]&raquo;&nbsp;"
			}
			if { $debug_p && $admin_p } {
			    a -href "admin/cluster-disable?cluster_sk=[$cluster set cluster_sk]" {
				t "\[disable\]"
			    }
			    br
			}
		    }
		    br
		    incr count
		}
	    }

	div -class topicGroup1 {


	    set comment {
div -style "padding:0;width:300;height:250;" {
    t -disableOutputEscaping {
	<script type="text/javascript"><!--
	google_language = 'en';
	google_encoding = 'utf-8';
	google_country = 'gr';
	//--></script>
	<!-- Begin: AdBrite -->
	<script type="text/javascript">
	var AdBrite_Title_Color = '0000FF';
	var AdBrite_Text_Color = '000000';
	var AdBrite_Background_Color = 'FFFFFF';
	var AdBrite_Border_Color = 'FFFFFF';
	</script>
	<script src="http://ads.adbrite.com/mb/text_group.php?sid=232809&zs=3330305f323530" type="text/javascript"></script>
	<!-- End: AdBrite -->
    }
}
}

    center {
	div -style "margin-top:180px;width:250;padding:5 5 5 5;border:1px dashed \#efefef;" {
	    t -disableOutputEscaping {
		<script type="text/javascript"><!--
		google_language = 'en';
		google_encoding = 'utf-8';
		google_country = 'gr';
		google_ad_client = "pub-1374549828513817";
		google_alternate_color = "ffffff";
		google_ad_width = 234;
		google_ad_height = 60;
		google_ad_format = "234x60_as";
		google_ad_type = "text";
		google_ad_channel = "";
		//--></script>
		<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
	    }
	}
    }


}
}
}

if {[memoize::cache exists News.All-in-One.Time]} {
    set time [::memoize::cache get News.All-in-One.Time]
} else {
    set time [ns_time]
}

$timeNode appendFromScript {
    t -disableOutputEscaping "Auto-generated <b>[expr {int(([ns_time]-${time})/60)}] minutes ago</b>"
    t " | "
    a -style "background:green; color:white;padding:2px;font-weight:bold;text-decoration:none;" -href "http://buzz.phigita.net/" -title [mc monitor_syndicated_content "Monitor Greek Blogs"] {
	t "(([mc Buzz_Monitor Buzz]))"
    }
}

br -clear both

div -style "margin:5;padding:0;border:1px dashed \#efefef;width:470" {
    t -disableOutputEscaping [subst -nobackslashes -nocommands {
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
    }]
}

br -clear both


}