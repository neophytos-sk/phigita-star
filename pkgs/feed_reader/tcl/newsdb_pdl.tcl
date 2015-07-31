# derived_attribute id creates a table with the given attributes
# and a third one that is the application of the fn for the given
# attributes.
# {derived_attribute id --type sha1_hex --fn_args {reversedomain url} --fn sha1_hex --fn_alternative serial_int --pk }

namespace eval ::newsdb::news_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "newsdb"
    variable cf "news_item"
    #TODO: variable pk "urlsha1_contentsha1" ;# supercolumns for by_urlsha1, by_contentsha1
    variable pk "urlsha1_contentsha1"

    # type ::= indextype
    variable idx
    array set idx {

        by_urlsha1_contentsha1 {
            atts "urlsha1 contentsha1"
            func "list"
            tags "one_to_one unique"
        }

        by_urlsha1 {
            atts "urlsha1"
            tags "all"
            tags "one_to_many"

            comment "one_to_many: same urlsha1 different contentsha1"
            comment "TODO: strategy to resolve conflicts, i.e. which contentsha1 to point to"
            keep "latest"
            comment "keep ::= (latest | all)"
            comment "keep is used to specify which records to return when we query by urlsha1"
            comment "keep belongs elsewhere, maybe in type variables, to resolve mtime conflicts"
            comment "tags is used to specify which attributes to save upon denormalization"
        }

        by_contentsha1 {
            atts "contentsha1"
            tags "one_to_many"

            comment "one_to_many: same contentsha1 different urlsha1"
            comment "TODO: strategy to resolve conflicts, i.e. which urlsha1 to point to"
        }

        by_reversedomain {         
            atts "reversedomain"
            tags "one_to_many"
            comment "one_to_many: many urlsha1 for each reversedomain"
        }

        by_langclass {
            atts "langclass"
            tags "one_to_many"
        }

        by_sort_date {
            atts "sort_date"
            tags "one_to_many"
        }

    }

    #by_ts_vector {
    #    atts "ts_vector"
    #    func "tokenize???"
    #    tags "eventual_consistency"
    #}

    #attribute add urlsha1_contentsha1 --type {sha1_hex_t sha1_hex_t}
    #attribute add urlsha1 --type sha1_hex_t

    # type ::= type
    variable att
    array set att {
        urlsha1_contentsha1 {
            type "sha1_hex sha1_hex"
            func {{itemVar} {
                upvar $itemVar item
                list $item(urlsha1) $item(contentsha1)
            }}
        }
        urlsha1 {
            type "sha1_hex"
        }
        contentsha1 {
            type "sha1_hex"
        }
        langclass {
            type "langclass"
        }
        url {
            type "url"
        }
        title {
            type ""
        }
        body {
            type ""
        }
        is_revision_p {
            type "boolean"
        }
        is_copy_p {
            type "boolean"
        }
        domain {
            type "domain"
        }
        reversedomain {
            type "reversedomain"
        }
        date {
            type "datetime"
            null "true"
            comment "date extracted from article, can be null"
        }
        sort_date {
            type "datetime"
        }


        first_sync {
            type ""
        }
        last_sync {
            type ""
        }
        timestamp {
            type "naturalnum"
        }
        attachment {
            type ""
        }
        tags {
            type ""
        }
        video {
            type ""
        }

        ts_vector {
            type "vector<varchar>"
            TODO_func {{text body} {tokenize [list $text $body]}}
            tags "eventual_consistency"
            null "true"
        }
    }

    variable aggregates
    array set aggregates [list]

}

::newsdb::news_item_t init_type

namespace eval ::newsdb::content_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "newsdb"
    variable cf "content_item"
    variable pk "contentsha1"

    variable idx
    array set idx {

        by_contentsha1 {
            type "unique_index"
            atts "contentsha1"
            tags "all"
        }

    }

    variable att
    array set att {
        contentsha1 {
            type "sha1_hex"
        }
        title {
            type ""
        }
        body {
            type ""
        }
    }

    variable aggregates
    array set aggregates [list]

    
}

::newsdb::content_item_t init_type

namespace eval ::newsdb::error_item_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "newsdb"
    variable cf "error_item"
    variable pk "urlsha1_timestamp"

    variable idx
    array set idx {

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

    variable att
    array set att {
        urlsha1 {
            type "sha1_hex"
            validate "notnull"
        }
        timestamp {
            type "timestamp"
            validate "notnull"
        }
        urlsha1_timestamp {
            type "sha1_hex timestamp"
            validate "notnull"
        }
        body {
            type ""
            validate "notnull"
        }
        errorcode {
            type "integer"
        }
        url {
            type "url"
        }
        http_fetch_info {
            validate "key_value_map"
        }
        title_in_feed {
            type ""
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

