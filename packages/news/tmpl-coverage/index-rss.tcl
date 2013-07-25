require_html_procs
ad_page_contract {
    @author Neophytos Demetriou
} {
    host:trim,optional    
    q:trim,optional
    {order_by:trim "date"}
    {topic:trim,optional ""}
    {edition:trim,optional ""}
}

set order "creation_date"
switch -exact -- ${order_by} {
    {date} {
	set order "creation_date"
    }
    {rank} {
	set order "rank"
    }
}


set offset 0
set limit 10
set base http://news.phigita.net/

set newsdata [::db::Set new -pool newsdb -mixin ::rss::Channel -alias story -select "title {'http://news.phigita.net/ct?s='||url_sha1 as link} {'http://news.phigita.net/ct?s='||url_sha1 as guid} {to_char(creation_date,'Dy, DD Mon YYYY HH24:MI:SS TZ') as pubdate}" -from "xo.xo__sw__agg__url u" -where [list "NOT buzz_p" "NOT feed_p" "language='el'" "title is not null" "creation_date > current_timestamp-'1 month'::interval"] -order "creation_date desc" -offset ${offset} -limit ${limit} -noinit]

set page_subtitle ""


if { ${edition} ne {} } {

    ${newsdata} lappend where "classification__edition_sk = [ns_dbquotevalue ${edition}]"
    lappend page_subtitle "[mc news.topic.${edition} [lindex [split $edition .] end]]"
}
if { ${topic} ne {} } {

    ${newsdata} lappend where "classification__tree_sk <@ [ns_dbquotevalue ${topic}]"
    lappend page_subtitle "[mc news.topic.${topic} $topic]"
}



if { [exists_and_not_null host] } {
    set no_www_host [regsub -- {^www\.} ${host} {}]
    set url_host_sha1 [ns_sha1 ${host}]
    ${newsdata} lappend where "url_host_sha1=[ns_dbquotevalue ${url_host_sha1}]"
    lappend page_subtitle "from source ${no_www_host}"
    append base "?host=${host}"
}




if { [exists_and_not_null q] } {
	set q [string map {' {} | {} & {} ! {} ~ {}} ${q}]

	set conn [${newsdata} getConn]
	set tsQuery [${conn} getvalue "select to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]])"]

	if { ${tsQuery} ne {} } {

	    set endRange end
#	    ${newsdata} unset type
	    ${newsdata} from "xo.xo__sw__agg__url u inner join (select url,ts_vector,q,rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__news_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where url in (select url from (select url, rank_cd('{0.1,0.2,0.4,1.0}'::real\[\],ts_vector,q,1|4) as rank from xo.xo__news_in_greek, to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q where ts_vector @@ q order by $order desc offset ${offset} limit [expr {${limit}+1}]) u)) r on (u.url=r.url)"

	    ${newsdata} lappend select "ts_headline('[default_text_search_config]',last_crawl_content,q,'MaxWords=45, MinWords=35') as description"
	    ${newsdata} lappend select "ts_headline('[default_text_search_config]',title,q) as title"

	    ${newsdata} order "$order desc"
	    ${newsdata} unset offset
	    ${newsdata} unset limit

#	$newsdata init
#	    ns_log notice [$newsdata set sql]
	    ${newsdata} load
	} else {
		# do nothing, empty set of results
	}
	set queryTitle "${q} - "
} else {
    ${newsdata} lappend select {substr(last_crawl_content,0,144) as description}
$newsdata init
    ns_log notice "[$newsdata set sql]"

    ${newsdata} load
	set queryTitle ""
}

set title "${queryTitle} [mc News "News in Greek"][util::decode ${page_subtitle} "" "" " - "][join ${page_subtitle} " - "]"


${newsdata} title ${title}
${newsdata} link ${base}
${newsdata} description ""
${newsdata} language el

#${newsdata} load
doc_return 200 text/xml [${newsdata} asRSS]