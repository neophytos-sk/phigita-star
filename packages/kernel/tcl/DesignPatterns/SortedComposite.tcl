# $Id: s.SortedComposite.xotcl 1.10 01/03/23 21:55:33+01:00 neumann@somewhere.wu-wien.ac.at $
package provide xotcl::pattern::sortedCompositeWithAfter 0.9

Class SortedComposite -superclass Class

@ @File {
  description {
    Composite pattern enhanced with sorting 
  }
}

SortedComposite instproc remove {array element} {
  if {[self] exists ${array}($element)]} {
    [self] unset ${array}($element)}
}

SortedComposite instproc addOperations args {
  foreach pair $args {
    foreach {proc op} $pair {[self] set operations($proc) $op}
  }
} 

SortedComposite instproc removeOperations args {
  foreach op $args {[self] remove operations $op}
}

SortedComposite instproc addAfterOperations args {
  foreach pair $args {
    foreach {proc op} $pair {[self] set afterOperations($proc) $op}
  }
} 
SortedComposite instproc removeAfterOperations args {
  foreach op $args {[self] remove afterOperations $op}
}

SortedComposite instproc compositeFilter args {
  set registrationclass [lindex [self filterreg] 0]
  set r [self calledproc]
  set result [next]
  if {[$registrationclass exists operations($r)] && [[self] exists children]} {
    set method [$registrationclass set operations($r)]
    foreach object [[self] set children] {
      eval [self]::$object $method $args
    }
  }
  if {[$registrationclass exists afterOperations($r)]} {
    eval [self] [$registrationclass set afterOperations($r)] $args
  }
  set result
}

SortedComposite instproc init args {
  [self] array set operations {}
  [self] array set afterOperations {}

  [self] instproc setChildren args {
    switch [llength $args] {
      0 { return [[self] set children] }
      1 { return [[self] set children [lindex $args 0]] }
      default {error "wrong # args: [self] setChildren ?children?"}
    }
  }
  [self] instproc appendChildren args {
    eval [self] lappend children $args
  }

  next
  [self] instfilterappend compositeFilter 
}

