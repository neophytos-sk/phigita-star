package require xotcl::serializer

::Serializer exportMethods {
  ::xotcl::Object instproc log 
}

::xotcl::Object instproc log {message} {
    ns_log notice $message
}
return


## tell serializer to export methods, although these are methods of 
# ::xotcl::Object


::Serializer exportMethods {
  ::xotcl::Object instproc log 
  ::xotcl::Object instproc ds
  ::xotcl::Object instproc msg
  ::xotcl::Object instproc __timediff
  ::xotcl::Object instproc debug
  ::xotcl::Object instproc qn
  ::xotcl::Object instproc serialize
  ::xotcl::Object instproc show-object
  ::xotcl::Object instforward db_1row
  ::xotcl::Object instproc destroy_on_cleanup
  ::xotcl::Object instproc set_instance_vars_defaults
  ::xotcl::nonposArgs proc integer
  ::xotcl::nonposArgs proc optional
}


if {$::xotcl::version < 1.5} {
  # XOTcl 1.5 comes already with a predefined, more powerful
  # implementation of contains.

  ::Serializer exportMethods {
    ::xotcl::Object instproc contains
  }
  ::xotcl::Object instproc contains cmds {
    my requireNamespace
    namespace eval [self] $cmds
  }
  # XOTcl 1.5 or newer supports slots. Here we have to 
  # emulate slots up to a certain point
  namespace eval ::xo {
    ::xotcl::MetaSlot create ::xo::Attribute \
      -parameter {
        {name "[namespace tail [::xotcl::self]]"}
        {domain "[lindex [regexp -inline {^(.*)::slot::[^:]+$} [::xotcl::self]] 1]"}
        {multivalued false}
        {required false}
        default
        type
        spec
        pretty_name 
        {pretty_plural ""}
        {datatype "text"} 
        constraint_values
        help_text 
        validator
      }
  }
} else {
  namespace eval ::xo {
    # create xo::Attribute as a subclass of the slot ::xotcl::Attribute
    ::xotcl::MetaSlot create ::xo::Attribute \
        -superclass ::xotcl::Attribute \
        -parameter {
          spec
          {required false}
          pretty_name 
          {pretty_plural ""}
          {datatype "text"}
          constraint_values
          help_text 
          validator
        }
  }
}

if {[info command ::nx::Object] ne ""} {
  ns_log notice "Defining minimal XOTcl 1 compatibility"
  ::nsf::method::alias ::xo::Attribute instvar ::nsf::methods::object::instvar

  # The following line would cause a dependency of an nx object to
  # xotcl (serializer); since XOTcl depends on NX, this would be a
  # cyclic dependency.
  #     ::nsf::method::alias ::nx::Slot istype ::nsf::classes::xotcl::Object::istype
  # Therefore, we just grab the body to reduce dependencies on nsf internals
  ::nx::Slot public method istype {class}  [::nx::Object info method body ::nsf::classes::xotcl::Object::istype]
  ::nx::Slot public alias set -frame object ::set
  ::nx::Slot public method exists {var}   {::nsf::var::exists [self] $var}
  ::nx::Object public method serialize {} {::Serializer deepSerialize [self]}
  ::nx::Object method set_instance_vars_defaults {} {:configure}
  ::nx::Object public method destroy_on_cleanup {} {set ::xo::cleanup([self]) [list [self] destroy]}
  ::nx::Object method qn {query_name} {
    return "dbqd.[:uplevel [list current class]]-[:uplevel [list current method]].$query_name"
  }
  ::xotcl::Object instproc set_instance_vars_defaults {} {:configure}
  ::xotcl::Object proc setExitHandler {code} {::nsf::exithandler set $code}

  ::Serializer exportMethods {
    ::nx::Object method serialize
    ::nx::Object method show-object
    ::nx::Object method set_instance_vars_defaults
    ::nx::Object method destroy_on_cleanup
    ::nx::Object method qn
    ::nx::Slot method istype
    ::nx::Slot method exists
    ::nx::Slot method set
  }

} else {
  ::xotcl::Object instproc set_instance_vars_defaults {} {
    set pcl [[my info class] info parameterclass]
    $pcl searchDefaults [self]
  }
}

