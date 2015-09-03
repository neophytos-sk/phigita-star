if { ![setting_p "critbit_tree"] } {
    return
}

package require critbit_tree

namespace eval ::persistence::critbit_tree {

    namespace import ::persistence::common::typeof_oid
    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::join_oid
    namespace import ::persistence::common::split_xid

    variable __cbt_TclObj
    array set __cbt_TclObj [list]

    variable __cbt_dirty
    array set __cbt_dirty [list]

}

proc ::persistence::critbit_tree::init {parent_oid} {
    variable __cbt_TclObj

    # what kind of parent_oid are we dealing with?
    set type [typeof_oid $parent_oid]

    # critbit tree name
    set name [binary encode base64 [list $type $parent_oid]]

    if { [info exists __cbt_TclObj(${name})] } {
        set bytes [::cbt::get_bytes $__cbt_TclObj(${name})]
        log "!!! cbt already initialized: [llength $bytes] parent_oid=$parent_oid"
        return
    }
    log "!!! cbt init: $parent_oid"

    # create the critbit tree (TclObj) structure
    set __cbt_TclObj(${name}) [::cbt::create $::cbt::STRING]

    assert { [info exists __cbt_TclObj(${name})] }

    if { [namespace exists "::sysdb::critbit_tree_t"] } {
        # see if we already have any records on it
        set where_clause [list]
        lappend where_clause [list name = $name]
        array set options [list]
        set cbt_oid [::sysdb::critbit_tree_t 0or1row $where_clause] 

        # load the bytes info (if any) into the critbit_tree (TclObj) structure
        if { $cbt_oid ne {} } {
            array set cbt_data [::sysdb::critbit_tree_t get $cbt_oid]
            binary scan $cbt_data(bytes) a* bytes
            # log "cbt,#items=[llength $bytes]"
            ::cbt::set_bytes $__cbt_TclObj(${name}) $bytes
        }
    }

    return

}

proc ::persistence::critbit_tree::insert {parent_oid rev} {
    variable __cbt_TclObj
    variable __cbt_dirty

    # what kind of parent_oid are we dealing with?
    set parent_type [typeof_oid $parent_oid]

    # critbit tree name
    set name [binary encode base64 [list $parent_type $parent_oid]]

    # ensures a critbit tree (TclObj) structure was initialized
    # for the given parent_oid
    assert { [info exists __cbt_TclObj(${name})] }

    ::cbt::insert $__cbt_TclObj(${name}) $rev

    set __cbt_dirty(${name}) ""

}

proc ::persistence::critbit_tree::dump {{parent_oid ""}} {
    variable __cbt_TclObj
    variable __cbt_dirty

    if { $parent_oid ne {} } {

        # what kind of parent_oid are we dealing with?
        set type [typeof_oid $parent_oid]

        # bloom filter name
        set name [binary encode base64 [list $type $parent_oid]]

        # add it to the list
        set names $name

    } else {
        # get all bloom filter names from the __bf_TclObj structure
        set names [array names __cbt_TclObj]
    }

    foreach name $names {

        if { ![info exists __cbt_dirty(${name})] } { 
            # log "!!! skipping cbt dump: [binary decode base64 $name]"
            continue 
        }

        set bytes [::cbt::get_bytes $__cbt_TclObj(${name})]

# log "dumping cbt (#items=[llength $bytes]) : [binary decode base64 $name]"

        array set cbt_item [list]
        set cbt_item(name) $name 
        set cbt_item(bytes) $bytes

        # find the db record for the given parent_oid
        set where_clause [list]
        lappend where_clause [list name = $name]
        array set options [list]
        set cbt_oid [::sysdb::critbit_tree_t 0or1row $where_clause] 

        # log cbt_oid=$cbt_oid

        if { 1 || $cbt_oid eq {} } {
            ::sysdb::critbit_tree_t insert cbt_item
        } else {
            ::sysdb::critbit_tree_t update $cbt_oid cbt_item
        }

        array unset __cbt_dirty ${name}

    }

}

proc ::persistence::critbit_tree::exists_p {parent_oid rev} {
    variable __cbt_TclObj
    variable __cbt_dirty

    # what kind of parent_oid are we dealing with?
    set parent_type [typeof_oid $parent_oid]

    # critbit tree name
    set name [binary encode base64 [list $parent_type $parent_oid]]

    # ensures a critbit tree (TclObj) structure was initialized
    # for the given parent_oid
    assert { [info exists __cbt_TclObj(${name})] }

    return [::cbt::exists $__cbt_TclObj(${name}) $rev]

}

proc ::persistence::critbit_tree::get_files {path} {
    variable __cbt_TclObj

    lassign [split_oid $path] ks cf_axis

    # TODO: fix issue with ::sysdb::* types
    if { $ks eq {sysdb} } {
        return
    }

    set parent_oid ${ks}/${cf_axis}

    # what kind of parent_oid are we dealing with?
    set parent_type [typeof_oid $parent_oid]

    # critbit tree name
    set name [binary encode base64 [list $parent_type $parent_oid]]

    # ensures a critbit tree (TclObj) structure was initialized
    # for the given parent_oid
    assert { [info exists __cbt_TclObj(${name})] } {
        log "!!! critbit_tree: name=[binary decode base64 $name]"
    }

    # log "cbt,get_files,num_items=[llength [::cbt::get_bytes $__cbt_TclObj(${name})]]"

    return [::cbt::prefix_match $__cbt_TclObj(${name}) ${path}]

}

proc ::persistence::critbit_tree::get_subdirs {path} {

    #log get_subdirs,path=$path

    set len [llength [split $path {/}]]

    set files [get_files "${path}/"]  ;# slash is important

    #log get_subdirs,ls=$files

    set result [list]
    foreach oid $files {
        set oid_parts [split $oid {/}] 
        lappend result [join [lrange $oid_parts 0 $len] {/}]
    }

    #log get_subdirs,result=$result

    return [lsort -unique ${result}]

}

proc ::persistence::critbit_tree::printall {parent_oid} {
    variable __cbt_TclObj

    # what kind of parent_oid are we dealing with?
    set type [typeof_oid $parent_oid]

    # bloom filter name
    set name [binary encode base64 [list $type $parent_oid]]

    return [::cbt::get_bytes $__cbt_TclObj(${name})]
}
