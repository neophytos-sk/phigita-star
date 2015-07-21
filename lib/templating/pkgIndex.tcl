set version 0.1

set dir [file dirname [info script]]
set package_name [file tail [file normalize ${dir}]]

package ifneeded ${package_name} ${version} \
    "::load_package ${package_name} ${dir} ${version}"
