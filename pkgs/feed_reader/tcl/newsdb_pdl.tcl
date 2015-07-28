# derived_attribute id creates a table with the given attributes
# and a third one that is the application of the fn for the given
# attributes.
# {derived_attribute id --datatype sha1_hex --fn_args {reversedomain url} --fn sha1_hex --fn_alternative serial_int --pk }

namespace eval ::newsdb::news_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "newsdb"
    variable cf "news_item"
    variable pk "urlsha1"

    variable indexes
    array set indexes {

        by_urlsha1 {
            type "unique_index"
            atts "urlsha1"
            tags "all"
        }

        by_domain {         
            type "index"
            atts "reversedomain"
            tags "summary"
        }

        by_langclass {
            type "index"
            atts "langclass"
            tags "summary"
        }

        by_contentsha1 {
            type "unique_index"
            atts "contentsha1"
            tags "summary"
        }

        by_sort_date {
            type "index"
            atts "sort_date"
            tags "summary"
        }

    }

    variable attributes
    array set attributes {
        urlsha1 {
            datatype "sha1_hex"
        }
        contentsha1 {
            datatype "sha1_hex"
        }
        site {}
        date {}
        langclass {
            datatype "langclass"
        }
        url {
            datatype "url"
        }
        title {
            datatype "text"
        }
        body {
            datatype "text"
        }

        first_sync {}
        last_sync {}
        is_revision_p {}
        is_copy_p {}

        timestamp {}
        date {}
        sort_date {}

        domain {}
        reversedomain {}
    }

    variable aggregates
    array set aggregates [list]

}

::newsdb::news_item_t init_type

namespace eval ::newsdb::content_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    namespace ensemble create -subcommands {
        to_path
        from_path
        insert
        find
        find_by
        init_type
    }

    variable ks "newsdb"
    variable cf "content_item"
    variable pk "contentsha1"

    variable indexes
    array set indexes {

        by_contentsha1 {
            type "unique_index"
            atts "contentsha1"
            tags "all"
        }

    }

    variable attributes
    array set attributes {
        contentsha1 {
            datatype "sha1_hex"
            validate "notnull"
        }
        title {
            datatype "text"
            validate "notnull"
        }
        body {
            datatype "text"
            validate "notnull"
        }
    }

    variable aggregates
    array set aggregates [list]

    
}

::newsdb::content_item_t init_type

namespace eval ::newsdb::error_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    namespace ensemble create -subcommands {
        to_path
        from_path
        insert
        find
        find_by
        init_type
    }

    variable ks "newsdb"
    variable cf "error_item"
    variable pk "urlsha1_timestamp"

    variable indexes
    array set indexes {

        by_urlsha1 {
            type "index"
            atts "urlsha1"
            tags "all"
        }

        by_urlsha1_timestamp {
            type "unique_index"
            atts "urlsha1 timestamp"
            tags "all"
        }

    }

    variable attributes
    array set attributes {
        urlsha1 {
            datatype "sha1_hex"
            validate "notnull"
        }
        timestamp {
            datatype "timestamp"
            validate "notnull"
        }
        urlsha1_timestamp {
            datatype "sha1_hex timestamp"
            validate "notnull"
        }
        body {
            datatype "text"
            validate "notnull"
        }
        errorcode {
            datatype "integer"
        }
        url {
            datatype "url"
        }
        http_fetch_info {
            validate "key_value_map"
        }
        title_in_feed {
            datatype "text"
        }
        item {
            validate "key_value_map"
        }
    }

    variable aggregates
    array set aggregates [list]

}

::newsdb::error_item_t init_type


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

