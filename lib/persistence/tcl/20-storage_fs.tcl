namespace eval ::persistence::fs {

    #namespace path ::persistence::common

    namespace __mixin ::persistence::common

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

    # log fs,get_subdirs,dir=$dir

    set names [glob -tails -types {d} -nocomplain -directory ${dir} *]
    set result [list]
    set path [string trimright $path {/}]
    foreach name $names {
        # log !!!get_subdirs,path=$path
        # log !!!get_subdirs,name=$name
        # log get_subdirs,${path}/${name}
        lappend result ${path}/${name}
    }
    return [lsort ${result}]
}

proc ::persistence::fs::get_dir {args} {
    variable base_dir
    set dir [join [list ${base_dir}/cur/ {*}${args}] {/}]
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

proc ::persistence::fs::exists_supercolumn_p {sc_oid} {
    assert { [is_supercolumn_oid_p $sc_oid] }
    set dirname [get_cur_filename $sc_oid]
    return [expr { [file exists $dirname] && [file isdirectory $dirname] }]
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
    error "set_column, mvcc=off"

    lassign [split_xid $xid] micros pid n_mutations mtime

    set filename [get_cur_filename ${oid}]
    file mkdir [file dirname ${filename}]
    writefile ${filename} ${data} {*}$codec_conf
    file mtime ${filename} ${mtime}

}


if { [setting_p "mvcc"] } {

    proc ::persistence::fs::set_column {oid data xid codec_conf} {
        lassign [split_xid $xid] micros pid n_mutations mtime
        set rev "${oid}@${micros}"
        writefile $xid/${rev} ${data} {*}$codec_conf
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

        set rev_names [glob -tails -nocomplain -types "f l d" -directory ${dir} $pattern]

        set result [list]
        foreach rev_name $rev_names {
            set rev [file join ${rootname} ${rev_name}]
            assert { [file exists [file join $base_dir cur $rev]] }
            lappend result $rev
        }
        return $result

    }

}

proc ::persistence::fs::ls {args} {
    variable base_dir
    return [::util::fs::ls [get_dir {*}$args]]
}

proc ::persistence::fs::begin_batch {} {
    set xid [::persistence::common::begin_batch]

    # fs::begin_batch
    variable base_dir

    set tmpdir [file join $base_dir tmp $xid]
    file mkdir $tmpdir

    return $xid
}

proc ::persistence::fs::end_batch {} {

    set xid [::persistence::common::cur_transaction_id]

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
        ::persistence::common::end_batch $xid

    }

    # error "just for debugging finalize_commit in fs::init"

    # fsync (i.e. copy to curdir) all xids in newdir
    ::persistence::fs::finalize_commit $xid

    return $xid
}

