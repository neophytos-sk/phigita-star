
set dir [file dirname [info script]]

set version "0.1"
set package_name "utilities"
package ifneeded ${package_name} ${version} \
    "source [list [file join $dir tcl module-${package_name}.tcl]]"

