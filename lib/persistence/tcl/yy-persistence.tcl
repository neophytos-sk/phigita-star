namespace eval ::persistence {

    variable base_dir
    set base_dir [config get ::persistence base_dir]

}

proc ::persistence::define_ks {args} {}
proc ::persistence::define_cf {args} {}

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

        # init_type, which is called by load_type, 
        # should precede install_type invocation
        load_type spec

        # install_type is a server-side proc,
        # calls define_ks and define_cf
        if { [use_p server] } {
            $spec(nsp) install_type
        }
        array unset spec
    }

    install_types_from_files $filelist
}

proc ::persistence::install_types_from_files {filelist} {

    set reload_types_p 0
    foreach filename $filelist {
        array set spec \
            [set data($filename) \
                [::util::readfile $filename]]

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