proc ::persistence::fs::complete_write_to_new {{basedir ""}} {

    set tmpdir [file join $basedir tmp]
    set newdir [file join $basedir new]

    set xids [glob -nocomplain -tails -type d -directory $newdir "*.batch"]
    foreach xid $xids {
        set xidtmpdir [file join $tmpdir $xid]

        # processes nested transactions
        complete_write_to_new $xidtmpdir

        # processes files in xidtmpdir,
        # including files copied into it
        # from nested transactions
        if { [file isdirectory $xidtmpdir] } {
            # log "complete_write_to_new xid (=$xid)"
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

    set xidtmpdir [file join $tmpdir $xid]
    set xidnewdir [file join $newdir $xid]

    set parent_xid [lrange [split $xid {/}] 0 end-1]
    if { $parent_xid ne {} } {
        set xidnewdir [file dirname $xidtmpdir]
    }
    set first [llength [split $xidtmpdir {/}]]

    # hard link not allowed for directory,
    # that said, the subsequent lines would
    # have been equivalent to:
    #
    # file link -hard $xidnewdir $xidtmpdir
    # file delete $xidtmpdir
    
    set tmpfiles [file __find [file join $tmpdir $xid]]
    foreach tmpfile $tmpfiles {
        set rev [join [lrange [split $tmpfile {/}] $first end] {/}]
        set newfile [file join $xidnewdir $rev]
        file mkdir [file dirname $newfile]

        # copy and then delete,
        # in the place of a "file rename"
        # in order to keep tmpfile until
        # it has been copied completely
        #
        # 1st way:
        # file rename $tmpfile $newfile
        #
        # 2nd way:
        # file copy $tmpfile $newfile
        # file delete $tmpfile
        #
        # 3rd way: 
        # uses hard symbolic link
        # and then deletes tmpfile
        # 

        file link -hard $newfile $tmpfile
        file delete $tmpfile
    }


    if { $parent_xid ne {} } {
        # log "xid=$xid parent_xid=$parent_xid"
        # log "just for debugging nested transactions, exiting fs::write_to_new..."
        # exit
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

            # see discussion in write_to_new
            #
            # file rename $newfile $curfile

            file link -hard $curfile $newfile
            file delete $newfile
        }

        # non-empty directories are removed 
        # only if the -force option is specified,
        # in this case newdir is empty of files,
        # but still has subdirs created for storing
        # those files

        file delete -force $xidnewdir
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
    ::persistence::fs::complete_write_to_new $base_dir

    # remove all remaining xids in tmpdir
    set xids [glob -nocomplain -tails -type d -directory $tmpdir "*"]
    ::persistence::fs::delete_from_tmp $xids

    # fsync (i.e. copy to curdir) all xids in newdir
    set xids [glob -nocomplain -tails -type d -directory $newdir "*"]
    ::persistence::fs::finalize_commit $xids

    # log "just for debugging, exiting..."
    # exit
}


# log server=[use_p server]
if { [use_p "server"] && ( 1 || [setting_p "sstable"] ) } {

    proc ::persistence::fs::read_sstable {dataVar row_endpos file_i} {
        upvar $dataVar data

        # log length=[string length $data]

        # seek _fp $row_endpos start
        # read_int _fp row_startpos

        assert { $row_endpos ne {} }

        set pos $row_endpos
        set scan_p [binary scan $data "@${pos}i" row_startpos]
        incr pos 4

        # log row_startpos,scan_p=$scan_p

        assert { $scan_p }

        # log row_startpos=$row_startpos

        assert { $row_startpos < $row_endpos } {
            log row_startpos=$row_startpos
            log row_endpos=$row_endpos
        }

        set pos $row_startpos

        # seek _fp $startpos start
        # read_string _fp row_key
        binary scan $data @${pos}i len
        incr pos 4
        incr pos $len  ;# skip_string (row_key)

        set revs [list]

        while { $pos < $row_endpos } {

            # read_string _fp rev
            binary scan $data @${pos}i len
            incr pos 4
            binary scan $data @${pos}a${len} rev
            incr pos $len

            # log pos=$pos,rev=$rev

            lappend revs [list $rev $file_i $pos]

            # skip_string _fp
            binary scan $data @${pos}i len

            incr pos 4
            incr pos $len  ;# skip_string (data)

        }

        return $revs

    }

    proc ::persistence::fs::merge_sstables_in_mem {type_oid} {

        set errorlist [list sysdb/object_type.by_nsp]
        if { $type_oid in $errorlist } {
            log "skipping sstable merge for $type_oid"
            return
        }

        set name [binary encode base64 $type_oid]

        # set where_clause [list]
        # lappend where_clause [list name = $name]
        # set sstable_revs [::sysdb::sstable_t find $where_clause]

        variable base_dir
        set dir [file join $base_dir cur]
        set pattern "sysdb/sstable.by_name/${name}/+/${name}@*"
        set sstable_revs [glob \
            -nocomplain \
            -tails \
            -directory $dir \
            $pattern]

        set sstable_revs [lsort -command ::persistence::compare_files $sstable_revs]

        if { [llength $sstable_revs] <= 1 } {
            # return
        }

        #log llen=[llength $sstable_revs]
        log \tsstable_revs=[join $sstable_revs \n\t]

        set file_i 0
        array set sstable_row_idx [list]
        foreach sstable_rev $sstable_revs {

            array set sstable_item__${file_i} [::sysdb::sstable_t get $sstable_rev]
            log -----
            log name=[binary decode base64 [set sstable_item__${file_i}(name)]]
            # log sstable_datalen=[set datalen [string length [set sstable_item__${file_i}(data)]]]

            foreach {row_key row_endpos} [set sstable_item__${file_i}(indexmap)] {

                # log row_key=$row_key
                # log row_endpos=$row_endpos

                # set sstable_data [binary decode hex [set sstable_item__${file_i}(data)]]
                # binary scan [binary decode hex [set sstable_item__${file_i}(data)]] a* sstable_data

                set sstable_data [set sstable_item__${file_i}(data)]
                # set sstable_data [binary format a* [set sstable_item__${file_i}(data)]]
                # log sstable_datalen=[string length $sstable_data]

                set revs [::persistence::fs::read_sstable \
                    sstable_data $row_endpos $file_i]

                foreach rev $revs {
                    lappend sstable_row_idx(${row_key}) $rev
                }

                # log revs=$revs

            }

            incr file_i
        }

        log \tsstable_row_idx=[join [array get sstable_row_idx] \n\t]

        set row_keys [lsort [array names sstable_row_idx]]

        if { $row_keys eq {} } {
            log "!!! nothing to merge"
            return
        }

        set indexmap [list]
        set output_data ""
        set pos 0
        foreach row_key $row_keys {

            set row_startpos $pos

            # write row_key
            set len [string length $row_key]
            append output_data [binary format i $len] $row_key
            incr pos 4
            incr pos $len

            foreach column_idx_item $sstable_row_idx(${row_key}) {
                lassign $column_idx_item rev file_i file_pos

                # set sstable_data [binary decode hex [set sstable_item__${file_i}(data)]]
                # binary scan [binary decode hex [set sstable_item__${file_i}(data)]] a* sstable_data
                # set sstable_data [binary format a* [set sstable_item__${file_i}(data)]]
                set sstable_data [set sstable_item__${file_i}(data)]

                # write column rev/oid
                set len [string length $rev]
                append output_data [binary format i $len] $rev 
                incr pos 4
                incr pos $len

                # read data from file $file_i
                set scan_p [binary scan $sstable_data @${file_pos}i len]
                assert { $scan_p } {
                    log file_pos=$file_pos
                }

                # assert { $len < 1000000 } {
                #     log failed,file_pos=$file_pos,rev=$rev
                #     log length=[string length $sstable_data]
                # }

                # write data for given rev
                incr file_pos 4
                set scan_p [binary scan $sstable_data @${file_pos}a${len} encoded_rev_data]
                assert { $scan_p } {
                    log file_pos=$file_pos,len=$len
                    exit
                }

                append output_data [binary format i $len] $encoded_rev_data
                incr pos 4
                incr pos $len

            }

            # write row_startpos at end of row
            set row_endpos $pos
            log "merged file, row_key=$row_key row_endpos=$row_endpos row_startpos=$row_startpos"
            append output_data [binary format i $row_startpos]
            incr pos 4

            lappend indexmap $row_key $row_endpos

        }

        # write merged sstable file

        set name [binary encode base64 $type_oid]
        set round [clock microseconds]

        array set item [list]
        set item(name) $name
        set item(data) $output_data  ;# [binary encode hex $output_data]
        set item(indexmap) $indexmap 
        set item(round) $round

        # log "merged_sstable_rev for $type_oid"
        set merged_sstable_rev [::sysdb::sstable_t insert item]
        log merged_sstable_rev=$merged_sstable_rev

        # log "here,just for debugging nested transactions, exiting fs::compact..."
        # exit

        # NOTE: delete old sstable files,
        # but once the new sstable has been
        # committed
        set file_i 0
        foreach sstable_rev $sstable_revs {
            set sstable_filename [get_cur_filename $sstable_rev]
            file delete $sstable_filename
            # ::sysdb::sstable_t delete $sstable_rev

            array unset sstable_item__${file_i}
            incr file_i
        }

    }


    wrap_proc ::persistence::fs::readfile {rev args} {
        set codec_conf $args

        # check fs cur files
        # HERE
        if { 1 || [string match "sysdb/*" $rev] } {
            set filename [get_cur_filename $rev]
            if { [file exists $filename] } {
                return [call_orig $rev {*}$codec_conf]
            }
        }

        # check sstable files
        set type_oid [type_oid $rev]
        set sstable_name [binary encode base64 $type_oid]

        set where_clause [list [list name = $sstable_name]]
        set sstable_rev [::sysdb::sstable_t 0or1row $where_clause]

        # log check,sstable_rev=$sstable_rev

        if { $sstable_rev ne {} } {

            lassign [split_oid $rev] ks cf_axis row_key column_path ext ts

            array set sstable_item [::sysdb::sstable_t get $sstable_rev]
            array set sstable_indexmap $sstable_item(indexmap)

            set row_endpos $sstable_indexmap(${row_key})

            # seek _fp $row_endpos start
            set pos $row_endpos
            binary scan $sstable_item(data) @${pos}i row_startpos
            assert { $row_startpos < $row_endpos }

            # seek _fp $row_startpos start
            set pos $row_startpos
            binary scan $sstable_item(data) @${pos}i len
            incr pos 4
            binary scan $sstable_item(data) @${pos}a${len} row_key_in_file
            incr pos $len
            assert { $row_key eq $row_key_in_file }

            set sstable_data_found_p 0
            while { $pos < $row_endpos } {
                binary scan $sstable_item(data) @${pos}i len
                incr pos 4
                binary scan $sstable_item(data) @${pos}a${len} rev_in_file
                incr pos $len
                if { $rev eq $rev_in_file } {
                    binary scan $sstable_item(data) @${pos}i len
                    incr pos 4
                    binary scan $sstable_item(data) @${pos}a${len} ss_data
                    incr pos $len
                    set sstable_data_found_p 1
                    break
                } else {
                    binary scan $sstable_item(data) @${pos}i len
                    incr pos 4
                    incr pos $len ;# skip_string data
                }
            }

            array unset sstable_indexmap
            array unset sstable_item

            if { !$sstable_data_found_p } {
                error "sstable_readfile: rev (=$rev) not found"    
            }

            set fs_data [call_orig $rev {*}$codec_conf]


            # tries all different encoders/decoders until ss_data
            # holds a string starting with newsdb

            log -----
            if {0} {
                set enc_fs_data [binary encode base64 $fs_data]

                foreach lambdaExpr {
                    {{s} {encoding convertto utf-8 $s}}
                    {{s} {encoding convertfrom utf-8 $s}}
                    {{s} {binary format a* $s}}
                    {{s} {binary scan $s a* x ; set x}}
                } {
                    set str [apply $lambdaExpr $ss_data]
                    set enc_str [binary encode base64 $str]
                    if { $enc_fs_data eq $enc_str } {
                        log "lambdaExpr=$lambdaExpr, fs_data eq str"
                    }
                }
            }

            assert { $ss_data eq $fs_data } {
                log ""
                log "!!! ss_data for rev=$rev"
                log ""
                log "!!! ss_data=[set enc_ss_data [binary encode base64 $ss_data]]"
                log ""
                log "!!! fs_data=[set enc_fs_data [binary encode base64 $fs_data]]"
                log ""
                log [string __diff [split $enc_ss_data ""] [split $enc_fs_data ""]]
            }

            return $ss_data

        }

        return

    }

    proc ::persistence::fs::compact {type_oid todelete_dirsVar} {
        upvar $todelete_dirsVar todelete_dirs

        log type_oid=$type_oid

        # assert { [is_type_oid_p $type_oid] }

        lassign [split_oid $type_oid] ks cf_axis
        lassign [split $cf_axis {.}] cf idxname

        assert { !( $ks eq {sysdb} && $cf eq {sstable} ) }

        # log "compact type_oid=$type_oid"

        # 1. get row keys
        set multirow_options [list]
        lassign [::persistence::fs::get_multirow_names $type_oid $multirow_options] \
            row_keys revised_multirow_options

        # 2. fget_leafs/slicelist for each row key
        set multirow_slicelist [::persistence::fs::multirow_slice \
            $type_oid $row_keys $revised_multirow_options]

        # 3. merge them in one sorted-strings (sstable) file
        set indexmap [list]
        set output_data ""
        set pos 0
        foreach {row_key slicelist} $multirow_slicelist {

            #log -----
            #log fs::compact,row_key=$row_key

            set row_startpos $pos

            set len [string length $row_key]
            append output_data [binary format i $len] $row_key
            incr pos 4
            incr pos $len

            foreach rev $slicelist {

                set len [string length $rev]
                append output_data [binary format i $len] $rev 
                incr pos 4
                incr pos $len

                # one may be tempted to read 
                # the effective rev/oid
                # in the case of a .link rev,
                # however, the right thing is
                # copying the data content of
                # the given rev asis, 
                # i.e. the target rev in the
                # case of a .link rev
                #
                # NOT: set encoded_rev_data [get $rev]
                
                # set encoded_rev_data [get_column $rev]
                binary scan [get_column $rev] a* encoded_rev_data
                set len [string length $encoded_rev_data]
                set encoded_rev_data [binary format "A${len}" $encoded_rev_data]

                set len [string length $encoded_rev_data]
                # log "!!! len=$len"
                append output_data [binary format i $len] $encoded_rev_data
                incr pos 4
                incr pos $len

            }

            set row_endpos $pos
            # log "fs::compact sst,row_key=$row_key row_endpos=$row_endpos row_startpos=$row_startpos"
            # log "\tfs::compact llen=[llength $slicelist]"
            append output_data [binary format i $row_startpos]
            

            #binary scan $output_data @${pos}i test_row_startpos
            #assert { $test_row_startpos == $row_startpos }
            #log test_row_startpos=$test_row_startpos


            incr pos 4

            lappend indexmap $row_key $row_endpos

        }

        #log "fs::compact work in progress, exiting..."
        #exit

        ##
        # 4. write the (sstable) file
        #

        set name [binary encode base64 $type_oid]
        set round [clock microseconds]

        array set item [list]
        set item(name) $name
        set item(data) $output_data
        set item(indexmap) $indexmap 
        set item(round) $round

        ::sysdb::sstable_t insert item
        # log "new sstable for $type_oid"

        # log "here,just for debugging nested transactions, exiting fs::compact..."
        # exit

        foreach row_key $row_keys {
          set row_oid [join_oid $ks $cf_axis $row_key]
          set row_dir [get_cur_filename $row_oid]
          lappend todelete_dirs $row_dir
        }

        # log "done compacting $type_oid"

        # note that call to ::sysdb::sstable_t->insert above,
        # created a nested transaction
        # log "just for debugging nested transactions, exiting fs::compact..."
        # exit

    }

    proc ::persistence::fs::compact_all {} {

        set todelete_dirs [list]

        set slicelist [::sysdb::object_type_t find]
        foreach rev $slicelist {

            ::persistence::fs::begin_batch

            set type_oids [list]
            array set object_type [::sysdb::object_type_t get $rev]
            foreach idx_data $object_type(indexes) {
                array set idx $idx_data
                set cf_axis $object_type(cf).$idx(name)
                set type_oid [join_oid $object_type(ks) $cf_axis]
                #if { $type_oid ne {sysdb/sstable.by_name} }
                if { $object_type(ks) ne {sysdb} } {
                    compact $type_oid todelete_dirs
                    lappend type_oids $type_oid
                }
            }
            array unset object_type

            # only delete row dirs once we are done with compacting,
            # as a row might still be referenced in a link of another cf_axis

            # ATTENTION: do not use with production data just yet
            foreach todelete_dir $todelete_dirs {
                # deleting the given row dirs
                # renders the storage_fs dependable
                # on an implementation of
                # get_files and get_subdirs that reads
                # from the sstable files, without such
                # an implementation compact_all (at the
                # very least) won't be able to discover
                # the object types to compact, SO MAKE
                # SURE THAT get_files/get_subdirs FOR
                # READING FROM SSTABLE FILES IS COMPLETED
                # BEFORE COMMENTING-IN THE FOLLOWING LINES
                #
                # NOTE: consider deleting by marking the row as .gone
                #

                # file delete -force $todelete_dir
                # log "deleted row_dir (=$todelete_dir)"
            }

            ::persistence::fs::end_batch

            # see storage_ss.tcl
            foreach type_oid $type_oids {
                log "merging sstables for $type_oid"
                if { [catch {
                    ::persistence::fs::merge_sstables_in_mem $type_oid
                } errmsg] } {
                    log errmsg=$errmsg
                    log errorInfo=$::errorInfo
                    log exiting
                    exit
                }
            }

        }

        
        # log "exiting..."
        # exit
    }

    # after_package_load persistence ::persistence::fs::compact_all

    if {0} {

        wrap_proc ::persistence::fs::get_files {nodepath} {
            set fs_filelist [call_orig $nodepath]
            set ss_filelist [list]
            # TODO: 
            # set ss_filelist [::persistence::ss::get_files $nodepath]
            #
            # lassign [split_oid $nodepath] ks cf_axis
            # set type_oid [join_oid $ks $cf_axis]
            # set name [list type $type_oid]
            # set where_clause [list]
            # lappend where_clause [list name = $name]
            # set rev [::sysdb::sstable_t 0or1row $where_clause]
            # if { $rev ne {} } {
            #   variable sstable_item__${name}
            #   array set sstable_item__${name} [::sysdb::sstable_t get $rev]
            #   array set sstable_indexmap [set sstable_item__${name}(indexmap)]
            #   # ::cbt::set_bytes $__cbt_TclObj(${name}) [array names sstable_indexmap]
            #   # return [::cbt::prefix_match $__cbt_TclObj(${name}) $nodepath]
            # }

            set tmptree [::cbt::create]
            ::cbt::set_bytes $tmptree $ss_filelist
            ::cbt::set_bytes $tmptree $fs_filelist
            return [::cbt::get_bytes $tmptree]

        }

        wrap_proc ::persistence::fs::get_subdirs {nodepath} {
        }

    }

}
