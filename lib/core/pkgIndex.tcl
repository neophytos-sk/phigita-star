set version 0.1

set dir [file dirname [info script]]
set package_name [file tail [file normalize ${dir}]]

# interpreter does not know about ::load_package at this stage
source [file join ${dir} tcl package.tcl]

package ifneeded ${package_name} ${version} \
    "::load_package ${package_name} ${dir} ${version}"
                           
