package require core
package require util_procs

package provide persistence 0.1

set dir [file dirname [info script]]
set package_dir [file normalize [file join ${dir} ..]]

namespace eval ::persistence {;}

proc ::persistence::get_package_dir {} "return ${package_dir}"

proc ::persistence::get_conf_dir {} "return ${package_dir}/conf"

# file join $dir nest-lang.tcl

set filelist {
    commitlog.tcl
    memtable.tcl
    storage_fs.tcl
    storage_ss.tcl
    data_procs.tcl
    orm.tcl
    orm_codec.tcl
    sysdb_pdl.tcl
}

foreach filename $filelist {
    source [file normalize [file join $dir $filename]]
}



