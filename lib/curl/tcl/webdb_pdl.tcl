# webdb {
#     web_page {
#         by_urlsha1
#     }
# }

namespace eval ::webdb::web_page_t {

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

    variable ks "webdb"
    variable cf "web_page"
    variable pk "urlsha1"

    variable indexes
    array set indexes {

        by_urlsha1 {
            type "unique_index"
            atts "urlsha1"
            tags "all"
        }

    }

    variable attributes
    array set attributes {
        urlsha1 {
            datatype "sha1_hex"
        }
        url {}
        content {}
    }

    variable aggregates
    array set aggregates [list]

}

::webdb::web_page_t init_type




