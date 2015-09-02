namespace eval ::persistence::fs {

    namespace path ::persistence::common

    variable base_dir
    set base_dir [config get ::persistence base_dir]

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
        end_batch \
        ls

}

proc ::persistence::fs::get_oid_filename {oid} {
    variable base_dir
    return [file normalize ${base_dir}/HEAD/master/${oid}]
}

proc ::persistence::fs::get_mtime {rev} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] }
    return [file mtime [get_filename $rev]]
}


proc ::persistence::fs::get_files {nodepath} {
    variable base_dir
    set dir [file normalize ${base_dir}/HEAD/master/${nodepath}]
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
    set dir [file normalize ${base_dir}/HEAD/master/${path}]
    set names [glob -tails -types {d} -nocomplain -directory ${dir} *]
    set result [list]
    foreach name $names {
        lappend result ${path}/${name}
    }
    return [lsort ${result}]
}

proc ::persistence::fs::get_dir {args} {
    variable base_dir
    set dir [join [list ${base_dir}/ {*}${args}] {/}]
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

proc ::persistence::fs::exists_supercolumn_p {oid} {
    assert { [is_supercolumn_oid_p $oid] }
    set filename [get_oid_filename $oid]
    return [expr { [file exists $filename] && [file isdirectory $filename] }]
}

proc ::persistence::fs::exists_column_rev_p {rev} {
    assert { [is_column_rev_p $rev] }
    set filename [get_filename $rev]
    return [file exists $filename]
}

proc ::persistence::fs::exists_link_rev_p {rev} {
    assert { [is_link_rev_p $rev] }
    set filename [get_filename $rev]
    return [file exists $filename]
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


proc ::persistence::fs::readfile {rev args} {
    set filename [get_filename ${rev}]
    set codec_conf $args
    return [::util::readfile $filename {*}$codec_conf]

}
proc ::persistence::fs::writefile {rev data args} {
    set filename [get_filename ${rev}]
    set codec_conf $args
    return [::util::writefile $filename $data {*}$codec_conf]

}


proc ::persistence::fs::set_column {oid data xid codec_conf} {
    lassign [split_xid $xid] micros pid n_mutations mtime

    set filename [get_oid_filename ${oid}]
    file mkdir [file dirname ${filename}]
    writefile ${filename} ${data} {*}$codec_conf
    file mtime ${filename} ${mtime}

}


if { [setting_p "mvcc"] } {

    # isolation level: read_uncommitted
    proc ::persistence::fs::set_column {oid data xid codec_conf} {

        lassign [split_xid $xid] micros pid n_mutations mtime

        set rev "${oid}@${micros}"

        # saves revision
        set rev_filename [get_filename ${rev}]
        file mkdir [file dirname ${rev_filename}]
        writefile ${rev} ${data} {*}$codec_conf
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
            #
            # set oid_filename [get_oid_filename ${oid}]
            # file mkdir [file dirname ${oid_filename}]
            # ::util::writelink ${oid_filename} ${rev_filename}
            # file mtime ${oid_filename} ${mtime}
            #
            # return [list $oid_filename $rev_filename]

        }
        
    }

    proc ::persistence::fs::get_files {nodepath} {
        variable base_dir
        variable branch
        set dir [file normalize ${base_dir}/${nodepath}]

        set rev_names [glob -tails -nocomplain -types "f l d" -directory ${dir} "*@*"]

        set result [list]
        foreach rev_name $rev_names {
            set rev [file join ${nodepath} ${rev_name}]
            lappend result $rev
        }
        return $result

    }

    proc ::persistence::fs::get_subdirs {path} {
        variable base_dir
        variable branch
        set dir [file normalize ${base_dir}/${path}]

        # log fs,get_subdirs,dir=$dir

        set names [glob -tails -types {d} -nocomplain -directory ${dir} *]
        set result [list]
        foreach name $names {
            lappend result ${path}/${name}
        }
        return $result
    }

}

proc ::persistence::fs::ls {args} {
    variable base_dir
    return [::util::fs::ls [get_dir {*}$args]]
}

