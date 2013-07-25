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
    {debug_p:boolean "1"}
    {permanent_train_p:boolean,optional ""}
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
set imageDir "/var/lib/naviserver/service-phgt-0/data/news/images"




set newsdata [::db::Set new -pool newsdb -alias story -type ::sw::agg::Url -where [list "NOT buzz_p" "NOT feed_p" "language='el'" "title is not null"] -offset ${offset} -limit [expr 1+${limit}] -noinit]



switch -exact -- "[string equal $q {}]${order_by}" {
    {1pop} {
	set order "cnt_clickthroughs"
	$newsdata lappend where "cnt_clickthroughs>0"
	$newsdata lappend where "creation_date > current_timestamp-'24 hours'::interval"
    }
    {0rank} {
	set order "rank"
    }
    default {
	set order "creation_date"
    }
}
$newsdata order "${order} desc"


if {[exists_and_not_null permanent_train_p]} {
    $newsdata lappend where "permanent_train_p=[::util::dbquotevalue $permanent_train_p]"
    set op "="
} else {
    set op "<@"
}


set perTopicLimit 2
set fromList ""
set count 0
foreach topicString { Politics Society Sports Economy Technology Culture Health}  {
    set from_part "select * from (select *,$count as sk from xo.xo__clustering__class _$topicString where live_p"
    append from_part " and cluster_sk ${op} [ns_dbquotevalue $topicString]"
    if { ${edition} ne {} } {
	append from_part " and cluster_sk ~ [ns_dbquotevalue "*{1}.[string map {. _} $edition].*"]"
    }
    append from_part " order by cnt_documents desc limit $perTopicLimit) $topicString"
    lappend fromList $from_part
    incr count
}

