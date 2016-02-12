if { ![use_p "server"] || ![setting_p "bloom_filters"] } {
    # log "skipped loading of [info script]"
    return
}

namespace eval ::persistence::bloom_filter {

    namespace import ::persistence::common::typeof_oid
    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::join_oid
    namespace import ::persistence::common::split_xid

    variable __bf_TclObj
    variable __bf_dirty

    # helps avoid infinite nested evaluations
    variable __seen
    array set __seen [list]

}

##
# TODO: use dynamic bloom filters
# TODO: or items_estimate from type info (.pdl file)
#
proc ::persistence::bloom_filter::init {parent_oid} {
    variable __bf_TclObj

    set items_estimate 10000
    set false_positive_prob 0.01

    # what kind of parent_oid are we dealing with?
    set type [typeof_oid $parent_oid]

    # bloom filter name
    set name [binary encode base64 [list $type $parent_oid]]

    if { [info exists __bf_TclObj(${name})] } {
        set bytes [::bloom_filter::get_bytes $__bf_TclObj(${name})]
        log "!!! bf already initialized: [llength $bytes] parent_oid=$parent_oid"
        return
    }
    log "!!! bf init: $parent_oid"

    # create the bloom filter (TclObj) structure
    set __bf_TclObj(${name}) \
        [::bloom_filter::create $items_estimate $false_positive_prob]

    if { [namespace exists "::sysdb::bloom_filter_t"] } {
        # see if we already have any records on it
        set where_clause [list]
        lappend where_clause [list name = $name]
        set bf_oid [::sysdb::bloom_filter_t 0or1row $where_clause] 

        # load the bytes info (if any) into the bloom filter (TclObj) structure
        if { $bf_oid ne {} } {
            array set bf_data [::sysdb::bloom_filter_t get $bf_oid]
            binary scan $bf_data(bytes) a* bytes
            ::bloom_filter::set_bytes $__bf_TclObj(${name}) $bytes
        }
    }

    return

}



proc ::persistence::bloom_filter::insert {parent_oid rev} {
    variable __bf_TclObj
    variable __bf_dirty

    # what kind of parent_oid are we dealing with?
    set parent_type [typeof_oid $parent_oid]

    # bloom filter name
    set name [binary encode base64 [list $parent_type $parent_oid]]

    # ensures a bloom filter (TclObj) structure was initialized
    # for the given parent_oid
    assert { [info exists __bf_TclObj(${name})] }

    # insert given key to bloom filter (TclObj) structure
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    if { $parent_type eq {type} } {
        set key $row_key
    } elseif { $parent_type eq {row} } {
        set key $column_path
    }
    ::bloom_filter::insert $__bf_TclObj(${name}) $key

    set __bf_dirty($name) ""

}

proc ::persistence::bloom_filter::may_contain {parent_oid oid} {
    variable __bf_TclObj

    # what kind of parent_oid are we dealing with?
    set type [typeof_oid $parent_oid]

    # bloom filter name
    set name [binary encode base64 [list $type $parent_oid]]

    # ensures a bloom filter (TclObj) structure was initialized
    # for the given parent_oid
    assert { [info exists __bf_TclObj(${name})] }

    # check the given key
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    set key [list $row_key $column_path]
    set may_contain_p [::bloom_filter::may_contain_p $__bf_TclObj(${name}) $key]

    return $may_contain_p
}

proc ::persistence::bloom_filter::dump {{parent_oid ""}} {
    variable __bf_TclObj
    variable __bf_dirty

    if { $parent_oid ne {} } {

        # what kind of parent_oid are we dealing with?
        set type [typeof_oid $parent_oid]

        # bloom filter name
        set name [binary encode base64 [list $type $parent_oid]]

        # add it to the list
        set names $name

    } else {
        # get all bloom filter names from the __bf_TclObj structure
        set names [array names __bf_TclObj]
    }

    foreach name $names {

        if { ![info exists __bf_dirty($name)] } { continue }

        set bytes [::bloom_filter::get_bytes $__bf_TclObj(${name})]

        array set bf_item [list]
        set bf_item(name) $name 
        set bf_item(bytes) $bytes

        # find the db record for the given parent_oid
        set where_clause [list]
        lappend where_clause [list name = $name]
        set bf_oid [::sysdb::bloom_filter_t 0or1row $where_clause] 

        if { $bf_oid eq {} } {
            #log bf_item=[array get bf_item]
            #set bf_oid [join_oid "sysdb" "bloom_filter" $name "_data_"]
            ::sysdb::bloom_filter_t insert bf_item
        } else {
            ::sysdb::bloom_filter_t update $bf_oid bf_item
        }

        unset __bf_dirty($name)

    }

}
