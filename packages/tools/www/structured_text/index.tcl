array set ::xo::lib::__LOADED_MODULES__ ""
::xo::lib::require structured_text

#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir structured_text/tcl/module-structured_text.tcl]

#set dir [file dirname [info script]]
set dir [acs_root_dir]/lib/structured_text/

set filename [file join $dir data/sample7.stx]
set fp [open $filename]
set data [read $fp]
close $fp

set start_time [clock clicks -milliseconds]
array set config [list root 814 container_object_id 112 image_prefix "/~k2pts/blog/image"]
::xo::structured_text::stx_to_html config data html
set end_time [clock clicks -milliseconds]
set duration1 [expr { $end_time - $start_time }]

set start_time [clock clicks -milliseconds]
set html2 [stx_to_html $data]
set end_time [clock clicks -milliseconds]
set duration2 [expr { $end_time - $start_time }]


doc_return 200 text/plain "
C++: ${duration1}ms
TCL: ${duration2}ms
Debug Mode: [::xo::kit::debug_mode_p]
${html}"