array set background [list Politics \#aa0033 Economy \#008000 Business \#888000 Society \#ffcc00 Sports \#ff6600 Technology \#cc0000 Culture \#663399 Health \#669999 Law \#999000 TV \#663399 Science \#cc0000 Nature \#aa1155 Lifestyle #663399] 

if { $topic eq {} } {
    set clusterList [::db::Set new \
			 -pool newsdb \
			 -from "([join $fromList " union "]) allClusters" \
			 -order "sk,cnt_documents desc"]

} else {
    set clusterList [::db::Set new \
			 -pool newsdb \
			 -from xo.xo__clustering__class \
			 -where [list "live_p"] \
			 -order "cnt_documents desc" \
			 -limit 7 \
			 -noinit]

}











set rss_feed_url [export_vars -url -base http://news.phigita.net/$base -no_empty -override [list [list output rss]] {q edition topic host}]

set subtitle ""
set page_subtitle ""







if { ${cluster} ne {} } {
	
    set clusterdata [::db::Set new \
			 -select [list {clustering__cluster_sk as cluster_sk} "title as head_title"] \
			 -pool newsdb \
			 -from xo.xo__sw__agg__url \
			 -where [list "url_sha1=[ns_dbquotevalue $cluster]"] \
			 -limit 1 \
			 -load]

    if { [$clusterdata emptyset_p] } {
	rp_returnnotfound
	return
    }

    set clusterHead [$clusterdata head]

    $newsdata lappend where "clustering__cluster_sk<@[ns_dbquotevalue [$clusterHead set cluster_sk]]"
    $newsdata lappend where "creation_date > current_timestamp-'96 hours'::interval"

    lappend subtitle "[mc cluster Cluster]: [$clusterHead set head_title]"
    lappend page_subtitle "[mc cluster Cluster]: [$clusterHead set head_title]"

} else {
    if { ${edition} eq {} } {
#	$clusterList lappend where "cluster_sk ~ [ns_dbquotevalue *.000]"
    }
}





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
    ${newsdata} lappend where "classification__tree_sk ${op} [ns_dbquotevalue ${topic}]"
    lappend page_subtitle "[mc news.topic.${topic} $topic]"
    lappend subtitle [mc news.topic.$topic [lindex [split $topic] 0]]
}

if { [exists_and_not_null host] } {
    #set rss_feed_url "${base}?host=${host}&output=rss"
    set no_www_host [regsub -- {^www\.} ${host} {}]
    set url_host_sha1 [ns_sha1 ${host}]
    ${newsdata} lappend where "url_host_sha1=[ns_dbquotevalue ${url_host_sha1}]"
    lappend subtitle "from <a href=\"http://${host}/\" style=\"color:green;\">http://${host}/</a>"
    lappend page_subtitle "from source ${no_www_host}"
}
set endRange 222 ;# 144

if { [exists_and_not_null q] } {
	set q [string map {: { } ' {} | {} & {} ! {} ~ {}} ${q}]
	set conn [${newsdata} getConn]
	set tsQuery [${conn} getvalue "select to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]])"]

	if { ${tsQuery} ne {} } {

	    set endRange end
	    ${newsdata} unset type
	    ${newsdata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector,q,rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__news_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where url in (select url from (select url, rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__news_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where ts_vector @@ q and creation_date > current_timestamp-'1 month'::interval order by $order desc offset ${offset} limit [expr {${limit}+1}]) u)) r on (u.url=r.url)"

	    ${newsdata} lappend select "ts_headline('[default_text_search_config]',last_crawl_content,q,'MaxWords=45, MinWords=35') as last_crawl_content"
	    ${newsdata} lappend select "ts_headline('[default_text_search_config]',title,q) as title"

	    ${newsdata} order "$order desc"
	    ${newsdata} unset offset
	    ${newsdata} unset limit

#	$newsdata init
#	    ns_log notice [$newsdata set sql]
set start_clicks [clock clicks -milliseconds]
	    ${newsdata} load
set end_clicks [clock clicks -milliseconds]
set search_duration [expr {(${end_clicks}-${start_clicks})/1000.0}]
	} else {
		# do nothing, empty set of results
	}
	set queryTitle "${q} - "
	lappend subtitle ${q}
} else {
    ${newsdata} load
	set queryTitle ""
}




set classList [db::Set new -pool newsdb -type ::classification::Class -order tree_sk]
$classList load





set title "${queryTitle} [mc News "News in Greek"][util::decode ${page_subtitle} "" "" " - "][join ${page_subtitle} " - "]"



set now_minus_24hours [expr {([clock seconds] - 86400)}]

tmpl::master -refreshInterval 900 -title ${title} -context_bar [ad_context_bar] -rss_feed_url ${rss_feed_url} -searchQuery [ad_decode ${q} {} {} "${q}"] -defaultSearchAction [export_vars -url -base $base] -searchButtonsScript [subst -nocommands -nobackslashes {
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
	    .datebox {white-space:nowrap;color:#666666;border: 1px solid #e0e0e0; font-family:georgia; margin:2;padding:2;float:left;width:60;text-align:center;background:#fff1cc;font-size:10px;}
	    .popular {width:200;}
	    .popular li {width:200;float:left;}
	    .popular a  {color:#009;font-weight:bold;}
	    .day {font-weight:bold;font-size:16px;}
	    .cluster ul {padding:0;margin:10 0 0 0;list-style-type:none;}
		.clusterHeadOld {text-decoration:none;font-weight:bold;font-size:16px;color:#cc6600;}
	    .clusterHeadOld:hover {background:#ffffcc;}
            .clusterHead {color:#009;font-weight:bold;font-size:12px;}
		.separator {border-top:2px dashed #efefef;}
	    .clusterMember {color:green;font-size:10px;}
	    .clusterRelated {color:green;font-weight:bold;font-size:10px;}
		.cluster li {padding:8;}
	    .pl {
		overflow:hidden;
	    }
	    .pl h1 {margin:0;padding:4;font-size:16px;}
	    h2 {margin:0;padding:4;font-size:16px;}
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
	    .little {font-size: 10px; color:#666666;}
	    .wh {color:#ffffff;}
                .ni {color:#009;font-weight:bold;font-size:14px;}
.abc {width:510px;}
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

	::xo::html::add_style {
		    #topicTabs {width:510;margin:0; padding:0 0 0 4px;list-style:none; height:18px; background:url(http://www.phigita.net/graphics/news/hr_999.gif) bottom repeat-x;}

		    #topicTabs li {display:inline;cursor:pointer;pointer:hand;font:10px verdana; font-weight:bold; white-space:nowrap; padding-right:3px; padding-bottom:1px; padding-left:3px;margin:0 0 0 4;line-height:19px;border-left: 1px solid #999;}

		    #topicTabs .normalTab {background:url(http://www.phigita.net/graphics/news/bg_nav_cnrr_on.gif) top right no-repeat;color:#333;}

		    #topicTabs .selectedTab {color:#fff; background:#344760 url(http://www.phigita.net/news/graphics/news/bg_nav_cnrr.gif) top right no-repeat;line-height:21px;border-left: 1px solid #344760;}

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
		    #editionTabs .tabIndex8 {border-left: 4px solid #840840;}
		    #editionTabs .tabIndex9 {border-left: 4px solid #440440;}
		    #editionTabs .tabIndex10 {border-left: 4px solid #240240;}

		    #editionTabs li {cursor:pointer;cursor:hand;border: 1px solid #bbb;padding:2;background:#eee;width:100%;margin:2;color:#888;font: bold 0.75em Verdana, Helvetica, sans-serif;}
		    #editionTabs .selectedTab {color:#ffffff;background:#344760;}
	    }

div -style "float:left;width:130;margin:5;padding:2;border-right: 2px solid #efefef;" {
    div -style "width:90;margin:2;padding:2;" {
		set selectedIndex 0
		set count 1
		set tabList "[export_vars -url -base ${base} -no_empty -override {q host order_by topic permanent_train_p}] [mc news.edition.Global Global]"
		foreach {tabType tabTopic tabKey} {
		    edition World World
		    edition World.Europe.Cyprus World.Europe.Cyprus
		    edition World.Europe.Greece World.Europe.Greece
		    edition World.North_America.USA World.North_America.USA
		    edition World.Europe.Spain World.Europe.Spain
		    edition World.Europe.France World.Europe.France
		    edition World.Europe.Italy World.Europe.Italy
		    edition World.Europe.United_Kingdom World.Europe.UK
		    edition World.Middle_East.Iraq World.Middle_East.Iraq
		    edition World.Middle_East.Iran World.Middle_East.Iran
		} {
		    if { [string match "${tabTopic}*" [set $tabType]] } {
			set selectedIndex $count
		    }
		    set tabURL [export_vars -url -base ${base} -no_empty -override [list [list $tabType $tabTopic]] {q host order_by topic permanent_train_p}]
		    lappend tabList "$tabURL [mc news.${tabType}.$tabKey [lindex [split $tabKey .] end]]"
		    incr count
		}
		navTabs -cssId editionTabs -selectedIndex $selectedIndex -tabs [join $tabList]
	p
	b {
	    a -class fl -href "../all-in-one" {
		t "All-in-One"
	    }
	}
	p
    a -style "background:green; color:white;padding:2px;font-weight:bold;text-decoration:none;" -href "http://buzz.phigita.net/" -title [mc monitor_syndicated_content "Monitor Greek Blogs"] {
	t "(([mc Buzz_Monitor Buzz]))"
    }

		p
		i { t [mc News.Sources "Sources"] }
		p
a -class "little" -href "?host=www.2810.gr" {
t "2810.gr"
}
br
a -class "little" -href "?host=www.agelioforos.gr" {
t "agelioforos.gr"
}
br
a -class "little" -href "?host=www.alphatv.gr" {
t "alphatv.gr"
}
br
a -class "little" -href "?host=www.analitis.com" {
t "analitis.com"
}
br
a -class "little" -href "?host=news.antenna.gr" {
t "antenna.gr"
}
br
a -class "little" -href "?host=www.chiosnews.com" {
t "chiosnews.com"
}
br
a -class "little" -href "?host=www.chiostimes.com" {
t "chiostimes.com"
}
br
a -class "little" -href "?host=www.contra.gr" {
t "contra.gr"
}
br
a -class "little" -href "?host=www.cpress.gr" {
t "cpress.gr"
}
br
a -class "little" -href "?host=www.diavima.gr" {
t "diavima.gr"
}
br
a -class "little" -href "?host=www2.dw-world.de" {
t "dw-world.de"
}
br
a -class "little" -href "?host=www.e-grammes.gr" {
t "e-grammes.gr"
}
br
a -class "little" -href "?host=www.e-pcmag.gr" {
t "e-pcmag.gr"
}
br
a -class "little" -href "?host=www.e-thessalia.gr" {
t "e-thessalia.gr"
}
br
a -class "little" -href "?host=www.enet.gr" {
t "enet.gr"
}
br
a -class "little" -href "?host=www.enew.gr" {
t "enew.gr"
}
br
a -class "little" -href "?host=news.ert.gr" {
t "ert.gr"
}
br
a -class "little" -href "?host=www.ert3.gr" {
t "ert3.gr"
}
br
a -class "little" -href "?host=www.ethnos.gr" {
t "ethnos.gr"
}
br
a -class "little" -href "?host=www.explo.gr" {
t "explo.gr"
}
br
a -class "little" -href "?host=www.express.gr" {
t "express.gr"
}
br
a -class "little" -href "?host=www.forthnet.gr" {
t "forthnet.gr"
}
br
a -class "little" -href "?host=www.gameover.gr" {
t "gameover.gr"
}
br
a -class "little" -href "?host=www.greenpeace.org" {
t "greenpeace.org"
}
br
a -class "little" -href "?host=www.go2.com.cy" {
t "go2.com.cy"
}
br
a -class "little" -href "?host=www.haravgi.com.cy" {
t "haravgi.com.cy"
}
br
a -class "little" -href "?host=www.hxo.gr" {
t "hxo.gr"
}
br
a -class "little" -href "?host=www.ikypros.com" {
t "ikypros.com"
}
br
a -class "little" -href "?host=www.imera.ws" {
t "imera.ws"
}
br
a -class "little" -href "?host=www.imeranews.gr" {
t "imeranews.gr"
}
br
a -class "little" -href "?host=www.imerisia.gr" {
t "imerisia.gr"
}
br
a -class "little" -href "?host=www.imerisia-ver.gr" {
t "imerisia-ver.gr"
}
br
a -class "little" -href "?host=www.in.gr" {
t "in.gr"
}
br
a -class "little" -href "?host=www.isotimia.gr" {
t "isotimia.gr"
}
br
a -class "little" -href "?host=www.kalimera.gr" {
t "kalimera.gr"
}
br
a -class "little" -href "?host=news.kathimerini.gr" {
t "kathimerini.gr"
}
br
a -class "little" -href "?host=www.kavalanet.gr" {
t "kavalanet.gr"
}
br
a -class "little" -href "?host=www.kerdos.gr" {
t "kerdos.gr"
}
br
a -class "little" -href "?host=www.lawnet.gr" {
t "lawnet.gr"
}
br
a -class "little" -href "?host=www.laosver.gr" {
t "laosver.gr"
}
br
a -class "little" -href "?host=www.madata.gr" {
t "madata.gr"
}
br
a -class "little" -href "?host=www.megatv.com" {
t "megatv.com"
}
br
a -class "little" -href "?host=www.mesogios.gr" {
t "mesogios.gr"
}
br
a -class "little" -href "?host=www.naftemporiki.gr" {
t "naftemporiki.gr"
}
br
a -class "little" -href "?host=www.patris.gr" {
t "patris.gr"
}
br
a -class "little" -href "?host=www.pcw.gr" {
t "pcw.gr"
}
br
a -class "little" -href "?host=www.phileleftheros.com" {
t "phileleftheros.com"
}
br
a -class "little" -href "?host=www.politis.com.cy" {
t "politis.com.cy"
}
br
a -class "little" -href "?host=www.rizospastis.gr" {
t "rizospastis.gr"
}
br
a -class "little" -href "?host=www.setimes.com" {
t "setimes.com"
}
br
a -class "little" -href "?host=www.sifnaikanea.gr" {
t "sifnaikanea.gr"
}
br
a -class "little" -href "?host=www.simerini.com.cy" {
t "simerini.com.cy"
}
br
a -class "little" -href "?host=www.stockwatch.com.cy" {
t "stockwatch.com.cy"
}
br
a -class "little" -href "?host=www.technews.gr" {
t "technews.gr"
}
br
a -class "little" -href "?host=www.tganews.com" {
t "tganews.com"
}
br
a -class "little" -href "?host=ta-nea.dolnet.gr" {
t "ta-nea.dolnet.gr"
}
br
a -class "little" -href "?host=tovima.dolnet.gr" {
t "tovima.dolnet.gr"
}
br
a -class "little" -href "?host=www.typos.com.cy" {
t "typos.com.cy"
}
br
a -class "little" -href "?host=www.voanews.com" {
t "voanews.com"
}
br
a -class "little" -href "?host=www.xronos.gr" {
t "xronos.gr"
}
br
br
if {!$debug_p} {
t -disableOutputEscaping {
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
}
p
}
}



div -class pl -style "float:left;width:525;" {

		set selectedIndex 0
		set count 1
		set tabList "[export_vars -url -base ${base} -no_empty -override {q host order_by edition permanent_train_p}] [mc news.topic.All All]"
		foreach {tabType tabTopic} {
		    topic Politics
		    topic Economy
		    topic Society
	            topic Culture
		    topic Technology
		    topic Health
		    topic Sports
		} {
		    if { [string match "${tabTopic}*" [set $tabType]] } {
			set selectedIndex $count
		    }
		    set tabURL [export_vars -url -base ${base} -no_empty -override [list [list $tabType $tabTopic]] {q host order_by edition permanent_train_p}]
		    lappend tabList "$tabURL [mc news.${tabType}.$tabTopic [lindex [split $tabTopic .] end]]"
		    incr count
		}

		navTabs -cssId topicTabs -selectedIndex $selectedIndex -tabs [join $tabList]
#		div -class wh -style "background:#344760;" { t -disableOutputEscaping "&nbsp;" }
br -clear both
if {[exists_and_not_null heading]} {
    h3 -style "display:inline;" { t $heading }
    br
}
		if {[exists_and_not_null subtitle]} {
t -disableOutputEscaping "( [join ${subtitle} {; }] <a href=\"[export_vars -url -base $base]\" class=\"fl nd\">\[clear\]</a> )"
		}
		t -disableOutputEscaping "&nbsp;"
		a -href ${rss_feed_url} -title "RSS" -class "o" {
		    t "RSS"
		}

        p



ul {
	    set newsdata_i 0
	    foreach newsitem [${newsdata} set result] {
		array set uri [uri::split [${newsitem} set url]]
		li -style "padding:5 15 5 15;" {
		    div -class "datebox" {
			t -disableOutputEscaping "[lc_time_fmt [$newsitem set creation_date] "%H:%M<br><span class=\"day\">%d</span><br>%b &\#39;%y"] "
		    }
		    div -style "margin-left:75;background:\#ffffff;" {
			if { [${newsitem} set image_file] ne {} } {
			    set imageFile [$newsitem set image_file]-sample-80x80.jpg
			    if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
				foreach {width height} ${image_size} break
				img -src "/images/[${newsitem} set image_file]" -width $width -height $height -align left
			    }
			}
			if { $debug_p && ${admin_p} } {
			    t "\["
			    a -class fl -href "url-update?buzz_p=&channel_url_sha1=&feed_p=f&url_sha1=[${newsitem} set url_sha1]&return_url=[export_vars -base .. {offset}]" -onclick "return confirm('Are you sure?');" {
				t "NULL"
			    }
			    t "\] "
			    t "\["
			    a -class fl -href "/admin/cache?url_sha1=[$newsitem set url_sha1]" {
				t "CACHE"
			    }
			    t "\] "
			    t "\["
			    a -class fl -href "/admin/classification-list?url=[ns_urlencode [$newsitem set url]]" {
				t "CLASS"
			    }
			    t "\] "
			    t "\["
			    a -class fl -href "/admin/ttext-bte?url=[ns_urlencode [$newsitem set url]]" {
				t "BTE"
			    }
			    t "\] "
			    t "\["
			    a -class fl -href "/admin/ttext-tidy?url=[ns_urlencode [$newsitem set url]]" {
				t "TIDY"
			    }
			    t "\] "
			    t "\["
			    a -class fl -href "/admin/news-item-refetch?url=[ns_urlencode [$newsitem set url]]&return_url=[ns_urlencode [export_vars -base . -no_empty {q host edition topic offset cluster}]]" {
				t "REFETCH"
			    }
			    t "\] "
				br
			    t "\[ct=[$newsitem set cnt_clickthroughs]\] "
			    set comment {
				t "\["
				a -class fl -href "/admin/url-update?buzz_p=f&channel_url_sha1=&feed_p=t&url_sha1=[${newsitem} set url_sha1]&return_url=[export_vars -base .. {offset}]" -onclick "return confirm('Are you sure?');" {
				    t "feed"
				}
				t "\] "

			    }
			  if { [exists_and_not_null q] } {
			    t "\[ "
			    b {
				t "r="
			    	t [$newsitem set rank]
			    }
			    t " \] "
			    br
			  }
			    br
			}
			form -action news-item-update {
			    input -type hidden -name "url_sha1" -value "[$newsitem set url_sha1]"
			    input -type hidden -name "return_url" -value "[export_vars -url -base $base -no_empty {q cluster host edition topic offset}]"

			span -class classificationBar {
			    if { [$newsitem set classification__edition_sk] ne {} } {
				a -class editionLink -href "[export_vars -url -base $base -no_empty -override [list [list edition [$newsitem set classification__edition_sk]]] {topic}]" {
				    t [mc news.edition.[$newsitem set classification__edition_sk] [lindex [split [$newsitem set classification__edition_sk] .] end]]
				}
			    }
			    if { [$newsitem set classification__edition_sk] ne {} && [$newsitem set classification__tree_sk] ne {} } {
				t ": "
			    }
			    if { [$newsitem set classification__tree_sk] ne {} } {
				set sk ""
				foreach sk_part [split [$newsitem set classification__tree_sk] .] {
				    lappend sk $sk_part
				    a -class topicLink -href "[export_vars -url -base $base -no_empty -override [list [list edition [$newsitem set classification__edition_sk]] [list topic [join $sk .]]]]" {

					t [mc news.topic.[join $sk .] $sk_part]
				    }
				    if { [join $sk .] ne [$newsitem set classification__tree_sk] } {
					t " . "
				    }
				}
			    }
			}


			if { $uri(host) eq {www.politis.com.cy} && ${now_minus_24hours} > [clock scan [lc_time_fmt [${newsitem} set creation_date] "%Y-%m-%d %H:%M"]] } {
			    set url [regsub -all -- {-V=[a-zA-Z]*} [${newsitem} set url] {-V=archive}]
			} else {
			    set url [${newsitem} set url]
			}
			a -href "/ct?s=[$newsitem set url_sha1]" -class "ni" {
			    if { [exists_and_not_null q] } {
				t -disableOutputEscaping [::util::coalesce [${newsitem} set title] Untitled]
			    } else {
				t -disableOutputEscaping [::util::coalesce [::util::striphtml [${newsitem} set title]] Untitled]
			    }
			}
			t -disableOutputEscaping " &nbsp; "
			set no_www_host [regsub -- {^www[0-9]?\.} $uri(host) {}]
			t -disableOutputEscaping "<a class=little href=\"?host=$uri(host)\">(${no_www_host})</a>"
			t -disableOutputEscaping " &nbsp; "
			span -class "s" {
			    t -disableOutputEscaping " &nbsp; "
			    if { [exists_and_not_null q] } {
				t -disableOutputEscaping [string range [${newsitem} set last_crawl_content] 0 ${endRange}]
			    } else {
				t -disableOutputEscaping [string range [::util::striphtml [${newsitem} set last_crawl_content]] 0 ${endRange}]
			    }
			}
			    p
			    b { t "Topic: " }

				
			    select -name classification__tree_sk {
				option -value "" { t "None" }
				foreach classObject [$classList set result] {
				    set optionNode [tmpl::option -value [$classObject set tree_sk] {
					t "[::util::pad [$classObject set id] 3] - [$classObject set tree_sk]"
				    }]
				    if { [$classObject set tree_sk] == [$newsitem set classification__tree_sk] } {
					$optionNode setAttribute selected ""
				    }
				}
			    }
			    br
			    b { t "Edition: " }
			    input -type text -name classification__edition_sk -value [$newsitem set classification__edition_sk] -size 50
			    br

#			    input -type text -name classification__tree_sk -value [$newsitem set classification__tree_sk]
			    br
			    eval "input -id train_topic_p__[$newsitem set url_sha1] -type checkbox -name train_topic_p [::util::decode [$newsitem set train_topic_p] t {-checked ""} ""]"
			    label -for "train_topic_p__[$newsitem set url_sha1]" {
				t "Topic Training Set"
			    }
			    p
			    eval "input -id train_edition_p__[$newsitem set url_sha1] -type checkbox -name train_edition_p [::util::decode [$newsitem set train_edition_p] t {-checked ""} ""]"
			    label -for "train_edition_p__[$newsitem set url_sha1]" {
				t "Edition Training Set"
			    }
			    p
			    eval "input -id permanent_train_p__[$newsitem set url_sha1] -type checkbox -name permanent_train_p [::util::decode [$newsitem set permanent_train_p] t {-checked ""} ""]"
			    label -for "permanent_train_p__[$newsitem set url_sha1]" {
				t "Permanent Training Material"
			    }
			    t " "
			    input -type submit -value "Submit"
			}

		    }

		}
		if {[incr newsdata_i]==${limit}} break
	    }
	}
		p -clear both
		set navigationNode [tmpl::div -class abc {
		    div -style "float:right;" {
			set size [llength [${newsdata} set result]]
			if {${offset} > 0} {

			    a -class wh -href [export_vars  -url -base ${base} -no_empty {q host order_by topic edition cluster}] {
				t -disableOutputEscaping "Latest Headlines"
			    }
			    t -disableOutputEscaping " &nbsp; "
			    set tmp_offset [expr ${offset}-${limit}]
			    if {${tmp_offset}==0} {
				set override_script {}
			    } else {
				set override_script [list [list offset ${tmp_offset}]]
			    }
			    a -class wh -href [export_vars  -url -base ${base} -no_empty -override ${override_script} {q host order_by topic edition cluster permanent_train_p }] {
				t -disableOutputEscaping "&#171; Newer"
			    }
			}
			span -class wh { t -disableOutputEscaping " (&nbsp;[expr 1+${offset}]&#150;[expr ${offset}+${limit}]&nbsp;) " }
			if { ${size}>${limit} } {
			    a -class wh -href [export_vars  -url -base ${base} -no_empty -override {{offset {[expr ${offset}+${limit}]}}} {q host order_by topic edition permanent_train_p cluster}] {
				t -disableOutputEscaping "Older &#187;"
			    }
			}
			t -disableOutputEscaping "&nbsp;"
		    }
		    h1 -style "background:#344760;" { t -disableOutputEscaping "&nbsp;" }
		}]
	p -clear both
	br

if { $edition eq {World.Europe.Cyprus} } {
	set country "google_country=\"cy\";"
} elseif { $edition eq {World.Europe.Greece} } {
	set country "google_country=\"gr\";"
} else {
	set country ""
}
if {!$debug_p} {
	    center {
		div -style "padding:5 5 5 5;border:1px dashed \#efefef;" {
		t -disableOutputEscaping [subst -nobackslashes -nocommands {
		    <script type="text/javascript"><!--
google_language = 'en';
google_encoding = 'utf-8';
$country
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
	    }
}
#		t -disableOutputEscaping [$navigationNode asHTML]
#p -clear both
set comment {
		p
		i { t "Breaking News" }
		p
		a -style "color:green;font-weight:bold;" -href "http://abcnews.go.com/" {
		    t "ABC"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://english.aljazeera.net/" {
		    t "Al Jazeera"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.nytimes.com/pages/aponline/news/index.html" {
		    t "AP"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://news.bbc.co.uk/" {
		    t "BBC"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.cbc.ca/" {
		    t "CBC"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.cbsnews.com/" {
		    t "CBS"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.cebil.gr/" {
		    t "CeBIL.gr"
		}
		t " / "

		a -style "color:green;font-weight:bold;" -href "http://www.cnn.com/" {
		    t "CNN"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.foxnews.com/" {
		    t "Fox News"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://news.google.com/" {
		    t "Google News"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.msnbc.msn.com/" {
		    t "MSNBC"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.npr.org/" {
		    t "NPR"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://today.reuters.com/" {
		    t "Reuters"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://news.yahoo.com/" {
		    t "Yahoo! News"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://cbs.marketwatch.com/news/default.asp?siteid=mktw&avatar=seen" {
		    t "CBSMarkets"
		}
		p
		i { t "Newspapers" }
		p
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.chicagotribune.com/" {
		    t "Chicago Tribune"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.theglobeandmail.com/" {
		    t -disableOutputEscaping "Globe & Mail"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://www.guardian.co.uk/" {
		    t "Guardian"
		}
		t " / "
		a -style "color:green;font-weight:bold;" -href "http://observer.guardian.co.uk/" {
		    t "Observer"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://news.independent.co.uk/" {
		    t "The Independent"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.ft.com/" {
		    t "Financial Times"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.moscowtimes.ru/" {
		    t "Moscow Times"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.nytimes.com/" {
		    t "New York Times"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.usatoday.com/" {
		    t "USA Today"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.washingtonpost.com/" {
		    t "Washington Post"
		}
		p
		i { t "Magazines" }
		p
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://harvardbusinessonline.hbsp.harvard.edu/b01/en/hbr/hbr_home.jhtml" {
		    t "HBR"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://money.cnn.com/magazines/fortune/" {
		    t "Fortune"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.economist.com/" {
		    t "The Economist"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.salon.com/" {
		    t "Salon"
		}
		t " / "

		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.sciam.com/page.cfm?section=currentissue" {
		    t "Scientific American"
		}
		t " / "
		a -style "color:green;font-weight:bold;white-space:nowrap;" -href "http://www.wired.com/news/" {
		    t "Wired"
		}
		p
		i { t "Miscellaneous" }
		p
		a -style "color:green;font-weight:bold;" -href "http://www.ananova.com/" {
		    t "Ananova"
		}
}

	    }

	    div -style "width:265;margin-left:685;padding:8;border-left: 2px solid #efefef;" {
		if { [exists_and_not_null q] } {
		    if { ![$newsdata emptyset_p] } {
			t "([format "%.2f" ${search_duration}] seconds)"
			p
			b { t "Order by: " }
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
			p
		    }
		}

#	        img -src http://www.phigita.net/graphics/testing.gif



	t \[
	a -class fl -href [export_vars -url -base .. -no_empty {offset host topic edition cluster}] {
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
	a -class fl -href "classification/" {
	    t "Categories"
	}
	t \]
	p

eval {

    $clusterList load

    center { h2 -style "margin-top:0;margin-bottom:5;background:#666666;color:white;" { t [_ News News el] } }
    div -class "little" {
	t -disableOutputEscaping "Aggregated ts_headlines of <b>Greek News</b> sources. Topics are updated continuously throughout the day, so you will see new stories each time you check the page."
	t "The selection and placement of stories were determined automatically by a computer program."
    }
	p
	t "Contact: "	
	img -src /graphics/53dab96f0fd8087a4110eb0174b4cfbb.png
    p
    div -class cluster {
	ul {
	    set count 0
	    set prev_topic_sk ""
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
		set topic_sk [string map {_ .} [lindex $cluster_sk_parts 0]]
		set edition_sk [string map {_ .} [lindex $cluster_sk_parts 1]]
		set topic_sk_part [lindex [split $topic_sk .] 0]
		set edition_sk_part [lindex [split $edition_sk .] end]
		
		if { $topic_sk ne $prev_topic_sk } {
		    set prev_topic_sk $topic_sk
		    a -href [export_vars -url -base $base -override [list [list topic $topic_sk]]] -style "color:black;display:block;font-size:14px;font-weight:bold;padding:5;margin:15 0 0 0;background:#eeeeee;border-top:2px solid $background($topic_sk_part);" { t -disableOutputEscaping "[mc news.topic.$topic_sk $topic_sk_part]&nbsp;&raquo;" }
		} else {
		    div -class separator
		}

		
		li {
		    if { [$cluster set image_file] ne {} } {
			set imageFile [$cluster set image_file]-sample-80x80.jpg
			if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
			    foreach {width height} ${image_size} break
			    img -src "/images/[$cluster set image_file]" -width $width -height $height -align right
			}
		    }
		    set comment {		    
			span -class classificationBar {
			    a -href [export_vars -url -base $base -override [list [list edition $edition_sk]]] {
				t "[mc news.edition.$edition_sk $edition_sk_part]"
			    }
			    t ": "
			    a -href [export_vars -url -base $base -override [list [list topic $topic_sk] [list edition $edition_sk]]] {
				t "[mc news.topic.$topic_sk $topic_sk_part]"
			    }
			}
		    br
		    }
		    a -class clusterHead -href "ct?s=[ns_sha1 [$cluster set head_url]]" -title [$cluster set head_title] {
			t "[::textutil::adjust [string range [$cluster set head_title] 0 144] -length 14 -strictlength t]"
		    }
		    t -disableOutputEscaping " &nbsp; "
		    span -style "font-size:10px;" {
			    t [string range [$cluster set head_summary] 0 144]
		    }
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
			a -href "cluster-disable?cluster_sk=[$cluster set cluster_sk]" {
			    t "\[disable\]"
			}
			br
		    }
		}
		incr count
	    }
	}
    }
}


}
}

