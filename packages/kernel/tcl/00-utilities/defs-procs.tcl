ad_library {
    ACS-specific general utility routines.
    @author Philip Greenspun (philg@arsdigita.com)
    @date 2 April 1998
    @cvs-id $Id: defs-procs.tcl,v 1.1.1.1 2002/11/22 09:47:33 nkd Exp $
}

proc ad_acs_version {} {
    set release_tag {}
    regexp "acs-(\[0-9\]+)-(\[0-9\]+)-(\[0-9\]+)" \
          $release_tag match major minor release

    if {[info exists major] && [info exists minor] && [info exists release]} {
      return "$major.$minor.$release"
    } else {
      return "development"
    }
}

proc ad_acs_release_date {} {
    set release_tag {}
    regexp "R(\[0-9\]+)" $release_tag match release_date

    if {[info exists release_date]} {
      set year  [string range $release_date 0 3]
      set month [string range $release_date 4 5]
      set day   [string range $release_date 6 7]
      return [util_AnsiDatetoPrettyDate "$year-$month-$day"]
    } else {
      return "not released"
    }
}

# this is a technical person who can fix problems
proc ad_host_administrator {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  HostAdministrator]
}

# The email address that will sign outgoing alerts
proc ad_outgoing_sender {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  OutgoingSender]
}

# set to return 1 if there is a graphics site

proc ad_graphics_site_available_p {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  GraphicsSiteAvailableP]
}

# this is the main name of the Web service that you're offering
# on top of the Arsdigita Web Publishing System

proc ad_system_name {} {
    return [ad_parameter -package_id [ad_acs_kernel_id] SystemName]
}

# This is the URL of a user's private workspace on the system, usually
# /pvt/home.tcl

proc ad_pvt_home {} {
    return [ad_parameter -package_id [ad_acs_kernel_id] HomeURL]
}

proc ad_admin_home {} {
    return "/admin"
}

proc ad_package_admin_home { package_key } {
    return "[ad_admin_home]/$package_key"
}

proc ad_pvt_home_name {} {
    return [ad_parameter -package_id [ad_acs_kernel_id] HomeName]
}

proc ad_pvt_home_link {} {
    return "<a href=\"[ad_pvt_home]\">[ad_pvt_home_name]</a>"
}

proc ad_site_home_link {} {
    if { [ad_get_user_id] != 0 } {
	return "<a href=\"[ad_pvt_home]\">[ad_system_name]</a>"
    } else {
	# we don't know who this person is
	return "<a href=\"/\">[ad_system_name]</a>"
    }
}

# person who owns the service 
# this person would be interested in user feedback, etc.

proc ad_system_owner {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  SystemOwner]
}

# a human-readable name of the publisher, suitable for
# legal blather

proc ad_publisher_name {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  PublisherName]
}

proc ad_url {} {
    # this will be called by email alerts. Do not use ad_conn location
    return [ad_parameter -package_id [ad_acs_kernel_id] SystemURL]
}

ad_proc -public acs_community_member_url {
    {-user_id:required}
} {
    return the url for the community member page of a particular user
} {
    return "/~${user_id}/"
#    return "[ad_parameter -package_id [ad_acs_kernel_id] CommunityMemberURL]?[export_vars user_id]"
}

ad_proc -public acs_community_member_link {
    {-user_id:required}
    {-label ""}
} {
    return the link of the community member page of a particular user
} {
    if {[empty_string_p $label]} {
        set label [db_string select_community_member_link_label {
            select persons.first_names || ' ' || persons.last_name
            from persons
            where person_id = :user_id
        } -default $user_id]
    }

    return "<a href=\"[acs_community_member_url -user_id $user_id]\">$label</a>"
}

proc ad_present_user {user_id name} {
    return [acs_community_member_link -user_id $user_id -label $name]
}

ad_proc -public acs_community_member_admin_url {
    {-user_id:required}
} {
    return the url for the community member admin page of a particular user
} {
    return "[ad_parameter -package_id [ad_acs_kernel_id] CommunityMemberAdminURL]?[export_vars user_id]"
}

