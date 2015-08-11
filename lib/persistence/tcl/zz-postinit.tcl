namespace eval ::persistence {

    variable db
    variable base_dir 
    variable storage_types "fs ss"

    # array set ks [list]
    # array set cf [list]

    proc unknown_handler {args} {
        puts "unknown: args=$args"
    }

    namespace unknown unknown_handler

}

proc ::persistence::init_db {db storage_type} {
    variable storage_types

    # log "initializing db..."

    if { ${storage_type} ni ${storage_types} } {
        error "error persistence->init: no such storage_type '${storage_type}'"
    }

    if { ![setting_p "client_server"] || [use_p "server"] } {

        namespace eval ::persistence \
            "namespace import -force ::persistence::${storage_type}::*"

        if { [setting_p "write_ahead_log"] } {

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

                ::persistence::mem::set_column_data $oid $data $codec_conf
                return $data
            }
        }

    } else {

        set nsp "::persistence::${storage_type}"
        set exported_procs [namespace eval ${nsp} "namespace export"]
        foreach exported_proc $exported_procs {
            interp alias {} ::persistence::$exported_proc {} ::db_client::exec_cmd ${nsp}::$exported_proc
            # TODO: interp alias {} ::persistence::$exported_proc {} apply [list {args} "thread::send $id ${nsp}::$exported_proc {*}$args]
        }

    }
}


#after_package_load persistence,tcl,enter [list ::persistence::init_db mystore fs]
::persistence::init_db mystore fs


