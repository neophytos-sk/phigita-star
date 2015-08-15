set dir [file dirname [info script]]

::persistence::load_type_from_file [file join $dir sysdb.object_type_t.pdl]
::persistence::load_type_from_file [file join $dir sysdb.attribute_t.pdl]
::persistence::load_type_from_file [file join $dir sysdb.index_t.pdl]
::persistence::load_type_from_file [file join $dir sysdb.bloom_filter_t.pdl]

