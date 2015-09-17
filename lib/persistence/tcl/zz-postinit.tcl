namespace eval ::persistence {

    variable base_dir
    set base_dir [config get ::persistence base_dir]

}

proc ::persistence::compare_timestamp { rev1 rev2 } {
    set ts1 [::persistence::get_timestamp $rev1]
    set ts2 [::persistence::get_timestamp $rev2]
    if { $ts1 < $ts2 } {
        return -1
    } elseif { $ts1 > $ts2 } {
        return 1
    } else {
        return 0
    }
}

proc ::persistence::compare_files { rev1 rev2 } {
    lassign [split $rev1 {@}] oid1 _ts1
    lassign [split $rev2 {@}] oid2 _ts2

    set oid_compare_result [string compare $oid1 $oid2]

    if { $oid_compare_result != 0 } {
        return $oid_compare_result
    } else {
        return [compare_timestamp $rev1 $rev2]
    }
    
}

proc ::persistence::get_timestamp {rev} {
    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    return $ts
}

proc ::persistence::reload_types {} {
    log "request to reload types"
    if { [setting_p "write_ahead_log"] } {
        ::persistence::commitlog::process
    }
    load_types_from_db
}

proc ::persistence::mkskel {} {
    variable base_dir

    file mkdir [file join $base_dir tmp]
    file mkdir [file join $base_dir new]
    file mkdir [file join $base_dir cur]  ;# tip of the current branch
}

proc ::persistence::init {} {

    # log "initializing db..."

    mkskel

    # OLD: ::persistence::fs::init

    set storage_type [setting "storage_type"]
    assert { $storage_type in {fs ss} }

    if { ![setting_p "client_server"] || [use_p "server"] } {

        # namespace path "::persistence::ss"
        # namespace import -force ::persistence::${storage_type}::*
        namespace __copy ::persistence::ss


        if { [setting_p "write_ahead_log"] } {

            # private
            # log which,[namespace which set_column]
            wrap_proc ::persistence::set_column {oid data xid codec_conf} {
                ::persistence::commitlog::insert $oid $data $xid $codec_conf
            }

            # private
            #log which,[namespace which get_column]
            wrap_proc ::persistence::get_column {rev {codec_conf ""}} {
                assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] }
                set exists_p [::persistence::mem::exists_column_rev_p $rev]
                if { $exists_p } {
                    return [::persistence::mem::get_column $rev $codec_conf]
                }
                set data [call_orig $rev $codec_conf]
                return $data
            }

            # private
            # log which,[namespace which get_link]
            wrap_proc ::persistence::get_link {rev {codec_conf ""}} {
                assert { [is_link_rev_p $rev] } 
                set exists_p [::persistence::mem::exists_link_rev_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_link $rev $codec_conf]
                }
                set data [call_orig $rev $codec_conf]
                return $data
            }

        }

        if { [setting_p "memtable"] } {

            wrap_proc ::persistence::begin_batch {{xid ""}} {
                set xid [call_orig]
                # log begin_batch,xid=$xid
                ::persistence::commitlog::begin_batch $xid
                return $xid
            }

            wrap_proc ::persistence::end_batch {{xid ""}} {
                set xid [call_orig]
                # log end_batch,xid=$xid
                ::persistence::commitlog::end_batch $xid
                return $xid
            }

            wrap_proc ::persistence::define_cf {ks cf_axis} {
                call_orig $ks $cf_axis
                ::persistence::mem::define_cf $ks $cf_axis
            }

            wrap_proc ::persistence::get_mtime {rev} {
                #if { [::persistence::mem::exists_p $rev] } {
                    return [::persistence::mem::get_mtime $rev]
                #}
                #return [call_orig $rev]
            }

            # log which,[namespace which exists_p]
            wrap_proc ::persistence::exists_p {oid} {
                # log exists_p,oid=$oid
                set exists_1_p [::persistence::mem::exists_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }
            
            wrap_proc ::persistence::exists_supercolumn_p {oid} {
                set exists_1_p [::persistence::mem::exists_supercolumn_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }

            if { [setting_p "critbit_tree"] } {
                # log "!!! critbit_tree"
                wrap_proc ::persistence::get_files {path} {
                    set filelist_1 [::persistence::critbit_tree::get_files $path]
                    #log cbt_get_files=$filelist_1
                    if { $filelist_1 ne {} } {
                        return $filelist_1
                    }
                    set filelist_2 [call_orig $path]
                    #log fs_get_files=$filelist_2
                    return [lsort -unique -command ::persistence::compare_files \
                        [concat $filelist_1 $filelist_2]]
                }
                wrap_proc ::persistence::get_subdirs {path} {
                    set subdirs_1 [::persistence::critbit_tree::get_subdirs $path]
                    if { $subdirs_1 ne {} } {
                        return $subdirs_1
                    }
                    set subdirs_2 [call_orig $path]
                    return [lsort -unique [concat $subdirs_1 $subdirs_2]]
                }
            } elseif { [setting_p "memtable"] } {
                wrap_proc ::persistence::get_files {path} {
                    set filelist1 [::persistence::mem::get_files $path]
                    set filelist2 [call_orig $path]
                    #log mem_get_files=$filelist1
                    #log fs_get_files=$filelist2
                    return [lsort -unique -command ::persistence::compare_files \
                        [concat $filelist1 $filelist2]]
                }

                wrap_proc ::persistence::get_subdirs {path} {
                    set subdirs_1 [::persistence::mem::get_subdirs $path]
                    set subdirs_2 [call_orig $path]
                    #log mem_get_subdirs=$subdirs_1
                    #log fs_get_subdirs=$subdirs_2
                    return [lsort -unique [concat $subdirs_1 $subdirs_2]]
                }
            }

        }

    } else {

        # namespace path "::persistence::ss"

        set procnames {
            define_ks
            define_cf

            exists_p
            get

            ins_column
            del_column
            set_column
            get_column
            find_column

            ins_link
            del_link

            get_slice
            multiget_slice

            get_multirow
            get_multirow_names

            exists_supercolumn_p

            sort
            get_mtime
            begin_batch
            end_batch

            join_oid
            split_oid
            typeof_oid

            ls
            get_leafs

            reload_types
        }

        foreach procname $procnames {

            # set nsp_which_procname [namespace which $procname]
            set nsp_which_procname ::persistence::${storage_type}::$procname
            if { $procname eq {reload_types} } {
                set nsp_which_procname ::persistence::reload_types
            }

            assert { $nsp_which_procname ne {} } {
                log procname=$procname
            }

            #log $nsp_which_procname

            interp alias \
                {} ::persistence::$procname \
                {} ::db_client::exec_cmd ::persistence::$procname
            
            if { [use_p "threads"] } {
                # TODO: 
                # set cmd "thread::send $id [namespace which $procname] {*}$args"
                # interp alias \
                #   {} ::persistence::$procname \
                #   {} apply [list {args} $cmd]
            }
        }

    }


}


