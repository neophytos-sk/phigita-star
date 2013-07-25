ad_library {
  ::xo::OrderedComposite to create tree structures with aggregated
  objects. This is similar to object aggregations, but
  preserves the order. The OrderedComposite supports
  hierarchical sorting.

  @author Gustaf Neumann (neumann@wu-wien.ac.at)
  @creation-date 2005-11-26
  @cvs-id $Id: 20-Ordered-Composite-procs.tcl,v 1.7 2006/12/12 09:32:15 gustafn Exp $
}

namespace eval ::xo {
  Class OrderedComposite 

  OrderedComposite instproc show {} {
    next
    foreach child [my children] {
      $child show
    }
  }

  OrderedComposite instproc orderby {{-order "increasing"} variable} {
    my set __order $order
    my set __orderby $variable
  }

  OrderedComposite instproc __compare {a b} {
    set by [my set __orderby]
    set x [$a set $by]
    set y [$b set $by]
    if {$x < $y} {
      return -1
    } elseif {$x > $y} {
      return 1
    } else {
      return 0
    }
  }

  OrderedComposite instproc children {} {
    set children [expr {[my exists __children] ? [my set __children] : ""}]
    if {[my exists __orderby]} {
      set order [expr {[my exists __order] ? [my set __order] : "increasing"}]
      return [lsort -command [list my __compare] -$order $children]
    } else {
      return $children
    }
  }
  OrderedComposite instproc add obj {
    my lappend __children $obj
    $obj set __parent [self]
    #my log "-- adding __parent [self] to $obj -- calling after_insert"
    #$obj __after_insert
  }

  OrderedComposite instproc last_child {} {
    lindex [my set __children] end
  }

  OrderedComposite instproc destroy {} {
    # destroy all children of the ordered composite
    if {[my exists __children]} {
      #my log "--W destroying children [my set __children]"
      foreach c [my set __children] { $c destroy }
    }
    #show_stack;my log "-- children murdered, now next, chlds=[my info children]"
    namespace eval [self] {namespace forget *}  ;# for pre 1.4.0 versions
    next
  }

  OrderedComposite instproc contains cmds {
    my requireNamespace ;# legacy for older xotcl versions
    set m [Object info instmixin]
    if {[lsearch $m [self class]::ChildManager] == -1} {
      set insert 1
      Object instmixin add [self class]::ChildManager
    } else { 
      set insert 0
    }
    set errorOccurred [catch {namespace eval [self] $cmds} errorMsg]
    if {$insert} {
      Object instmixin delete [self class]::ChildManager
    }
    if {$errorOccurred} {error $errorMsg}
  }
  Class OrderedComposite::ChildManager -instproc init args {
    set r [next]
    [self callingobject] lappend __children [self]
    my set __parent [self callingobject]
    #my __after_insert
    #my log "-- adding __parent  [self callingobject] to [self]"
    return $r
  }

  Class OrderedComposite::Child -instproc __after_insert {} {;}

}