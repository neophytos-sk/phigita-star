# The very first file invoked when OpenACS is started up. Sources
# /packages/bootstrap-installer/bootstrap.tcl.

# Set HOME directory. This is need for critcl to function properly.
env set HOME /web/


# Determine the OpenACS root directory, which is the directory right above the
# Tcl library directory [ns_server -server [ns_info server] tcllib].
set root_directory [file dirname [string trimright  [ns_server -server [ns_info server] tcllib] "/"]]
ns_log notice "root_directory=$root_directory"
nsv_set acs_properties root_directory $root_directory


global auto_path
lappend auto_path [file join $root_directory lib]
lappend auto_path /opt/naviserver/lib/critcl.vfs/lib/critcl/


# Set system encoding.
encoding system [ns_config ns/server/[ns_info server] SystemEncoding utf-8]

#nstrace::excludensp ::xotcl::classes

ns_log notice "ns_db pools=[ns_db pools]"
ns_log notice "pwd=[pwd]"

#ns_eval {

# package require xcmds
#    package require tdom
    package require TclCurl
    package require textutil

::xo::lib::require critcl
::xo::lib::require templating
::xo::lib::require structured_text
::xo::lib::require critbit_tree
::xo::lib::require geoip
::xo::lib::require curl
::xo::lib::require ttext
::xo::lib::require tcalc
::xo::lib::require htmltidy
::xo::lib::require util_procs
::xo::lib::require html_procs
::xo::lib::require tlucene

#::xo::lib::require nssmtpd
#::xo::lib::require tspam

#}

critcl::config keepsrc 1 

# IMPORTANT: DO NOT REMOVE LINE BELOW
# * critcl creates an interp and keeps track of it in a namespace variable (run)
# * NaviServer threads perform a "package require" ONLY ONCE to save time
# * Loading modules during initialization means that the interpreter (interp0) 
#   is created in the master thread (which seems to be deleted after startup).
# * We unset the __LOADED_MODULE__ array to make sure that every thread will 
#   perform its own "package require" once for every module in order to avoid 
#   any trouble with module dependencies, especially to critcl.

# critbit_tree structured_text geoip curl nssmtpd ttext tspam tcalc htmltidy
foreach module_name {critcl} {
    ::xo::lib::forget $module_name
}


ns_log "Notice" "Loading service, rooted at $root_directory"
set bootstrap_file "$root_directory/packages/bootstrap-installer/bootstrap.tcl"
ns_log "Notice" "Sourcing $bootstrap_file"
if { [file isfile $bootstrap_file] } {
    source $bootstrap_file
} else {
    ns_log "Error" "$bootstrap_file does not exist. Aborting the XOACS load process."
}


