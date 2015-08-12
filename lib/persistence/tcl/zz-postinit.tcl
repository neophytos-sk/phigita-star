namespace eval ::persistence {;}

proc ::persistence::init {} {

    # log "initializing db..."

    set storage_type [config get ::persistence "default_storage_type"]

    assert { $storage_type in {fs ss} }

    if { ![setting_p "client_server"] || [use_p "server"] } {

        namespace eval ::persistence \
            "namespace import -force ::persistence::${storage_type}::*"

        if { [setting_p "write_ahead_log"] } {

            wrap_proc ::persistence::fs::exists_column_data_p {oid} {
                set exists_p [call_orig $oid]
                return [expr {
                    [::persistence::mem::exists_column_data_p $oid]
                    || $exists_p
                }]
            }

            wrap_proc ::persistence::fs::set_column_data {oid data {codec_conf ""}} {
                ::persistence::commitlog::set_column_data $oid $data $codec_conf
                ::persistence::mem::set_column_data $oid $data $codec_conf
            }

            wrap_proc ::persistence::fs::get_column_data {oid {codec_conf ""}} {

                set exists_p [::persistence::mem::exists_column_data_p $oid]
                if { $exists_p } {
                    return [::persistence::mem::get_column_data $oid $codec_conf]
                }

                set data [call_orig $oid $codec_conf]

                #::persistence::mem::cache_column_data $oid $data $codec_conf
                return $data
            }

            if {0} {

                wrap_proc ::persistence::fs::get_files {path} {
                    set files [::persistence::mem::get_files $path]
                    return [lunion $files [call_orig $path]]
                }

                wrap_proc ::persistence::fs::get_subdirs {path} {
                    set subdirs [::persistence::mem::get_subdirs $path]
                    return [lunion $subdirs [call_orig $path]]
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


#after_package_load persistence,tcl,leave [list ::persistence::init]
::persistence::init


