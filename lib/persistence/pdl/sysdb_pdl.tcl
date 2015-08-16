set dir [file dirname [info script]]

::persistence::load_types_from_files \
    [lsort [glob -nocomplain -directory $dir *.pdl]]

