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

            # private
            wrap_proc ::persistence::fs::set_column {oid data {ts ""} {codec_conf ""}} {
                set ts [clock seconds]
                ::persistence::commitlog::set_column $oid $data $ts $codec_conf
                ::persistence::mem::set_column $oid $data $ts $codec_conf
            }

            # private
            wrap_proc ::persistence::fs::get_column {oid {codec_conf ""}} {
                set exists_p [::persistence::mem::exists_column_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_column $oid $codec_conf]
                }
                set data [call_orig $oid $codec_conf]
                return $data
            }

            # private
            wrap_proc ::persistence::fs::get_link {oid {codec_conf ""}} {
                set exists_p [::persistence::mem::exists_link_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_link $oid $codec_conf]
                }
                set data [call_orig $oid $codec_conf]
                return $data
            }

        }

        if { [use_p "memtable"] } {

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
            wrap_proc ::persistence::fs::get_files {path} {
                set filelist1 [::persistence::mem::get_files $path]
                set filelist2 [call_orig $path]
                # log mem_get_files=$filelist1
                # log fs_get_files=$filelist2
                return [lunion $filelist1 $filelist2]
            }

            # private
            wrap_proc ::persistence::fs::get_subdirs {path} {
                set subdirs_1 [::persistence::mem::get_subdirs $path]
                set subdirs_2 [call_orig $path]
                return [lunion $subdirs_1 $subdirs_2]
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


}


proc ::persistence::load_type_from_file {filename} {
    array set spec [::util::readfile $filename]
    load_type spec
    # TODO: if client, broadcast to servers to reload types from db
}

proc ::persistence::load_type {specVar} {
    upvar $specVar spec

    # log spec=[array get spec]

    namespace eval $spec(nsp) {
        # see core/tcl/namespace.tcl for details about "mixin" namespaces
        namespace __mixin ::persistence::orm
    }
    namespace upvar $spec(nsp) __spec __spec
    array set __spec [array get spec]

    $spec(nsp) init_type
}

proc ::persistence::load_all_types_from_db {} {
    set slicelist [::sysdb::object_type_t find]
    foreach oid $slicelist {
        #log "loading type $oid"
        array set spec [::sysdb::object_type_t get $oid]
        load_type spec
        array unset spec
    }
}

#after_package_load persistence,tcl,leave [list ::persistence::init]
::persistence::init

# TODO: check for new types (on the server side)
after_package_load persistence ::persistence::load_all_types_from_db


