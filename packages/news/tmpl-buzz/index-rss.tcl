#source [acs_root_dir]/packages/persistence/tcl/rss-procs.tcl


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

if { $offset > 100 } {
	rp_returnnotfound
	return
}


set tsQueryDict [default_text_search_config]
#set tsQueryDict simple



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

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]


set base http://buzz.phigita.net/



set limit 25
set storydata [::db::Set new \
		   -pool newsdb \
		   -alias story \
		   -select "title {'http://buzz.phigita.net/ct?s='||url_sha1 as link} {'http://buzz.phigita.net/ct?s='||url_sha1 as guid} {to_char(creation_date,'Dy, DD Mon YYYY HH24:MI:SS TZ') as pubdate} {substr(last_crawl_content,0,275) as description}" \
		   -type ::sw::agg::Url \
		   -where [list "buzz_p" "language='el'"] \
		   -order "creation_date desc" \
		   -offset ${offset} \
		   -limit [expr 1+${limit}] -noinit]


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
    set base ${base}tag/${tag}
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




set endRange 275 ;#  144
if { [exists_and_not_null q] } {

	set firstindex [string first {=} ${q}]
	set directive [string tolower [string range ${q} 0 ${firstindex}]]
	set subQuery [string trimleft [string range ${q} ${firstindex} end] { =}]

	if {${directive} eq {tag=} } {
	    ad_returnredirect [export_vars -base ${base}/tag/$subQuery]
	    return
	}

	set q [string map {- { } {(} {} {)} {} : { } ' {} {/} {} | {} & {} ! {} ~ {}} ${q}]

	set conn [${storydata} getConn]
	set tsQuery [${conn} getvalue "select to_tsquery('${tsQueryDict}',[ns_dbquotevalue [join ${q} {&}]])"]
	set tsQuery [string trim [string map {{'} { }} $tsQuery]]

    if { ${tsQuery} ne {} } {

	set tsTableName xo.xo__buzz_in_greek
	#set tsTableName xo.xo__buzz_in_greek_static

	
	#set tsQuery [string map {' { } {|} {&}} [string trim ${tsQuery}]]

	#	set tsQuery [regsub -all -- {([\|] [^ ] )} __dummy__ {}]
	set tsQuery [ns_dbquotevalue ${tsQuery}]::tsquery

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
	${storydata} unset offset
	${storydata} unset limit

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




set title "${queryTitle} [mc Buzz "Buzz"] - [mc monitor_syndicated_content "Greek Blogs"] ${page_subtitle}"

set rss_feed_url [export_vars -url -base http://buzz.phigita.net/$base -no_empty -override [list [list output rss]] {q host tag}]






${storydata} mixin add ::rss::Channel
${storydata} title ${title}
${storydata} link ${base}
${storydata} description ""
${storydata} language el
### ${storydata} css_link http://buzz.phigita.net/css/rss.css

doc_return 200 text/xml [${storydata} asRSS]













