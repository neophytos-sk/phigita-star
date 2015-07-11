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
proc ::util::term::clear_line {{mode "2"}} {
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
proc ::util::term::move_cursor_right {{num_cols "1"}} {
    puts -nonewline "\x1b\[${num_cols}C"
}
# Move the cursor backward N columns
proc ::util::term::move_cursor_left {{num_cols "1"}} {
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

proc ::util::term::readline {fid {stateVar ""}} {

    if { $stateVar ne {} } {
        upvar $stateVar state
    }

    set viewRow 1    ; # row idx into view area, 1-based
    set viewCol 1    ; # col idx into view area, 1-based
    set IDX(ROWLAST) -1    ; # last row most recently displayed in view
    set IDX(COLLAST) -1    ; # last col most recently displayed in view

    set pos $state(pos)    ; # col idx into full buffer, 0-based
    set line $state(init_value)

    if { $line ne {} } {
        puts -nonewline "$line"
        flush stdout
    }

    set char ""        ; # last char received
    while {$char ni "\x11 \x0d"} {
        set char [read $fid 1]
        if { [eof $fid] } {
            set key ""
            break
        }
        switch -exact -- $char {
            \n -
            \r {
                set key "ENTER"
                puts -nonewline $char
                break
            }
            \x11 { # ^q - quit
                set key "ESC"
                break
            }
            \x01 { # ^a - beginning of line
                set pos 0
            }
            \x04 { # ^d - delete
                if {$pos > [string length $line]} {
                    set pos [string length $line]
                }
                set line [string replace $line $pos $pos]
                #set buffer [lreplace $buffer $bufRow $bufRow $line]
                #set IDX(COLLAST) -1 ; # force redraw
            }
            \x05 { # ^e - end of line
                set pos [string length $line]
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
                     set len [llength $buffer]
                     if {$bufRow > $len} {
                         set bufRow [expr {$len-1}]
                     }
                 }
             }
            }
            \x0a { # ^j - insert last yank
             set currline [string range $line 0 [expr {$pos - 1}]]
             #set buffer [lreplace $buffer $bufRow $bufRow $currline]

             incr bufRow
             incr viewRow
             set buffer [linsert $buffer $bufRow \
                     [string range $line $pos end]]
             set IDX(COLLAST) -1 ; # force redraw
             set line [lindex $buffer $bufRow]
             set pos 0
            }
            \x19 { # ^y - yank line
             if {$bufRow < [llength $buffer]} {
                 #set buffer [lreplace $buffer $bufRow $bufRow]
                 set IDX(COLLAST) -1 ; # force redraw
             }
            }
            \x08 -
            \x7f { # ^h && backspace ?
                   set key "BACKSPACE"
                if {$pos != 0} {
                    if {$pos > [string length $line]} {
                        set pos [string length $line]
                    }
                    incr pos -1
                    set line [string replace $line $pos $pos]
                    move_cursor_left
                    clear_line 0 ;# clear line from current position to end
                    flush stdout
                }
            }
            \x1b { # ESC - handle escape sequences
                set next [read $fid 1]
                if {$next == "\["} { ; # \[
                    set next [read $fid 1]
                    switch -exact -- $next {
                        A { # Cursor Up (cuu1,up)
                            set key "UP"
                            break
                        }
                        B { # Cursor Down
                            set key "DOWN"
                            break
                        }
                        C { # Cursor Right (cuf1,nd)
                            if {$pos < [string length $line]} {
                                incr pos 1
                                move_cursor_right
                                flush stdout
                            }
                        }
                        D { # Cursor Left
                            if {$pos > [string length $line]} {
                                set pos [string length $line]
                            }
                            if {$pos > 0} {
                                incr pos -1 
                                move_cursor_left
                                flush stdout
                            }
                        }
                        H { # Cursor Home
                            move_cursor_left $pos
                            set pos 0
                            set bufRow 0
                            set viewRow 1
                        }
                        1 { # check for F3/Home
                            set next [read $fid 1]
                            if {$next == "~"} {
                                # Home:
                                set pos [regexp -indices -inline -- \
                                    {^[[:space:]]*} $line]
                                set pos [lindex [lindex $pos 0] 1]
                                incr pos 1
                            } elseif {$next == "3" && [read $fid 1] == "~"} {
                                # F3:
                                handleSearch
                            }
                        }
                        3 { # delete
                            set next [read $fid 1]
                            if {$pos > [string length $line]} {
                                set pos [string length $line]
                            }
                            set line [string replace $line $pos $pos]
                            #set buffer [lreplace $buffer $bufRow $bufRow $line]
                            set IDX(COLLAST) -1 ; # force redraw
                        }
                        4 { # end
                            if {[read $fid 1] == "~"} {
                                set pos [string length $line]
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
                                if {$bufRow >= [llength $buffer]} {
                                    set viewRow [llength $buffer]
                                    set bufRow  [expr {$viewRow - 1}]
                                }
                            }
                        }
                    }
                }
                # most of the above cause a buffer row change
                #set line [lindex $buffer $bufRow]
            }
            default {
                set before_chars [string range $line 0 [expr $pos - 1]]
                set after_chars [string range $line $pos end]

                set line ""
                append line $before_chars $char $after_chars

                #set buffer [lreplace $buffer $bufRow $bufRow $line]
                incr pos [string length $char]
                if {$pos > [string length $line]} {
                    set pos [string length $line]
                }
                set IDX(COLLAST) -1 ; # force redraw

                puts -nonewline $char
                flush stdout
            }
        }
        
    }

    set state(key) $key
    set state(pos) $pos
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

    array set state [list key "" pos "0" init_value ""]
    set buffer [list]
    set bufRow 0
    set line ""
    while { [set line [readline stdin state]] ne {exit} } {
        set buffer [lreplace $buffer $bufRow $bufRow $line]
        switch -exact -- $state(key) {
            UP {
                if { $bufRow > 0 } {
                    incr bufRow -1
                    set state(init_value) [lindex $buffer $bufRow]
                }
            }
            DOWN {
                if { $bufRow < [llength $buffer] - 1 } {
                    incr bufRow
                    set state(init_value) [lindex $buffer $bufRow]
                }
            }
            default {
                lappend buffer ""
                incr bufRow
                $callback $line
                set state(init_value) ""
            }
        }
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


