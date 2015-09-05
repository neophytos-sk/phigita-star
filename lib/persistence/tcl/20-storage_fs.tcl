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
        get_timestamp \
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
    log "fs::get_files exiting..."
    exit

    variable base_dir
    set dir [file normalize ${base_dir}/cur/${nodepath}]
    set names [glob -tails -nocomplain -types "f l d" -directory ${dir} "*"]
    set result [list]
    foreach name $names {
        set oid ${nodepath}/${name}
        lappend result ${oid}
    }

    return [lsort -unique -command ::persistence::compare_files ${result}]
}

proc ::persistence::fs::get_subdirs {path} {
    variable base_dir
    set dir [file normalize ${base_dir}/cur/${path}]
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
    #log "fs::exists_column_rev_p $rev"
    set filename [get_cur_filename $rev]
    return [file exists $filename]
}

proc ::persistence::fs::exists_link_rev_p {rev} {
    assert { [is_link_rev_p $rev] }
    set filename [get_cur_filename $rev]
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
    set filename [get_cur_filename ${rev}]
    set codec_conf $args
    return [::util::readfile $filename {*}$codec_conf]

}

# tmprev = tmp/xid/rev
proc ::persistence::fs::writefile {xid_rev data args} {
    set tmpfile [get_tmp_filename ${xid_rev}]
    file mkdir [file dirname $tmpfile]
    set codec_conf $args
    return [::util::writefile $tmpfile $data {*}$codec_conf]

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
        # set rev_filename [get_filename ${rev}]
        # file mkdir [file dirname ${rev_filename}]
        writefile $xid/${rev} ${data} {*}$codec_conf
        # file mtime ${rev_filename} ${mtime}

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

        set last_char [string index $nodepath end]
        if { $last_char eq {/} } {
            set dir [file normalize ${base_dir}/cur/${nodepath}]
            set rootname $nodepath
            set pattern "*@*"
        } else {
            set rootname [file dirname $nodepath]
            set dir [file normalize [file join ${base_dir} cur $rootname]]
            set tail [file tail $nodepath]
            set pattern "${tail}@*"
        }

        #log [info frame -1]
        #log last_char=$last_char
        #log glob_dir=$dir
        #log glob_pattern=$pattern

        set rev_names [glob -tails -nocomplain -types "f l d" -directory ${dir} $pattern]
        #log [info frame -1]
        #log rev_names=$rev_names

        set result [list]
        foreach rev_name $rev_names {
            set rev [file join ${rootname} ${rev_name}]
            assert { [file exists [file join $base_dir cur $rev]] }
            lappend result $rev
        }
        return $result

    }

    proc ::persistence::fs::get_subdirs {path} {
        variable base_dir
        set dir [file normalize ${base_dir}/cur/${path}]

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

wrap_proc ::persistence::common::begin_batch {{xid ""}} {
    set xid [call_orig $xid]

    # fs::begin_batch
    variable base_dir

    set tmpdir [file join $base_dir tmp $xid]
    file mkdir $tmpdir

    return $xid
}

wrap_proc ::persistence::common::end_batch {{xid ""}} {

    if { $xid eq {} } {
        set xid [::persistence::common::cur_transaction_id]
    }

    assert { $xid ne {} }

    # fs::end_batch
    variable base_dir
    set tmpdir [file join $base_dir tmp $xid]
    set newdir [file join $base_dir new $xid]
    set curdir [file join $base_dir cur]
    file mkdir $newdir
    set first [llength [split $tmpdir {/}]]

    # del_from_tmp call in fs::init deletes all
    # uncommitted xids, i.e. xids that
    # have no files copied to newdir at all
    #
    # error "just for debugging del_from_tmp in fs::init"

    # copies xid files from tmpdir to newdir
    # if copying is interrupted, then 
    # complete_write_to_new in fs::init will 
    # make sure that copying is completed in full
    #
    # note that any trace of xid in newdir 
    # implies that write_to_new started copying files
    # before interrupted and thus it was in the process
    # of performing the end_batch proc
    #
    write_to_new $xid

    # if processing breaks at this point,
    # then complete_write_to_new in fs::init will
    # make sure that copying is completed in full
    #
    # error "just for debugging complete_write_to_new in fs::init"

    # without_lock - no need for lock
    if {1} {

        ::persistence::fs::delete_from_tmp $xid

        # commit, common::end_batch $xid
        # log "fs::end_batch about to call common::end_batch"
        call_orig $xid

    }

    # error "just for debugging finalize_commit in fs::init"

    # fsync (i.e. copy to curdir) all xids in newdir
    ::persistence::fs::finalize_commit $xid

    return $xid
}

proc ::persistence::fs::complete_write_to_new {} {
    variable base_dir

    set tmpdir [file join $base_dir tmp]
    set newdir [file join $base_dir new]

    set xids [glob -nocomplain -tails -type d -directory $newdir "*"]
    foreach xid $xids {
        set xidtmpdir [file join $tmpdir $xid]
        if { [file isdirectory $xidtmpdir] } {
            log "complete_write_to_new xid (=$xid)"
            ::persistence::fs::write_to_new $xid
            ::persistence::fs::delete_from_tmp $xid
        }
    }
}

proc ::persistence::fs::write_to_new {xid} {
    variable base_dir

    # log "write_to_new xid (=$xid)"

    set tmpdir [file join $base_dir tmp]
    set newdir [file join $base_dir new]
    set first [llength [split $newdir {/}]]

    set tmpfiles [file __find [file join $tmpdir $xid]]
    foreach tmpfile $tmpfiles {
        set rev [join [lrange [split $tmpfile {/}] $first end] {/}]
        set newfile [file join $newdir $rev]
        file mkdir [file dirname $newfile]
        file copy $tmpfile $newfile
        file delete $tmpfile
    }
}


proc ::persistence::fs::delete_from_tmp {xids} {
    # log "delete_from_tmp xids=$xids"
    variable base_dir
    set tmpdir [file join $base_dir tmp]
    foreach xid $xids {
        # log "delete_from_tmp xid (=$xid)"
        set xidtmpdir [file join $tmpdir $xid]
        file delete -force $xidtmpdir
    }
}

proc ::persistence::fs::finalize_commit {xids} {
    variable base_dir

    set newdir [file join $base_dir new]
    set curdir [file join $base_dir cur]
    set first [llength [split $newdir {/}]]
    incr first

    foreach xid $xids {
        # log "finalizing commit $xid"

        set xidnewdir [file join $newdir $xid]
        set newfiles [file __find $xidnewdir]
        foreach newfile $newfiles {
            set rev [join [lrange [split $newfile {/}] $first end] {/}]
            set curfile [file join $curdir $rev]
            file mkdir [file dirname $curfile]
            file rename $newfile $curfile
        }
        file delete -force $newdir
    }

}




# ROLLBACK upon bootstrap/init
# 1. complete copying tmpfiles to newdir for xidnewdir that has a corresponding xidtmpdir
# 2. remove all tmpfiles
# 3. commit all remaining newfiles
proc ::persistence::fs::init {} {
    variable base_dir

    set tmpdir [file join $base_dir tmp]
    set newdir [file join $base_dir new]

    # complete writing xids to new
    # i.e. xids both in newdir and tmpdir
    ::persistence::fs::complete_write_to_new

    # remove all remaining xids in tmpdir
    set xids [glob -nocomplain -tails -type d -directory $tmpdir "*"]
    ::persistence::fs::delete_from_tmp $xids

    # fsync (i.e. copy to curdir) all xids in newdir
    set xids [glob -nocomplain -tails -type d -directory $newdir "*"]
    ::persistence::fs::finalize_commit $xids

    # log "just for debugging, exiting..."
    # exit
}

wrap_proc ::persistence::common::init {} {
    call_orig
    ::persistence::fs::init
}

