namespace eval ::util::term {;}

# Home positioning to root (0,0)
proc ::util::term::home {} {
    puts -nonewline "\x1b\[H"
}

# Clear the screen, move to (0,0)
proc ::util::term::clear_screen {} {
    puts -nonewline "\x1b\[2J"
}

# 0 Clear line from current cursor position to end of line
# 1 Clear line from beginning to current cursor position
# 2 Clear whole line (cursor position unchanged)
proc ::util::term::clear_line {{mode "0"}} {
    puts -nonewline "\x1b\[${mode}K" ; # erase current line
}

# Moves the cursor to the specified position (coordinates).
# If you do not specify a position, the cursor moves to the home
# position at the upper-left corner of the screen (line 0, column 0).
proc ::util::term::move_cursor {{row "0"} {col "0"}} {
    puts -nonewline "\x1b\[${row};${col}H"
}

# Move the cursor up N lines
proc ::util::term::move_cursor_up {{num_lines "1"}} {
    puts -nonewline "\x1b\[${num_cols}A"
}
# Move the cursor down N lines
proc ::util::term::move_cursor_up {{num_lines "1"}} {
    puts -nonewline "\x1b\[${num_cols}B"
}
# Move the cursor forward N columns
proc ::util::term::move_cursor_up {{num_lines "1"}} {
    puts -nonewline "\x1b\[${num_cols}C"
}
# Move the cursor backward N columns
proc ::util::term::move_cursor_backwards {{num_cols "1"}} {
    puts -nonewline "\x1b\[${num_cols}D"
}
# Save cursor position
proc ::util::term::save_cursor_position {} {
    puts -nonewline "\x1b\[s"
}
# Restore cursor position
proc ::util::term::restore_cursor_position {} {
    puts -nonewline "\x1b\[u"
}

# Reset terminal:
proc ::util::term::reset {} {
    puts -nonewline "\033c"
}

proc ::util::term::readline {fid} {

    set BUFFER ""

    set viewRow 1    ; # row idx into view area, 1-based
    set viewCol 1    ; # col idx into view area, 1-based
    set bufRow 0    ; # row idx into full buffer, 0-based
    set bufCol 0    ; # col idx into full buffer, 0-based
    set IDX(ROWLAST) -1    ; # last row most recently displayed in view
    set IDX(COLLAST) -1    ; # last col most recently displayed in view
    set char ""        ; # last char received
    set line [lindex $BUFFER $bufRow] ; # line data of current line

    while {$char ni "\x11 \x0d"} {
        set char [read $fid 1]
        if { [eof $fid] } {
            break
        }
        switch -- $char {
            \n -
            \r {
                puts -nonewline $char
                return $line
            }
            \x11 { # ^q - quit
                return exit
            }
            \x01 { # ^a - beginning of line
                set bufCol 0
            }
            \x04 { # ^d - delete
             if {$bufCol > [string length $line]} {
                 set bufCol [string length $line]
             }
             set line [string replace $line $bufCol $bufCol]
             set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
             set IDX(COLLAST) -1 ; # force redraw
            }
            \x05 { # ^e - end of line
             set bufCol [string length $line]
            }
            \x06 { ;# ^f - find/search
             global searchpattern
             set searchpattern [getInput fid "Search:"]
             handleSearch
            }
            \x07 { ;# ^g - goto line
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
            \x0a { # ^j - insert last yank
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
            \x19 { # ^y - yank line
             if {$bufRow < [llength $BUFFER]} {
                 set BUFFER [lreplace $BUFFER $bufRow $bufRow]
                 set IDX(COLLAST) -1 ; # force redraw
             }
            }
            \x08 -
            \x7f { # ^h && backspace ?
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
            \x1b { # ESC - handle escape sequences
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
                set before_chars [string range $line 0 [expr $bufCol - 1]]
                set after_chars [string range $line $bufCol end]

                set line ""
                append line $before_chars $char $after_chars

                set BUFFER [lreplace $BUFFER $bufRow $bufRow $line]
                incr bufCol [string length $char]
                if {$bufCol > [string length $line]} {
                    set bufCol [string length $line]
                }
                set IDX(COLLAST) -1 ; # force redraw

                ::util::term::clear_line
                ::util::term::move_cursor_backwards $bufCol
                puts -nonewline $line
                #puts "\x1b\[41m$line" ;# red
                flush stdout
            }
        }
    }
    return $line
}


proc ::util::term::read_eval_print_loop {callback} {

    # save stdin/stdout configuration options
    set stdin_options [fconfigure stdin]
    set stdout_options [fconfigure stdout]

    fconfigure stdin -buffering none -blocking 1 -encoding iso8859-1
    fconfigure stdout -translation crlf -encoding iso8859-1
    flush stdout
    exec stty raw -echo

    set line ""
    while { [set line [readline stdin]] ne {exit} } {
puts $line
        $callback $line
    }

    #after 10000
    flush stdout
    exec stty echo

    ::util::term::reset

    # restore stdin/stdout configuration options
    fconfigure stdin {*}${stdin_options}
    fconfigure stdout {*}${stdout_options}


    return $line
}


