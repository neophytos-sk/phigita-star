foreach {ks spec} {

    web_cache_db {
        web_page {
            by_domain
        }
    }

    newsdb {
        news_item {
            by_const_and_date
            by_urlsha1_and_const
            by_urlsha1_and_contentsha1
            by_site_and_date
            by_langclass
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
    }

    crawldb {
        sync_info {
            by_urlsha1_and_const
        }
        round_stats {
            by_timestamp_and_const
        }
        feed_stats {
            by_feed_and_const
            by_feed_and_period
        }
    }

} {

    ::persistence::define_ks $ks

    foreach {column_family axis_list} ${spec} {
        foreach axis $axis_list {
            ::persistence::define_cf $ks ${column_family}/${axis}
        }
    }
}

#    train_item/el
#    train_item/el/edition
#    train_item/el/topic
#    train_item/el/priority
#    train_item/el/type

