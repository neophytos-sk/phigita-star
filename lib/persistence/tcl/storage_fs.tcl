namespace eval ::persistence::fs {

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
        get_multirow_names \
        exists_supercolumn_p \
        find_column \
        get_name \
        get_mtime

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

proc ::persistence::fs::exists_supercolumn_p {args} {
    set supercolumn_dir [get_supercolumn {*}${args}]
    return [file isdirectory ${supercolumn_dir}]
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

proc ::persistence::fs::get_row {ks cf_axis row_key} {
    set row_dir [join_oid ${ks} ${cf_axis} ${row_key}]
    return ${row_dir}
}

proc ::persistence::fs::get_supercolumn {keyspace column_family row_key supercolumn_path} {
    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
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

    set ts [clock seconds] ;# TODO: improve timestamps handling

    set_column ${oid} ${data} $ts ${codec_conf}

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

    set_link ${oid} ${target_oid} ${codec_conf}

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
    assert { [is_supercolumn_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [expr { [file exists $filename] && [file isdirectory $filename] }]
}

# private
proc ::persistence::fs::exists_column_rev_p {rev} {
    assert { [is_column_rev_p $rev] }
    set filename [get_rev_filename $rev]
    return [file exists $filename]
}

# public
proc ::persistence::fs::exists_column_p {oid} {
    assert { [is_column_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::fs::exists_link_p {oid} {
    assert { [is_link_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::fs::exists_p {oid} {
    if { [is_link_oid_p $oid] } {
        return [exists_link_p $oid]
    } else {
        return [exists_column_p $oid]
    }
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

proc ::persistence::fs::set_link {oid target_oid {codec_conf ""}} {

    if { 0 } {

        # if data is on a single host, then create a symbolic link
        set src [get_oid_filename ${oid}] 
        set target [get_oid_filename ${target_oid}]
        if { [exists_column_p $oid] } {
            set old_target [file link $src] 
            #log "file node (link) exists: $src"
            #log "checking to see if link points to the same target: $old_target"
            if { $old_target ne $target } {
                #log "deleting link $src -> $old_target"
                #log "new target for link: $target"
                file delete $src
            } else {
                #log "link already exists and points to the same target"
                return
            }
        }
        file mkdir [file dirname $src]
        file link $src $target

    } else {

        # otherwise, use set_column to replicate the data
        # this would suffice as a generic case, though we prefer
        # to use features from the underlying storage where
        # possible, in this case filesystem links would enable us
        # to actually browse the directories and see the links
        # themselves as opposed to having to open the .link file
        # to see its target (and thus requiring knowledge of the
        # persistence layer internals)

        set_column ${oid}.link $target_oid

    }

}

proc ::persistence::fs::get_link {oid {codec_conf ""}} {
    assert { [is_link_oid_p $oid] }
    # log "retrieving link (=$oid) from fs"
    set target_oid [::util::readfile [get_oid_filename $oid] {*}$codec_conf]
    return [get $target_oid $codec_conf]
}

proc ::persistence::fs::get_column {oid {codec_conf ""}} {
    assert { [is_column_oid_p $oid] }
    # log "retrieving column (=$oid) from fs"
    set filename [get_oid_filename ${oid}]
    return [::util::readfile ${filename} {*}$codec_conf]
}

proc ::persistence::fs::get {oid {codec_conf ""}} {
    # log "get $oid"
    if { [is_link_oid_p $oid] } {
        return [get_link $oid $codec_conf]
    } else {
        return [get_column $oid $codec_conf]
    }
}


proc ::persistence::fs::__del_column {ks cf_axis row_key column_path {ts ""}} {
    assert { [is_column_oid_p $oid] }

    # TODO: insert_column tombstone
    assert_refcount_is_zero ${oid}
    set filename [get_oid_filename ${oid}]
    return [file delete ${filename}]
}

proc ::persistence::fs::join_oid {ks cf_axis {row_key ""} {column_path ""}} {
    assert { $ks ne {} }        ;# is_ks $ks
    assert { $cf_axis ne {} }   ;# is_cf_axis $cf_axis

    set oid ${ks}/${cf_axis}

    if { $row_key ne {} } {
        append oid "/" $row_key "/+"
        if { $column_path ne {} } {
            append oid "/" $column_path
            #if { $ts ne {} } {
            #    append oid "@${ts}"
            #}
        } else {
            # assert { $ts eq {} }
        }
    } else {
        assert { $column_path eq {} }
        # assert { $ts eq {} }
    }

    return $oid

}


proc ::persistence::fs::split_oid {oid_with_ts} {
    lassign [split ${oid_with_ts} {@}] oid ts
    set column_path_args [lassign [split $oid {/}] ks cf_axis row_key __delimiter__]
    set column_path [join $column_path_args {/}]
    set ext [file extension $column_path] 
    return [list $ks $cf_axis $row_key $column_path $ext]
}

proc ::persistence::fs::del_column {oid} {
    assert { [is_column_oid_p $oid] }
    lassign [split_oid $oid] ks cf_axis row_key column_path
    __del_column $ks $cf_axis $row_key $column_path
}


proc ::persistence::fs::expand_oid {oid} {
    #log "is_row_oid_p=[is_row_oid_p $oid]"
    #log "is_supercolumn_oid_p=[is_supercolumn_oid_p $oid]"

    if { [is_row_oid_p $oid] && [exists_row_data_p $oid] } {
        return [get_leaf_nodes $oid]
    } elseif { [is_supercolumn_oid_p $oid] && [exists_supercolumn_p $oid] } {
        set leafs [get_leaf_nodes $oid]
        #log "expand_oid->leafs=$leafs"
        return $leafs
    } else {
        #log "expand_oid->column oid $oid"
        return [list $oid]
    }
}

proc ::persistence::fs::is_expanded_p {slicelist} {
    set llen [llength $slicelist]
    if { $llen == 0 } {
        return 1
    }


    set oid [lindex $slicelist 0]
    if { [is_row_oid_p $oid] && [exists_row_data_p $oid] } {
        return 0
    } elseif { [is_supercolumn_oid_p $oid] && [exists_supercolumn_p $oid] } {
        return 0
    } else {
        return 1
    }

}

proc ::persistence::fs::expand_slice {slicelistVar fn} {

    upvar $slicelistVar slicelist

    #if { [is_expanded_p $slicelist] } {
        # HERE HERE HERE - FIX
        # return $slicelist
    #}

    set result [list]
    foreach oid $slicelist {
        set leafs [expand_oid $oid]

        if { $fn ne {} } {
            if { [llength $fn] == 1 } {
                predicate=$fn leafs
            } elseif { [llength $fn] == 2 } {
                apply $fn leafs
            } else {
                error "unknown type of expand_fn: must be lambda or procname"
            }
        }
        
        foreach leaf_oid $leafs {
            lappend result $leaf_oid
        }
    }

    return $result
}

proc ::persistence::fs::predicate=forall {slicelistVar predicates} {
    upvar $slicelistVar slicelist
    foreach predicate $predicates {
        lassign ${predicate} cmd argv
        predicate=$cmd slicelist {*}$argv
    }
}

# TODO: more checks needed here
proc ::persistence::fs::is_supercolumn_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} }]
    # set first_char [string index $column_path 0]
    # return [expr { $column_path ne {} && $first_char eq {^} }]
}

# TODO: more checks needed here
proc ::persistence::fs::is_column_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} && $ext eq {} }]
}

# TODO: more checks needed here
proc ::persistence::fs::is_column_rev_p {rev} {
    lassign [split ${rev} {@}] oid ts
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { $column_path ne {} && ${ts} ne {} }]
}

# TODO: more checks needed here
proc ::persistence::fs::is_row_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    return [expr { ${row_key} ne {} && $column_path eq {} }]
}

proc ::persistence::fs::get_name {oid} {
    set filename_or_dir [get_oid_filename $oid]
    if { [file extension $oid] eq {.link} } {
        set filename_or_dir [::util::readfile $filename_or_dir]
        #set filename_or_dir [file link ${filename_or_dir}]
    }
    return [file tail [file rootname ${filename_or_dir}]]
}

proc ::persistence::fs::get_leaf_nodes {path} {
    # log "!!! get_leaf_nodes $path"
    set subdirs [get_subdirs $path]
    if { $subdirs eq {} } {
        return [get_files $path]
    } else {
        # log "subdirs:\n>>>$path\n***[join $subdirs "\n***"]"
        set result [list]
        foreach subdir_path $subdirs {
            assert { $subdir_path ne $path }
            foreach oid [get_leaf_nodes $subdir_path] {
                lappend result $oid
            }
        }
        return $result
    }
}

proc ::persistence::fs::is_link_oid_p {oid} {
    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    if { $ext eq {.link} } {
        return 1
    }
    return 0
}

proc ::persistence::fs::__get_slice_from_row {row_path {options ""}} {
    set slicelist [get_files ${row_path}]
    set slicelist [expand_slice slicelist ""]  ;# expand_fn used to be latest_mtime
    __exec_options slicelist $options
    return ${slicelist}
}

proc ::persistence::fs::__get_slice {ks cf_axis row_key {options ""}} {
    set row_path [get_row ${ks} ${cf_axis} ${row_key}]
    return [__get_slice_from_row ${row_path} ${options}]

}

proc ::persistence::fs::__get_slice_names {args} {
    set result [list]
    set slicelist [__get_slice {*}${args}]
    foreach filename ${slicelist} {
        lappend result [::persistence::fs::get_name ${filename}]
    }
    return ${result}
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
    set row_path [get_row ${ks} ${cf_axis} ${row_key}]

    set oid [file join ${row_path} ${column_path}]

    if { ${dataVar} ne {} } {
        upvar $dataVar data
    }

    if { ${exists_pVar} ne {} } {
        upvar ${exists_pVar} exists_p
    }

    set exists_p [exists_column_p ${oid}]
    if { ${exists_p} } {
        set data [get_column ${oid} ${codec_conf}]
        return ${oid}
    } else {
        return
    }

}

proc ::persistence::fs::__get_column_name {args} {
    set result [list]
    set column [__get_column {*}${args}]
    set result [file tail ${column}]
    return ${result}
}

proc ::persistence::fs::sort {slicelistVar type_nsp attname sort_direction {sort_comparison "dictionary"}} {
    upvar $slicelistVar slicelist

    assert { $sort_direction in {decreasing increasing} }
    assert { $sort_comparison in {dictionary ascii integer} }

    set sortlist [list]
    set i 0
    foreach oid $slicelist {
        array set item [$type_nsp get ${oid}]
        lappend sortlist [list $i $item($attname) $oid]
        incr i
    }
    set sortlist [lsort -${sort_direction} -${sort_comparison} -index 1 $sortlist] 

    set sorted_slicelist [map x $sortlist {lindex $x 2}]
    return $sorted_slicelist 
}





proc ::persistence::fs::__exec_options {slicelistVar options} {
    upvar $slicelistVar slicelist

    # hack to load feed_reader types until all types are loaded in zz-postinit
    namespace eval :: {
        package require feed_reader
    }

    array set options_arr $options

    set slice_predicate [value_if options_arr(__slice_predicate) ""]
    if { $slice_predicate ne {} } {
        predicate=forall slicelist $slice_predicate
    }

    set option_order_by [value_if options_arr(order_by) ""]
    if { $option_order_by ne {} } {
        lassign $option_order_by sort_attname sort_direction sort_comparison
        # assert { $sort_direction in {increasing decreasing} }
        # assert { $sort_comparison in {ascii dictionary integer} }
        set type_nsp $options_arr(__type_nsp)
        set slicelist [sort slicelist $type_nsp $sort_attname $sort_direction]
    }

    if { exists("options_arr(offset)") || exists("options_arr(limit)") } {
        set offset [value_if options_arr(offset) "0"]
        set limit [value_if options_arr(limit) ""]
        set first $offset
        if { $limit ne {} } {
            set last [expr { $offset + $limit - 1 }]
        } else {
            set last end
        }
        if { $first ne {0} || $last ne {end} } {
            set slicelist [lrange $slicelist $first $last]
        }
    }


}

proc ::persistence::fs::__multiget_slice {ks cf_axis row_keys {options ""}} {

    set result [list]

    foreach row_key ${row_keys} {
        set slicelist [__get_slice ${ks} ${cf_axis} ${row_key} $options]
        # row_key can be extracted from the filename from the given slicelist, if needed
        #lappend result ${row_key}
        foreach oid ${slicelist} {
            lappend result $oid
        }
    }

    __exec_options result $options

    # log result=[join $result \n-----]
    return ${result}

}


################################################################################3

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

proc ::persistence::fs::ins_link {oid target_oid {codec_conf ""}} {
    # TODO: IncrRefCount

    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    __ins_link $ks $cf_axis $row_key $column_path $target_oid $codec_conf
}

proc ::persistence::fs::ins_column {oid data {codec_conf ""}} {

    lassign [split_oid $oid] ks cf_axis row_key column_path ext
    __ins_column $ks $cf_axis $row_key $column_path $data $codec_conf
}

proc ::persistence::fs::get_slice {nodepath {options ""}} {
    assert { [is_row_oid_p $nodepath] }
    lassign [split_oid $nodepath] ks cf_axis row_key
    return [__get_slice $ks $cf_axis $row_key $options]
}

proc ::persistence::fs::multiget_slice {nodepath row_keys {options ""}} {
    #assert { [is_cf_nodepath_p $nodepath] }

    lassign [split_oid $nodepath] ks cf_axis

    set slicelist [__multiget_slice $ks $cf_axis $row_keys $options]

    return $slicelist
}


###################################################################################################

proc ::persistence::fs::predicate=maybe_in_path {slicelistVar parent_path {predicate ""}} {
    upvar $slicelistVar slicelist

    variable __bf

    set result [list]
    foreach oid $slicelist {
        lassign [split_oid $oid] ks cf_axis row_key column_path ext
        set other_oid "${parent_path}${column_path}"

        set column_path_args [lassign [split $other_oid {/}] ks cf_axis row_key __delimiter__]
        set may_contain_p [::bloom_filter::may_contain $__bf(${ks}.${cf_axis}) $other_oid]
        if { $may_contain_p } {
            lappend result $oid
        }
        # log oid=$oid
        # log other_oid=$other_oid
        # log "may_contain_p returned $may_contain_p #times=[incr may_contain_p=$may_contain_p,__$cf_axis]"


    }
    return $result
}

proc ::persistence::fs::exists_row_data_p {oid} {
    assert { [is_row_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [file exists $filename]
}

proc ::persistence::fs::exists_data_p {oid} {
    if { [is_row_oid_p $oid] } {
        return [exists_row_data_p $oid]
    } elseif { [is_column_oid_p $oid] || [is_supercolumn_oid_p $oid] } {
        return [expr { [exists_column_p $oid] || [exists_supercolumn_p $oid] }]
    } else {
        error "unknown oid (=$oid) type: must be row, column, or supercolumn"
    }
}


proc ::persistence::fs::predicate=in_path {slicelistVar parent_path {predicate ""}} {
    upvar $slicelistVar slicelist
    set result [list]
    foreach oid $slicelist {
        lassign [split_oid $oid] ks cf_axis row_key column_path ext
        # log parent_path=$parent_path
        # log column_path=$column_path
        set other_oid "${parent_path}${column_path}"
        # log other_oid=$other_oid
        set exists_p [exists_data_p $other_oid]
        if { $exists_p } {
            lappend result $oid
        }
    }
    set slicelist $result

}

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
        lappend result [get_name ${row}]
    }
    return ${result}
}


