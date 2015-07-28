# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here

namespace eval ::persistence::orm {
    namespace export \
        to_path \
        from_path \
        insert \
        find \
        find_by \
        init_type
}

proc ::persistence::orm::init_type {} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::indexes

    # log "persistence (ORM): initializing [namespace __this] ensemble/type"

    set nsp [namespace __this]
    set oid [::sysdb::object_type_t find $nsp "" exists_p]

    if { !$exists_p } {
        ::persistence::define_ks $ks
        foreach {index_name index_item} [array get indexes] {
            set axis $index_name
            ::persistence::define_cf $ks $cf.$axis
        }

        array set item [list ks $ks cf $cf nsp $nsp]
        ::sysdb::object_type_t insert item
    }
}

proc ::persistence::orm::to_path_by {axis args} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf

    set target "${ks}/${cf}.${axis}"
    if {1} {
        # if datatype of first arg/attribute exceeds a certain threshold
        # then we map the attribute values to row keys
        set args [lassign $args row_key]
        #set column_path [::persistence::to_column_path $args]
        set column_path [join $args {/}]
        append target "/${row_key}/+/$column_path"
    } else {
        # check that supercolumns are allowed for the given axis
        #set column_path [::persistence::to_column_path $args]
        set column_path [join $args {/}]
        append target "__default__/+/$column_path"
    }

}

proc ::persistence::orm::to_path {id} {
    variable [namespace __this]::pk
    set axis "by_$pk"
    return [to_path_by $axis $id "__data__"]
}

proc ::persistence::orm::from_path {path} {
    set column_key [lassign [split ${path} {/}] _ks _cf row_key __delimiter__]
    if {1} {
        return ${row_key}
    } else {
        return ${column_key}
    }
}


# finds the first record matching some conditions
# set slicelist [::newsdb::news_item_t find_by contentsha1 $contentsha1]
# set oid [::newsdb::news_item_t find_by contentsha1 $contentsha1 $urlsha1] "" exists_revision_p]
proc ::persistence::orm::find_by {args} {
    variable [namespace __this]::indexes

    set argc [llength $args]
    assert { $argc in {5 4 3 2 1} }

    if { $argc >= 3 } {

        lassign $args attname attvalue id dataVar exists_pVar
        set varname ""
        if { $dataVar ne {} } {
            upvar $dataVar _
            set varname _
        }
        if { $exists_pVar ne {} } {
            upvar $exists_pVar exists_p
        }
        set path [to_path_by by_$attname $attvalue $id]
        set oid [::persistence::get_column $path ${varname} exists_p]
        return $oid

    } elseif { $argc == 2 } {

        lassign $args attname attvalue
        set path [to_path_by by_$attname $attvalue]
        set predicate ""
        set slicelist [::persistence::get_slice $path $predicate]
        return $slicelist

    } elseif { $argc == 1 } {

        lassign $args attname
        set path [to_path_by by_$attname]
        set predicate ""
        set slicelist [::persistence::multiget_slice $path $predicate]

    }

    # set axis "by_${key}"
    # assert { exists("indexes($axis)") }
    # array set idx $indexes($axis)

    set predicate ""
    set path [to_path_by ${axis} ${value}]

    # puts path=$path
    # puts slicelist=$slicelist

    return $slicelist

}

# finds the record corresponding to the specified primary key
proc ::persistence::orm::find {id {itemVar ""} {exists_pVar ""}} {
    variable [namespace __this]::pk
    variable [namespace __this]::attributes

    array set attinfo $attributes($pk)
    foreach datatype $attinfo(datatype) {
        assert { vcheck("id",$datatype) }
    }

    # get_column will only retrieve the data
    # if a non-empty itemVar argument is given 

    set varname ""
    if { $itemVar ne {} } {
        upvar $itemVar item
        set varname {_}
    }

    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    set path [to_path $id]
    set oid [::persistence::get_column $path ${varname} exists_p]

    if { $exists_p && $itemVar ne {} } {
        array set item ${_}
    }

    return $oid
}


proc ::persistence::orm::insert {itemVar} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::indexes

    upvar $itemVar item

    set data [array get item]

    set target [to_path $item($pk)]

    ::persistence::insert_column $target $data

    foreach {index_name index_item} [array get indexes] {
        if { $index_name eq "by_$pk" } {
            continue
        }

        array set idx $index_item
        set attributes $idx(atts)

        set row_key [list]
        foreach attname $attributes {
            lappend row_key $item($attname)
        }

        set axis $index_name
        set src [to_path_by ${axis} ${row_key} $item($pk)]
        ::persistence::insert_link $src $target

     }

}



