#!/bin/sh
 # The next line is executed by /bin/sh, but not tcl \
     exec tclsh "$0" ${1+"$@"}

 # con-editor.tcl a linux console based editor in pure tcl
 # 2004-06-16 Steve Redler IV
 # 2005-05-04 mods by Hobbs to work in any terminal size, clean up code
 #            and add more key functionality, tab handling
 # 2006-03-17 bugfix for cursor-left & for terms that report 0 cols & rows
 #            place cursor at home after file is loaded
 #            bugfix: allow inserting text to blank lines
 # 2006-06-16 slebetman, added search and goto line functionality
 #            bugfix: removed extra newline each time a file is saved
 #            added handling for Home and End keys.

 set filename [lindex $argv 0]
 set searchpattern ""

 proc handleSearch {} {
 uplevel 1 {
     global searchpattern
     status "Search: $searchpattern"

     if {$searchpattern != ""} {
         set found [lsearch -regexp \
             [lrange $BUFFER \
             [expr {$bufRow+1}] end] $searchpattern]
         if {$found == -1} {
             set found [lsearch -regexp $BUFFER $searchpattern]
             if {$found != -1} {
                 set bufRow $found
             }
         } else {
             incr bufRow $found
             incr bufRow
         }
         if {$found != -1} {
             set C [regexp -indices -inline $searchpattern \
                 [lindex $BUFFER $bufRow]]
             set bufCol [lindex [lindex $C 0] 0]
         } else {
             status "Search: $searchpattern (not found!)"
         }
     }

     if {$bufRow < $viewRow} {
         set viewRow 0
     }
 }
 }

 proc getInput {f {txt ""}} {
     upvar 1 $f fid

     status ""
     goto end 1
     puts -nonewline "$txt "
     flush stdout
     set ret ""
     while {[set ch [read $fid 1]] != "\n" && $ch != "\r"} {
         if {$ch == ""} continue
         if {$ch == "\u007f"} {
             # handle backspace:
             set ret [string range $ret 0 end-1]
         } else {
             append ret $ch
         }
         set stat "$txt $ret"
         status $stat
         goto end [expr [string length $stat]+1]
         flush stdout
     }
     return $ret
 }

 proc edittext {fid} {
     global BUFFER IDX

     set viewRow 1    ; # row idx into view area, 1-based
     set viewCol 1    ; # col idx into view area, 1-based
     set bufRow 0    ; # row idx into full buffer, 0-based
     set bufCol 0    ; # col idx into full buffer, 0-based
     set IDX(ROWLAST) -1    ; # last row most recently displayed in view
     set IDX(COLLAST) -1    ; # last col most recently displayed in view
     set char ""        ; # last char received
     set line [lindex $BUFFER $bufRow] ; # line data of current line

     display $bufRow $bufCol
     home; flush stdout

     while {$char != "\u0011"} {
     set char [read $fid 1]
     if {[eof $fid]} {return done}

     # Control chars start at a == \u0001 and count up.
     switch -exact -- $char {
         \u0011 { # ^q - quit
             return done
         }
         \u0001 { # ^a - beginning of line
             set bufCol 0
         }
         \u0004 { # ^d - delete
             if {$bufCol > [string length $line]} {
                 set bufCol [string length $line]
             }
             set line [string replace $line $bufCol $bufCol]
             set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
             set IDX(COLLAST) -1 ; # force redraw
         }
         \u0005 { # ^e - end of line
             set bufCol [string length $line]
         }
         \u0006 { ;# ^f - find/search
             global searchpattern
             set searchpattern [getInput fid "Search:"]
             handleSearch
         }
         \u0007 { ;# ^g - goto line
             if [string is integer [set n [getInput fid "Goto Line:"]]] {
                 set bufRow [expr {$n-1}]
                 if {$bufRow < $viewRow} {
                     set viewRow 0
                 } else {
                     set len [llength $BUFFER]
                     if {$bufRow > $len} {
                         set bufRow [expr {$len-1}]
                     }
                 }
             }
         }
         \u000a { # ^j - insert last yank
             set currline [string range $line 0 [expr {$bufCol - 1}]]
             set BUFFER [lreplace $BUFFER $bufRow $bufRow $currline]

             incr bufRow
             incr viewRow
             set BUFFER [linsert $BUFFER $bufRow \
                     [string range $line $bufCol end]]
             set IDX(COLLAST) -1 ; # force redraw
             set line [lindex $BUFFER $bufRow]
             set bufCol 0
         }
         \u0019 { # ^y - yank line
             if {$bufRow < [llength $BUFFER]} {
                 set BUFFER [lreplace $BUFFER $bufRow $bufRow]
                 set IDX(COLLAST) -1 ; # force redraw
             }
         }
         \u0008 -
         \u007f { # ^h && backspace ?
             if {$bufCol != 0} {
                 if {$bufCol > [string length $line]} {
                 set bufCol [string length $line]
                 }
                 incr bufCol -1
                 set line [string replace $line $bufCol $bufCol]
                 set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
                 set IDX(COLLAST) -1 ; # force redraw
             }
         }
         \u001b { # ESC - handle escape sequences
             set next [read $fid 1]
             if {$next == "\["} { ; # \[
                 set next [read $fid 1]
                 switch -exact -- $next {
                     A { # Cursor Up (cuu1,up)
                         if {$bufRow > 0} {
                         incr bufRow -1
                         incr viewRow -1
                         }
                     }
                     B { # Cursor Down
                         if {$bufRow < [expr {[llength $BUFFER] - 1}]} {
                         incr bufRow 1
                         incr viewRow 1
                         }
                     }
                     C { # Cursor Right (cuf1,nd)
                         if {$bufCol < [string length $line]} {
                         incr bufCol 1
                         }
                     }
                     D { # Cursor Left
                         if {$bufCol > [string length $line]} {
                         set bufCol [string length $line]
                                     }
                         if {$bufCol > 0} { incr bufCol -1 }
                     }
                     H { # Cursor Home
                         set bufCol 0
                         set bufRow 0
                         set viewRow 1
                     }
                     1 { # check for F3/Home
                         set next [read $fid 1]
                         if {$next == "~"} {
                             # Home:
                             set bufCol [regexp -indices -inline -- \
                                 {^[[:space:]]*} $line]
                             set bufCol [lindex [lindex $bufCol 0] 1]
                             incr bufCol 1
                         } elseif {$next == "3" && [read $fid 1] == "~"} {
                             # F3:
                             handleSearch
                         }
                     }
                     3 { # delete
                         set next [read $fid 1]
                         if {$bufCol > [string length $line]} {
                         set bufCol [string length $line]
                         }
                         set line [string replace $line $bufCol $bufCol]
                         set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
                         set IDX(COLLAST) -1 ; # force redraw
                     }
                     4 { # end
                         if {[read $fid 1] == "~"} {
                             set bufCol [string length $line]
                         }
                     }
                     5 { # 5 Prev screen
                         if {[read $fid 1] == "~"} {
                         set size [expr {$IDX(ROWMAX) - 1}]
                         if {$bufRow < $size} {
                             set bufRow  0
                             set viewRow 1
                         } else {
                             incr bufRow  -$size
                             incr viewRow -$size
                         }
                         }
                     }
                     6 { # 6 Next screen
                         if {[read $fid 1] == "~"} {
                         set size [expr {$IDX(ROWMAX) - 1}]
                         incr bufRow  $size
                         incr viewRow $size
                         if {$bufRow >= [llength $BUFFER]} {
                             set viewRow [llength $BUFFER]
                             set bufRow  [expr {$viewRow - 1}]
                         }
                         }
                     }
                 }
             }
             # most of the above cause a BUFFER row change
             set line [lindex $BUFFER $bufRow]
         }
         default {
             set line [string range $line 0 [expr $bufCol - 1]]
             append line $char
             append line [string range $line $bufCol end]

             set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
             incr bufCol [string length $char]
             if {$bufCol > [string length $line]} {
                 set bufCol [string length $line]
             }
             set IDX(COLLAST) -1 ; # force redraw
         }

     }

     # Constrain current view idx
     if {$viewRow <= 1} {set viewRow 1}
     if {$viewRow >= ($IDX(ROWMAX) - 1)} {
         set viewRow [expr {$IDX(ROWMAX) - 1}]
     }
     set viewCol [expr {$bufCol + 1}]
     if {$viewCol >= $IDX(COLMAX)} {set viewCol $IDX(COLMAX)}

     # start and end view area to display
     set startRow [expr {$bufRow + 1 - $viewRow}]
     set startCol [expr {$bufCol + 1 - $viewCol}]

     display $startRow $startCol

     # translate viewCol to proper index (account for tabs)
     if {[string match "*\t*" $line]} {
         # let's just brute force over the line
         set i 0
         foreach c [split [string range $line \
                 $startCol [expr {$bufCol - 1}]] ""] {
         if {[string equal "\t" $c]} {
             set i [expr {$i + (8 - $i%8)}] ; # align to 8c boundary
         } else {
             incr i
         }
         }
         set viewCol [expr {$startCol + 1 + $i}]
     }

     idx [expr {$bufRow + 1}] $viewCol

     goto $viewRow $viewCol
     cursor on
     flush stdout
     }
 }

 proc linerange {line start end} {
     # Get # *visual* chars - account for tabs (== 8c) in line range
     set line [string range $line $start $end]
     if {[string match "*\t*" $line]} {
     # let's just brute force over the line
     set i    0
     set end [expr {$end-$start}]
     set res {}
     foreach c [split $line ""] {
         if {[string equal "\t" $c]} {
         set i [expr {$i + (8 - $i%8)}] ; # align to 8c boundary
         } else {
         incr i
         }
         append res $c
         if {$i > $end} { break }
     }
     return $res
     }
     return $line
 }

 proc display {startRow startCol} {
     global IDX BUFFER

     cursor off ; home

     if {($IDX(ROWLAST) != $startRow) || ($IDX(COLLAST) != $startCol)} {
     # Add display size to get end points
     set endRow [expr {$startRow + $IDX(ROWMAX) - 1}]
     set endCol [expr {$startCol + $IDX(COLMAX) - 1}]

     for {set i $startRow} {$i < $endRow} {incr i} {
         puts -nonewline "\u001b\[K" ; # erase current line
         puts [linerange [lindex $BUFFER $i] $startCol $endCol]
     }

     set IDX(ROWLAST) $startRow
     set IDX(COLLAST) $startCol
     }
 }

 proc status {msg} {
     global IDX
     set len [expr {$IDX(ROWCOL) - 1}]
     set str [format "%-${len}.${len}s" $msg]
     goto $IDX(ROWMAX) 1
     puts -nonewline "$str"
 }

 proc idx {row col} {
     global IDX
     set str [format " L:%-4d C:%-4d" $row $col]
     # the string must not exceed $IDX(ROWCOLLEN) length
     goto $IDX(ROWMAX) $IDX(ROWCOL)
     puts -nonewline [string range $str 0 $IDX(ROWCOLLEN)]
 }

 proc home {}  { goto 1 1 }
 proc goto {row col} {
     global IDX
     if {$row == "end"} {
         set row $IDX(ROWMAX)
     }
     puts -nonewline "\u001b\[${row};${col}H"
 }
 proc clear {} { puts -nonewline "\u001b\[2J" }
 proc cursor {bool} {
     puts -nonewline "\u001b\[?[expr \
         {$::IDX(ROWMAX)+1}][expr {$bool ? "h" : "j"}]"
 }

 #start of console editor program

 proc console_edit {fileName} {
     global BUFFER IDX
     #Script-Edit by Steve Redler IV  5-30-2001

     set IDX(ROWMAX) 24
     set IDX(COLMAX) 80
     if {![catch {exec stty -a} err]
     && [regexp {rows (\d+); columns (\d+)} $err -> rows cols]} {
         if {$rows != "0" && $cols != 0} {
     set IDX(ROWMAX) $rows
     set IDX(COLMAX) $cols
         }
     }
     set IDX(ROWCOLLEN) 15
     set IDX(ROWCOL) [expr {$IDX(COLMAX) - $IDX(ROWCOLLEN)}]

     set infile [open $fileName RDWR]
     set BUFFER [split [read $infile] "\n"]
     close $infile

     clear ; home
     status "\u0007$fileName loaded"
     idx [llength $BUFFER] 1

     fconfigure stdin -buffering none -blocking 1 -encoding iso8859-1
     fconfigure stdout -translation crlf -encoding iso8859-1

     flush stdout
     exec stty raw -echo
     edittext stdin
     status "Save '$fileName'? Y/n"
     flush stdout
     #fconfigure stdin -buffering full -blocking 1
     set line [read stdin 1]
     exec stty -raw echo
     if {$line != "n"} {
         set outfile [open $fileName w ]
         puts "len of buffer [llength $BUFFER]"
         for {set i 0} {$i<[expr [llength $BUFFER]-1]} {incr i} {
             puts $outfile [lindex $BUFFER $i]
         }
         puts -nonewline $outfile [lindex $BUFFER end]
         close $outfile
         status " Saved"
     } else {
         status " Aborted"
     }
     after 100

     # Reset terminal:
     puts -nonewline "\033c"

     exit 0
 }

 if {$filename == ""} {
     puts "\nPlease specify a filename"
     gets stdin filename
     if {$filename == ""} {exit}

 }

 #SRIV place hostname & filename into the xterms titlebar
 puts -nonewline  "\033\]0;[info hostname] - [file tail $filename]\007"

 console_edit $filename
