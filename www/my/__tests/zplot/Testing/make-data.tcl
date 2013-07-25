#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*


set size [lindex $argv 0]

for {set i 0} {$i < $size} {incr i} {
    puts "$i $i"
}

