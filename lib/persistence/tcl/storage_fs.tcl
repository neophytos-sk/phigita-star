namespace eval ::persistence::fs {

    namespace __mixin ::persistence::common

    variable base_dir
    set base_dir [config get ::persistence base_dir]
    variable branch "master"

    namespace export -clear \
        define_ks \
        define_cf \
        exists_p \
        get \
        ins_column \
        del_column \
        ins_link \
        del_link \
        get_slice \
        multiget_slice \
        get_multirow \
        get_multirow_names \
        exists_supercolumn_p \
        find_column \
        get_name \
        get_mtime \
        get_files \
        get_subdirs \
        get_leafs \
        exists_column_p \
        exists_link_p \
        get_column \
        join_oid \
        split_oid \
        ins_column \
        ins_link \
        get_link \
        get_slice \
        multiget_slice \
        exists_p \
        is_supercolumn_oid_p \
        is_column_oid_p \
        is_column_rev_p \
        is_row_oid_p \
        is_link_oid_p \
        sort \
        __exec_options \
        get


    # private
    # set_column
    # set_link
    #

    variable __bf
    array set __bf [list]

}

# bloom filters and other auxiliary files
proc ::persistence::fs::get_meta_filename {path} {
    variable base_dir
    return [file normalize ${base_dir}/META/${path}]
}

# the tip of the current branch
proc ::persistence::fs::get_oid_filename {oid} {
    variable base_dir
    variable branch
    return [file normalize ${base_dir}/HEAD/${branch}/${oid}]
}

# user data & indexes
proc ::persistence::fs::get_rev_filename {rev} {
    variable base_dir
    return [file normalize ${base_dir}/DATA/${rev}]
}

proc ::persistence::fs::get_mtime {oid} {
    return [file mtime [get_oid_filename $oid]]
}


proc ::persistence::fs::get_files {nodepath} {
    variable base_dir
    variable branch
    set dir [file normalize ${base_dir}/HEAD/${branch}/${nodepath}]
    set names [glob -tails -nocomplain -types "f l d" -directory ${dir} "*"]
    set result [list]
    foreach name $names {
        set oid ${nodepath}/${name}
        lappend result ${oid}
    }

    return [lsort ${result}]
}

proc ::persistence::fs::get_subdirs {path} {
    variable base_dir
    variable branch
    set dir [file normalize ${base_dir}/HEAD/${branch}/${path}]
    set names [glob -tails -types {d} -nocomplain -directory ${dir} *]
    set result [list]
    foreach name $names {
        lappend result ${path}/${name}
    }
    return [lsort ${result}]
}






proc ::persistence::fs::get_dir {args} {
    variable base_dir
    set dir [join [list ${base_dir}/DATA {*}${args}] {/}]
    return ${dir}
}

proc ::persistence::fs::exists_ks_p {keyspace} {
    variable ks
    return [file isdirectory [get_dir ${keyspace}]]
    # return [info exists ks(${keyspace})]
}

proc ::persistence::fs::assert_ks {keyspace} {
    if { ![exists_ks_p ${keyspace}] } {
        error "assert_ks: no such keyspace (${keyspace})"
    }
}

proc ::persistence::fs::exists_cf_p {keyspace column_family} {
    variable ks
    variable cf
    return [file isdirectory [get_dir ${keyspace} ${column_family}]]
    # return [info exists cf(${keyspace},${column_family})]
}

proc ::persistence::fs::assert_cf {keyspace column_family} {
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
        error "assert_cf: no such column family (${keyspace},${column_family})"
    }
}


proc ::persistence::fs::create_ks_if {keyspace {replication_factor "3"}} {
    if { ![exists_ks_p ${keyspace}] } {
        file mkdir [get_dir ${keyspace}]
        return 1
    }
    return 0
}

proc ::persistence::fs::create_cf_if {keyspace column_family} {
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
        file mkdir [get_dir ${keyspace} ${column_family}]
        return 1
    }
    return 0
}

proc ::persistence::fs::define_ks {keyspace} {
    variable ks
    create_ks_if ${keyspace}
    # set ks(${keyspace}) 1
}

proc ::persistence::fs::define_cf {ks cf_axis {spec {}}} {
    assert_ks ${ks}
    create_cf_if ${ks} ${cf_axis}
    # set cf(${keyspace},${column_family}) ${spec}

    #puts define_cf,$ks,$cf_axis

    ##
    # cf_axis bloom filter
    #

    variable __bf

    set items_estimate 10000
    set false_positive_prob 0.01

    set __bf(${ks}.${cf_axis}) \
        [::bloom_filter::create $items_estimate $false_positive_prob]

    # Bloom Filter File (aka BFF)
    set bff [get_meta_filename ${ks}.${cf_axis}.bff]
    if { [file exists $bff] } {
        binary scan [::util::readfile $bff -translation binary] a* bytes
        ::bloom_filter::set_bytes $__bf(${ks}.${cf_axis}) $bytes
    }
    
    return

}


