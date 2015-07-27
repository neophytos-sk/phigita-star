package provide feed_reader 0.1

package require curl
package require tdom_procs
package require util_procs
package require htmltidy
package require persistence


# tcllib
package require uri
package require sha1

package require util_procs
package require ttext

set dir [file dirname [info script]]
set package_dir [file normalize [file join ${dir} ..]]

namespace eval ::feed_reader {;}

proc ::feed_reader::get_package_dir {} "return ${package_dir}"

proc ::feed_reader::get_conf_dir {} "return ${package_dir}/conf"

source [file join $dir newsdb_pdl.tcl]
source [file join $dir xpathfunc_procs.tcl]
source [file join $dir feed_procs.tcl]
source [file join $dir crawler_procs.tcl]
source [file join $dir generate_procs.tcl]
source [file join $dir classifier_procs.tcl]



::feed_reader::init
