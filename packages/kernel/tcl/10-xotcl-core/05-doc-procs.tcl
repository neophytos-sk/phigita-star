ad_library {
  XOTcl API for api browser, defines the methods 
  ad_proc (for object specific methods), 
  ad_instproc (for tradional methods) and 
  ad_odc (for documenting classes). Syntax for the methods
  ad_proc and ad_instproc is like oacs ad_proc, ad_doc
  receives one argument, similar to ad_library.

  @author Gustaf Neumann
  @creation-date 2005-05-13
  @cvs-id $Id: 05-doc-procs.tcl,v 1.9 2006/12/18 08:06:36 gustafn Exp $
}

# Per default, the content of the ::xotcl:: namespace is not serialized;
# so we add the specified methods explizitely to the export list
::Serializer exportMethods {
  ::xotcl::Object instproc ad_proc
  ::xotcl::Object instproc ad_forward
  ::xotcl::Class  instproc ad_instproc
  ::xotcl::Object instproc ad_doc
  ::xotcl::Object instproc __api_make_doc
  ::xotcl::Object instproc __api_make_forward_doc
}
::Serializer exportObjects {
  ::xotcl::api
}

::xotcl::Object create ::xotcl::api \
    -proc isclass {scope obj} {
      expr {$scope eq "" ? 
            [::xotcl::Object isclass $obj] : 
            [$scope do ::xotcl::Object isclass $obj]}
    } -proc isobject {scope obj} {
      expr {$scope eq "" ? 
            [::xotcl::Object isobject $obj] : 
            [$scope do ::xotcl::Object isobject $obj]}
    } -proc scope {} {
      if {[info exists ::xotcl::currentThread]} {
	# we are in an xotcl thread; the body won't be accessible directly
	return $::xotcl::currentThread
      }
      return ""

    } -proc scope_from_object_reference {scope_var object_var} {
      upvar $scope_var scope $object_var object
      set scope ""
      regexp {^(.+) do (.+)$} $object match scope object

    } -proc scope_from_proc_index {proc_index} {
      set scope ""
      regexp {^(.+) .+ (inst)?proc (.+)$} $proc_index match scope
      return $scope

    } -proc inscope {scope args} {
      expr {$scope eq "" ? [eval $args] : [eval $scope do $args]}

    } -proc script_name {scope} {
      #set kind [expr {[my istype ::xotcl::Class] ? "Class" : "Object"}]
      #return "$scope$kind [self]"
      set script [info script]
      if {$script eq "" && [info exists ::xotcl::currentScript]} {
	set script $::xotcl::currentScript
      }
      set root_dir [nsv_get acs_properties root_directory]
      set root_length [string length $root_dir]
      if { $root_dir eq [string range $script 0 [expr {$root_length - 1}]]} {
        set script [string range $script [expr {$root_length + 1}] end]
      }
      return $script
      
    } -proc object_link {{-noimg:boolean off} scope obj} {
      set link "<a href='[my object_url $scope $obj]'>"
      if {$noimg} {
	return "$link$obj</a>"
      } else {
	return "$obj$link<img src='/resources/acs-subsite/ZoomIn16.gif' alt='\[i\]' border='0'></a>"
      }

    } -proc object_url {{-show_source 0} {-show_methods 1} scope obj} {
      set object [expr {$scope eq "" ? $obj : "$scope do $obj"}]
      return [export_vars -base /xotcl/show-object {object show_source show_methods}]
    } -proc object_index {scope obj} {
      set kind [expr {[my isclass $scope $obj] ? "Class" : "Object"}]
      return "$scope$kind $obj"

    } -proc proc_index {scope obj instproc proc_name} {
      if {$scope eq ""} {
	return "$obj $instproc $proc_name"
      } else {
	return "$scope $obj $instproc $proc_name"
      }

    } -proc source_to_html {{-width 100} string} {
      set lines [list]
      foreach l [split $string \n] {
	while {[string length $l] > $width} {
	  set pos [string last " \{" $l $width]
	  if {$pos>10} {
	    lappend lines "[string range $l 0 [expr {$pos-1}]] \\" 
	    set l "      [string range $l $pos end]"
	  } else {
	    # search for a match right of the target
	    set pos [string first " \{" $l $width]
	    if {$pos>10} {
	      lappend lines "[string range $l 0 [expr {$pos-1}]] \\" 
	      set l "      [string range $l $pos end]"
	    } else {
	      # last resort try to split around spaces 
	      set pos [string last " " $l $width]
	      if {$pos>10} {
		lappend lines "[string range $l 0 [expr {$pos-1}]] \\" 
		set l "      [string range $l $pos end]"
	      } else {
		break
	      }
	    }
	  }
	}
	lappend lines $l
      }
      set string [join $lines \n]
      set html [ad_quotehtml $string]
      regsub -all {(\n[\t ]*)(\#[^\n]*)} $html \\1<it>\\2</it> html
      return "<pre class='code'>$html</pre>"
    }




::xotcl::Object instproc __api_make_doc {inst proc_name} {
  upvar doc doc private private public public deprecated deprecated
  if {$doc eq ""} {
    set doc_elements(main) ""
  } else {
    ad_parse_documentation_string $doc doc_elements
  }
  set defaults [list]
  foreach a [my info ${inst}args $proc_name] {
    if {[my info ${inst}default $proc_name $a d]} {lappend defaults $a $d}
  }
  set public [expr {$private ? false : true}]
  set doc_elements(public_p) $public
  set doc_elements(private_p) $private
  set doc_elements(deprecated_p) $deprecated
  set doc_elements(varargs_p) [expr {[lsearch args [my info ${inst}args $proc_name]]>-1}] 
  set doc_elements(flags) [list]
  set doc_elements(switches) [list]
  foreach f [my info ${inst}nonposargs $proc_name] {
    set pair [split [lindex $f 0 0] :]
    set sw [string range [lindex $pair 0] 1 end]
    lappend doc_elements(switches) $sw
    lappend doc_elements(flags) $sw [lindex $pair 1]
    #my log "default_value $proc_name: $sw -> '[lindex $f 1]' <$pair/$f>"
    if {[lindex $pair 1] eq "switch" && [lindex $f 1] eq ""} {
      set default "false"
    } else {
      set default [lindex $f 1]
    }
    #my log "default_value $proc_name: $sw -> 'default' <$pair/$f>"
    lappend defaults $sw $default
  }
  set doc_elements(default_values) $defaults
  set doc_elements(positionals) [my info ${inst}args $proc_name] 
  # argument documentation finished
  set scope [::xotcl::api scope]
  set doc_elements(script) [::xotcl::api script_name $scope]
  set proc_index [::xotcl::api proc_index $scope [self] ${inst}proc $proc_name]
  if {![nsv_exists api_proc_doc $proc_index]} {
    nsv_lappend api_proc_doc_scripts $doc_elements(script) $proc_index
  }
  #my log "doc_elements=[array get doc_elements]"
  #my log "SETTING api_proc_doc '$proc_index'"
  nsv_set api_proc_doc $proc_index [array get doc_elements]
}

::xotcl::Object instproc __api_make_forward_doc {inst method_name} {
  upvar doc doc private private public public deprecated deprecated
  if {$doc eq ""} {
    set doc_elements(main) ""
  } else {
    ad_parse_documentation_string $doc doc_elements
    #my log "doc_elements=[array get doc_elements]"
  }
  set defaults [list]
  set public [expr {$private ? false : true}]
  set doc_elements(public_p) $public
  set doc_elements(private_p) $private
  set doc_elements(deprecated_p) $deprecated
  set doc_elements(varargs_p) false
  set doc_elements(flags) [list]
  set doc_elements(switches) [list]
  set doc_elements(default_values) [list]
  set doc_elements(positionals) [list] 
  # argument documentation finished
  set scope [::xotcl::api scope]
  set doc_elements(script) [::xotcl::api script_name $scope]
  set proc_index [::xotcl::api proc_index $scope [self] ${inst}forward $method_name]
  if {![nsv_exists api_proc_doc $proc_index]} {
    nsv_lappend api_proc_doc_scripts $doc_elements(script) $proc_index
  }
  #my log "doc_elements=[array get doc_elements]"
  #my log "SETTING api_proc_doc '$proc_index'"
  nsv_set api_proc_doc $proc_index [array get doc_elements]
}

::xotcl::Object instproc ad_proc {
  {-private:switch false}
  {-deprecated:switch false}
  {-warn:switch false}
  {-debug:switch false} 
  proc_name arguments doc body} {
    uplevel [list [self] proc $proc_name $arguments $body]
    my __api_make_doc "" $proc_name
  }

::xotcl::Object instproc ad_forward {
  {-private:switch false}
  {-deprecated:switch false}
  {-warn:switch false}
  {-debug:switch false} 
  method_name doc args} {
    uplevel [self] forward $method_name $args
    my __api_make_forward_doc "" $method_name
  }

::xotcl::Class instproc ad_instproc {
   {-private:switch false}
   {-deprecated:switch false}
   {-warn:switch false}
   {-debug:switch false} 
  proc_name arguments doc body} {
    uplevel [list [self] instproc $proc_name $arguments $body]
    my __api_make_doc inst $proc_name
  }


#::xotcl::Object instproc ad_instforward {
#  {-private:switch false}
#  {-deprecated:switch false}
#  {-warn:switch false}
#  {-debug:switch false} 
#  method_name doc args} {
#    uplevel [self] instforward $method_name $args
#    my __api_make_forward_doc inst $method_name
#  }



::xotcl::Object instproc ad_doc {doc_string} {
  ad_parse_documentation_string $doc_string doc_elements
  set scope [::xotcl::api scope]
  set doc_elements(script) [::xotcl::api script_name $scope]
  set proc_index [::xotcl::api object_index $scope [self]]

  #if {![nsv_exists api_proc_doc $proc_index]} {
  #  nsv_lappend api_proc_doc_scripts $doc_elements(script) $proc_index
  #}
  set doc_elements(public_p) true
  set doc_elements(private_p) false
  set doc_elements(varargs_p) false
  set doc_elements(deprecated_p) false
  set doc_elements(default_values) ""
  set doc_elements(switches) ""
  set doc_elements(positionals) ""
  set doc_elements(flags) ""
  nsv_set api_proc_doc $proc_index [array get doc_elements]
  nsv_set api_library_doc \
      $proc_index \
      [array get doc_elements]

  set file_index $doc_elements(script)
  if {[nsv_exists api_library_doc $file_index]} {
    array set elements [nsv_get api_library_doc $file_index]
  }
  set oldDoc [expr {[info exists elements(main)] ? \
			[lindex $elements(main) 0] : ""}]
  set prefix "This file defines the following Objects and Classes"
  set entry [::xotcl::api object_link $scope [self]]
  if {![string match *$prefix* $oldDoc]} {
    append oldDoc "<p>$prefix: $entry"
  } else {
    append oldDoc ", $entry"
  }
  set elements(main) [list $oldDoc]
  #my log "elements = [array get elements]"
  nsv_set api_library_doc $file_index [array get elements]
}