ad_proc -public acs_community_member_admin_link {
    {-user_id:required}
    {-label ""}
} {
    return the link of the community member page of a particular user
} {
    if {[empty_string_p $label]} {
        set label [db_string select_community_member_link_label {
            select persons.first_names || ' ' || persons.last_name
            from persons
            where person_id = :user_id
        } -default $user_id]
    }

    return "<a href=\"[acs_community_member_admin_url -user_id $user_id]\">$label</a>"
}

proc ad_admin_present_user {user_id name} {
    return [acs_community_member_admin_link -user_id $user_id -label $name]
}

ad_proc ad_header {
    {-focus ""}
    page_title
    {extra_stuff_for_document_head ""} 
} {
    writes HEAD, TITLE, and BODY tags to start off pages in a consistent fashion
} {
    
    #    if {[ad_parameter MenuOnUserPagesP pdm] == 1} {
    #	return [ad_header_with_extra_stuff -focus $focus $page_title [ad_pdm] [ad_pdm_spacer]]
    #    } else {
    #    }
    return [ad_header_with_extra_stuff -focus $focus $page_title $extra_stuff_for_document_head]

}

ad_proc ad_header_with_extra_stuff {
    {-focus ""}
    page_title
    {extra_stuff_for_document_head ""} 
    {pre_content_html ""}
} {
    This is the version of the ad_header that accepts extra stuff for the document head and pre-page content html
} {
    set html "<html>
<head>
$extra_stuff_for_document_head
<title>$page_title</title>
</head>
"

    array set attrs [list]

    if { [info exists prefer_text_only_p] && $prefer_text_only_p == "f" && [ad_graphics_site_available_p] } {
        set attrs(bgcolor) [ad_parameter -package_id [ad_acs_kernel_id]  bgcolor "" "white"]
	set attrs(background) [ad_parameter -package_id [ad_acs_kernel_id]  background "" "/graphics/bg.gif"]
	set attrs(text) [ad_parameter -package_id [ad_acs_kernel_id]  textcolor "" "black"]
    } else {
	set attrs(bgcolor) [ad_parameter -package_id [ad_acs_kernel_id]  bgcolor "" "white"]
	set attrs(text) [ad_parameter -package_id [ad_acs_kernel_id]  textcolor "" "black"]
    }

    if { ![empty_string_p $focus] } {
	set attrs(onLoad) "javascript:document.${focus}.focus()"
    }

    foreach attr [array names attrs] {
	lappend attr_list "$attr=\"$attrs($attr)\""
    }
    append html "<body [join $attr_list]>\n"

    append html $pre_content_html
    return $html
}

proc_doc ad_footer {{signatory ""} {suppress_curriculum_bar_p 0}} "writes a horizontal rule, a mailto address box (ad_system_owner if not specified as an argument), and then closes the BODY and HTML tags"  {
    global sidegraphic_displayed_p
    if [empty_string_p $signatory] {
	set signatory [ad_system_owner]
    } 
    if { [info exists sidegraphic_displayed_p] && $sidegraphic_displayed_p } {
	# we put in a BR CLEAR=RIGHT so that the signature will clear any side graphic
	# from the ad-sidegraphic.tcl package
	set extra_br "<br clear=right>"
    } else {
	set extra_br ""
    }
    if { [ad_parameter -package_id [ad_acs_kernel_id]  EnabledP curriculum 0] && [ad_parameter -package_id [ad_acs_kernel_id]  StickInFooterP curriculum 0] && !$suppress_curriculum_bar_p} {
	set curriculum_bar "<center>[curriculum_bar]</center>"
    } else {
	set curriculum_bar ""
    }
    if { [llength [info procs ds_link]] == 1 } {
	set ds_link [ds_link]
    } else {
	set ds_link ""
    }
    return "
$extra_br
$curriculum_bar
<hr>
$ds_link
<a href=\"mailto:$signatory\"><address>$signatory</address></a>
</body>
</html>"
}

# need special headers and footers for admin pages
# notably, we want pages signed by someone different
# (the user-visible pages are probably signed by
# webmaster@yourdomain.com; the admin pages are probably
# used by this person or persons.  If they don't like
# the way a page works, they should see a link to the
# email address of the programmer who can fix the page).

proc ad_admin_owner {} {
    return [ad_parameter -package_id [ad_acs_kernel_id]  AdminOwner]
}

