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
Table -table bucketized -columns time,syscall,count
TableBucketize -from plot -fcolumns time,syscall \
    -xbucketsize 10.0 -ybucketsize 1.0 \
    -to bucketized -tcolumns time,syscall,count 

proc TableBucketize {args} {
    set default {
	{"from"         ""         "table to get raw data from"}
	{"fcolumns"     "x,y"      "columns to get data from"}
	{"to"           ""         "table to put data into"}
	{"tcolumns"     "x,y,heat" "columns to put data into"}
	{"xbucketsize"  "1.0"      "size of each bucket for first fcolumn (x)"}
	{"ybucketsize"  "1.0"      "size of each bucket for second fcolumn (x)"}
    }

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
