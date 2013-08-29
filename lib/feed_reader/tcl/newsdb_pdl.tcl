::persistence::define_ks "newsdb"

foreach column_family {

    news_item
    news_item/by_const_and_date
    news_item/by_urlsha1_and_const
    news_item/by_urlsha1_and_contentsha1
    news_item/by_site_and_date

    content_item
    content_item/by_contentsha1_and_const

    error_item/by_urlsha1_and_timestamp

    index
    index/contentsha1_to_label
    index/contentsha1_to_urlsha1
    index/urlsha1_to_date_sk

    classifier
    classifier/model
    classifier/el.utf8.edition
    classifier/el.utf8.topic
    classifier/el.utf8.priority
    classifier/el.utf8.type



} {
    ::persistence::define_cf "newsdb" ${column_family}
}


::persistence::define_ks "crawldb"

foreach column_family {

    sync_info/by_urlsha1_and_const
    round_stats/by_timestamp_and_const
    feed_stats/by_feed_and_const
    feed_stats/by_feed_and_period

} {
    ::persistence::define_cf "crawldb" ${column_family}
}