ad_proc ad_admin_header {
    {-focus ""}
    page_title
} "" {
    
    # if {[ad_parameter -package_id [ad_acs_kernel_id]  MenuOnAdminPagesP pdm] == 1} {
	
	# return [ad_header_with_extra_stuff -focus $focus $page_title [ad_pdm "admin" 5 5] [ad_pdm_spacer "admin"]]
	
	# } else {}

	return [ad_header_with_extra_stuff -focus $focus $page_title]
}

proc_doc ad_admin_footer {} "Signs pages with ad_admin_owner (usually a programmer who can fix bugs) rather than the signatory of the user pages" {
    if { [llength [info procs ds_link]] == 1 } {
	set ds_link [ds_link]
    } else {
	set ds_link ""
    }
    return "<hr>
$ds_link
<a href=\"mailto:[ad_admin_owner]\"><address>[ad_admin_owner]</address></a>
</body>
</html>"
}



proc ad_return_exception_page {status title explanation} {
    ns_return $status text/html "[ad_header_with_extra_stuff $title "" ""]
<h2>$title</h2>
<hr>
$explanation
[ad_footer]";				#"emacs
    # raise abortion flag, e.g., for templating
    global request_aborted
    set request_aborted [list $status $title]
}


proc_doc ad_return_error {title explanation} "Returns a page with the HTTP 500 (Error) code, along with the given title and explanation.  Should be used when an unexpected error is detected while processing a page." {
    ad_return_exception_page 200 $title $explanation
}

proc_doc ad_return_warning {title explanation} "Returns a page with the HTTP 200 (Success) code, along with the given title and explanation.  Should be used when an exceptional condition arises while processing a page which the user should be warned about, but which does not qualify as an error." {
    ad_return_exception_page 200 $title $explanation
}

proc_doc ad_return_forbidden {title explanation} "Returns a page with the HTTP 403 (Forbidden) code, along with the given title and explanation.  Should be used by access-control filters that determine whether a user has permission to request a particular page." {
    ad_return_exception_page 403 $title $explanation
}

proc_doc ad_return_if_another_copy_is_running {{max_simultaneous_copies 1} {call_adp_break_p 0}} {Returns a page to the user about how this server is busy if another copy of the same script is running.  Then terminates execution of the thread.  Useful for expensive pages that do sequential searches through Oracle tables, etc.  You don't want to tie up all of your Oracle handles and deny service to everyone else.  The call_adp_break_p argument is essential if you are calling this from an ADP page and want to avoid the performance hit of continuing to parse and run.} {
    # first let's figure out how many are running and queued
    set this_connection_url [ad_conn url]
    set n_matches 0
    foreach connection [ns_server active] {
	set query_connection_url [lindex $connection 4]
	if { $query_connection_url == $this_connection_url } {
	    # we got a match (we'll always get at least one
	    # since we should match ourselves)
	    incr n_matches
	}
    }
    if { $n_matches > $max_simultaneous_copies } {
	ad_return_warning "Too many copies" "This is an expensive page for our server, which is already running the same program on behalf of some other users.  Please try again at a less busy hour."
	# blow out of the caller as well
	if $call_adp_break_p {
	    # we were called from an ADP page; we have to abort processing
	    ns_adp_break
	}
	return -code return
    }
    # we're okay
    return 1
}

proc ad_record_query_string {query_string subsection n_results {user_id [db_null]}} {  

    if { $user_id == 0 } {
	set user_id [db_null]
    }

    db_dml query_string_record {
	insert into query_strings 
	(query_date, query_string, subsection, n_results, user_id) values
	(sysdate, :query_string, :subsection, :n_results, :user_id)
    }
}

proc ad_pretty_mailing_address_from_args {line1 line2 city state postal_code country_code} {
    set lines [list]
    if [empty_string_p $line2] {
	lappend lines $line1
    } elseif [empty_string_p $line1] {
	lappend lines $line2
    } else {
	lappend lines $line1
	lappend lines $line2
    }
    lappend lines "$city, $state $postal_code"
    if { ![empty_string_p $country_code] && $country_code != "us" } {
	lappend lines [ad_country_name_from_country_code $country_code]
    }
    return [join $lines "\n"]
}



