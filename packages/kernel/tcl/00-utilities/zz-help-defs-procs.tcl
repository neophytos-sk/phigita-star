# help-defs.tcl,v 3.0 2000/02/06 03:13:42 ron Exp
#
# help-defs.tcl
# 
# by philg@mit.edu on July 1, 1999
# 
# documented at /doc/help.html 
#

util_report_library_entry

proc_doc help_link {} "If a help file isn't available for the currently executing .tcl script, return empty string.  Otherwise, returns a hyperlinked anchor of \"help\" that will take a user to /help/for-one-page.tcl" {
    # we may have multi-lingual help but right now we don't care; let's
    # just look for anything that starts with the URL filename and ends with .help
    set pageroot [::xo::ns::pagedir]
    set helproot [ad_parameter HelpPageRoot help ""]
    set helproot_fullpath "$pageroot$helproot"

    # full path name will always start with the page root, so we want to cut off the page root from 
    # head of the full_path_name string in order to get a full_url
    set full_path_name [info script]
    set full_url [string range $full_path_name [string length $pageroot] [expr [string length $full_path_name] - 1]]

    set just_the_dir [file dirname $full_url]
    set just_the_filename [file rootname [file tail $full_url]]
    set help_file_directory "$helproot_fullpath$just_the_dir"
    set glob_pattern "${help_file_directory}/${just_the_filename}*.help"
    set available_help_files [glob -nocomplain $glob_pattern]

    if { [llength $available_help_files] == 0 } {
	return ""
    } else {
	# if page is served through /groups directories then help link should be /groups/group/help.tcl
	# otherwise help link should be /help/for-one-page.tcl
	if { [uplevel \#1 {info exists scope}] && [uplevel \#1 {expr [string compare $scope group]==0}] && [uplevel \#1 {info exists group_vars_set}] } {
	    # page is served through /groups pages
	    upvar \#1 group_vars_set group_vars_set
	    set group_public_url [ns_set get $group_vars_set group_public_url]
	    set help_url "$group_public_url/help.tcl" 
	} else {
	    set help_url "/help/for-one-page.tcl"
	}   

	return "<a href=\"$help_url?url=[ns_urlencode $full_url]\">help</a>"
    }
}

proc_doc help_upper_right_menu args "Returns an HTML table, with \"out-of-flow\" options at the upper right, including those specified in the args plus a help option at the far right.  Intended for use right under the first HR on a page." {
    set choices [list]
    foreach arg $args {
	lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    }
    set help_choice [help_link]
    if ![empty_string_p $help_choice] {
	lappend choices $help_choice
    }
    if { [llength $choices] > 0 } {
	return "<table align=right><tr><td>[join $choices " | "]</td></tr></table>\n"
    } else {
	return ""
    }
}

proc_doc help_upper_right_menu_b args "Returns an HTML table, with \"out-of-flow\" options at the upper right, including those specified in the args plus a help option at the far right (enclosed in square brackets).  Intended for use right under the first HR on a page." {
    set choices [list]
    foreach arg $args {
	lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    }
    set help_choice [help_link]
    if ![empty_string_p $help_choice] {
	lappend choices $help_choice
    }
    if { [llength $choices] > 0 } {
	return "<table align=right><tr><td>\[ [join $choices " | "] \]</td></tr></table>\n"
    } else {
	return ""
    }
}


util_report_successful_library_load