namespace eval ::xo {
  ::xo::Attribute instproc init {} {
    my instvar name pretty_name
    next
    # provide a default pretty name for the attribute based on message keys
    if {![info exists pretty_name]} {
      set object_type [my domain] 
      if {[regexp {^::([^:]+)::} $object_type _ head]} {
        set tail [namespace tail $object_type]
	set pretty_name "#$head.$tail-$name#"
	#my log "--created pretty_name = $pretty_name"
      } else {
        error "Cannot determine automatically message key for pretty name. \
		Use namespaces for classes"
      }
    }
  }

  proc package_id_from_package_key { key } {
    return [db_string dbqd.null.get_package_id_from_key \
                {select package_id from apm_packages where package_key = :key}]
  }
}

::xotcl::Object instforward db_1row -objscope

::xotcl::Object instproc serialize {} {
  ::Serializer deepSerialize [self]
}

::xotcl::Object instproc show-object {} {
  #
  # Allow to show an arbitrary object via API-browser.  Per-default,
  # e.g. site-wide can use e.g. /xowiki/index?m=show-object
  #
  set form [rp_getform]
  ns_set update $form object [self]
  ns_set update $form show_source    [::xo::cc query_parameter "show_source" 1]
  ns_set update $form show_methods   [::xo::cc query_parameter "show_methods" 2]
  ns_set update $form show_variables [::xo::cc query_parameter "show_variables" 1]
  rp_internal_redirect /packages/xotcl-core/www/show-object
}

namespace eval ::xo {
  proc slotobjects cl {
    set so [list]
    array set names ""
    foreach c [concat $cl [$cl info heritage]] {
      foreach s [$c info slots] {
	set n [namespace tail $s]
	if {![info exists names($n)]} {
	  lappend so $s
	  set names($n) $s
	}
      }
    }
    return $so
  }
  ::xotcl::Class create ::xo::InstanceManager \
      -instproc alloc args {
        set r [next]
        set key blueprint($r)
        if {![ns_conn isconnected]} {
          [self class] set $key 1
        } elseif {![[self class] exists $key]} {
          [self class] set connectionobject($r) 1
        }
        return $r
      } \
      -instproc destroy args {
        next
        ns_log notice "--unset -nocomplain [self class]::blueprint([self])"
        [self class] unset -nocomplain blueprint([self])
        [self class] unset -nocomplain connectionobject([self])
      }

  # deactivate for now
  #::xotcl::Object instmixin add ::xo::InstanceManager
}

if {[info command ::xotcl::nonposArgs] ne ""} {
  ::xotcl::nonposArgs proc integer args {
    if {[llength $args] < 2} return
    foreach {name value} $args break
    if {![string is integer $value]} {error "value '$value' of $name not an integer"}
  }
  ::xotcl::nonposArgs proc optional {name args} {
    ;
  }
}

::xotcl::Object instproc __timediff {} {
  set now [ns_time get]
  if {[ns_conn isconnected]} {
    set start_time [ns_conn start]
  } else {
    if {![info exists ::__start_time]} {set ::__start_timestamp $now}
    set start_time $::__start_timestamp
  }
  set t [ns_time diff $now $start_time]
  set ms [expr {[ns_time seconds $t]*1000 + [ns_time microseconds $t]/1000}]
  if {[info exists ::__last_timestamp]} {
    set t [ns_time diff $now $::__last_timestamp]
    set dms [expr {[ns_time seconds $t]*1000 + [ns_time microseconds $t]/1000}]
    set diff ", ${dms}ms"
  } else {
    set diff ""
  }
  set ::__last_timestamp $now
  return "${ms}ms$diff"
}

