# log server=[use_p server]
if { ![use_p "server"] || ![setting_p "sstable"] } {
    return
}

namespace eval ::persistence::ss {

    namespace __copy ::persistence::common

    variable base_dir
    set base_dir [config get ::persistence base_dir]

    variable base_nsp
    set base_nsp [config get ::persistence base_nsp]

}

proc ::persistence::ss::init {} {
    variable base_nsp
    ${base_nsp}::init
    if { [setting_p "compact_p"] } {
        compact_all
    }
}


proc ::persistence::ss::define_ks {args} {}
proc ::persistence::ss::define_cf {args} {}

proc ::persistence::ss::set_column {args} {
    variable base_nsp
    return [${base_nsp}::set_column {*}${args}]
}

proc ::persistence::ss::begin_batch {args} {
    variable base_nsp
    return [${base_nsp}::begin_batch {*}${args}]
}

proc ::persistence::ss::end_batch {args} {
    variable base_nsp
    return [${base_nsp}::end_batch {*}${args}]
}

proc ::persistence::ss::get_mtime {rev} {
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    return [expr { $ts / (10**6) }]
}


# Even though ss::get_leafs helps work around the issue
# discussed in ss::get_subdirs_helper, it lacks
# when it comes to (generalized) providence for retrieving 
# the list of subdirs and leafs from distributed nodes
# compared to the fs::get_leafs.

proc ::persistence::ss::get_leafs {path {direction "0"} {limit ""}} {
    variable base_nsp

    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [${base_nsp}::get_leafs $path]
    }

    set base_leafs [${base_nsp}::get_leafs $path]

    set ss_leafs [::persistence::ss::get_leafs_helper $path]

    if { $base_leafs eq {} } {
        return [resolve_latest_revs $ss_leafs]
    }

    set result [lsort -unique -command ::persistence::compare_files \
        [concat $base_leafs $ss_leafs]]

    return [resolve_latest_revs $result]
}

proc ::persistence::ss::get_leafs_helper {path {direction "0"} {limit ""}} {
    set type_oid [type_oid $path]
    if { [load_sstable $type_oid] } {
        variable __cbt_TclObj
        set result [::cbt::prefix_match $__cbt_TclObj(${type_oid},cols) $path]
        return $result
    }
    return
}

proc ::persistence::ss::get_subdirs_helper {path direction limit} {

    set type_oid [type_oid $path]
    if { [load_sstable $type_oid sstableVar sstable_colsVar sstable_rowsVar] } {
        upvar $sstableVar sstable
        upvar $sstable_rowsVar sstable_rows

        lassign [split_oid $path] ks cf_axis row_key_prefix delim

        # row_key_prefix either empty or actual row key 
        # i.e. not as much a prefix

        if { $row_key_prefix ne {} } {

            # BUG:
            #
            # fs::get_leafs will take care of this case
            # when it comes to using the ss::get_files_helper proc,
            # yet this not entirely acceptable and it would have to be fixed,
            # in particular, when fs::get_subdirs returns a non-empty list, 
            # get_leafs won't call get_files but it would iterate over the subdir_paths
            # that ss::get_subdirs (fs::get_subdirs + ss::get_subdirs_helper) returned
            # for feed_reader->ls --lang el.utf8
            #
            # UPDATE: introduced ss::get_leafs that resolves this issue but kept the
            # comment as a reminder when mem/commitlog is rewritten/refactored
            #

            return

            if { $delim eq {} && [info exists sstable_rows(${row_key_prefix})] } {
                log row_key_prefix=$row_key_prefix
                return ${type_oid}/${row_key_prefix}/+
            }
            return

        }

        if {0} {
            set row_keys [::cbt::prefix_match \
                $__cbt_Tcl_Obj__rows \
                "" \
                ${direction} \
                [coalesce ${limit} "-1"]]
        } else {
            set row_keys [map {x y} $sstable(rows) {set x}]
        }

        set result [list]
        foreach row_key $row_keys {
            lappend result ${type_oid}/${row_key}
        }

        return $result
    }

    # sysdb column families are still using ::persistence::fs,
    # i.e. no sstable, no entries in the commitlog
    # log "sstable for type_oid (=$type_oid) not loaded"

    return
}

# TODO:  add blob_file attribute type that writes data to filesystem
proc ::persistence::ss::ORM_get_sstable_rev {rev} {
    error "not implemented yet"
    set type_oid [type_oid $rev]
    set sstable_name [encode_sstable_name $type_oid]
    set where_clause [list [list name = $sstable_name]]
    set sstable_rev [::sysdb::sstable_t 0or1row $where_clause]
    return $sstable_rev
}

proc ::persistence::ss::get_sstable_rev {rev} {

    set type_oid [type_oid $rev]
    set name [encode_sstable_name $type_oid]

    # log get_sstable_rev,type_oid=$type_oid,name=$name

    variable base_dir
    set dir [file join $base_dir cur]
    set pattern "sysdb/sstable.by_name/${name}/+/${name}@*"

    set sstable_revs [glob \
        -nocomplain \
        -tails \
        -directory $dir \
        $pattern]

    set sstable_revs [lsort -command ::persistence::compare_files $sstable_revs]

    assert { [llength $sstable_revs] <= 1 }

    return [lindex $sstable_revs 0]
}

