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

    train_item
    train_item/el
    train_item/el/edition
    train_item/el/topic
    train_item/el/priority
    train_item/el/type



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
