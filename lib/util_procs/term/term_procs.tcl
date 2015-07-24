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

# Sets multiple display attribute settings.
# The following lists standard attributes:
#
# 0   Reset all attributes
# 1   Bright
# 2   Dim
# 4   Underscore  
# 5   Blink
# 7   Reverse
# 8   Hidden
#     Foreground Colours
# 30  Black
# 31  Red
# 32  Green
# 33  Yellow
# 34  Blue
# 35  Magenta
# 36  Cyan
# 37  White
#     Background Colours
# 40  Black
# 41  Red
# 42  Green
# 43  Yellow
# 44  Blue
# 45  Magenta
# 46  Cyan
# 47  White

proc ::util::term::set_attribute_mode {args} {
    # Set Attribute Mode  <ESC>[{attr1};...;{attrn}m

    set attrlist [join ${args} {;}]
    puts -nonewline "\x1b\[${attrlist}m"
}

proc ::util::term::color {color_number} {
    set_attribute_mode [expr { 30 + $color_number }]
}

proc ::util::term::bgcolor {color_number} {
    set_attribute_mode [expr { 40 + $color_number }]
}

proc ::util::term::readline {fid {stateVar ""}} {

color 0
bgcolor 7

    if { $stateVar ne {} } {
        upvar $stateVar state
    }

    set viewRow 1    ; # row idx into view area, 1-based
    set viewCol 1    ; # col idx into view area, 1-based

    set pos $state(pos)    ; # col idx into full buffer, 0-based
    set line $state(init_value)

    if { $line ne {} } {
        clear_line 2
        save_cursor_position
        move_cursor_left $pos
        puts -nonewline $line
        set len [string length $line]
        restore_cursor_position
        if { $pos > $len } {
            move_cursor_left [expr { $len - $pos }]
            set pos $len
        }
        flush stdout
    }

    set char ""        ; # last char received
    while {$char ne "\x11"} {
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
                set key "DC1" ;# device control 1
                break
            }
            \x01 { # ^a - beginning of line
               set key "CTRL-A"
                set pos 0
                break
            }
            \x03 { # ^c - break
                puts "ctrl+c pressed"
                set key "CTRL-C"
                break
            }
            \x04 { # ^d - delete
                if {$pos > [string length $line]} {
                    set pos [string length $line]
                }
                set line [string replace $line $pos $pos]
                #set buffer [lreplace $buffer $bufRow $bufRow $line]
            }
            \x05 { # ^e - end of line
                   set key "CTRL-E"
                set pos [string length $line]
            }
            \x06 { ;# ^f - find/search
                   set key "CTRL-F"
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
             set line [lindex $buffer $bufRow]
             set pos 0
            }
            \x19 { # ^y - yank line
             if {$bufRow < [llength $buffer]} {
                 #set buffer [lreplace $buffer $bufRow $bufRow]
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
                    save_cursor_position
                    set len [string length $line]
                    if { $pos < $len } {
                        puts -nonewline [string range $line $pos end]
                    }
                    clear_line 0 ;# clear line from current position to end
                    restore_cursor_position
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
                            set key "RIGHT"
                            if {$pos < [string length $line]} {
                                incr pos 1
                                move_cursor_right
                                flush stdout
                            }
                        }
                        D { # Cursor Left
                            set key "LEFT"
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
                            set key "HOME"
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
                            set key "DELETE"
                            set next [read $fid 1]
                            set len [string length $line]
                            if { $pos < $len } {
                                set line [string replace $line $pos $pos]
                                save_cursor_position
                                puts -nonewline [string range $line $pos end]
                                clear_line 0 ;# clear line from current cursor position to end
                                restore_cursor_position
                                flush stdout
                            }
                        }
                        7 {
                            # home
                            set key "HOME"
                            if {[read $fid 1] == "~"} {
                                move_cursor_left $pos
                                set pos 0
                                flush stdout
                            }
                        }
                        8 -
                        4 { # end
                            set key "END"
                            if {[read $fid 1] == "~"} {
                                set len [string length $line]
                                move_cursor_right [expr { $len - $pos }]
                                set pos $len
                                flush stdout
                            }
                        }
                        5 { # 5 Prev screen
                            set key "PAGE_UP"
                            break
                        }
                        6 { # 6 Next screen
                            set key "PAGE_DOWN"
                            break
                        }
                        default {
                            puts esc_char=$next
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

                puts -nonewline $char
                save_cursor_position
                puts -nonewline $after_chars
                restore_cursor_position
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
                set firstChar [string index $line 0]
                switch -exact -- $firstChar {
                    ! {
                        set buffer [lreplace $buffer $bufRow $bufRow]
                        set secondChar [string index $line 1]
                        if { $secondChar eq {?} } {
                            set pattern "[string range $line 2 end]"
                        } else {
                            set pattern "^[string range $line 1 end]"
                        }
                        # start a history substitution
                        set index [lsearch -regexp [lreverse $buffer] $pattern]
                        if { $index == -1 } {
                            puts "event not found"
                            exit
                        } else {
                            set offset [expr { [llength $buffer] - $index - 1 }]
                            set line [lindex $buffer $offset]
                            lappend buffer $line
                            puts $line
                        }
                    }
                }

                $callback $line

                lappend buffer ""
                incr bufRow
                set state(init_value) ""
                set state(pos) 0
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


