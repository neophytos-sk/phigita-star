# A mapping strategy for db types, should only contain calls to
# procs that are generic (highest-level of abstraction) in the
# persistence package, i.e. no storage system-specific calls here

namespace eval ::persistence::orm {
    namespace export \
        to_path \
        from_path \
        insert \
        find \
        find_by
}

proc ::persistence::orm::to_path_by {key args} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf

    set axis by_${key}
    set target "${ks}/${cf}.${axis}"
    if {1} {
        # if datatype of first arg/attribute exceeds a certain threshold
        # then we map the attribute values to row keys
        set args [lassign $args row_key]
        #set column_path [::persistence::to_column_path $args]
        if { $args eq {} } {
            set column_path "__data__"
        } else {
            set column_path [join $args {/}]
        }
        append target "/${row_key}/+/$column_path"
    } else {
        # check that supercolumns are allowed for the given axis
        #set column_path [::persistence::to_column_path $args]
        set column_path [join $args {/}]
        append target "__data__/+/$column_path"
    }

}

proc ::persistence::orm::to_path {id} {
    variable [namespace __this]::pk
    return [to_path_by $pk $id]
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
proc ::persistence::orm::find_by {key value {dataVar ""}} {
    set varname {}
    if { $dataVar ne {} } {

        upvar $dataVar _

        # get/get_column only gets the data 
        # (as opposed to just the filename)
        # if a non-empty dataVar argument is given 

        set varname {_}
    }

    set path [to_path_by ${key} ${value}]
    set filename [::persistence::get $path {*}${varname}]

    puts path=$path
    puts filename=$filename

    return $filename

}

# finds the record corresponding to the specified primary key
proc ::persistence::orm::find {id {dataVar ""}} {
    variable [namespace __this]::pk

    if { $dataVar ne {} } {

        upvar $dataVar _

        # get/get_column only gets the data 
        # (as opposed to just the filename)
        # if a non-empty dataVar argument is given 

        set varname {_}
    }

    return [find_by $pk $id {*}$varname]
}


proc ::persistence::orm::insert {itemVar} {
    variable [namespace __this]::ks
    variable [namespace __this]::cf
    variable [namespace __this]::pk
    variable [namespace __this]::indexes

    upvar $itemVar item

    set data [array get item]

    set target [to_path $item($pk)]

    ::persistence::insert $target $data

    foreach index_item $indexes {
        lassign $index_item axis attributes __tags__

        set row_key [list]
        foreach attname $attributes {
            lappend row_key $item($attname)
        }

        set src [to_path_by ${axis} ${row_key} $item($pk)]
        ::persistence::insert_link $src $target

     }

}



