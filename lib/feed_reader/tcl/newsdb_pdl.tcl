::persistence::define_ks "web_cache_db"
::persistence::define_cf "web_cache_db" "web_page"

::persistence::define_ks "newsdb"

foreach {column_family axis_list} {

    news_item {
        by_const_and_date
        by_urlsha1_and_const
        by_urlsha1_and_contentsha1
        by_site_and_date
    }

    content_item {
        by_contentsha1_and_const
    }

    error_item {
        by_urlsha1_and_timestamp
    }

    index {
        contentsha1_to_label
        contentsha1_to_urlsha1
        urlsha1_to_date_sk
    }

    classifier {
        model
    }

    train_item {
        default
    }
} {
    foreach axis $axis_list {
        ::persistence::define_cf "newsdb" ${column_family}/${axis}
    }
}

#    train_item/el
#    train_item/el/edition
#    train_item/el/topic
#    train_item/el/priority
#    train_item/el/type

::persistence::define_ks "crawldb"

foreach column_family {

    sync_info.by_urlsha1_and_const
    round_stats.by_timestamp_and_const
    feed_stats.by_feed_and_const
    feed_stats.by_feed_and_period

} {
    ::persistence::define_cf "crawldb" ${column_family}
}