proc ::persistence::fs::get_supercolumn {keyspace column_family row_key supercolumn_path} {
    set row_dir [join_oid ${keyspace} ${column_family} ${row_key}]
    set supercolumn_dir ${row_dir}/${supercolumn_path}
    return ${supercolumn_dir}
}


# example column families and column names:
#
# cf=news_item url/3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=news_item item keywspace:newsdb log/row:3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=content_item keyspace:newsdb content/row:cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# cf=revision     keyspace:newsdb site/row:com.philenews/super:3ef3908e7438635a03e2321669b5855dbf4f238f/column:cdaa22d5ca05c6111d900ce81f5686c376a50881
# cf=revision     keywspace:newsdb site/row:com.philenews.3ef3908e7438635a03e2321669b5855dbf4f238f/cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# name := keyspace/row_key/column_path
# column_path := super_column_name/column_name or just column_name
#
proc ::persistence::fs::__ins_column {ks cf_axis row_key column_path data {codec_conf ""}} {

    # create_row_if ${ks} ${cf_axis} ${row_key} row_path

    set oid [join_oid $ks $cf_axis $row_key $column_path]

    set mtime [clock seconds] ;# TODO: improve timestamps handling
    set_column ${oid} ${data} $mtime ${codec_conf}

    ##
    # bloom filter
    #

    variable __bf
    ::bloom_filter::insert $__bf(${ks}.${cf_axis}) $oid

    set bff [get_meta_filename ${ks}.${cf_axis}.bff]
    ::util::writefile $bff \
        [binary format a* [::bloom_filter::get_bytes $__bf(${ks}.${cf_axis})]] \
        -translation binary

}

proc ::persistence::fs::__ins_link {
    ks 
    cf_axis 
    row_key 
    column_path 
    target_oid 
    {codec_conf ""}
} {

    # create_row_if ${ks} ${cf_axis} ${row_key} row_path

    set oid [join_oid $ks $cf_axis $row_key $column_path]

    set mtime [clock seconds] ;# TODO: improve timestamps handling
    set_link ${oid} ${target_oid} $mtime ${codec_conf}

    ##
    # bloom filter
    #

    variable __bf
    ::bloom_filter::insert $__bf(${ks}.${cf_axis}) $oid

    set bff [get_meta_filename ${ks}.${cf_axis}.bff]
    ::util::writefile $bff \
        [binary format a* [::bloom_filter::get_bytes $__bf(${ks}.${cf_axis})]] \
        -translation binary

}


proc ::persistence::fs::del_link {oid} {
    # TODO: DecrRefCount
    del_column_data $oid
}

