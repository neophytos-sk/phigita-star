if { ![setting_p "tree"] } {
    return
}

namespace eval ::persistence::tree {

    namespace import ::persistence::common::typeof_oid
    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::join_oid

}

proc ::persistence::tree::init {parent_oid} {
    set varname __tree_${parent_oid}__
    variable $varname
    array set $varname [list]
}

proc ::persistence::tree::insert {parent_oid oid data xid codec_conf} {
    set varname __tree_${parent_oid}__
    variable $varname

    array set $varname [list $oid ""]

}

proc ::persistence::tree::exists_p {parent_oid oid} {
    set varname __tree_${parent_oid}__
    variable $varname
    return [info exists ${varname}($oid)]

}

proc ::persistence::tree::dump {{parent_oid ""}} {}