proc_doc ad_get_user_info {} {Sets first_name, last_name, email in the environment of its caller.} {
    uplevel {
	set user_id [ad_conn user_id]
	if [catch {
	    db_1row user_name_select {
		select first_names, last_name, email
		from persons, parties
		where person_id = :user_id
		and person_id = party_id
	    }
	} errmsg] {
	    ad_return_error "Couldn't find user info" "Couldn't find user info."
	    return
	}
    }
}

# for pages that have optional decoration

proc_doc ad_decorate_top {simple_headline potential_decoration} "Use this for pages that might or might not have an image defined in ad.ini; if the second argument isn't the empty string, ad_decorate_top will make a one-row table for the top of the page" {
    if [empty_string_p $potential_decoration] {
	return $simple_headline
    } else {
	return "<table cellspacing=10><tr><td>$potential_decoration<td>$simple_headline</tr></table>"
    }
}

ad_proc -private ad_requested_object_id {} {

    @return The requested object id, or if it is not available, the kernel id.  

} {
    set package_id ""
    #  Use the object id stored in ad_conn.
    if { [ad_conn_connected_p] } {
	set package_id [ad_conn package_id]
    }

    if { [empty_string_p $package_id] } {
	if { [catch {
	    set package_id [ad_acs_kernel_id]
	}] } {
	    set package_id 0
	}
    }
    return $package_id
}

ad_proc -deprecated ad_parameter {
    -set
    {-package_id ""}
    name
    {package_key ""}
    {default ""}
} {
    Package instances can have parameters associated with them.  This function is used for accessing  
    and setting these values.  Parameter values are stored in the database and cached within memory.
    New parameters can be created with the <a href=\"/control-panel/apm/\">APM</a> and values can be set
    using the <a href=\"/admin/site-map\">Site Map UI.</a>.  Because parameters are specified on an instance
    basis, setting the package_key parameter (preserved from the old version of this function) does not 
    affect the parameter retrieved.  If the code that calls ad_parameter is being called within the scope
    of a running server, the package_id will be determined automatically.  However, if you want to use a
    parameter on server startup or access an arbitrary parameter (e.g., you are writing bboard code, but
    want to know an acs-kernel parameter), specifiy the package_id parameter to the object id of the package
    you want.

    Note: <strong>The parameters/ad.ini file is deprecated.</strong>

    @see parameter::set_value
    @see parameter::get

    @param -set Use this if you want to indicate a value to set the parameter to.
    @param -package_id Specify this if you want to manually specify what object id to use the new parameter. 
    @return The parameter of the object or if it doesn't exist, the default.
} {
    if {[info exists set]} {
	set ns_param [parameter::set_value -package_id $package_id -parameter $name -value $set]
    } else {
        set ns_param [ad_parameter_from_file $name $package_key]
	if {[empty_string_p $ns_param]} {
            set ns_param [parameter::get -package_id $package_id -parameter $name -default $default]
	}
    }

    return $ns_param
}

ad_proc -deprecated ad_parameter_from_file {
    name
    {package_key ""}
} {
    This proc returns the value of a parameter that has been set in the
    parameters/ad.ini file.

    Note: <strong>The use of the parameters/ad.ini file is discouraged.</strong>  Some sites
    need it to provide instance-specific parameter values that are independent of the contents of the
    apm_parameter tables.

    @param name The name of the parameter.
    @return The parameter of the object or if it doesn't exist, the default.
} {
    set ns_param ""

    # The below is really a hack because none of the calls to ad_parameter in the system
    # actually call 'ad_parameter param_name acs-kernel'.

    if { [empty_string_p $package_key] || $package_key == "acs-kernel"} {
	set ns_param [ns_config "ns/server/[ns_info server]/acs" $name]
    } else {
	set ns_param [ns_config "ns/server/[ns_info server]/acs/$package_key" $name]
    }

    return $ns_param
}


ad_proc -private ad_parameter_cache {
    -set
    -delete:boolean
    package_id
    parameter_name
} {
    
    Manages the cache for ad_paremeter.
    @param -set Use this flag to indicate a value to set in the cache.
    @param package_id Specifies the package instance id for the parameter.
    @param parameter_name Specifies the parameter name that is being cached.
    @return The cached value.
    
} {
    if {$delete_p} {
	if {[nsv_exists ad_param_$package_id $parameter_name]} {
	    nsv_unset ad_param_$package_id $parameter_name
	}
	return
    }
    if {[info exists set]} {
	nsv_set "ad_param_$package_id" $parameter_name $set
	return $set
    } elseif { [nsv_exists ad_param_$package_id $parameter_name] } {
	return [nsv_get ad_param_$package_id $parameter_name]
    } else {
        #ns_log Warning "APM: $parameter_name does not exist"
	return ""
    }
}

