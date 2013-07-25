namespace eval ::buzz {;}
DB_Class ::buzz::Feed -lmap mk_attribute {
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
    {Boolean active_p -isNullable no -default 'f'}
    {Boolean use_feed_body_p -default 'f'}
    {Timestamp score}
    {String guard}
    {String image_file}
    {String tags}
    {String anchor_list}
    {String object_list}
    {LTree classification__tree_sk -isNullable yes}
    {LTree classification__edition_sk -isNullable yes}
    {LTree clustering__cluster_sk -isNullable yes}
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