proc ::persistence::fs::exists_supercolumn_p {oid} {
    assert { [::persistence::is_supercolumn_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [expr { [file exists $filename] && [file isdirectory $filename] }]
}

# private
proc ::persistence::fs::exists_column_rev_p {rev} {
    assert { [::persistence::is_column_rev_p $rev] }
    set filename [get_rev_filename $rev]
    return [file exists $filename]
}

# public
proc ::persistence::fs::exists_column_p {oid} {
    assert { [::persistence::is_column_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::fs::exists_link_p {oid} {
    assert { [::persistence::is_link_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::fs::set_column {oid data mtime codec_conf} {

    set rev "${oid}@${mtime}"

    set rev_filename [get_rev_filename ${rev}]
    set oid_filename [get_oid_filename ${oid}]

    file mkdir [file dirname ${rev_filename}]
    file mkdir [file dirname ${oid_filename}]

    ::util::writefile ${rev_filename} ${data} {*}$codec_conf
    ::util::writelink $oid_filename $rev_filename

    if { ${mtime} ne {} } {
        file mtime $rev_filename $mtime
        file mtime $oid_filename $mtime
    }

    
}

proc ::persistence::fs::set_link {oid target_oid mtime codec_conf} {

    if { 0 } {

        # if data is on a single host, then create a symbolic link
        set src [get_oid_filename ${oid}.link] 
        set target [get_oid_filename ${target_oid}]
        ::util::writelink $oid_filename $rev_filename
        file mtime $oid_filename $mtime

    } else {

        # otherwise, use set_column to replicate the data
        # this would suffice as a generic case, though we prefer
        # to use features from the underlying storage where
        # possible, in this case filesystem links would enable us
        # to actually browse the directories and see the links
        # themselves as opposed to having to open the .link file
        # to see its target (and thus requiring knowledge of the
        # persistence layer internals)

        set_column ${oid}.link $target_oid $mtime

    }

}

proc ::persistence::fs::get_link_target {oid} {

    assert { [::persistence::is_link_oid_p $oid] } 

    if { 0 } {

        variable base_dir
        set oid_filename [get_oid_filename $oid]
        set target_oid_filename [file link ${oid_filename}]
        set index [string length $base_dir]
        set target_oid [string range $target_filename $index end]

    } else {

        set target_oid [get_column $oid]

    }

    return $target_oid

}


# note: default implementation uses column to store the target_oid of a link
# and thus why we allow for link oids in the assertion statement
proc ::persistence::fs::get_column {oid {codec_conf ""}} {
    assert { [::persistence::is_column_oid_p $oid] || [::persistence::is_link_oid_p $oid] }
    # log "retrieving column (=$oid) from fs"
    set filename [get_oid_filename ${oid}]
    return [::util::readfile ${filename} {*}$codec_conf]
}


proc ::persistence::fs::__del_column {ks cf_axis row_key column_path {ts ""}} {
    assert { [::persistence::is_column_oid_p $oid] }

    # TODO: insert_column tombstone
    assert_refcount_is_zero ${oid}
    set filename [get_oid_filename ${oid}]
    return [file delete ${filename}]
}

proc ::persistence::fs::del_column {oid} {
    assert { [::persistence::is_column_oid_p $oid] }
    lassign [split_oid $oid] ks cf_axis row_key column_path
    __del_column $ks $cf_axis $row_key $column_path
}


proc ::persistence::fs::get_name {oid} {
    set oid_filename [get_oid_filename $oid]
    if { [::persistence::is_link_oid_p $oid] } {
        set oid_filename [get_link_target $oid]
    }
    return [file tail [file rootname ${oid_filename}]]
}

proc ::persistence::fs::get_leafs {path} {
    set subdirs [get_subdirs $path]
    if { $subdirs eq {} } {
        return [get_files $path]
    } else {
        # log "subdirs:\n>>>$path\n***[join $subdirs "\n***"]"
        set result [list]
        foreach subdir_path $subdirs {
            assert { $subdir_path ne $path }
            foreach oid [get_leafs $subdir_path] {
                lappend result $oid
            }
        }
        return $result
    }
}


proc ::persistence::fs::__find_column {
    ks 
    cf_axis 
    row_key 
    column_path 
    {dataVar ""} 
    {exists_pVar ""}
    {codec_conf ""}
} {

    # row_path includes the "+" delimiter
    set row_path [join_oid ${ks} ${cf_axis} ${row_key}]

    set oid [file join ${row_path} ${column_path}]

    if { ${dataVar} ne {} } {
        upvar $dataVar data
    }

    if { ${exists_pVar} ne {} } {
        upvar ${exists_pVar} exists_p
    }

    set exists_p [exists_p ${oid}]
    if { ${exists_p} } {
        set data [get_column ${oid} ${codec_conf}]
        return ${oid}
    } else {
        return
    }

}


proc ::persistence::fs::find_column {
    oid 
    {dataVar ""} 
    {exists_pVar ""}
    {codec_conf ""}
} {

    set varname1 ""
    if { $dataVar ne {} } {
        upvar $dataVar _1
        set varname1 {_1}
    }

    if { $exists_pVar ne {} } {
        upvar $exists_pVar exists_p
    }

    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    set oid [__find_column $ks $cf_axis $row_key $column_path ${varname1} exists_p ${codec_conf}]
    return $oid
}


###################################################################################################


#TODO: get_range_slices
#TODO: batch_mutate
#TODO: incr_column
#TODO: incr_super_column


################ multirow

# TODO: replace glob with ::util::fs::ls
# TODO: replace ::util::fs::ls with ::persistence::fs::list_rows
proc ::persistence::fs::get_multirow {ks cf_axis {predicate ""}} {

    assert_cf ${ks} ${cf_axis}

    set multirow [get_subdirs ${ks}/${cf_axis}]

    if { ${predicate} ne {} } {
        predicate=forall multirow $predicate
    }

    return ${multirow}

}


proc ::persistence::fs::get_multirow_names {nodepath {predicate ""}} {
    #assert { [is_cf_nodepath_p $nodepath] }

    set residual_path [lassign [split $nodepath {/}] ks cf_axis]
    return [__get_multirow_names $ks $cf_axis $predicate]
}

proc ::persistence::fs::__get_multirow_names {ks cf_axis {predicate ""}} {
    set multirow [get_multirow $ks $cf_axis $predicate]
    set result [list]
    foreach row ${multirow} {
        set row_key [get_name ${row}]
        lappend result $row_key
    }
    return ${result}
}


