namespace eval ::persistence {

    variable base_dir
    set base_dir [config get ::persistence base_dir]

}

proc ::persistence::compare_mtime { oid1 oid2 } {
    set mtime1 [::persistence::get_mtime $oid1]
    set mtime2 [::persistence::get_mtime $oid2]
    if { $mtime1 < $mtime2 } {
        return -1
    } elseif { $mtime1 > $mtime2 } {
        return 1
    } else {
        return 0
    }
}


proc ::persistence::mkskel {} {
    variable base_dir

    file mkdir [file join $base_dir HEAD]  ;# oids, tip of the current branch
    file mkdir [file join $base_dir DATA]  ;# revs
    file mkdir [file join $base_dir META]  ;# CommitLog
    file mkdir [file join $base_dir tmp]   ;# fs::read_committed__set_column
}

proc ::persistence::init {} {

    # log "initializing db..."

    mkskel

    set storage_type [config get ::persistence "default_storage_type"]

    assert { $storage_type in {fs ss} }

    namespace path "::persistence::$storage_type ::persistence::common"

    if { ![setting_p "client_server"] || [use_p "server"] } {

        namespace import -force ::persistence::common::*
        namespace import -force ::persistence::${storage_type}::*


        if { [setting_p "write_ahead_log"] } {

            # private
            # log which,[namespace which set_column]
            wrap_proc ::persistence::set_column {oid data xid codec_conf} {
                lassign [split_xid $xid] micros pid n_mutations mtime

                array set item [list]
                set item(oid) $oid
                set item(data) $data
                set item(xid) $xid
                set item(codec_conf) $codec_conf
                
                ::persistence::commitlog::insert item
            }

            # private
            # log which,[namespace which get_column]
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

            wrap_proc ::persistence::begin_batch {} {
                set xid [call_orig]
                ::persistence::mem::begin_batch $xid
            }

            wrap_proc ::persistence::end_batch {} {
                set xid [call_orig]
                ::persistence::mem::end_batch $xid
            }

            wrap_proc ::persistence::define_cf {ks cf_axis} {
                call_orig $ks $cf_axis
                ::persistence::mem::define_cf $ks $cf_axis
            }

            wrap_proc ::persistence::get_mtime {rev} {
                if { [::persistence::mem::exists_column_rev_p $rev] } {
                    return [::persistence::mem::get_mtime $rev]
                }
                return [call_orig $rev]
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

            wrap_proc ::persistence::get_files {path} {
                set filelist1 [::persistence::mem::get_files $path]
                set filelist2 [call_orig $path]
                #log mem_get_files=$filelist1
                #log fs_get_files=$filelist2
                return [lsort -unique [concat $filelist1 $filelist2]]
            }

            wrap_proc ::persistence::get_subdirs {path} {
                set subdirs_1 [::persistence::mem::get_subdirs $path]
                set subdirs_2 [call_orig $path]
                #log mem_get_subdirs=$subdirs_1
                #log fs_get_subdirs=$subdirs_2
                return [lsort -unique [concat $subdirs_1 $subdirs_2]]
            }

        }

    } else {

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
        }

        foreach procname $procnames {

            set nsp_which_procname [namespace which $procname]

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
        array set spec \
            [set data($filename) \
                [::util::readfile $filename]]

        load_type spec
        array unset spec
    }

    # TODO: if client, broadcast to servers to reload types from db

    foreach filename $filelist {
        array set spec $data($filename)

        set where_clause [list [list nsp = $spec(nsp)]]
        set oid [::sysdb::object_type_t 0or1row $where_clause]

        if { $oid ne {} } {
            # TODO: integrity check
        } else {
             # log "*** save_type_to_db $spec(nsp)"
            ::sysdb::object_type_t insert spec
        }

        assert { [::sysdb::object_type_t exists $where_clause] } {
            ::persistence::mem::printall
        }

        array unset spec
    }
}

proc ::persistence::load_type {specVar} {
    upvar $specVar spec

    namespace eval $spec(nsp) {
        # see core/tcl/namespace.tcl for details about "mixin" namespaces
        namespace __mixin ::persistence::orm
    }
    namespace upvar $spec(nsp) __spec __spec
    array set __spec [array get spec]

    $spec(nsp) init_type

    assert { [namespace exists $spec(nsp)] }

}

proc ::persistence::load_all_types_from_db {} {
    set slicelist [::sysdb::object_type_t find]
    foreach oid $slicelist {
        # log "!!! load_type_from_db $oid"
        array set spec [::sysdb::object_type_t get $oid]
        load_type spec
        array unset spec
    }
}

#after_package_load persistence,tcl,leave [list ::persistence::init]
::persistence::init

# TODO: check for new types (on the server side)
after_package_load persistence ::persistence::load_all_types_from_db