::xotcl::Object instproc log msg {
  ns_log notice "$msg, [self] [self callingclass]->[self callingproc] ([my __timediff])"
}
::xotcl::Object instproc ds msg {
  ds_comment "[self]: $msg, ([self callingclass]->[self callingproc] [my __timediff])"
}
::xotcl::Object instproc debug msg {
  ns_log debug "[self] [self callingclass]->[self callingproc]: $msg"
}
::xotcl::Object instproc msg {{-html false} msg} {
  if {[ns_conn isconnected]} {
    set msg "[self]: $msg  ([self callingclass]->[self callingproc])"
    if {$html} {
        util_user_message -html -message $msg
    } else {
      util_user_message -message $msg
    }
  }
}

# quick debugging tool
proc ::! args {
  ns_log notice "-- PROC [info level -1]"
  ns_log notice "-- CALL $args"
  set r [uplevel $args]
  ns_log notice "-- EXIT $r"
  return $r
}

::xotcl::Object instproc qn query_name {
  set qn "dbqd.[my uplevel [list self class]]-[my uplevel [list self proc]].$query_name"
  return $qn
}
namespace eval ::xo {
  Class Timestamp
  Timestamp instproc init {} {my set time [clock clicks -milliseconds]}
  Timestamp instproc diffs {} {
    set now [clock clicks -milliseconds]
    set ldiff [expr {[my exists ltime] ? [expr {$now-[my set ltime]}] : 0}]
    my set ltime $now
    return [list [expr {$now-[my set time]}] $ldiff]
  }
  Timestamp instproc diff {{-start:switch}} {
    lindex [my diffs] [expr {$start ? 0 : 1}]
  }

  Timestamp instproc report {{string ""}} {
    foreach {start_diff last_diff} [my diffs] break
    my log "--$string (${start_diff}ms, diff ${last_diff}ms)"
  }

  proc show_stack {{m 100}} {
    if {[::info exists ::template::parse_level]} {
      set parse_level $::template::parse_level
    } else {
      set parse_level ""
    }
    set msg "### tid=[::thread::id] <$parse_level> connected=[ns_conn isconnected] "
    if {[ns_conn isconnected]} {
      append msg "flags=[ad_conn flags] status=[ad_conn status] req=[ad_conn request]"
    }
    ::xotcl::Object log $msg
    set max [info level]  
    if {$m<$max} {set max $m}
    ::xotcl::Object  log "### Call Stack (level: command)"
    for {set i 0} {$i < $max} {incr i} {
      if {[catch {set s [uplevel $i self]} msg]} {
	set s ""
      }
      ::xotcl::Object  log "### [format %5d -$i]:\t$s [info level [expr {-$i}]]"
    }
  }

}

namespace eval ::xo {
  # 
  # Make reporting back of the version numbers of the most important 
  # nvolved components easier.
  #
  proc report_version_numbers {{pkg_list {acs-kernel xotcl-core xotcl-request-monitor xowiki s5 xoportal xowf}}} {
    append _ "Database: "
    if {[db_driverkey {}] eq "postgresql"} {
      append _ [db_string dbqd.null.get_version {select version() from dual}] \n
    } else {
      append _ [db_driverkey {}]\n
    }
    append _ "Server:    [ns_info patchlevel] ([ns_info name])\n"
    append _ "Tcl:       $::tcl_patchLevel\n"
    append _ "XOTcl:     $::xotcl::version$::xotcl::patchlevel\n"
    append _ "Tdom:      [package req tdom]\n"
    append _ "libthread: [ns_config ns/server/[ns_info server]/modules libthread]\n"
    append _ "Tcllib:    "
    foreach dir $::auto_path {
      set p [glob -nocomplain $dir/tcllib*]
      if {$p ne ""} {
        append _ "$p"
        # just show first occurances on path
        break
      }
    }
    append _ \n
    foreach pk $pkg_list {
      if {[apm_package_installed_p $pk]} {
        append _ "[format %-22s $pk:] " [apm_version_get -package_key $pk -array ""; set x "$(release_date), $(version_name)"] \n
      }
    }
    return $_
  }
}

