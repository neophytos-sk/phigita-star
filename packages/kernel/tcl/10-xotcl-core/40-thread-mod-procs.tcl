ad_library {
  Tcl API for Thread management provides some support for threads
   under the AOL-server and XOTcl. It contains
   essentially two classes THREAD and Proxy.
  <p>
   The class THREAD is used to create, initialize
   and destroy threads and to pass commands to these 
   threads. It is designed in a way to create threads
   lazyly such that thread definitions can be included
   in the modules directory of the aolserver and 
   therefore be part of the aolserver blueprints.
   When an instance of THREAD is created (e.g. t1), 
   an init-command is provided. e.g.:
  <pre>
    THREAD create t1 {
      Class Counter -parameter {{value 1}}
      Counter instproc ++ {} {my incr value}
      Counter c1
      Counter c2
    }
  </pre>
   Commands are sent to the thread via the
   "do" method, which returns the result of the
   command evaluated in the specified thread. 
   When the first command is sent to a 
   non-initialized thread, such as
  <pre>
    set x [t1 do c1 ++]
  </pre> 
   the actual thread is created and the thread 
   ID is remembered in a tsv array. When a
   THREAD object is destroyed, the associated
   thread is terminated as well. 
  
   Notice that according to the aol-server behavior it
   is possible to create **persistent threads**
   (when the thread object is created during
   startup and provided to all request threads
   through the blueprint, or to create **volatile
   threads** that are created during a request
   and which are deleted when the thread cleanup
   is called after some timeout. Volatile threads can 
   shared as well (when different request-threads
   create the same-named thread objects) and can 
   be used for caching proposes. Flushing the cache
   can be done in the thread's exitHandler.
  
   The Proxy class can be used to simplify
   the interaction with a thread and to 
   hide the fact, that certain classes/objects
   are part of a thread. The following command
   creates a Proxy for an object c1 in thread t1.
   After this, c1 can be used like an local object.
  <pre>
    THREAD::Proxy c1 -attach t1
    set x [c1 ++]
  </pre>
  The Proxy forwards all commands to the 
  attached thread except the methods attatch, filter, 
  detachAll and destroy. The attach method can be used 
  to reattach a proxy instance to a different thread, such as 
  <pre>  
    c1 attach t2
  </pre>
   A proxy can be (temporarily) detachted from a thread via
  <pre>
    c1 filter ""
  </pre>
  Later forwarding to the thread can be re-enabled via 
  <pre>
    c1 filter forward
  </pre>
  When a proxy is attached to a thread and 
  receives a destroy command, both the proxy
  and the corresponding object in the thread 
  are deleted. If only the proxy object is to be
  destroyed, the proxy must be detachted at first.
  The class method detatchAll is provided to detach 
  all proxies from their objects.

  @author Gustaf Neumann
  @creation-date 2005-05-13
  @cvs-id $Id: 40-thread-mod-procs.tcl,v 1.3 2006/07/14 01:22:11 gustafn Exp $
}

::xotcl::Object setExitHandler {
  #my log "EXITHANDLER of request thread [pid]"
  if {[catch {Proxy detachAll} m]} {
    #my log "EXITHANDLER error in detachAll $m"
  }
}

::Serializer exportObjects {
  ::xotcl::THREAD
  ::xotcl::THREAD::Client
}
# HERE (move inside exportObjects)  ::xotcl::THREAD::Proxy


################## main thread support ##################
#::xotcl::RecreationClass create ::xotcl::THREAD \
#    -instrecreate 1 \
#    -parameter {{persistent 0}}

Class create ::xotcl::THREAD \
    -parameter {{persistent 0}}

#Class create ::xotcl::THREAD \
#    -parameter {{persistent 0}}

::xotcl::THREAD instproc check_blueprint {} {
  if {![[self class] exists __blueprint_checked]} {
    if {[string first ::xotcl::THREAD [ns_ictl get]] == -1} {
      _ns_savenamespaces
    }
    [self class] set __blueprint_checked 1
  }
}

::xotcl::THREAD instproc init cmd {
  my instvar initcmd
  set initcmd {
    ::xotcl::Object setExitHandler {
      #my log "EXITHANDLER of slave thread SELF [pid]"
    }
  }
  regsub -all SELF $initcmd [self] initcmd
  append initcmd \n\
      [list set ::xotcl::currentScript [info script]] \n\
      [list set ::xotcl::currentThread [self]] \n\
      $cmd 
  my set mutex [thread::mutex create]
  ns_log notice "mutex [my set mutex] created"
  next
}

::xotcl::THREAD ad_proc -private recreate {obj args} {
  this method catches recreation of THREADs in worker threads 
  it reinitializes the thread according to the new definition.
} {
    my log "recreating [self] $obj, tid [$obj exists tid]"
  if {![string match "::*" $obj]} { set obj ::$obj }
  $obj set recreate 1
  next
  $obj init [lindex $args 0]
  if {[nsv_exists [self] $obj]} {
    set tid [nsv_get [self] $obj]
    ::thread::send $tid [$obj set initcmd]
    $obj set tid $tid
    my log "+++ content of thread $obj ($tid) redefined"
  }
}

::xotcl::THREAD instproc destroy {} {
  my log "destroy called"
  if {![my persistent] && 
      [nsv_exists [self class] [self]]} {
    set tid [nsv_get [self class] [self]]
    set refcount [::thread::release $tid]
    my log "destroying thread object tid=$tid cnt=$refcount"
    if {$refcount == 0} {
      my log "thread terminated"
      nsv_unset [self class] [self]
      thread::mutex destroy [my set mutex]
      ns_log notice "mutex [my set mutex] destroyed"
    }
  }
  next
}

::xotcl::THREAD instproc get_tid {} {
  if {[nsv_exists [self class] [self]]} {
    # the thread was already started
    return [nsv_get [self class] [self]]
  }
  # start a small command in the thread
  my do info exists x
  # now we have the thread and can return the tid
  return [my set tid]
}

::xotcl::THREAD instproc do {-async:switch args} {
  if {![nsv_exists [self class] [self]]} {
    # lazy creation of a new slave thread

    thread::mutex lock [my set mutex]
    #my check_blueprint
    #my log "after lock"
    if {![nsv_exists [self class] [self]]} {
      set tid [::thread::create]
      nsv_set [self class] [self] $tid
      if {[my persistent]} {
	my log "created new persistent [self class] as $tid pid=[pid]"
      } else {
	my log "created new [self class] as $tid pid=[pid]"
      }
      ::thread::send $tid [my set initcmd]
    } else {
      set tid [nsv_get [self class] [self]]
    }
    #my log "doing unlock"
    thread::mutex unlock [my set mutex]
  } else {
    # target thread is already up and running
    set tid [nsv_get [self class] [self]]
  }
  if {![my exists tid]} {
    # this is the first call 
    if {![my persistent] && ![my exists recreate]} {
      # for a shared thread, we do ref-counting through preseve
      my log "must preserve for sharing request-thread [pid]"
      set tid [nsv_get [self class] [self]]
      ::thread::preserve $tid
    }
    my set tid $tid
  }
  #my log "calling [self class] ($tid, [pid]) $args"
  if {$async} {
    return [thread::send -async $tid $args]
  } else {
    return [thread::send $tid $args]
  }
}

# create a sample persistent thread that can be acessed 
# via request threads
#THREAD create t0 {
#  Class Counter -parameter {{value 1}}
#  Counter instproc ++ {} {my incr value}
#  
#  Counter c1
#  Counter c2
#} -persistent 1
#

################## forwarding  proxy ##################
# Class ::xotcl::THREAD::Proxy -parameter {attach} 
# ::xotcl::THREAD::Proxy configure \
#     -instproc forward args {
#       set cp [self calledproc]
#       if { [string equal $cp "attach"] 
# 	   || $cp eq "filter" 
# 	   || $cp eq "detachAll"} {
# 	next
#       } elseif {$cp eq "destroy"} {
# 	eval [my attach] do [self] $cp $args
# 	my log "destroy"
# 	next
#       } else {
# 	my log "forwarding [my attach] do [self] $cp $args"
# 	eval [my attach] do [self] $cp $args
#       }
#     } -instproc init args {
#       my filter forward
#     } -proc detachAll {} {
#       foreach i [my info instances] {$i filter ""}
#     }


# sample Thread client routine, calls a same named object in the server thread
# a thread client should be created in an connection thread dynamically to 
# avoid name clashes in the blueprint.
 
Class create ::xotcl::THREAD::Client -parameter {server {serverobj [self]}}
::xotcl::THREAD::Client instproc do args {
  eval [my server] do [my serverobj] $args
}

