source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require tcalc

puts [tcalc::eval { 5 * 3}]
puts [tcalc::eval { 5 * pi}]
