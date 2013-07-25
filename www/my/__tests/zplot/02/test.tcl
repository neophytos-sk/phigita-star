# tcl

set x +

puts [expr 3 $x 4]


set info(a,b,xaxis) 1
set info(a,b,yaxis) 3

set var y
puts $info(a,b,xaxis)
puts $info(a,b,yaxis)
puts $info(a,b,${var}axis)




