namespace eval ::persistence {

    variable db
    variable base_dir 
    variable storage_types "fs ss"

    array set ks [list]
    array set cf [list]

    proc unknown_handler {args} {
        puts "unknown: args=$args"
    }

    namespace unknown unknown_handler

}

proc ::persistence::init_db {db storage_type} {
    variable storage_types
    if { ${storage_type} ni ${storage_types} } {
        error "error persistence->init: no such storage_type '${storage_type}'"
    }
    namespace eval ::persistence "namespace import -force ::persistence::${storage_type}::*"
}

# after_package_load ::persistence::init_db mystore fs
::persistence::init_db mystore fs


