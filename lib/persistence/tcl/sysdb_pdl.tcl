namespace eval ::sysdb::object_type_t {

    # see core/tcl/namespace.tcl for details about "mixin" namespaces
    namespace __mixin ::persistence::orm

    variable ks "sysdb"
    variable cf "object_type"
    variable pk "nsp"

    variable indexes
    array set indexes {

        by_nsp {
            type "unique_index"
            atts "nsp"
            tags "summary"
        }

    }

    variable attributes
    array set attributes {
        nsp {
            datatype "sysdb_namespace"
        }
        ks {}
        cf {}
    }

    variable aggregates
    array set aggregates [list]

}

::sysdb::object_type_t init_type
