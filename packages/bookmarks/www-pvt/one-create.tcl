ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
    title:trim,notnull,allhtml
    snippet:trim,allhtml
    description:trim,allhtml
    shared_p:boolean
    unread_p:boolean
    favorite_p:boolean
    interesting_p:boolean
    sticky_p:boolean
    subscribe_p:boolean
    cache_p:boolean
    adult_p:boolean
    {edit_p:boolean,notnull "0"}
    {feed:trim,allhtml,multiple ""}
    {referrer:trim ""}
    {attach:multiple ""}
}

#    {label:multiple ""}

#ns_log notice "edit_p=$edit_p"

set v_url [::uri::canonicalize ${url}]
set v_feed ""

set v_feed_url_sha1 ""
if {[exists_and_not_null feed]} {
    set v_feed [::uri::canonicalize [uri::resolve ${v_url} [::util::striphtml ${feed}]]]
    set v_feed_url_sha1 [ns_sha1 ${v_feed}]
}
set v_referrer ""
if {[exists_and_not_null referrer]} {
    if {![string equal ${referrer} "http:///"]} {

    }
	set v_referrer [::uri::canonicalize ${referrer}]
}

set extra [dict create]
set video_p f
if { [::util::videoIf $v_url href video_id] } {
    lassign [::xo::buzz::getVideo $video_id] found_p vo
    if { $found_p } {
	set video_p t
	dict set extra video_id $video_id
    }
}

set preview_p f
if { $attach ne {} } {
    set preview_p t
    dict set extra preview [lsort -unique $attach]
}



#ns_log notice "Feed: $v_feed"

array set uri [uri::split ${v_url}]
set url_host_sha1 [ns_sha1 $uri(host)]
set url_sha1 [ns_sha1 ${v_url}]

set peeraddr [ad_conn peeraddr]
set user_id [ad_conn user_id]
set pathexp [list "User ${user_id}"]

set o [bm::Bookmark new \
	   -mixin ::db::Object \
	   -pathexp ${pathexp} \
	   -set feed_url ${v_feed} \
	   -set feed_url_sha1 ${v_feed_url_sha1} \
	   -set r_url ${v_referrer} \
	   -url ${v_url} \
	   -title ${title} \
	   -snippet ${snippet} \
	   -description ${description} \
	   -shared_p ${shared_p} \
	   -unread_p ${unread_p} \
	   -starred_p ${favorite_p} \
	   -interesting_p ${interesting_p} \
	   -sticky_p ${sticky_p} \
	   -subscribe_p ${subscribe_p} \
	   -cache_p ${cache_p} \
	   -adult_p ${adult_p} \
	   -video_p ${video_p} \
	   -preview_p ${preview_p} \
	   -extra $extra \
	   -cnt_clickthroughs 1 \
	   -creation_user ${user_id} \
	   -creation_ip ${peeraddr} \
	   -modifying_ip ${peeraddr} \
	   -modifying_user ${user_id}]



${o} beginTransaction
if { $edit_p } {
    ${o} rdb.self-load -pk url -select id
    ${o} rdb.self-update "url=[ns_dbquotevalue $v_url]"
    ::xo::db::touch main.xo.xo__sw__agg__url
} else {
    ${o} rdb.self-id
    ${o} rdb.self-insert
}

set bookmark_id [${o} set id]



if { [exists_and_not_null label] } {

    foreach label_id ${label} {

	if {![string is integer ${label_id}]} continue;

	set label_map [::bm::Label_Map new \
			   -mixin ::db::Object \
			   -pathexp ${pathexp} \
			   -bookmark_id ${bookmark_id} \
			   -label_id ${label_id} \
			   -set url ${v_url}]

	${label_map} rdb.self-insert {select true;}
    }

    set label [::bm::Label new -mixin ::db::Object -pathexp ${pathexp}]
    set conn1 [${label_map} getConn]
    set sql1 "select int_array_aggregate(la.name_crc32) from [${label} info.db.table] la,[${label_map} info.db.table] lm where la.id=lm.label_id and bookmark_id=[ns_dbquotevalue ${bookmark_id}]"
    ns_log notice ${sql1}
    set label_crc32_arr [${conn1} getvalue ${sql1}]

    set comment {
	if {[${o} set shared_p]} {
	    set swu [::sw::agg::Url new -mixin ::db::Object -url_host_sha1 ${url_host_sha1}]
	    set conn2 [${swu} getConn]
	    set sql2 "update [${swu} info.db.table] set label_crc32_arr=sort_asc([ns_dbquotevalue ${label_crc32_arr}]) where url=[ns_dbquotevalue ${v_url}]"
	    ns_log notice ${sql2}
	    ${conn2} do ${sql2}
	}
    }

    set uum [::sw::agg::Url_User_Map new -mixin ::db::Object -url_host_sha1 ${url_host_sha1}]
    set conn3 [${uum} getConn]
    set sql3 "update [${uum} info.db.table] set label_crc32_arr=sort_asc([ns_dbquotevalue ${label_crc32_arr}]) where user_id=[ns_dbquotevalue ${user_id}] and url_sha1=[ns_dbquotevalue ${url_sha1}]"
    ns_log notice ${sql3}
    ${conn3} do ${sql3}
}


${o} endTransaction

set json [::util::map2json status ok message "Bookmark has been saved"]
doc_return 200 text/plain $json


# set response [list]
# lappend response "OK: 1"
# lappend response "Info-Text: Bookmark has been saved"
# doc_return 200 text/plain [join ${response} \n]
