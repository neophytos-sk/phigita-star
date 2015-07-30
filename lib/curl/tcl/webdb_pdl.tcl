# webdb {
#     web_page {
#         by_urlsha1
#     }
# }

namespace eval ::webdb::web_page_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "webdb"
    variable cf "web_page"
    variable pk "urlsha1"

    variable idx
    array set idx {

        by_urlsha1 {
            type "unique_index"
            atts "urlsha1"
            tags "all"
        }

    }

    variable att
    array set att {
        urlsha1 {
            type "sha1_hex"
        }
        url {}
        content {}
    }

    variable aggregates
    array set aggregates [list]

}

::webdb::web_page_t init_type