#ns_log notice "--T [info command ::ttrace::isenabled]"
# tell ttrace to put these to the blueprint
#if {[info command ::ttrace::isenabled] ne "" && [::ttrace::isenabled]} {
#  ns_log notice "--T :ttrace::isenabled"
#  set blueprint [ns_ictl get]
#  ns_ictl save [append blueprint [::Serializer serializeExportedMethods \
#				      [::Serializer new -volatile]]]
#  unset blueprint
#  ns_log notice "--T [ns_ictl get]"
#}

namespace eval ::xo {
  #
  # In earlier versions of xotcl-core, we used variable traces
  # to trigger deletion of objects. This had two kind of problems:
  #   1) there was no way to control the order of the deletions
  #   2) the global variables used for managing db handles might
  #      be deleted already
  #   3) the traces are executed at a time when the connection 
  #      is already closed
  # Aolserver 4.5 supports a trace for freeconn. We can register
  # a callback to be executed before the connection is freed,
  # therefore, we have still information from ns_conn available.
  # For aolserver 4.5 we use oncleanup, which is at least before
  # the cleanup of variables.
  #
  # In contrary, in 4.0.10, on cleanup is called after the global
  # variables of a connection thread are deleted. Therefore
  # the triggered calls should not use database handles,
  # since these are as well managed via global variables,
  # the will be deleted as well at this time,.
  # 
  # To come up with an approach working for 4.5 and 4.0.10, we
  # distinguish between a at_cleanup and at_close, so connection
  # related info can still be obtained. 
  #
  if {[catch {set registered [ns_ictl gettraces freeconn]}]} {
    ns_log notice "*** you should really upgrade to Aolserver 4.5"
    # "ns_ictl oncleanup" is called after variables are deleted
    if {[ns_ictl epoch] == 0} {
      ns_ictl oncleanup ::xo::at_cleanup
      ns_ictl oninit [list ns_atclose ::xo::at_close]
      ns_ictl ondelete ::xo::at_delete
    }
    
#     proc trace_cleanup {args} {
#       set name [lindex $args 1]
#       #ns_log notice "*** cleanup <$args> '$name'"
#       if {[::xotcl::Object isobject $name]} {
# 	ns_log notice "*** cleanup $name destroy"
# 	$name destroy
#       }
#     }
  } else {

    # register only once
    if {[lsearch $registered ::xo::cleanup] == -1} {
      ns_ictl trace freeconn ::xo::freeconn
    }
    if {[lsearch [ns_ictl gettraces delete] ::xo::at_delete] == -1} {
      ns_ictl ondelete ::xo::at_delete
    }    

    proc ::xo::freeconn {} {
      catch {::xo::at_close}
      catch {::xo::at_cleanup}
    }
  }

  #proc ::xo::at_create {} {
  #  ns_log notice "--at_create *********"
  #  foreach i [::xo::InstanceManager array names blueprint] {
  #    if {![::xotcl::Object isobject $i]} {
  #      ::xo::InstanceManager unset blueprint($i)
  #      ns_log notice "--at_create no such object: $i"
  #    }
  #  }
  #}

  ::xotcl::Object instproc destroy_on_cleanup {} {
    #my log "--cleanup adding ::xo::cleanup([self]) [list [self] destroy]"
    set ::xo::cleanup([self]) [list [self] destroy]
  }

  proc at_close {args} {
  }

