# For documentation, see the ad_library call at the bottom of this script.

nsv_array set api_proc_doc [list]
nsv_array set api_proc_doc_scripts [list]
nsv_array set api_library_doc [list]
nsv_array set proc_doc [list]
nsv_array set proc_source_file [list]

proc number_p { str } {
  return [regexp {^[-+]?[0-9]*(.[0-9]+)?$} $str]
}

proc empty_string_p { query_string } {
    return [string equal $query_string ""]
}

proc acs_root_dir {} {
    return [nsv_get acs_properties root_directory]
}

proc web_root_dir {} {
    return /web
}

proc acs_package_root_dir { package } {
    return "[file join [acs_root_dir] packages $package]"
}

proc ad_make_relative_path { path } {
    set root_length [string length [acs_root_dir]]
    if { ![string compare [acs_root_dir] [string range $path 0 [expr { $root_length - 1 }]]] } {
	return [string range $path [expr { $root_length + 1 }] [string length $path]]
    }
    error "$path is not under the path root ([acs_root_dir])"
}

proc ad_parse_documentation_string { doc_string elements_var } {
    upvar $elements_var elements
    if { [info exists elements] } {
        unset elements
    }

    set lines [split $doc_string "\n\r"]

    array set elements [list]
    set current_element main
    set buffer ""

    foreach line $lines {
	
	# lars@pinds.com, 8 July, 2000
	# We don't do a string trim anymore, because it breaks the formatting of 
	# code examples in the documentation, something that we want to encourage.
        
	# set line [string trim $line]

        if { [regexp {^[ \t]*@([-a-zA-Z_]+)(.*)$} $line "" element remainder] } {
            lappend elements($current_element) [string trim $buffer]

            set current_element $element
            set buffer "$remainder\n"
        } else {
            append buffer $line "\n"
        }
    }

    lappend elements($current_element) [string trim $buffer]
}

proc ad_proc_valid_switch_p {str} {
  return [expr [string equal "-" [string index $str 0]] && ![number_p $str]]
}

proc ad_proc args {
    set public_p 0
    set private_p 0
    set deprecated_p 0
    set warn_p 0
    set debug_p 0

    # Loop through args, stopping at the first argument which is
    # not a switch.
    for { set i 0 } { $i < [llength $args] } { incr i } {
        set arg [lindex $args $i]

        # If the argument doesn't begin with a hyphen, break.
        if { ![ad_proc_valid_switch_p $arg] } {
            break
        }

        # If the argument is "--", stop parsing for switches (but
        # bump up $i to the next argument, which is the first
        # argument which is not a switch).
        if { [string equal $arg "--"] } {
            incr i
            break
        }

        switch -- $arg {
            -public { set public_p 1 }
            -private { set private_p 1 }
            -deprecated { set deprecated_p 1 }
            -warn { set warn_p 1 }
            -debug { set debug_p 1 }
            default {
                return -code error "Invalid switch [lindex $args $i] passed to ad_proc"
            }
        }
    }

    if { $public_p && $private_p } {
        return -code error "Mutually exclusive switches -public and -private passed to ad_proc"
    }

    if { $warn_p && !$deprecated_p } {
        return -code error "Switch -warn can be provided to ad_proc only if -deprecated is also provided"
    }

    # Now $i is set to the index of the first non-switch argument.
    # There must be either three or four arguments remaining.
    set n_args_remaining [expr { [llength $args] - $i }]
    if { $n_args_remaining != 3 && $n_args_remaining != 4 } {
        return -code error "Wrong number of arguments passed to ad_proc"
    }

    # Set up the remaining arguments.
    set proc_name [lindex $args $i]

    # (SDW - OpenACS). If proc_name is being defined inside a namespace, we
    # want to use the fully qualified name. Except for actually defining the
    # proc where we want to use the name as passed to us. We always set
    # proc_name_as_passed and conditionally make proc_name fully qualified
    # if we were called from inside a namespace eval.

    set proc_name_as_passed $proc_name
    set proc_namespace [uplevel {::namespace current}]
    if { $proc_namespace ne {::} } {
	regsub {^::} $proc_namespace {} proc_namespace
	set proc_name "${proc_namespace}::${proc_name}"
    }

    set arg_list [lindex $args [expr { $i + 1 }]]
    if { $n_args_remaining == 3 } {
        # No doc string provided.
        array set doc_elements [list]
	set doc_elements(main) ""
    } else {
        # Doc string was provided.
        ad_parse_documentation_string [lindex $args end-1] doc_elements
    }
    set code_block [lindex $args end]

    set log_code ""
    if { $warn_p } {
        set log_code "ns_log Debug \"Deprecated proc $proc_name used:\\n\[ad_get_tcl_call_stack\]\"\n"
    }
    if { $code_block eq {-} } { return }
    uplevel [::list ::nsf::proc -ad $proc_name_as_passed $arg_list ${log_code}$code_block]
}

