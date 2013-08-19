package provide feed_procs 0.1

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri
package require sha1

::xo::lib::require util_procs
::xo::lib::require ttext

set dir [file dirname [info script]]
source [file join $dir xpathfunc_procs.tcl]
source [file join $dir feed_procs.tcl]
source [file join $dir classifier_procs.tcl]



::feed_reader::init