ad_proc -private ad_parameter_cache_all {} {
    Loads all package instance parameters into the proper nsv arrays
} { 
    # Cache all parameters for enabled packages. .
    db_foreach parameters_get_all {
	select v.package_id, p.parameter_name, v.attr_value
	from apm_parameters p, apm_parameter_values v
	where p.parameter_id = v.parameter_id
    } {
	ad_parameter_cache -set $attr_value $package_id $parameter_name
    }	
}

# returns particular parameter values as a Tcl list (i.e., it selects
# out those with a certain key)

ad_proc -public ad_parameter_all_values_as_list {
    {-package_id ""}
    name {subsection ""}
} {

    Returns multiple values for a parameter as a list.

} {  
    return [join [ad_parameter -package_id $package_id $name $subsection] " "]
}

ad_proc doc_return {args} {
   
    A wrapper to be used instead of ns_return.  It calls
    <code>db_release_unused_handles</code> prior to calling ns_return.
    This should be used instead of <code>ns_return</code> at the bottom
    of every non-templated user-viewable page. 

} {
    db_release_unused_handles
#    eval "ns_returnz $args"
    eval "ns_return $args"
}







ad_proc -public ad_return_url {
    -urlencode:boolean
    -qualified:boolean
    {extra_args {}}
} {

    Build a return url suitable for passing to a page you expect to return back
    to the current page.

    <p>

    Example for direct inclusion in a link:

    <pre>
    ad_returnredirect "foo?return_url=[ad_return_url -url_encode]"
    </pre>

    Example setting a variable to be used by export_vars:

    <pre>
    set return_url [ad_return_url]
    set edit_link "edit?[export_vars item_id return_url]"
    </pre>

    Example setting a variable with extra_vars:

    <pre>
    set return_url [ad_return_url [list some_id $some_id] [some_other_id $some_other_id]]
    </pre>

    @author Don Baccus (dhogaza@pacifier.com)

    @param urlencode If true url-encode the result
    @param qualified If provided the return URL will be fully qualified including http or https.
    @param extra_args A list of {name value} lists to append to the query string

} {

    set query_list [export_entire_form_as_url_vars]

    foreach {extra_arg} $extra_args {
        lappend query_list [join $extra_arg "="]
    }

    if { [llength $query_list] == 0 } {
        set url [ns_conn url]
    } else {
        set url "[ns_conn url]?[join $query_list "&"]"
    }

    if { $qualified_p } {
        # Make the return_url fully qualified
        if { [security::secure_conn_p] } {
            set url [security::get_secure_qualified_url $url]
        } else {
            set url [security::get_insecure_qualified_url $url]
        }
    }

    if { $urlencode_p } {
        return [ns_urlencode $url]
    } else {
        return $url
    }
}


set comment {

    ad_proc -public ad_return_url {
	-urlencode:boolean
	{extra_args {}}
    } {

	@author Don Baccus
	@param url_encode If true url_encode the result.
	@param args A list of (name,value) pairs to append to the query string

	Build a return url suitable for passing to a page you expect to return back
	to the current page.

	Examples:

	ad_returnredirect "foo?return_url=[ad_return_url -url_encode]"

	set return_url [ad_return_url { {foo bar} {bar foo}}]

    } {

	set query_list [ns_conn query]

	foreach {extra_arg} $extra_args {
	    lappend query_list [join $extra_arg "="]
	}

	if { [llength $query_list] == 0 } {
	    return [ns_conn url]
	} else {
	    if { $urlencode_p } {
		return [ns_urlencode "[ns_conn url]?[join $query_list "&"]"]
	    } else {
		return "[ns_conn url]?[join $query_list "&"]"
	    }
	}
    }

}

