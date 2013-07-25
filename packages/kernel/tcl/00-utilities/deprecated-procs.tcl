ad_proc -deprecated ad_export_vars { 
    -form:boolean
    {-exclude {}}
    {-override {}}
    {include {}}
} {
    <b><em>Note</em></b> This proc is deprecated in favor of 
    <a href="/api-doc/proc-view?proc=export_vars"><code>export_vars</code></a>. They're very similar, but 
    <code>export_vars</code> have a number of advantages:
    
    <ul>
    <li>It can sign variables (the the <code>:sign</code> flag)
    <li>It can export variables as a :multiple.
    <li>It can export arrays with on-the-fly values (not pulled from the environment)
    </ul>

    It doesn't have the <code>foo(bar)</code> syntax to pull a single value from an array, however, but
    you can do the same by saying <code>export_vars {{foo.bar $foo(bar)}}</code>.

    <p>

    Helps export variables from one page to the next, 
    either as URL variables or hidden form variables.
    It'll reach into arrays and grab either all values or individual values
    out and export them in a way that will be consistent with the 
    ad_page_contract :array flag.
    
    <p>

    Example:

    <blockquote><pre>doc_body_append [ad_export_vars { msg_id user(email) { order_by date } }]</pre></blockquote>
    will export the variable <code>msg_id</code> and the value <code>email</code> from the array <code>user</code>,
    and it will export a variable named <code>order_by</code> with the value <code>date</code>.

    <p>
    
    The args is a list of variable names that you want exported. You can name 

    <ul>
    <li>a scalar varaible, <code>foo</code>,
    <li>the name of an array, <code>bar</code>, 
    in which case all the values in that array will get exported, or
    <li>an individual value in an array, <code>bar(baz)</code>
    <li>a list in [array get] format { name value name value ..}.
    The value will get substituted normally, so you can put a computation in there.
    </ul>

    <p>

    A more involved example:
    <blockquote><pre>set my_vars { msg_id user(email) order_by }
doc_body_append [ad_export_vars -override { order_by $new_order_by } $my_vars]</pre></blockquote>

    @param form set this parameter if you want the variables exported as hidden form variables,
    as opposed to URL variables, which is the default.

    @param exclude takes a list of names of variables you don't want exported, even though 
    they might be listed in the args. The names take the same form as in the args list.

    @param override takes a list of the same format as args, which will get exported no matter
    what you have excluded.

    @author Lars Pind (lars@pinds.com)
    @creation-date 21 July 2000

    @see export_vars
} {

    ####################
    #
    # Build up an array of values to export
    #
    ####################

    array set export [list]

    set override_p 0
    foreach argument { include override } {
	foreach arg [set $argument] {
	    if { [llength $arg] == 1 } { 
		if { $override_p || [lsearch -exact $exclude $arg] == -1 } {
		    upvar $arg var
		    if { [array exists var] } {
			# export the entire array
			foreach name [array names var] {
			    if { $override_p || [lsearch -exact $exclude "${arg}($name)"] == -1 } {
				set export($arg.$name) $var($name)
			    }
			}
		    } elseif { [info exists var] } {
			if { $override_p || [lsearch -exact $exclude $arg] == -1 } {
			    # if the var is part of an array, we'll translate the () into a dot.
			    set left_paren [string first ( $arg]
			    if { $left_paren == -1 } {
				set export($arg) $var
			    } else {
				# convert the parenthesis into a dot before setting
				set export([string range $arg 0 [expr { $left_paren - 1}]].[string \
					range $arg [expr { $left_paren + 1}] end-1]) $var
			    }
			}
		    }
		}
	    } elseif { [llength $arg] %2 == 0 } {
		foreach { name value } $arg {
		    if { $override_p || [lsearch -exact $exclude $name] == -1 } {
			set left_paren [string first ( $name]
			if { $left_paren == -1 } {
			    set export($name) [lindex [uplevel list \[subst [list $value]\]] 0]
			} else {
			    # convert the parenthesis into a dot before setting
			    set export([string range $arg 0 [expr { $left_paren - 1}]].[string \
				    range $arg [expr { $left_paren + 1}] end-1]) \
				    [lindex [uplevel list \[subst [list $value]\]] 0]
			}
		    }
		}
	    } else {
		return -code error "All the exported values must have either one or an even number of elements"
	    }
	}
	incr override_p
    }
    ####################
    #
    # Translate this into the desired output form
    #
    ####################

    if { !$form_p } {
	set export_list [list]
	foreach varname [array names export] {
	    lappend export_list "[ns_urlencode $varname]=[ns_urlencode $export($varname)]"
	}
	return [join $export_list &]
    } else {
	set export_list [list]
	foreach varname [array names export] {
	    lappend export_list "<input type=\"hidden\" name=\"[ad_quotehtml $varname]\"\
		    value=\"[ad_quotehtml $export($varname)]\" />"
	}
	return [join $export_list \n]
    }
}


    

