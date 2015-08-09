load [file join $::tcl_platform(os) curses[info sharedlibextension]]

# Order is nswe

array set ldc [list nw j ne m se l sw k nswe n we  q nse t nsw u nwe v swe w ns x bullet ~ diamond `]

proc box {row1 col1 row2 col2} {
    global ldc

    curses attr on alt
    curses move $row1 $col1
    curses puts $ldc(se)
    curses move $row2 $col1
    curses puts $ldc(ne)
    for {set i [expr $row1 + 1] } {$i < $row2} {incr i} {
       curses move $i $col1
       curses puts $ldc(ns)
       curses move $i $col2
       curses puts $ldc(ns)
    }
    for {set i [expr $col1 + 1] } {$i < $col2} {incr i} {
       curses move $row1 $i
       curses puts $ldc(we)
       curses move $row2 $i
       curses puts $ldc(we)
    }
    curses move $row1 $col2
    curses puts $ldc(sw)
    curses move $row2 $col2
    curses puts $ldc(nw)
    curses attr off alt
}


proc menu {row col items} {
    set maxlength 0
    foreach item $items {
       if {[string length $item] > $maxlength} {
           set maxlength [string length $item]
       }
    }
    box $row $col [expr $row + [llength $items] + 1] [expr $col + $maxlength + 2]
    set selected 0
    while {1} {
       if {$selected < 0} {
           set selected 0
       } elseif {$selected > [llength $items] - 1} {
           set selected [expr [llength $items] - 1]
       }
       set i 0
       foreach item $items {
           if {$i == $selected} {
               curses attr on reverse
               set prefix ">"
           } else {
               curses attr off reverse
               set prefix " "
           }
           curses move [expr $row + $i + 1] [expr $col + 1]
           curses puts [format "$prefix%-${maxlength}s" $item]
           incr i
       }
       curses refresh
       binary scan [read stdin 1] c k
       switch $k {
           16 {incr selected -1}
           14 {incr selected 1}
           13 - 10 {return $selected}
           default {
               if {$k >= 0x30 && $k < 0x3A} {
                   set selected [expr $k - 0x30]
               }
           }
       }
    }
}

fconfigure stdin -buffering none
menu 10 10 {alpha beta gamma delta epsilon "A really long string"  "some more junk" "..."}

# http://wiki.tcl.tk/12953
