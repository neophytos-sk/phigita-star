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

proc is_server_p {} {
    return [info exists ::__is_server_p]
}

proc ::persistence::init_db {db storage_type} {
    variable storage_types

    if { ${storage_type} ni ${storage_types} } {
        error "error persistence->init: no such storage_type '${storage_type}'"
    }

    if { 1 || [is_server_p] } {
        namespace eval ::persistence "namespace import -force ::persistence::${storage_type}::*"
    } else {
        set nsp "::persistence::${storage_type}"
        set exported_procs [namespace eval ${nsp} "namespace export"]
        foreach exported_proc $exported_procs {
            interp alias {} ::persistence::$exported_proc {} ::db_client::exec_cmd ${nsp}::$exported_proc
        }
    }
}

# after_package_load ::persistence::init_db mystore fs
::persistence::init_db mystore fs