  proc at_cleanup {args} {
    #ns_log notice "*** start of cleanup <$args> ([array get ::xo::cleanup])"
    set at_end ""
    foreach {name cmd} [array get ::xo::cleanup] {
      #::trace remove variable ::xotcl_cleanup($name) unset ::xo::cleanup
      if {![::xotcl::Object isobject $name]} {
        #ns_log notice "--D $name already destroyed, nothing to do"
        continue
      }
      if {$name eq "::xo::cc"} {
        append at_end $cmd\n
        continue
      }
      #ns_log notice "*** cleanup $cmd"
      if {[catch {eval $cmd} errorMsg]} {
        set obj [lindex $cmd 0]
        ns_log error "Error during ::xo::cleanup: $errorMsg $::errorInfo"
        catch {
          ns_log notice "... analyze: cmd = $cmd"
          ns_log notice "... analyze: $obj is_object? [::xotcl::Object isobject $obj]"
          ns_log notice "... analyze: class [$obj info class]"
          ns_log notice "... analyze: precedence [$obj info precedence]"
          ns_log notice "... analyze: methods [lsort [$obj info methods]]"
          #
          # In case, we want to destroy some objects, and the
          # destructor fails, make sure to destroy them even
          # then. Half-deleted zombies can produce harm. We reclass
          # the object to the base classe and try again.
          #
          if {[lindex $cmd 1] eq "destroy"} {
            ns_log error "... forcing object destroy without application level destuctors"
            if {[$obj isclass]} {
              $obj class ::xotcl::Class; $obj destroy
            } else {
              $obj class ::xotcl::Object; $obj destroy
            }
          }
        }
      }
    }
    #ns_log notice "*** at_end $at_end"
    if {[catch {eval $at_end} errorMsg]} {
      ns_log notice "Error during ::xo::cleanup: $errorMsg $::errorInfo"
    }
    array unset ::xo::cleanup
    #ns_log notice "*** end of cleanup"
  }

  proc ::xo::at_delete args {
    #
    # Delete all object and classes at a time, where the thread is
    # fully functioning. During interp exit, the commands would be
    # deleted anyhow, but there exists a potential memory leak, when
    # e.g. a destroy method (or an exit handler) writes to ns_log.
    # ns_log requires the thread name, but it is cleared already
    # earlier (after the interp deletion trace). Aolserver recreated
    # the name and the an entry in the thread list, but this elements
    # will not be freed. If we destroy the objects here, the mentioned
    # problem will not occur.
    #
    ns_log notice "ON DELETE $args"
    set t0 [clock clicks -milliseconds]
    #
    # Check, if we have a new XOTcl implementation with ::xotcl::finalize
    # 
    if {[info command ::xotcl::finalize] ne ""} {
      ::xotcl::finalize
    } else {
      # Delete the objects and classes manually
      set objs [::xotcl::Object allinstances]
      ns_log notice "no finalize available, deleting [llength $objs] objects"
      foreach o $objs {
        if {![::xotcl::Object isobject $o]} continue
        if {[$o istype ::xotcl::Class]} continue
        catch {$o destroy} errorMsg
      }
      foreach o [::xotcl::Class allinstances] {
        if {![::xotcl::Object isobject $o]} continue
        if {$o eq "::xotcl::Object" || $o eq "::xotcl::Class"} continue
        catch {$o destroy} errorMsg
      }
    }
    set t1 [clock clicks -milliseconds]
    ns_log notice "ON DELETE done ([expr {$t1-$t0}]ms)"
  }
 
  #
  # ::xo::Module is very similar to a plain tcl namespace: When it is
  # created/recreated, it does not perform a cleanup of its
  # contents. This means that preexisting procs, objects classes,
  # variables etc. will survive a recreation. As a consequence,
  # ::xo::Modules can easily span multiple files an they can be used
  # like a namespace. However, the modules have the advantage that it
  # is possible to define procs, instprocs with non-positional
  # arguments directly in it. It is as well possible to use mixins
  # etc.
  #
  Class create Module 
  Module instproc init    args {my requireNamespace}
  Module instproc cleanup args {ns_log notice "create/recreate [self] without cleanup"}
}

