#   crawldb {
#       sync_info {
#           by_urlsha1_and_const
#       }
#       round_stats {
#           by_timestamp_and_const
#       }
#       feed_stats {
#           by_feed_and_const
#           by_feed_and_period
#       }
#   }


namespace eval ::crawldb::sync_info_t {

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

    variable ks "crawldb"
    variable cf "sync_info"
    variable pk "datetime_urlsha1"

    variable indexes
    array set indexes {

        by_datetime_urlsha1 {
            type "unique_index"
            atts "datetime urlsha1"
            tags "all"
        }

        by_urlsha1 {         
            type "index"
            atts "urlsha1"
            tags "all"
        }

        by_datetime {
            type "index"
            atts "datetime"
            tags "all"
        }

    }

    variable attributes
    array set attributes {
        datetime_urlsha1 {
            type "datetime sha1_hex"
            lambda {{datetime urlsha1} {list $datetime $urlsha1}}
            comment "derived attribute from datetime and urlsha1"
        }
        urlsha1 {
            type "sha1_hex"
        }
        datetime {
            type "datetime"
            fmt  "%Y%m%dT%H%M"
        }
    }

    variable aggregates
    array set aggregates [list]

}


::crawldb::sync_info_t init_type