proc ::persistence::ss::load_sstable {
    type_oid 
    {sstableVarVar ""} 
    {sstable_colsVarVar ""}
    {sstable_rowsVarVar ""}
} {

    lassign [split_oid $type_oid] ks
    if { $ks eq {sysdb} } {
        return 0
    }

    # log "!!! load_sstable,type_oid=$type_oid"

    if { $sstableVarVar ne {} } {
        upvar $sstableVarVar sstableVar
    }

    if { $sstable_colsVarVar ne {} } {
        upvar $sstable_colsVarVar sstable_colsVar
    }

    if { $sstable_rowsVarVar ne {} } {
        upvar $sstable_rowsVarVar sstable_rowsVar
    }

    set nsp [namespace current]
    set sstableVar "${nsp}::sstable__${type_oid}"
    set sstable_colsVar "${nsp}::sstable_cols__${type_oid}"
    set sstable_rowsVar "${nsp}::sstable_rows__${type_oid}"

    upvar $sstableVar sstable
    upvar $sstable_colsVar sstable_cols
    upvar $sstable_rowsVar sstable_rows
    
    variable __cbt_TclObj

    if { ![info exists __cbt_TclObj(${type_oid},cols)] } {
        set sstable_rev [get_sstable_rev $type_oid]

        # log sstable_rev=$sstable_rev
        # log type_oid=$type_oid

        if { $sstable_rev eq {} } {
            return 0
        }

        array set sstable [::sysdb::sstable_t get $sstable_rev]

        set __cbt_TclObj(${type_oid},cols) [::cbt::create $::cbt::STRING]

        array set sstable_cols $sstable(cols)
        array set sstable_rows $sstable(rows)

        # To save some memory, comment in the following lines:
        # unset sstable(cols)
        # unset sstable(rows)

        ::cbt::set_bytes $__cbt_TclObj(${type_oid},cols) [array names sstable_cols]

        # ::cbt::set_bytes $__cbt_TclObj(${type_oid},cols) \
        #    [map {x y} [set ${sstableVar}(cols)] {set x}]


        return 1

    } else {
        assert { [array size sstable] }
        assert { [array size sstable_cols] }
    }
    return 2
}

proc ::persistence::ss::readfile_helper {rev args} {
    set codec_conf $args

    set type_oid [type_oid $rev]

    if { ![load_sstable $type_oid sstableVar sstable_colsVar] } {
        error "sstable loading error"
    }
    upvar $sstableVar sstable
    upvar $sstable_colsVar sstable_cols

    set rev_startpos $sstable_cols(${rev})

    # seek _fp $rev_startpos start
    set pos $rev_startpos

    # start of code using sstable_item_t
    binary scan $sstable(data) @${pos}i len
    incr pos 4
    binary scan $sstable(data) @${pos}a${len} sstable_item_data
    incr pos $len

    array set sstable_item \
        [::sysdb::sstable_item_t decode sstable_item_data]

    return $sstable_item(data)
    # end of code using sstable_item_t

}


proc ::persistence::ss::exists_p_helper {rev} {
    assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] }
    set type_oid [type_oid $rev]
    if { [load_sstable $type_oid] } {
        variable __cbt_TclObj
        set exists_p [::cbt::exists $__cbt_TclObj(${type_oid},cols) $rev]
        # log exists_p=$exists_p
        return $exists_p
    }
    return 0
}


# first read from the latest, i.e. commitlog or fs, then from sstable
proc ::persistence::ss::readfile {rev args} {
    set codec_conf $args

    # log ss,readfile,rev=$rev

    lassign [split_oid $rev] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::readfile $rev {*}$codec_conf]
    }

    variable base_nsp
    if { [${base_nsp}::exists_p $rev] } {
        return [${base_nsp}::readfile $rev {*}$codec_conf]
    } elseif { [::persistence::ss::exists_p_helper $rev] } {
        return [::persistence::ss::readfile_helper $rev {*}$codec_conf]
    }

}

proc ::persistence::ss::get_files {path} {
    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [::persistence::fs::get_files $path]
    }

    set base_files [${base_nsp}::get_files $path]
    set ss_files [::persistence::ss::get_files_helper $path]

    set result [lsort -unique [concat $base_files $ss_files]]
    return $result
}

proc ::persistence::ss::get_subdirs {path {direction "0"} {limit ""}} {
    variable base_nsp

    lassign [split_oid $path] ks
    if { $ks eq {sysdb} } {
        return [${base_nsp}::get_subdirs $path ${direction} ${limit}]
    }

    set base_subdirs [${base_nsp}::get_subdirs $path ${direction} ${limit}]
    set ss_subdirs [::persistence::ss::get_subdirs_helper $path ${direction} ${limit}]

    set result [lsort -unique [concat $base_subdirs $ss_subdirs]]
    return $result
}


