ad_library {
  Definition of a connection context, containing user info, urls, parameters.
  this is used via "Package initialize"... similar as page_contracts and
  for included content (includelets), and used for per-connection caching as well.
  The intention is similar as with ad_conn, but based on objects.
  So far, it is pretty simple, but should get more clever in the future.

  @author Gustaf Neumann (neumann@wu-wien.ac.at)
  @creation-date 2006-08-06
  @cvs-id $Id: context-procs.tcl,v 1.6 2006/10/13 07:06:40 gustafn Exp $
}

namespace eval ::xo {

  Class create Context -ad_doc {
    This class provides a context for evaluation, somewhat similar to an 
    activation record in programming languages. It combines the parameter
    declaration (e.g. of a page, an includelet) with the actual parameters
    (specified in an includelet) and the provided query values (from the url).
    The parameter decaration are actually XOTcl's non positional arguments.
  } -parameter {
    {parameter_declaration ""} 
    {actual_query " "}
    {package_id 0}
  }

  # syntactic sugar for includelets, to allow the same syntax as 
  # for "Package initialize ...."; however, we do not allow currently
  # do switch user or package id etc., just the parameter declaration
  Context instproc initialize {{-parameter ""}} {
    my set parameter_declaration $parameter
  }

  Context instproc process_query_parameter {
    {-all_from_query:boolean true}
    {-all_from_caller:boolean true}
    {-caller_parameters}
  } {
    my instvar queryparm actual_query 
    my proc __parse [my parameter_declaration]  {
      foreach v [info vars] { uplevel [list set queryparm($v) [set $v]]}
    }
    
    foreach v [my parameter_declaration] {
      set ([lindex [split [lindex $v 0] :] 0]) 1
    }
    if {$actual_query eq " "} {
      set actual_query [ns_conn query]
      #my log "--CONN ns_conn query = <$actual_query>"
    }

    # get the query parameters (from the url)
    foreach querypart [split $actual_query &] {
      set name_value_pair [split $querypart =]
      set att_name  [ns_urldecode [lindex $name_value_pair 0]]
      set att_value [expr {[llength $name_value_pair] == 1 ? 1 :
                           [ns_urldecode [lindex $name_value_pair 1]]  }]
      if {[info exists (-$att_name)]} {
        set passed_args(-$att_name) $att_value
      } elseif {$all_from_query} {
        set queryparm($att_name) $att_value
      }
    }

    # get the query parameters (from the form if necessary)
    if {[my istype ::xo::ConnectionContext]} {
      foreach param [array names ""] {
	#my log "--cc check $param [info exists passed_args($param)]"
	set name [string range $param 1 end]
	if {![info exists passed_args($param)] &&
	    [my exists_form_parameter $name]} {
	  my log "--cc adding passed_args(-$name) [my form_parameter $name]"
	  set passed_args($param) [my form_parameter $name]
	}
      }
    }
    
    # get the caller parameters (e.g. from the includelet call)
    if {[info exists caller_parameters]} {
      #my log "--cc caller_parameters=$caller_parameters"
      array set caller_param $caller_parameters
    
      foreach param [array names caller_param] {
        if {[info exists ($param)]} { 
          set passed_args($param) $caller_param($param) 
        } elseif {$all_from_caller} {
          set queryparm([string range $param 1 end]) $caller_param($param) 
        }
      }
    }

    set parse_args [list]
    foreach param [array names passed_args] {
      lappend parse_args $param $passed_args($param)
    }
    
    #my log "--cc calling parser eval [self] __parse $parse_args"
    eval [self] __parse $parse_args
    #my log "--cc qp [array names queryparm] // $actual_query"
  }


  Context ad_instproc export_vars {{-level 1}} {
    Export the query variables
    @param level target level
  } {
    my instvar queryparm package_id
    foreach p [my array names queryparm] {
      set value [my set queryparm($p)]
      uplevel $level [list set $p [my set queryparm($p)]]
    }
    uplevel $level [list set package_id $package_id]
    #::xo::show_stack
  }


