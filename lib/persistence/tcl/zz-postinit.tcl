namespace eval ::persistence {;}

proc ::persistence::init {} {

    # log "initializing db..."

    set storage_type [config get ::persistence "default_storage_type"]

    assert { $storage_type in {fs ss} }

    if { ![setting_p "client_server"] || [use_p "server"] } {

        namespace eval ::persistence \
            "namespace import -force ::persistence::${storage_type}::*"

        if { [setting_p "write_ahead_log"] } {

            wrap_proc ::persistence::fs::set_column_data {oid data {codec_conf ""}} {
                ::persistence::commitlog::set_column_data $oid $data $codec_conf
                ::persistence::mem::cache_column_data $oid $data $codec_conf
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