proc ::persistence::ss::exists_p {path} {
    return [expr { [get_leafs $path] ne {} }]
}

# merge sstables in mem
proc ::persistence::ss::compact {type_oid todelete_revsVar} {
    upvar $todelete_revsVar todelete_revs

    lassign [split_oid $type_oid] ks
    if { $ks eq {sysdb} } {
        # log "skipping sstable merge for $type_oid"
        return
    }
    log "merging sstables for $type_oid"

    set name [encode_sstable_name $type_oid]

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
        log "-> type_oid (=$type_oid) already merged"
        return
    }

    #log llen=[llength $sstable_revs]
    # log \tsstable_revs=[join $sstable_revs \n\t]

    set file_i 0
    array set sstable_row_idx [list]
    array set fp [list]
    array set filename [list]
    foreach sstable_rev $sstable_revs {

        lappend todelete_revs $sstable_rev
        
        array set sstable [::sysdb::sstable_t get $sstable_rev]

        # set sstable_filename [get_cur_filename $sstable_rev]
        # log filename=$sstable_filename
        # log size=[file size $sstable_filename]

        set filename(${file_i}) "/tmp/file__${file_i}"
        set fp(${file_i}) [open $filename(${file_i}) "w+"]
        fconfigure $fp(${file_i}) -translation binary 
        puts -nonewline $fp(${file_i}) $sstable(data)


        foreach {rev rev_start_pos} $sstable(cols) {
            lassign [split_oid $rev] _ks _cf_axis row_key
            lappend sstable_row_idx(${row_key}) [list $rev $file_i $rev_start_pos]
        }

        array unset sstable

        incr file_i
    }

    # log \tsstable_row_idx=[join [array get sstable_row_idx] \n\t]

    set row_keys [lsort [array names sstable_row_idx]]

    if { $row_keys eq {} } {
        #log "!!! nothing to merge"
        return
    }

    set output_rows [list]
    set output_cols [list]
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
            lassign $column_idx_item rev file_i input_rev_start_pos
            
            # TODO: load_chunk/_fragment that includes rev_start_pos
            # into sstable_data var
            # 

            seek $fp(${file_i}) $input_rev_start_pos 
            ::util::io::read_string $fp(${file_i}) sstable_item_data

            # writing sstable rev item data
            set output_rev_start_pos $pos
            # TODO: 
            # if { fragment_size_exceeds_threshold } {
            #   sstable_fragment_t insert sstable_fragment_data
            # }
            set len [string length $sstable_item_data]
            append output_data [binary format i $len] $sstable_item_data
            incr pos 4
            incr pos $len
            unset sstable_item_data

            lappend output_cols $rev $output_rev_start_pos
        }

        # write row_startpos at end of row
        set row_endpos $pos
        append output_data [binary format i $row_startpos]
        incr pos 4

        lappend output_rows $row_key $row_endpos

        #log "merged file, row_key=$row_key row_endpos=$row_endpos row_startpos=$row_startpos"

    }

    # write merged sstable file

    set name [encode_sstable_name $type_oid]
    set round [clock microseconds]

    array set item [list]
    set item(name) $name
    set item(data) $output_data  ;# [binary encode hex $output_data]
    set item(rows) $output_rows  ;# row_keys 
    set item(cols) $output_cols  ;# col_keys
    set item(round) $round

    # log "merged_sstable_rev for $type_oid"
    set merged_sstable_rev [::sysdb::sstable_t insert item]
    log merged_sstable_rev=$merged_sstable_rev

    set file_i 0
    foreach sstable_rev $sstable_revs {
        close $fp(${file_i})
        file delete $filename(${file_i})
        incr file_i
    }

}


proc ::persistence::ss::compact_all {} {
    variable base_nsp

    ${base_nsp}::compact_all

    set slicelist [::sysdb::object_type_t find]

    foreach rev $slicelist {

        set type_oids [list]

        array set object_type [::sysdb::object_type_t get $rev]
        foreach idx_data $object_type(indexes) {
            array set idx $idx_data
            set cf_axis $object_type(cf).$idx(name)
            set type_oid [join_oid $object_type(ks) $cf_axis]
            lappend type_oids $type_oid
            array unset idx
        }
        array unset object_type

        set todelete_revs [list]
        foreach type_oid $type_oids {
            # merges sstables for type_oid
            if { [catch {
                ::persistence::ss::compact $type_oid todelete_revs
            } errmsg] } {
                log errmsg=$errmsg
                log errorInfo=$::errorInfo
                log exiting
                exit
            }
        }

        # NOTE: delete old sstable files,
        # but only after the new sstable 
        # has been committed/fsync-ed.

        foreach todelete_rev $todelete_revs {
            set sstable_filename [get_cur_filename $todelete_rev]
            file delete $sstable_filename
            log "deleted old sstable: $sstable_filename"
        }

    }

}

after_package_load persistence ::persistence::ss::init
