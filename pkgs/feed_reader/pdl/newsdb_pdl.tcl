set dir [file dirname [info script]]
::persistence::load_type_from_file [file join $dir newsdb.news_item_t.pdl]
::persistence::load_type_from_file [file join $dir newsdb.content_item_t.pdl]
::persistence::load_type_from_file [file join $dir newsdb.error_item_t.pdl]

# index {
#     contentsha1_to_label
#     contentsha1_to_urlsha1
#     urlsha1_to_date_sk
# }

foreach {ks spec} {

    newsdb {
        classifier {
            model
        }

        train_item {
            default
        }
    }

    crawldb {
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
            ::persistence::define_cf $ks ${column_family}.${axis}
        }
    }
}

#    train_item/el
#    train_item/el/edition
#    train_item/el/topic
#    train_item/el/priority
#    train_item/el/type

