namespace eval ::persistence::fs {

    namespace path ::persistence::common

    variable base_dir
    set base_dir [config get ::persistence base_dir]
    variable branch "master"

    namespace export -clear \
        define_ks \
        define_cf \
        get_files \
        get_subdirs \
        set_column \
        exists_p \
        get \
        ins_column \
        del_column \
        ins_link \
        del_link \
        get_multirow \
        get_multirow_names \
        exists_supercolumn_p \
        find_column \
        get_name \
        get_mtime \
        get_column \
        join_oid \
        split_oid \
        ins_column \
        ins_link \
        get_link \
        is_supercolumn_oid_p \
        is_column_oid_p \
        is_column_rev_p \
        is_row_oid_p \
        is_link_oid_p \
        sort \
        __exec_options \
        get \
        begin_batch \
        end_batch


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
}


proc ::persistence::fs::get_supercolumn {keyspace column_family row_key supercolumn_path} {
    set row_dir [join_oid ${keyspace} ${column_family} ${row_key}]
    set supercolumn_dir ${row_dir}/${supercolumn_path}
    return ${supercolumn_dir}
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

proc ::persistence::fs::exists_column_rev_p {rev} {
    assert { [is_column_rev_p $rev] }
    set filename [get_rev_filename $rev]
    return [file exists $filename]
}

proc ::persistence::fs::exists_link_rev_p {rev} {
    assert { [is_link_rev_p $rev] }
    set filename [get_rev_filename $rev]
    return [file exists $filename]
}


# isolation level: read_committed
proc ::persistence::fs::get_tmp_filename {filename} {
    variable base_dir
    set key [binary encode base64 $filename]
    set tmp_filename [file join $base_dir tmp $key]
    return $tmp_filename
}

proc ::persistence::fs::write_data {ext filename data xid codec_conf} {
    lassign [split_xid $xid] micros pid n_mutations mtime
    set tmp_filename [file join [get_tmp_filename ${filename}] ${ext}]
    ::util::writefile ${tmp_filename} ${data} {*}${codec_conf}
    file mtime ${tmp_filename} ${mtime}
}

proc ::persistence::fs::read_committed__set_column {oid data xid codec_conf} {

    lassign [split_xid $xid] micros pid n_mutations mtime

    set rev "${oid}@${mtime}"

    # saves revision
    set rev_filename [get_rev_filename $rev]
    write_data ".ins_rev" $rev_filename $data $mtime $codec_conf

    # checks if oid is a tombstone and updates the link
    # at the tip of the current branch,
    # i.e. removes the link if oid is a tombstone,
    # creates link in any other case 
    set ext [file extension ${oid}]
    if { $ext eq {.gone} } {

        set orig_oid [file rootname ${oid}]
        set orig_oid_filename [get_oid_filename $orig_odi]
        write_data ".del_orig_oid" $orig_oid_filename "" $mtime $codec_conf

    } else {

        # add link from tip of the current branch to rev file
        # note that, when we delete, we delete this link,
        # the revision remains intact
        set oid_filename [get_oid_filename ${oid}]
        write_data ".lnk_oid_rev" $oid_filename $rev_filename $mtime $codec_conf

    }
    
}




# note: default implementation uses column to store the target_oid of a link
# and thus why we allow for link oids in the assertion statement
proc ::persistence::fs::get_column {rev {codec_conf ""}} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] } {
        log failed,rev=$rev
    }

    # log "retrieving column (=$oid) from fs"
    set filename [get_rev_filename ${rev}]
    return [::util::readfile ${filename} {*}$codec_conf]
}






proc ::persistence::fs::get_name {oid} {
    set oid_filename [get_oid_filename $oid]
    if { [is_link_oid_p $oid] } {
        set oid_filename [get_link_target $oid]
    }
    return [file tail [file rootname ${oid_filename}]]
}


proc ::persistence::fs::find_column {
    oid
    {dataVar ""} 
    {exists_pVar ""}
    {codec_conf ""}
} {

    lassign [split_oid $oid] ks cf_axis row_key column_path ext

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

    set multirow [::persistence::get_subdirs ${ks}/${cf_axis}]

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


proc ::persistence::fs::set_column {oid data xid codec_conf} {
    lassign [split_xid $xid] micros pid n_mutations mtime

    set filename [get_oid_filename ${oid}]
    file mkdir [file dirname ${filename}]
    ::util::writefile ${filename} ${data} {*}$codec_conf
    file mtime ${filename} ${mtime}

}


if { [setting_p "mvcc"] } {

    # isolation level: read_uncommitted
    proc ::persistence::fs::set_column {oid data xid codec_conf} {

        lassign [split_xid $xid] micros pid n_mutations mtime

        set rev "${oid}@${micros}"

        # saves revision
        set rev_filename [get_rev_filename ${rev}]
        file mkdir [file dirname ${rev_filename}]
        ::util::writefile ${rev_filename} ${data} {*}$codec_conf
        file mtime ${rev_filename} ${mtime}

        # checks if oid is a tombstone and updates the link
        # at the tip of the current branch,
        # i.e. removes the link if oid is a tombstone,
        # creates link in any other case 
        set ext [file extension ${oid}]
        if { $ext eq {.gone} } {

            set orig_oid [file rootname ${oid}]
            set orig_oid_filename [get_oid_filename $orig_oid]
            file delete $orig_oid_filename

            return [list $orig_oid_filename ""]

        } else {

            # add link from tip of the current branch to rev file
            # note that, when we delete, we delete this link,
            # the revision remains intact
            set oid_filename [get_oid_filename ${oid}]
            file mkdir [file dirname ${oid_filename}]
            ::util::writelink ${oid_filename} ${rev_filename}
            file mtime ${oid_filename} ${mtime}

            return [list $oid_filename $rev_filename]

        }
        
    }

    proc ::persistence::fs::get_files {nodepath} {
        variable base_dir
        variable branch
        set dir [file normalize ${base_dir}/DATA/${nodepath}]

        set rev_names [glob -tails -nocomplain -types "f l d" -directory ${dir} "*@*"]

        array set latest_rev [list]
        foreach rev_name $rev_names {
            lassign [split $rev_name "@"] name micros
            if { [value_if latest_rev($name) "0"] < $micros } {
                set latest_rev($name) $micros
            }
        }

        set latest_rev_names [array names latest_rev]

        # log get_files,latest_rev_names=$latest_rev_names

        set result [list]
        foreach name $latest_rev_names {
            if { [file extension $name] eq {.gone} } { continue }
            set micros $latest_rev($name)
            set rev [file join ${nodepath} ${name}]@${micros}
            lappend result ${rev}
        }

        # log get_files,result=$result

        return [lsort ${result}]

    }

    proc ::persistence::fs::get_subdirs {path} {
        variable base_dir
        variable branch
        set dir [file normalize ${base_dir}/DATA/${path}]

        # log fs,get_subdirs,dir=$dir

        set names [glob -tails -types {d} -nocomplain -directory ${dir} *]
        set result [list]
        foreach name $names {
            lappend result ${path}/${name}
        }
        return [lsort ${result}]
    }

}


