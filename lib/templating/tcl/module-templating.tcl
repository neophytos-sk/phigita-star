package provide templating 0.1

::xo::lib::require critcl
::xo::lib::require util_procs
::xo::lib::require tdom_procs

set dir [file dirname [info script]]

source [file join $dir templating-config.tcl]
source [file join $dir adp-compiler.tcl]
source [file join $dir templating-compiler.tcl]
source [file join $dir templating-css.tcl]
source [file join $dir templating-js.tcl]
source [file join $dir templating-util.tcl]
source [file join $dir templating-validation.tcl]
source [file join $dir templating-renderer.tcl]
source [file join $dir templating-data.tcl]
source [file join $dir templating-tag.tcl]
source [file join $dir templating.tcl]

