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

        if { [setting_p "bloom_filters"] } {

            wrap_proc [namespace which define_cf] {ks cf_axis} {
                call_orig $ks $cf_axis
                set type_oid [join_oid $ks $cf_axis]
                ::persistence::bloom_filter::init $type_oid
            }

            wrap_proc [namespace which ins_column] {oid data {codec_conf ""}} {
                # log [info frame 0]
                # log "ins_column oid=$oid"
                lassign [split_oid $oid] ks cf_axis row_key column_path
                call_orig $oid $data $codec_conf
                set type_oid [join_oid $ks $cf_axis]
                ::persistence::bloom_filter::insert $type_oid $oid
            }

            wrap_proc [namespace which ins_link] {oid target_oid {codec_conf ""}} {
                # log "ins_link oid=$oid data=$target_oid"
                lassign [split_oid $oid] ks cf_axis row_key column_path
                call_orig $oid $target_oid $codec_conf
                set type_oid [join_oid $ks $cf_axis]
                ::persistence::bloom_filter::insert $type_oid $oid
            }

        }


        if { [setting_p "write_ahead_log"] } {

            # private
            # log which,[namespace which set_column]
            wrap_proc ::persistence::set_column {oid data {mtime ""} {codec_conf ""}} {
                set mtime [clock seconds]

                array set item [list]
                set item(oid) $oid
                set item(data) $data
                set item(mtime) $mtime
                set item(codec_conf) $codec_conf
                
                ::persistence::commitlog::insert item
            }

            # private
            # log which,[namespace which get_column]
            wrap_proc ::persistence::get_column {oid {codec_conf ""}} {
                set exists_p [::persistence::mem::exists_column_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_column $oid $codec_conf]
                }
                set data [call_orig $oid $codec_conf]
                return $data
            }

            # private
            wrap_proc ::persistence::get_link {oid {codec_conf ""}} {
                set exists_p [::persistence::mem::exists_link_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_link $oid $codec_conf]
                }
                set data [call_orig $oid $codec_conf]
                return $data
            }

        }

        if { [setting_p "memtable"] } {

            wrap_proc ::persistence::get_mtime {oid} {
                if { [::persistence::mem::exists_column_p $oid] } {
                    return [::persistence::mem::get_mtime $oid]
                }
                return [call_orig $oid]
            }

            wrap_proc ::persistence::exists_p {oid} {
                set exists_1_p [::persistence::mem::exists_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }
            
            wrap_proc ::persistence::exists_supercolumn_p {oid} {
                set exists_1_p [::persistence::mem::exists_supercolumn_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }

            # private
            #log which,get_files=[namespace which get_leafs] 
            wrap_proc ::persistence::get_leafs {path} {
                set filelist1 [::persistence::mem::get_leafs $path]
                set filelist2 [call_orig $path]
                log mem_get_files=$filelist1
                log fs_get_files=$filelist2
                return [lsort -unique [concat $filelist1 $filelist2]]
            }

            # private
            #log which,get_subdirs=[namespace which get_subdirs] 
            wrap_proc ::persistence::get_subdirs {path} {
                set subdirs_1 [::persistence::mem::get_subdirs $path]
                set subdirs_2 [call_orig $path]
                log mem_get_subdirs=$subdirs_1
                log fs_get_subdirs=$subdirs_2
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

            ins_link
            del_link
            set_link

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

            interp alias \
                {} ::persistence::$procname \
                {} ::db_client::exec_cmd $nsp_which_procname

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
            # log "!!! save_type_to_db $spec(nsp)"
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


