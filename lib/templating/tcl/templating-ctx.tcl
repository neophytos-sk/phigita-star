namespace eval ::templating::ctx {

    if {0} {
        # context based on naviserver commands
        namespace import ::xo::kit::*
    } else {
        # context based on command_line_interface module
        namespace import ::cli::kit::*
    }

}

