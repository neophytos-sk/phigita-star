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

        by_reversehost {
            type "index"
            atts "reversehost"
        }

    }

    variable att
    array set att {
        urlsha1 {
            type "sha1_hex"
        }

        url {}
        content {}

        scheme {}
        host {
            null "0"
        }
        port {}
        path {}
        query {}
        fragment {}

        reversehost {
            null "0"
            func {{itemVar} {
                upvar $itemVar item
                reversedotted $item(host)
            }}
        }

    }

    variable aggregates
    array set aggregates [list]

}

::webdb::web_page_t init_type
