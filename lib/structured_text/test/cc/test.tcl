load /opt/naviserver/lib/libnsd.so
package require tdom
source /web/service-phgt-0/packages/kernel/tcl/20-xo/structured_text-procs.tcl
package require critcl

set fp [open sample.html]
set data [read $fp]
close $fp

# If -simple is specified, a simple but fast parser is used (conforms not fully
# to XML recommendation). That should double parsing and DOM generation speed. 
# The encoding of the data is not transformed inside the parser. The simple 
# parser does not respect any encoding information in the XML declaration. It 
# skips over the internal DTD subset and ignores any information in it. 
# Therefor it doesn't include defaulted attribute values into the tree, even if
# the according attribute declaration is in the internal subset. It also 
# doesn't expand internal or external entity references other than the
# predefined entities and character references.

dom createNodeCmd element test
dom createNodeCmd element div
dom createNodeCmd element img
dom createNodeCmd text t


set start [clock clicks -milliseconds]
::xo::structured_text::to_html data html
set end [clock clicks -milliseconds]
puts $html

puts "Time Duration: [expr { $end - $start }]ms"