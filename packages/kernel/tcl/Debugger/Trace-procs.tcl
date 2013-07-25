 Object instproc traceFilter args {
  set context "[self callingclass]->[self callingproc]"
  set method [self calledproc]
  switch -- $method {
    proc -
    instproc {set dargs [list [lindex $args 0] [lindex $args 1] ...] }
    default  {set dargs $args }
  }
  ns_log Notice "+++ CALL $context>  [self]->$method $dargs"
  set result [next]
  ns_log Notice "+++ EXIT $context>  [self]->$method ($result)"
  return $result
}


## lr_page instfilter traceFilter
## ...
## lr_page instfilter {}