proc ::persistence::load_types_from_files {filelist} {

    # we batch load to ensure ::sysdb::* types work
    array set data [list]
    foreach filename $filelist {
        # log "loading type from file: $filename"
        array set spec \
            [set data($filename) \
                [::util::readfile $filename]]

        assert { [info exists spec(nsp)] } {
            log spec=[array get spec]
        }

        install_type spec
        array unset spec
    }

    set reload_types_p 0
    foreach filename $filelist {
        array set spec $data($filename)

        set where_clause [list [list nsp = $spec(nsp)]]
        set oid [::sysdb::object_type_t 0or1row $where_clause]

        if { $oid ne {} } {
            # TODO: integrity check
            set changed_p 0
            if { !$changed_p } {
                continue
            }
        } else {
             # log "*** save_type_to_db $spec(nsp)"
            ::sysdb::object_type_t insert spec
        }

        # assert { [::sysdb::object_type_t exists $where_clause] } {
        #    log "failed to find type $spec(nsp)"
        #    ::persistence::reload_types
        # }

        if { !$reload_types_p && $spec(ks) eq {sysdb} } {
            set reload_types_p 1
        }

        array unset spec
    }

    # covers case when client introduces a new object type
    # that the server instances are not yet aware, and so
    # they are notified to reload types from db
    if { $reload_types_p } {
        ::persistence::reload_types
    }
}

proc ::persistence::load_type {specVar} {
    upvar $specVar spec

    assert { [info exists spec(nsp)] } {
        log spec=[array get spec]
    }

    namespace eval $spec(nsp) {
        # see core/tcl/namespace.tcl for details about "mixin" namespaces
        namespace __mixin ::persistence::orm

        #set storage_type [config get ::persistence storage_type]
        #namespace path "::persistence::${storage_type}"

        namespace path "::persistence::ss"
    }
    namespace upvar $spec(nsp) __spec __spec
    array set __spec [array get spec]

    $spec(nsp) init_type

    assert { [namespace exists $spec(nsp)] }

}

proc ::persistence::install_type {specVar} {
    upvar $specVar spec

    load_type spec

    # init_type, which is called by load_type, 
    # precedes install_type invocation

    $spec(nsp) install_type
}

proc ::persistence::load_types_from_db {} {
    set slicelist [::sysdb::object_type_t find]
    #log "load_types_from_db,slicelist=$slicelist"
    foreach rev $slicelist {
        # log "!!! load_type_from_db $rev"
        array set spec [::sysdb::object_type_t get $rev]
        load_type spec
        array unset spec
    }
}

#after_package_load persistence,tcl,leave [list ::persistence::init]
::persistence::init

# TODO: check for new types (on the server side)
after_package_load persistence ::persistence::load_types_from_db


proc ::persistence::import_pdl {package_dir} {
    set dir [file dirname [info script]]
    set root_dir [file normalize [file join $dir ../../../]]
    set dir [file normalize [file join $root_dir $package_dir pdl]]
    assert { [file isdirectory $dir] }
    set pattern "*.pdl"
    set filelist [lsort [glob -nocomplain -directory $dir $pattern]]
    log filelist=$filelist
    load_types_from_files $filelist
    reload_types
}
