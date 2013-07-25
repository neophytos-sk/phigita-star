ad_page_contract {
  Show classed defined in the connection threads

  @author Gustaf Neumann
  @cvs-id $id:$
} -query {
  {all_classes:optional 0}
} -properties {
  title:onevalue
  context:onevalue
  output:onevalue
}

set title "XOTcl Classes Defined in Connection Threads"
set context [list "XOTcl"]

set dimensional_slider [ad_dimensional {
  {
    all_classes "Show:" 0 {
      { 1 "All Classes" }
      { 0 "Application Classes only" }
    }
  }
}]


proc local_link cl {
  upvar all_classes all_classes
  if {$all_classes || ![string match ::xotcl::* $cl]} {
    return "<a href='#$cl'>$cl</a>"
  } else {
    return $cl
  }
}

proc doc_link {obj kind method} {
  set kind [string trimright $kind s]
  set proc_index [::xotcl::api proc_index "" $obj $kind $method]
  if {[nsv_exists api_proc_doc $proc_index]} {
    return "<a href='/api-doc/proc-view?proc=[ns_urlencode $proc_index]'>$method</a>"
  } else {
    return $method
  }
}

proc info_classes {cl key} {
  upvar all_classes all_classes
  set infos ""
  foreach s [$cl info $key] {
    append infos [local_link $s] ", "
  }
  set infos [string trimright $infos ", "]
  if {[string compare "" $infos]} {
    return "<li><em>$key</em> $infos</li>\n"
  } else {
    return ""
  }
}

set output "<ul>"
foreach cl [lsort [::xotcl::Class allinstances]] {
  if {!$all_classes && [string match ::xotcl::* $cl]} \
      continue
  
  append output "<li><b><a name='$cl'>[::xotcl::api object_link {} $cl]</b> <ul>"

  foreach kind {class superclass mixin instmixin} {
    append output [info_classes $cl $kind]
  }

  foreach key {procs instprocs} {
    set infos ""
    foreach i [$cl info $key] {append infos [doc_link $cl $key $i] ", "}
    set infos [string trimright $infos ", "]
    if {[string compare "" $infos]} {
      append output "<li><em>$key:</em> $infos</li>\n"
    }
    
  }

  set infos ""
  foreach o [$cl info instances] {append infos [::xotcl::api object_link {} $o] ", "}
  set infos [string trimright $infos ", "]
  if {[string compare "" $infos]} {
    append output "<li><em>instances:</em> $infos</li>\n"
  }


  append output </ul>
}
append output </ul>

