# source the library
source zplot.tcl
namespace import Zplot::*

# read in the file into a table called bar1
Table -table nitin -file "data.heatorig"

# select subrange of data (y-value less than eleven in this case)
Table -table plot -columns time,syscall
TableSelect -from nitin -fcolumns time,syscall -where {$syscall <= 11} -to plot -tcolumns time,syscall

# bucketize data and put into new table 'bucketized'
Table -table bucketized -columns time,syscall,count
TableBucketize -from plot -fcolumns time,syscall \
    -xbucketsize 0.1 -ybucketsize 1.0 \
    -to bucketized -tcolumns time,syscall,count 

# store new table into a file
TableStore -table bucketized -file "data.heat"

