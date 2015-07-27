# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here

namespace eval ::persistence::orm {
    namespace export to_path from_path insert get
}

proc ::persistence::orm::to_path {id} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::metadata

    set axis by_$metadata(pk)
    set target "${ks}/${cf}.${axis}"
    if {1} {
        # if datatype of primary key attribute exceeds a certain threshold
        # then we map the primary key attribute to row keys
        append target "/${id}/+/__data__"
    } else {
        # otherwise, map the primary key attribute to column names
        append target "/__data__/+/${id}"
    }
}

proc ::persistence::orm::from_path {path} {
    set column_key [lassign [split ${path} {/}] _ks _cf row_key __delimiter__]
    if {1} {
        return ${row_key}
    } else {
        return ${column_key}
    }
}


proc ::persistence::orm::get {id {dataVar ""}} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::metadata

    set varname {}
    if { $dataVar ne {} } {

        upvar $dataVar _

        # get/get_column only gets the data 
        # (as opposed to just the filename)
        # if a non-empty dataVar argument is given 

        set varname {_}
    }

    set path [to_path ${id}]
    set filename [::persistence::get $path {*}${varname}]

    return $filename

}

proc ::persistence::orm::insert {itemVar} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::metadata

    upvar $itemVar item

    set data [array get item]

    set pk $metadata(pk)
    set target [to_path $item($pk)]

    ::persistence::insert $target $data

    foreach index_item $metadata(indexes) {
        lassign $index_item axis attributes __tags__

        set row_key [list]
        foreach attname $attributes {
            lappend row_key $item($attname)
        }

        set src "${ks}/${cf}.${axis}/${row_key}/+/$item($pk)"
        ::persistence::insert_link $src $target

     }

}



