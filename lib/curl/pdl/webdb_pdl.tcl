set dir [file dirname [info script]]
::persistence::load_types_from_files [glob -nocomplain -directory $dir "*.pdl"]

