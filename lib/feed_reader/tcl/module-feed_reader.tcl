package provide feed_reader 0.1

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri
package require sha1

::xo::lib::require util_procs
::xo::lib::require ttext

set dir [file dirname [info script]]
set package_dir [file normalize [file join ${dir} ..]]

namespace eval ::feed_reader {;}

proc ::feed_reader::get_package_dir {} "return ${package_dir}"

proc ::feed_reader::get_conf_dir {} "return ${package_dir}/conf"

source [file join $dir xpathfunc_procs.tcl]
source [file join $dir feed_procs.tcl]
source [file join $dir crawler_procs.tcl]
source [file join $dir generate_procs.tcl]
source [file join $dir classifier_procs.tcl]



::feed_reader::init
