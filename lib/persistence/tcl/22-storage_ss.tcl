# log server=[use_p server]
if { ![use_p "server"] || ![setting_p "sstable"] } {
    return
}

namespace eval ::persistence::ss {
    namespace import ::persistence::common::split_oid
    namespace import ::persistence::common::join_oid
    namespace import ::persistence::common::type_oid
    namespace import ::persistence::common::get_cur_filename

    # namespace __mixin ::persistence::common

    variable base_dir
    set base_dir [config get ::persistence base_dir]
}

proc ::persistence::ss::read_sstable {dataVar row_endpos file_i {lambdaExpr ""}} {
    upvar $dataVar data

    # log read_sstable,datalen=[string length $data]

    # seek _fp $row_endpos start
    # read_int _fp row_startpos

    assert { $row_endpos ne {} }

    set pos $row_endpos
    set scan_p [binary scan $data "@${pos}i" row_startpos]
    incr pos 4

    assert { $scan_p } {
        log row_endpos=$row_endpos
        log failed,row_startpos,scan_p=$scan_p
    }

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

        if { $lambdaExpr eq {} || [apply $lambdaExpr data $rev] } {
            lappend revs [list $rev $file_i $pos]
        }

        # skip_string _fp
        binary scan $data @${pos}i len

        incr pos 4
        incr pos $len  ;# skip_string (data)

    }

    return $revs

}


proc ::persistence::ss::get_files {path} {

    set len [string length $path]
    set list_path [list $path]
    set lambdaExpr [subst -nocommands -nobackslashes \
        {{dataVar rev} {
            set prefix [string range [set rev] 0 $len]
            return [expr { [set prefix] eq "\{${list_path}\}" }]
        }}]

    set type_oid [type_oid $path]
    set name [binary encode base64 $type_oid]
    #set where_clause [list [list name = $sstable_name]]
    #set sstable_rev [::sysdb::sstable_t 0or1row $where_clause]

    variable base_dir
    set dir [file join $base_dir cur]
    set pattern "sysdb/sstable.by_name/${name}/+/${name}@*"
    set sstable_revs [glob \
        -nocomplain \
        -tails \
        -directory $dir \
        $pattern]

    if { $sstable_revs eq {} } {
        return
    }

    assert { [llength $sstable_revs] == 1 } {
        log sstable_revs=\n[join $sstable_revs \n]
        log type_oid=$type_oid
        log name=$name
    }

    set sstable_rev [lindex $sstable_revs 0]

    assert { $sstable_rev ne {} }

    lassign [split_oid $path] ks cf_axis row_key column_path ext ts

    array set sstable_item [::sysdb::sstable_t get $sstable_rev]
    array set sstable_indexmap $sstable_item(indexmap)

    set row_endpos $sstable_indexmap($row_key)
    set file_i ""
    set column_idx_items [::persistence::ss::read_sstable \
        sstable_item(data) $row_endpos $file_i $lambdaExpr]

    set ss_filelist [list]
    foreach column_idx_item $column_idx_items {
        lassign $column_idx_item rev file_i pos
        lappend ss_filelist $rev
    }

    return $ss_filelist

}

proc ::persistence::ss::merge_sstables_in_mem {type_oid} {

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
        return
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

            set sstable_data [set sstable_item__${file_i}(data)]

            set column_idx_items [::persistence::ss::read_sstable \
                sstable_data $row_endpos $file_i]

            foreach column_idx_item $column_idx_items {
                lappend sstable_row_idx(${row_key}) $column_idx_item
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
        log "deleted old sstable: $sstable_filename"
        # ::sysdb::sstable_t delete $sstable_rev

        array unset sstable_item__${file_i}
        incr file_i
    }

}


proc ::persistence::ss::readfile {rev args} {
    set codec_conf $args

    # check sstable file
    set type_oid [type_oid $rev]
    # log type_oid=$type_oid
    set sstable_name [binary encode base64 $type_oid]

    set where_clause [list [list name = $sstable_name]]
    set sstable_rev [::sysdb::sstable_t 0or1row $where_clause]

    # log check,sstable_rev=$sstable_rev

    if { $sstable_rev ne {} } {

        lassign [split_oid $rev] ks cf_axis row_key column_path ext ts

        array set sstable_item [::sysdb::sstable_t get $sstable_rev]
        array set sstable_indexmap $sstable_item(indexmap)

        if {0} {
            assert { [info exists sstable_indexmap(${row_key})] } {
                log "row_key=$row_key"
                log "sstable_indexmap=\n\t[join [map {x y} [array get sstable_indexmap] {list $x $y}] \n\t], exiting..."
                exit
            }
        }

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

        log "!!! returning ss_data for rev=$rev"

        return $ss_data

    }

    return

}

wrap_proc ::persistence::fs::readfile {rev args} {
    set codec_conf $args
    
    # log fs,readfile,rev=$rev

    # checks files in filesystem first i.e. cur directory
    # and, if no file is found for the given rev,
    # it calls ::persistence::ss:readfile

    set filename [get_cur_filename $rev]
    if { [file exists $filename] } {
        set fs_data [call_orig $rev {*}$codec_conf]
        return $fs_data
    }

    set ss_data [::persistence::ss::readfile $rev {*}$codec_conf]

    if {1} {
        set fs_data [call_orig $rev {*}$codec_conf]

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
    }


    return $ss_data
}
    
if {1} {
    wrap_proc ::persistence::fs::get_files {path} {
        set fs_filelist [call_orig $path]
        if { [string match "sysdb/*" $path] } {
            return $fs_filelist
        }

        set ss_filelist [::persistence::ss::get_files $path]

        return [lsort -unique -command ::persistence::compare_files \
            [concat $fs_filelist $ss_filelist]]
    }
}

proc ::persistence::fs::compact {type_oid todelete_dirsVar} {
    upvar $todelete_dirsVar todelete_dirs

    log "compacting type_oid=$type_oid"

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

        # log -----
        # log fs::compact,row_key=$row_key

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
            
            set encoded_rev_data [get_column $rev "-translation binary"]
            set scan_p [binary scan $encoded_rev_data a* encoded_rev_data]
            set len [string length $encoded_rev_data]

            # log encoded_rev_data,len=$len

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

        # log indexmap,row_key=$row_key
        if { $row_key eq {gr} } {
            log "fs::compact,wrong_row_key, exiting..."
            log x=[map {x y} $multirow_slicelist {set x}]
            exit
        }
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
        if { ![string match "sysdb/*" $row_oid] } {
            set row_dir [get_cur_filename $row_oid]
            lappend todelete_dirs $row_dir
        }
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

            file delete -force $todelete_dir
            log "deleted row_dir (=$todelete_dir)"
        }

        ::persistence::fs::end_batch

        # see storage_ss.tcl
        foreach type_oid $type_oids {
            log "merging sstables for $type_oid"
            if { [catch {
                ::persistence::ss::merge_sstables_in_mem $type_oid
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

after_package_load persistence ::persistence::fs::compact_all

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


