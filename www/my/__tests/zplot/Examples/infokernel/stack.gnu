set terminal postscript eps color solid 20
set output 'stack.eps'

set xlabel "Target Replacement Algorithm"
set ylabel "Time per Read (usec)"

set title "InfoReplace Overheads"

set key 0.3,9

set xtics ("FIFO" 0, "LRU" 1, "MRU" 2, "LFU" 3);

set yrange [0:10]
set xrange [-0.5:3.5]

set label "100" at 2.6,8

plot \
'times.4.dat' t 'Misc' w impulses, \
'times.3.dat' t 'Sim' w impulses, \
'times.2.dat' t 'Refresh' w impulses, \
'times.1.dat' t 'Check' w impulses