namespace eval ::xo {
  #
  # ns_log_redirector_manager manages the ns_log-redirector, which can
  # be used to direct debugging output from the error log file as well
  # to the developer support. The behavior is controlled via a package
  # parameter.
  #
  Object ns_log_redirector_manager 

  ns_log_redirector_manager proc clean {} {
    #
    # check if nothing to do
    #
    if {[info command ::xo::ns_log] eq ""} return
    if {![my isobject ::ns_log]} return
    #
    # remove the stub
    #
    ::ns_log destroy
    rename ::xo::ns_log ::ns_log
  }

  ns_log_redirector_manager proc require_stub {} {
    #
    # check if nothing to do
    #
    if {[info command ::xo::ns_log] ne ""} return
    if {[my isobject ::ns_log]} return
    #
    # provide an XOTcl stub for ns_log
    #
    rename ::ns_log ::xo::ns_log
    ::xotcl::Object create ::ns_log
    ::ns_log proc unknown {m args} {::xo::ns_log notice "Warning ns_log called with unknown severity '$m' $args"}
    foreach flag {notice warning error fatal bug debug dev} {
      ::ns_log forward [string totitle $flag] %self $flag
      ::ns_log forward $flag ::xo::ns_log $flag
    }
  }

  ns_log_redirector_manager proc set_level {new_logging_level} {
    ::ns_log notice "SET LEVEL $new_logging_level"
    #
    # We want ns_log error be reported as well via ds_comment;
    # severity new_logging_level defines the amount of logging
    #
    ::xotcl::Class create ::xo::DS
    switch -- $new_logging_level {
      1 {set severities [list error]}
      2 {set severities [list error notice]}
      default {set severities [list]}
    }
    if {[llength $severities] > 0} {
      my require_stub
      foreach severity $severities {
        ::xo::DS instproc $severity args {
          catch {ds_comment "[self proc]: [join $args { }]"}
          ::xo::ns_log [self proc] [join $args " "]
        }
      }
      ::ns_log mixin ::xo::DS
    } else {
      my clean
    }
  }

  #
  # per default, the redirector is deactivated
  #
  ns_log_redirector_manager set_level [::parameter::get_from_package_key \
                                           -package_key xotcl-core \
                                           -parameter NslogRedirector \
                                           -default 0]
  

  #
  # For the time being: catch changed parameter values; it would be nice
  # to have in the future a more generic interface to trigger actions
  # directly on all parameter changes.
  #
  ad_proc -public -callback subsite::parameter_changed -impl xotcl-core_param_changed {
    -package_id:required
    -parameter:required
    -value:required
  } {
    Implementation of subsite::parameter_changed for xotcl-core parameters
    
    @param package_id the package_id of the package the parameter was changed for
    @param parameter  the parameter name
    @param value      the new value
  } {
    set package_key [apm_package_key_from_id $package_id]
    if {$package_key eq "xotcl-core" && $parameter eq "NslogRedirector"} {
      ::xo::ns_log_redirector_manager set_level $value
      #
      # Update the blueprint to reflect the parameter change
      # immediately.
      #
      # This is a heavy solution, but the NslogRedirector is not
      # likely to be changed frequently on a production system. The
      # alternative, a server restart, is even more expensive.
      #
      set blueprint [ns_ictl get]
      set last [string last "\n::xo::ns_log_redirector_manager" $blueprint]
      if {$last > -1} { set blueprint [string range $blueprint 0 [expr {$last-1}]]}
      ns_ictl save "$blueprint\n::xo::ns_log_redirector_manager set_level $value"
    }
  }
}

#ns_log notice "*** FREECONN? [ns_ictl gettraces freeconn]"
#ns_ictl trace freeconn {ns_log notice "*** FREECONN  isconnected=[ns_conn isconnected]"}
#ns_ictl oncleanup {ns_log notice "*** ONCLEANUP isconnected=[ns_conn isconnected]"}
