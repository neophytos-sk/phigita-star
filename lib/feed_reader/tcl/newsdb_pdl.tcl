# derived_attribute id creates a table with the given attributes
# and a third one that is the application of the fn for the given
# attributes.
# {derived_attribute id --datatype sha1_hex --fn_args {reversedomain url} --fn sha1_hex --fn_alternative serial_int --pk }

array set ::news_item {
    pk { urlsha1 }
    attributes {
        urlsha1
        contentsha1
        site
        date
        langclass

        url
        title
        body
        first_sync
        last_sync
        is_revision_p
        is_copy_p

        timestamp
        date
        sort_date

        domain
        reversedomain
    }
    indexes {
        {by_urlsha1                  {urlsha1}                  "all"}
        {by_domain                   {reversedomain}            "summary"}
        {by_langclass                {langclass}                "summary"}
        {by_contentsha1              {contentsha1}              "summary"}
        {by_sort_date                {sort_date}                "summary"}
    }
    aggregates {
    }
}

# by_const_and_date
# by_urlsha1_and_const
# by_urlsha1_and_contentsha1
# by_langclass
foreach {ks spec} {

    web_cache_db {
        web_page {
            by_domain
        }
    }

    newsdb {
        news_item {
            by_urlsha1
            by_domain
            by_langclass
            by_contentsha1
            by_sort_date
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

