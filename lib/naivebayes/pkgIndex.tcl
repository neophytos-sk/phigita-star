
set dir [file dirname [info script]]

set package_name [file tail ${dir}]

package ifneeded ${package_name} 0.1 \
    "source [list [file join $dir tcl module-${package_name}.tcl]]"

