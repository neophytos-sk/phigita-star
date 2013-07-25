set buzz_url http://buzz.phigita.net/
set buzz_offset 0
set storydata [::db::Set new \
		   -pool newsdb \
		   -alias story \
		   -select "* {substr(last_crawl_content,0,222) as last_crawl_content}" \
		   -type ::sw::agg::Url \
		   -where [list "buzz_p" "language='el'"] \
		   -order "creation_date desc" \
		   -offset ${buzz_offset} \
		   -limit [expr 1+${limit}] \
		   -noinit]

set tsQueryDict [default_text_search_config]
set order creation_date
set limitTags 25
set tag Βιβλια

### HERE: REVISIT THIS ISSUE - SEARCH BUZZ FOR BOOK SEARCH QUERIES
if { [exists_and_not_null tag] } {
    set buzz_url http://buzz.phigita.net/tag/${tag}

    set conn [$storydata getConn]

    set tsTagsQueryDict simple
    set tsTagsQuery [${conn} getvalue "select to_tsquery('${tsTagsQueryDict}',[ns_dbquotevalue [join ${tag} {&}]])"]
    set tsTagsQuery [string trim [string map {{'} { }} $tsTagsQuery]]
    if { $tsTagsQuery ne {} } {


	$storydata unset type

	set tsTagsQuery [ns_dbquotevalue $tsTagsQuery]::tsquery
	#set tsLimit [expr { 1 + ${limit} }]
	set tsLimit 5
	set tsTableName1 xo.xo__buzz__tags_gist
	set tsTableName2 xo.xo__buzz__tags_index
	if { 1 || $order eq {creation_date} } {

	    set query1 "(select *  from ${tsTableName1} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${buzz_offset})"
	    set query2 "(select *  from ${tsTableName2} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${buzz_offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from (${query1} union all ${query2}) qq order by qq.creation_date desc offset ${buzz_offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from ${query1} qq order by qq.creation_date desc offset ${buzz_offset} limit ${tsLimit}) r on (u.url=r.url)"
	    ###${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector from ${query2} qq order by qq.creation_date desc offset ${buzz_offset} limit ${tsLimit}) r on (u.url=r.url)"



	} else {

	    set query1 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],tags_ts_vector,${tsTagsQuery},1|4) as rank from ${tsTableName1} where tags_ts_vector @@ ${tsTagsQuery} order by rank desc limit $tsLimit offset ${buzz_offset})"
	    set query2 "(select *, ts_rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],tags_ts_vector,${tsTagsQuery},1|4) as rank  from ${tsTableName2} where tags_ts_vector @@ ${tsTagsQuery} order by creation_date desc limit $tsLimit offset ${buzz_offset})"
	    ${storydata} from "xo.xo__sw__agg__url u inner join (select url,tags_ts_vector,rank from (${query1} union all ${query2}) qq order by rank desc offset ${buzz_offset} limit ${tsLimit}) r on (u.url=r.url)"

	}
	###$storydata init
	####ns_log notice "tagsTsQuery SQL= [$storydata set sql]"



	### $storydata lappend where "tags_ts_vector @@ $tsQuery"
	#	set q [concat $q $tag]
	set conn [$storydata getConn]
	#set related_tags [$conn query "select rule_head from xo.xo__buzz_related_tags where rule_size=[llength $tag] and rule_ts_vector @@ $tsTagsQuery order by confidence desc limit 5"]

	#set popularTags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1+[llength [string map {{_} { }} $tag]] and itemset_ts_vector @@ $tsTagsQuery order by occurrence desc limit $limitTags"]

	append queryTitle "$tag - "
	lappend subtitle "<b>Tag:</b> <a href=$tag style=\"color:green\">$tag</a>"
	#    set searchQuery [concat "tag=$tag" $searchQuery]
    } else {
        # do nothing 
    }


} else {

    #set conn [$storydata getConn]	
    #set popularTags [$conn query "select occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1 order by occurrence desc limit $limitTags"]
}



${storydata} load


