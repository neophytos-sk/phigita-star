# source the library
source libs.tcl
namespace import Zplot::*

# read in the file into a table called bar1
TableLoad -table nitin -file "data.heatorig"
# puts "Columns are: [TableColNames nitin]"

# select subrange of data
Table -table plot -columns time,syscall
TableSelect -from nitin -fcolumns time,syscall -where {$syscall <= 11} -to plot -tcolumns time,syscall

# bucketize data
set rows [TableGetNumRows plot]
for {set r 0} {$r < $rows} {incr r} {
    set time    [TableGetVal plot time $r]
    set syscall [TableGetVal plot syscall $r]
    set itime   [expr int($time * 10.0)]
    if {[info exists data($itime,$syscall)] == 0} {
	set data($itime,$syscall) 1
    } else {
	incr data($itime,$syscall)
    }
}

# store results in new table
Table -table "output" -columns "x,y,heat"

foreach index [array names data] {
    set vals [split $index ","]
    set itime   [lindex $vals 0]
    set syscall [lindex $vals 1]
    TableAddVal "output" "x,$itime : y,$syscall : heat,$data($itime,$syscall)"
}

TableStore -table output -file "data.heat"

exit 0
