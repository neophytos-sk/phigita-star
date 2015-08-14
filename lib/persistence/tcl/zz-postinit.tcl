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

    file mkdir [file join $base_dir HEAD]  ;# for oids
    file mkdir [file join $base_dir DATA]  ;# for revs
    file mkdir [file join $base_dir META]  ;# for bffs, etc
}

proc ::persistence::init {} {

    # log "initializing db..."

    mkskel

    set storage_type [config get ::persistence "default_storage_type"]

    assert { $storage_type in {fs ss} }

    if { ![setting_p "client_server"] || [use_p "server"] } {

        namespace eval ::persistence \
            "namespace import -force ::persistence::${storage_type}::*"

        if { [setting_p "write_ahead_log"] } {
            wrap_proc ::persistence::fs::set_column {oid data {ts ""} {codec_conf ""}} {
                set ts [clock seconds]
                ::persistence::commitlog::set_column $oid $data $ts $codec_conf
                ::persistence::mem::set_column $oid $data $ts $codec_conf
            }

            wrap_proc ::persistence::fs::get_column {oid {codec_conf ""}} {
                set exists_p [::persistence::mem::exists_column_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_column $oid $codec_conf]
                }
                set data [call_orig $oid $codec_conf]
                return $data
            }

        }

        if { [use_p "memtable"] } {

            wrap_proc ::persistence::fs::get_mtime {oid} {
                if { [::persistence::mem::exists_column_p $oid] } {
                    return [::persistence::mem::get_mtime $oid]
                }
                return [call_orig $oid]
            }

            wrap_proc ::persistence::fs::exists_column_p {oid} {
                set exists_1_p [::persistence::mem::exists_column_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }
            
            wrap_proc ::persistence::fs::exists_supercolumn_p {oid} {
                set exists_1_p [::persistence::mem::exists_supercolumn_p $oid]
                set exists_2_p [call_orig $oid]
                return [expr { $exists_1_p || $exists_2_p }]
            }

            wrap_proc ::persistence::fs::get_files {path} {
                set filelist1 [::persistence::mem::get_files $path]
                set filelist2 [call_orig $path]
                # log mem_get_files=$filelist1
                # log fs_get_files=$filelist2
                return [lunion $filelist1 $filelist2]
            }

            wrap_proc ::persistence::fs::get_subdirs {path} {
                set subdirs_1 [::persistence::mem::get_subdirs $path]
                set subdirs_2 [call_orig $path]
                return [lunion $subdirs_1 $subdirs_2]
            }


        }

        if {0} {

            wrap_proc ::persistence::fs::create_row_if {ks cf_axis row_key row_pathVar} {

                assert_ks ${ks}
                assert_cf ${ks} ${cf_axis}

                upvar ${row_pathVar} row_path

                set row_path [get_row ${ks} ${cf_axis} ${row_key}]

                # NOTE: messes with get_files results when use_memtable is true
                # set row_dir [get_filename ${row_path}]
                # file mkdir $row_dir


            }

            wrap_proc ::persistence::fs::get_name {oid} {
                return [file tail $oid]
            }

            # NOT IMPLEMENTED YET
            wrap_proc ::persistence::fs::set_link_data {oid target_oid {codec_conf ""}} {
                ::persistence::commitlog::set_link_data $oid $target_oid $codec_conf
                ::persistence::mem::cache_link_data $oid $target_oid $codec_conf
            }
        }

    } else {

        set nsp "::persistence::${storage_type}"
        set exported_procs [namespace eval ${nsp} "namespace export"]
        foreach exported_proc $exported_procs {
            interp alias {} ::persistence::$exported_proc {} ::db_client::exec_cmd ${nsp}::$exported_proc
            if { [use_p "threads"] } {
                # TODO: interp alias {} ::persistence::$exported_proc {} apply [list {args} "thread::send $id ${nsp}::$exported_proc {*}$args]
            }
        }

    }


    # TODO: load_all_types_from_db

}


#after_package_load persistence,tcl,leave [list ::persistence::init]
::persistence::init