ad_proc -public ad_progress_bar_begin {
    {-title:required}
    {-message_1 ""}
    {-message_2 ""}
    {-template "/packages/core-platform/lib/progress-bar"}
} {
    Return a proress bar.

    @param title     The title of the page
    @param message_1 Message to display above the progress bar.
    @param message_2 Message to display below the progress bar.
    @param template  Name of template to use. Default value is recommended.

    Example:

    <code>ad_progress_bar_begin -title "Installing..." -message_1 "Please wait..." -message_2 "Will continue automatically"</code>
    
    <p><code>...</code></p>
    
    <code>ad_progress_bar_end -url $next_page</code>

    @see ad_progress_bar_end
} {
    db_release_unused_handles
    ad_http_cache_control
    
    ReturnHeaders
    ns_write [ad_parse_template -params [list [list title $title] [list message_1 $message_1] [list message_2 $message_2]] $template]
}

ad_proc -public ad_progress_bar_end {
    {-url:required}
} {
    Ends the progress bar by causing the browser to redirect to a new URL.

    @see ad_progress_bar_begin
} { 
    ns_write "<script language=\"javascript\">window.location='$url';</script>"
    ns_conn close
}



ad_proc -private ad_http_cache_control { } {

    This adds specific headers to the http output headers for the current 
    request in order to prevent user agents and proxies from caching 
    the page.

    <p>

    It should be called only when the method to return the data to the 
    client is going to be ns_return. In other cases, e.g. ns_returnfile,
    one can assume that the returned content is not dynamic and can in
    fact be cached. Besides that, aolserver implements its own handling
    of Last-Modified headers with ns_returnfile. Also it should be
    called as late as possible - shortly before ns_return, so that 
    other code has the chance to set no_cache_control_p to 1 before
    it runs.
    
    <p>

    This proc can be disabled per request by calling
    "ad_conn_set no_http_cache_control_p 1" before this proc is reached. 
    It will not modify any headers if this variable is set to 1.
    
    <p>

    If the acs-kernel parameter CacheControlP is set to 0 then
    it's fully disabled.

    @author Tilmann Singer (tils-oacs@tils.net)

} {

    if { ![parameter::get -package_id [ad_acs_kernel_id] -parameter HttpCacheControlP -default 0]} {
	return
    }

    global ad_conn
    if { [info exists ad_conn(no_http_cache_control_p)] && $ad_conn(no_http_cache_control_p) } {
	return
    }

    set headers [ad_conn outputheaders]

    # Check if any relevant header is already present - in this case
    # don't touch anything. 
    set modify_p 1

    if { ([ns_set ifind $headers  "cache-control"] > -1 ||
         [ns_set ifind $headers  "expires"] > -1) } {
        set modify_p 0
    } else {
        for { set i 0 } { $i < [ns_set size $headers] } { incr i } {
            if { [string tolower [ns_set key $headers $i]] == "pragma" &&
                 [string tolower [ns_set value $headers $i]] == "no-cache" } {
                set modify_p 0
                break
            }
        }
    }

    # Set three headers, to be sure it won't get cached. If you are in
    # doubt, check the spec:
    # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html

    if { $modify_p } {
        # actually add the headers
        ns_setexpires 0
        ns_set put $headers "Pragma" "no-cache"
        ns_set put $headers "Cache-Control" "no-cache"
    }
    
    # Prevent subsequent calls of this proc from adding the same
    # headers again.
    ad_conn_set no_http_cache_control_p 1
}

ad_proc -public ad_parse_template {
    {-params ""}
    template
} {
    Return a string containing the parsed and evaluated template to the caller.
                                                                                                                             
    @param params The parameters to pass to the template.
                                                                                                                             
    @param template The template file name.
                                                                                                                             
    Example:
                                                                                                                             
    <code>set page [ad_parse_template -params {errmsg {custom_message "My Message"}} some-template]</code>
                                                                                                                             
    @param template Name of template file
} {
    set template_params [list]
    foreach param $params {
        switch [llength $param] {
            1 { lappend template_params "&"
                lappend template_params [lindex $param 0]
              }
            2 { lappend template_params [lindex $param 0]
                lappend template_params [lindex $param 1]
              }
            default { return -code error [_ acs-templating.Template_parser_error_in_parameter_list] }
        }
    }
    return [uplevel [list template::adp_parse [template::util::url_to_file $template [ad_conn file]] $template_params]]
}
