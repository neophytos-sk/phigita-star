package provide templating 0.1

package require core
package require critcl
package require util_procs
package require tdom_procs

config section "::templating"

if { [namespace exists ::cli] } {
    # context based on command_line_interface module
    config param context_import_pattern "::cli::kit::*"
} else {
    # context based on naviserver API
    config param context_import_pattern "::httpd::kit::*"
}


