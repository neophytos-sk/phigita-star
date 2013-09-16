
set dir [file dirname [info script]]

package ifneeded struct/heapq 0.1 \
    [list source [file join $dir tcl module-heapq.tcl]]

