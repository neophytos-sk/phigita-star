#source /web/service-phigita/packages/persistence/pdl/ZZ-aggregators.tcl

ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
    {guard:trim ""}
    {classification__edition_sk ""}
}

set peeraddr [ad_conn peeraddr]
set user_id [ad_conn user_id]

set v_url [::uri::canonicalize ${url}]
array set uri [uri::split ${v_url}]
set url_host_sha1 [ns_sha1 $uri(host)]
set url_sha1 [ns_sha1 ${v_url}]


set o [::buzz::Feed new \
	   -mixin ::db::Object \
	   -pool newsdb \
	   -url ${v_url} \
	   -url_sha1 ${url_sha1} \
	   -url_host_sha1 ${url_host_sha1} \
	   -feed_p t \
	   -buzz_p t \
	   -last_crawl [::util::sysdate] \
	   -last_crawl_sha1 "" \
	   -crawl_interval "5 min" \
	   -creation_user ${user_id} \
	   -creation_ip ${peeraddr} \
	   -modifying_user ${user_id} \
	   -modifying_ip ${peeraddr} \
	   -guard $guard \
	   -classification__edition_sk $classification__edition_sk \
	   -train_topic_p f \
	   -active_p t \
	   -train_edition_p f]

set jic_sql [subst {
    update [${o} info.db.table] set
    last_crawl=[ns_dbquotevalue [::util::sysdate]]
    ,last_crawl_sha1=null
    ,buzz_p='t'
    ,feed_p='t'
    ,guard=[ns_dbquotevalue $guard]
    ,classification__edition_sk=[ns_dbquotevalue $classification__edition_sk]
    ,train_topic_p='f'
    ,train_edition_p='f'
    where url=[${o} quoted url]
}]


${o} do self-insert ${jic_sql}

ad_returnredirect "feeds-grid"