ad_proc -public -deprecated proc_doc { args } {

    A synonym for <code>ad_proc</code> (to support legacy code).
    
} {
    eval ad_proc $args
}

ad_proc -public ad_proc {
    -public:boolean
    -private:boolean
    -deprecated:boolean
    -warn:boolean
    arg_list
    args
} {

    Declares a procedure.

    @param public specifies that the procedure is part of a public API.
    @param private specifies that the procedure is package-private.
    @param deprecated specifies that the procedure should not be used.
    @param warn specifies that the procedure should generate a warning when invoked.
    @param arg_list the list of switches and positional parameters which can be
        provided to the procedure.

} -

ad_proc -public ad_arg_parser { allowed_args argv } {

    Parses an argument list for a database call (switches at the end).
    Switch values are placed in corresponding variable names in the calling
    environment.

    @param allowed_args a list of allowable switch names.
    @param argv a list of command-line options. May end with <code>args</code> to
        indicate that extra values should be tolerated after switches and placed in
        the <code>args</code> list.
    @error if the list of command-line options is not valid.

} {
    if { [string equal [lindex $allowed_args end] "args"] } {
	set varargs_p 1
	set allowed_args [lrange $allowed_args 0 [expr { [llength $allowed_args] - 2 }]]
    } else {
	set varargs_p 0
    }

    if { $varargs_p } {
	upvar args args
	set args [list]
    }

    set counter 0
    foreach { switch value } $argv {
	if { ![string equal [string index $switch 0] "-"] } {
	    if { $varargs_p } {
		set args [lrange $argv $counter end]
		return
	    }
	    return -code error "Expected switch but encountered \"$switch\""
	}
	set switch [string range $switch 1 end]
	if { [lsearch $allowed_args $switch] < 0 } {
	    return -code error "Invalid switch -$switch (expected one of -[join $allowed_args ", -"])"
	}
	upvar $switch switch_var
	set switch_var $value
	incr counter 2
    }
    if { [llength $argv] % 2 != 0 } {
	# The number of arguments has to be even!
	return -code error "Invalid switch syntax - no argument to final switch \"[lindex $argv end]\""
    }
}

ad_proc ad_library {
    doc_string
} {

    Provides documentation for a library (<code>-procs.tcl</code> file).

} {
    ad_parse_documentation_string $doc_string doc_elements
    nsv_set api_library_doc [ad_make_relative_path [info script]] [array get doc_elements]
}

ad_library {

    Routines for defining procedures and libraries of procedures (<code>-procs.tcl</code>
    files).

    @creation-date 7 Jun 2000
    @author Jon Salz (jsalz@mit.edu)
    @cvs-id $Id: 0000-proc-procs.tcl,v 1.1.1.1 2002/11/22 09:47:31 nkd Exp $
}

ad_proc empty_string_p {query_string} {
    returns 1 if a string is empty; this is better than using == because it won't fail on long strings of numbers
} -

ad_proc acs_root_dir {} { 
    Returns the path root for the OpenACS installation. 
} -

ad_proc acs_package_root_dir { package } { 
    Returns the path root for a particular package within the OpenACS installation. 
} -

ad_proc ad_make_relative_path { path } { 
    Returns the relative path corresponding to absolute path $path. 
} -

# procedures for doing type based dispatch
ad_proc ad_method {
    method_name
    type
    argblock
    docblock
    body
} {
    @param method_name the method name
    @param type the type for which this method will be used
    @param argblock the argument description block, is passed to ad_proc
    @param docblock the documentation block, is passed to ad_proc
    @param body the body, is passed to ad_proc

    Defines a method for type based dispatch. This method can be
    called using <code>ad_call_method</code>. The first arg to the
    method is the target on which the type dispatch happens. Use this
    with care.
} {
    ad_proc ${method_name}__$type $argblock $docblock $body
}

ad_proc ad_call_method {
    method_name
    object_id
    args 
} {
    @param method_name method name
    @param object_id the target, it is the first arg to the method
    @param args the remaining arguments

    Calls method_name for the type of object_id with object_id as the
    first arg, and the remaining args are the remainder of the args to
    method_name. Example ad_call_method method1 foo bar baz calls the
    the method1 associated with the type of foo, with foo bar and baz
    as the 3 arguments.
} {
    return [apply ${method_name}__[util_memoize "acs_object_type $object_id"] [concat $object_id $args]]
}

ad_proc ad_dispatch {
    method_name
    type
    args 
} {
    @param method_name method name
    @param object_id the target, it is the first arg to the method
    @param args the remaining arguments

    Calls method_name for the type of object_id with object_id as the
    first arg, and the remaining args are the remainder of the args to
    method_name. Example ad_call_method method1 foo bar baz calls the
    the method1 associated with the type of foo, with foo bar and baz
    as the 3 arguments.
} {
    return [apply ${method_name}__$type $args]
}