  Context ad_instproc get_parameters {} {
    Conveniance routine for includelets. It combines the actual
    parameters from the call in the page (highest priority) wit
    the values from the url (second priority) and the default
    values from the signature
  } {
    set source [expr {[my exists __caller_parameters] ? 
                      [self] : [my info parent]}]
    $source instvar __caller_parameters
    
    if {![my exists __including_page]} {
      # a includelet is called from the toplevel. the actual_query might
      # be cached, so we reset it here.
      my actual_query [::xo::cc actual_query]
    }

    if {[info exists __caller_parameters]} {
      my process_query_parameter -all_from_query false -caller_parameters $__caller_parameters
    } else {
      my process_query_parameter -all_from_query false
    }
    my export_vars -level 2 
  }


  #
  # ConnectionContext, a context with user and url-specific information
  #

  Class ConnectionContext -superclass Context -parameter {
    user_id
    requestor
    user
    url
  }
  
  # TODO code (in xinha, + css)
  # TODO edit revision loop

  ConnectionContext proc require {
    -url
    {-package_id 0} 
    {-parameter ""}
    {-user_id -1}
    {-actual_query " "}
  } {
    if {![info exists url]} {
      my log "--CONN ns_conn url"
      set url [ns_conn url]
    }
    #my log "--i [self args]"

    # create connection context if necessary
    if {$package_id == 0} {
      array set "" [site_node::get_from_url -url $url]
      set package_id $(package_id)
    } 
    if {![my isobject ::xo::cc]} {
      my create ::xo::cc \
          -package_id $package_id \
          -parameter_declaration $parameter \
	  -user_id $user_id \
	  -actual_query $actual_query \
          -url $url
      #my log "--cc ::xo::cc created $url"
      ::xo::cc destroy_on_cleanup 
    } else {
      #my log "--cc ::xo::cc reused $url"
      ::xo::cc configure \
          -package_id $package_id \
          -url $url \
	  -actual_query $actual_query \
          -parameter_declaration $parameter
      ::xo::cc set_user_id $user_id
      ::xo::cc process_query_parameter
    }
  }
  ConnectionContext instproc set_user_id {user_id} {
    if {$user_id == -1} {  ;# not specified
      my set user_id [expr {[info exists ::ad_conn(user_id)] ? [ad_conn user_id] : 0}]
    } else {
      my set user_id $user_id
    }
  }

  ConnectionContext instproc returnredirect {url} {
    my log "--rp"
    my set __continuation [list ad_returnredirect $url]
    return ""
  }

  ConnectionContext instproc init {} {
    my instvar requestor user user_id
    my set_user_id $user_id
    set pa [expr {[ns_conn isconnected] ? [ad_conn peeraddr] : "nowhere"}]

    if {[my user_id] != 0} {
      set requestor $user_id
    } else {
      # for requests bypassing the ordinary connection setup (resources in oacs 5.2+)
      # we have to get the user_id by ourselves
      if { [catch {
        if {[info command ad_cookie] ne ""} {
          # we have the xotcl-based cookie code
          set cookie_list [ad_cookie get_signed_with_expr "_SID"]
        } else {
          set cookie_list [ad_get_signed_cookie_with_expr "_SID"]
        }
        set cookie_data [split [lindex $cookie_list 0] {,}]
        set untrusted_user_id [lindex $cookie_data 1]
        set requestor $untrusted_user_id
      } errmsg] } {
        set requestor 0
      }
    }
    
    # if user not authorized, use peer address as requestor key
    if {$requestor == 0} {
      set requestor $pa
      set user "client from $pa"
    } else {
      set user "<a href='/acs-admin/users/one?user_id=$requestor'>$requestor</a>"
    }
    #my log "--i requestor = $requestor"
    
    my process_query_parameter
  }

  ConnectionContext ad_instproc permission {-object_id -privilege -party_id } {
    call ::permission::permission_p but avoid multiple calls in the same
    session through caching in the connection context
  } {
    #my log "--p [self args] [info exists party_id] "
    if {![info exists party_id]} {
      set party_id [my user_id]
      #my log "--p party_id $party_id"
      #::xo::show_stack
      if {$party_id == 0} {
        auth::require_login
        return 0
      }
    }
    set key permission($object_id,$privilege,$party_id)
    if {[my exists $key]} {return [my set $key]}
    #my log "--p lookup $key"
    my set $key [permission::permission_p -party_id $party_id \
                     -object_id $object_id \
                     -privilege $privilege]
  }
  
#   ConnectionContext instproc destroy {} {
#     my log "--i destroy [my url]"
#     #::xo::show_stack
#     next
#   }

