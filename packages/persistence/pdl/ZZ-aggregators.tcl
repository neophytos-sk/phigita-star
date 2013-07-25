###########################
### ::user::aggregator   ##
###########################

namespace eval ::user::agg {;}
DB_Class ::user::agg::Object -lmap mk_attribute {
    {Integer object_id}
    {Integer class_id}
} -lmap mk_like {
    ::auditing::Auditing
} -lmap mk_index {
    {Index class_id -cluster_p yes}
}

###########################
### ::sw::aggregator   ##
###########################

namespace eval ::sw::agg {;}


DB_Class ::sw::agg::Most_Recent_Objects -is_final_if_no_scope "1" -lmap mk_attribute {
    {Integer   object_id}
    {Integer   class_id}
    {Integer   root_class_id}
    {Integer   root_object_id}
} -lmap mk_like {
    ::content::Title
    ::content::Content
    ::sharing::Flag_with_Start_Date
} -lmap mk_index {
    {Index class_id -cluster_p yes}
    {Index sharing_start_date}
    {Index shared_p}
    {Index obj_idx -subject {
	root_class_id
	root_object_id
	class_id 
	object_id} -isUnique yes}
}

DB_Class ::sw::agg::Url -is_final_if_no_scope "1" -lmap mk_attribute {
    {String url_sha1 -maxlen 40}
    {String url_host_sha1 -maxlen 40}
    {String url}
    {String language -maxlen 2}
    {String feed_url_sha1 -maxlen 40 -isNullable yes}
    {String channel_url_sha1 -maxlen 40 -isNullable yes}
    {Integer cnt_clickthroughs -default 0}
    {Integer cnt_unread -default 0}
    {Integer cnt_favorite -default 0}
    {Integer cnt_shared -default 0}
    {Integer cnt_sticky -default 0}
    {Integer cnt_subscribe -default 0}
    {Integer cnt_adult -default 0}
    {Integer cnt_users -default 0}
    {Integer cnt_cache -default 0}
    {Integer cnt_interesting -default 0}
    {Integer cnt_comment -default 0}
    {Timestamptz max_sharing_start_date -isNullable yes -default NULL}
    {Integer max_sharing_user_id -isNullable yes}
    {Intarray  label_crc32_arr -default "'{}'"}
    {Interval crawl_interval -isNullable no -default "'1 week'::interval"}
    {Timestamp last_crawl -isNullable yes -default null} 
    {String last_crawl_content -isNullable yes}
    {String last_crawl_sha1 -maxlen 40 -isNullable yes}
    {Boolean feed_p -default 'f'}
    {Boolean buzz_p -isNullable yes}
    {Integer classification__class_id -isNullable yes}
    {Boolean train_topic_p -isNullable no -default 'f'}
    {Boolean train_edition_p -isNullable no -default 'f'}
    {Boolean permanent_train_p -isNullable no -default 'f'}
    {Timestamp score}
    {String guard}
    {String image_file}
    {String tags}
    {String anchor_list}
    {String object_list}
    {LTree classification__tree_sk -isNullable yes}
    {LTree classification__edition_sk -isNullable yes}
    {LTree clustering__cluster_sk -isNullable yes}

    {Boolean video_p -isNullable no -default 'f'}
    {Boolean preview_p -isNullable no -default 'f'}
    {TclDict extra -isNullable yes}

} -lmap mk_like {
    ::content::Title
    ::content::Description
    ::auditing::Auditing
} -lmap mk_index {
    {Index url -isUnique yes}
    {Index url_sha1}
    {Index max_sharing_start_date}
    {Index channel_url_sha1}
    {Index feed_url_sha1}
    {Index last_crawl_pl_crawl_interval -subject "timestamp_pl_interval(last_crawl,crawl_interval)"}
    {Index feed_p}
    {Index buzz_p}
}


#    {String    r_url -isNullable yes}
#    {String    r_url_sha1 -maxlen 40 -isNullable yes}
#    {String    r_url_host_sha1 -maxlen 40 -isNullable yes}

DB_Class ::sw::agg::Url_User_Map -lmap mk_attribute {
    {String    url_sha1 -maxlen 40}
    {String    url_host_sha1 -maxlen 40}
    {Integer   user_id}
    {Timestamptz sharing_start_date}
    {Boolean   shared_p}
    {String    snippet -maxlen 1000 -isNullable yes}
    {Intarray  label_crc32_arr -default '{}'}
} -lmap mk_like {
    ::content::Title
    ::content::Description
} -lmap mk_partition {
    {Partition=HASH_TEXT url_host_sha1}
} -lmap mk_index {
    {Index url_sha1}
    {Index url_host_sha1}
    {Index label_crc32_arr}
    {Index url_user -subject "url_sha1 user_id" -isUnique yes}
}





DB_Class ::sw::agg::Url_Label -lmap mk_attribute {
    {Integer cnt_users}
} -lmap mk_like {
    ::content::Name
    ::content::Name_CRC32
}


DB_Class ::sw::agg::Blog_Stats -is_final_if_no_scope "1" -lmap mk_attribute {
    {Integer   user_id -isNullable no}
    {Integer   cnt_entries -isNullable no -default 0}
    {Integer   cnt_shared_entries -isNullable no -default 0}
    {Timestamptz last_entry -isNullable yes -default current_timestamp}
    {Timestamptz last_shared_entry -isNullable yes -default null}
    {HStore extra -isNullable yes}
} -lmap mk_index {
    {Index user_id -isUnique yes}
    {Index last_shared_entry}
    {Index extra}
}