  ConnectionContext instproc query_parameter {name {default ""}} {
    my instvar queryparm
    return [expr {[info exists queryparm($name)] ? $queryparm($name) : $default}]
  }
  ConnectionContext instproc exists_query_parameter {name} {
    #my log "--qp my exists $name => [my exists queryparm($name)]"
    my exists queryparm($name)
  }

  ConnectionContext instproc form_parameter {name {default ""}} {
    my instvar form_parameter
    if {![info exists form_parameter]} {
      array set form_parameter [ns_set array [ns_getform]]
    }
    return [expr {[info exists form_parameter($name)] ? 
                  $form_parameter($name) : $default}]
  }
  ConnectionContext instproc exists_form_parameter {name} {
    my instvar form_parameter
    if {![info exists form_parameter]} {
      array set form_parameter [ns_set array [ns_getform]]
    }
    my exists form_parameter($name)
  }
  



  #
  # Meta-Class for Application Package Classes
  #

  Class PackageMgr -superclass Class
  PackageMgr ad_instproc initialize {
    -ad_doc
    {-parameter ""}
    {-package_id 0}
    {-url ""}
    {-user_id -1}
    {-actual_query " "}
    {-init_url true}
    {-form_parameter}
  } {
    Create a connection context if there is none available.
    The connection context should be reclaimed after the request
    so we create it as a volatile object in the toplevel scope,
    it will be destroyed automatically with destroy_on_cleanup, 
    when the global variables are reclaimed.
    
    As a side effect this method sets in the calling context
    the query parameters and package_id as variables, using the 
    "defaults" for default values.

    init_url false requires the package_id to be specified and
    a call to Package instproc set_url to complete initialization
  } {

    #my log "--i [self args]"
    if {$url eq "" && $init_url} {
      #set url [ns_conn url]
      #my log "--CONN ns_conn url"
      set url [root_of_host [ad_host]][ns_conn url]
    }
    #my log "--cc actual_query = <$actual_query>"

    # require connection context
    ConnectionContext require \
	-package_id $package_id -user_id $user_id \
	-parameter $parameter -url $url -actual_query $actual_query
    set package_id [::xo::cc package_id]
    if {[info exists form_parameter]} {
      ::xo::cc array set form_parameter $form_parameter
    }

    # create package object if necessary
    my require -url $url $package_id
    ::xo::cc export_vars -level 2
  }

  PackageMgr ad_instproc require {{-url ""} package_id} {
    Create package object if needed.
  } {
    #my log "--R $package_id exists? [my isobject ::$package_id]"
    if {![my isobject ::$package_id]} {
      #my log "--R we have to create ::$package_id"
      if {$url ne ""} {
        my create ::$package_id -url $url
      } else {
        my create ::$package_id
      }
      ::$package_id destroy_on_cleanup
    } else {
      if {$url ne ""} {
        ::$package_id set_url -url $url
      }
    }
  }

  #
  # generic Package class
  #

  PackageMgr create Package -parameter {
    id
    url 
    package_url
    instance_name
  }
  Package instforward query_parameter        ::xo::cc %proc
  Package instforward exists_query_parameter ::xo::cc %proc
  Package instforward form_parameter         ::xo::cc %proc
  Package instforward exists_form_parameter  ::xo::cc %proc
  Package instforward returnredirect         ::xo::cc %proc


  Package instproc get_parameter {attribute {default ""}} {
    return [parameter::get -parameter $attribute -package_id [my id] \
                -default $default]
  }
 
  Package instproc init args {
    #my log "--R creating"
    my instvar id url
    set id [namespace tail [self]]
    array set info [site_node::get_from_object_id -object_id $id]
    my package_url $info(url)
    my instance_name $info(instance_name)
    if {![my exists url]} {
      # if we have no more information, we use the package_url as actual url
      set url [my package_url]
    }
    my set_url -url $url
  }
 
  Package instproc set_url {-url} {
    my url $url
    my set object [string range [my url] [string length [my package_url]] end]
  }

#   Package instproc destroy {} {
#     my log "--i destroy"
#     #::xo::show_stack
#     next
#   }
  
}