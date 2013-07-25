ad_page_contract {
  Show an xotcl class or object
  
  @author Gustaf Neumann
  @cvs-id $id:$
} -query {
  {object:optional ::xotcl::Object}
  {show_methods:optional 1}
  {show_source:optional 0}
  {show_variables:optional 0}
} -properties {
  title:onevalue
  context:onevalue
  output:onevalue
}

set context [list "XOTcl"]
set output ""
::xotcl::api scope_from_object_reference scope object
set isclass [::xotcl::api isclass $scope $object]

interp alias {} DO {} ::xotcl::api inscope $scope 
set s [DO Serializer new]

set dimensional_slider [ad_dimensional {
  {
    show_methods "Methods:" 1 {
      { 2 "All Methods" }
      { 1 "Documented Methods" }
      { 0 "Hide Methods" }
    }
  }
  {
    show_source "Source:" 0 {
      { 1 "Display Source" }
      { 0 "Hide Source" }
    }
  }
  {
    show_variables "Variables:" 0 {
      { 1 "Show Variables" }
      { 0 "Hide Variables" }
    }
  }
  }]


proc api_documentation {scope object kind method} {
  upvar show_methods show_methods 
  set proc_index [::xotcl::api proc_index $scope $object $kind $method]
  if {[nsv_exists api_proc_doc $proc_index]} {
    set documentation [api_proc_documentation \
			   -first_line_tag "<h4>" \
			   -label "$kind <em>$method</em>" \
			   $proc_index]
    set result $documentation
  } else {
    if {$show_methods == 2} {
      set result "<h4>$kind <em>$method</em></h4>"
    } else {
      set result ""
    }
  }
  return $result
}

proc info_option {scope object kind {dosort 0}} {
  upvar class_references class_references
  set list [DO $object info $kind]
  set refs [list]
  foreach e $list {
    if {[DO $object isclass $e]} {
      lappend refs [::xotcl::api object_link $scope $e]
    }
  }
  if {[llength $refs]>0 && [string compare ::xotcl::Object $list]} {
    append class_references "<li>$kind: [join $refs {, }]</li>\n"
  }
  if {[llength $list]>0 && [string compare ::xotcl::Object $list]} {
    return " \\\n     -$kind [list $list]"
  }
  return ""
}


#
# document the class or the object"
#
set index [::xotcl::api object_index $scope $object]
append output "<blockquote>\n"

if {[nsv_exists api_library_doc $index]} {
  array set doc_elements [nsv_get api_library_doc $index]
  append output [lindex $doc_elements(main) 0]
  append output "<dl>\n"
  if { [info exists doc_elements(creation-date)] } {
    append output "<dt><b>Created:</b>\n<dd>[lindex $doc_elements(creation-date) 0]\n"
  }
  if { [info exists doc_elements(author)] } {
    append output "<dt><b>Author[ad_decode [llength $doc_elements(author)] 1 "" "s"]:</b>\n"
    foreach author $doc_elements(author) {
      append output "<dd>[api_format_author $author]\n"
    }
  }
  if { [info exists doc_elements(cvs-id)] } {
    append output "<dt><b>CVS Identification:</b>\n<dd>\
	<code>[ns_quotehtml [lindex $doc_elements(cvs-id) 0]]</code>\n"
  }
  append output "</dl>\n"

  set url "/api-doc/procs-file-view?path=[ns_urlencode $doc_elements(script)]"
  append output "Defined in <a href='$url'>$doc_elements(script)</a><p>"

  array unset doc_elements
}
set my_class [DO $object info class]
set obj_create_source "$my_class create $object"
set title "[::xotcl::api object_link $scope $my_class] $object"
set class_references ""

if {$isclass} {
  append obj_create_source \
      [info_option $scope $object superclass] \
      [info_option $scope $object parameter] \
      [info_option $scope $object instmixin] 
  info_option $scope $object subclass
}

append obj_create_source \
    [info_option $scope $object mixin]

if {$class_references ne ""} {
  append output "<h4>Class Relations</h4><ul>\n$class_references</ul>\n"
}
append output "</blockquote>\n"

if {$show_source} {
  append output [::xotcl::api source_to_html $obj_create_source] \n
}

if {$show_methods} {
  append output "<h3>Methods</h3>\n" <ul> \n
   foreach m [lsort [DO $object info procs]] {
    set out [api_documentation $scope $object proc $m]
    if {$out ne ""} {
      append output "<a name='proc-$m'></a><li>$out"
      if { $show_source } { 
	append output \
	    "<pre class='code'>" \
	    [api_tcl_to_html [::xotcl::api proc_index $scope $object proc $m]] \
	    </pre>
      }
    }
  }
  if {$isclass} {
    set cls [lsort [DO $object info instprocs]]
    foreach m $cls {
      set out [api_documentation $scope $object instproc $m]
      if {$out ne ""} {
        append output "<a name='instproc-$m'></a><li>$out"
	if { $show_source } { 
	  append output \
	      "<pre class='code'>" \
	      [api_tcl_to_html [::xotcl::api proc_index $scope $object instproc $m]] \
	      </pre>
	}
      }
    }
  }
  append output </ul> \n
}

if {$show_variables} {
  set vars ""
  foreach v [lsort [DO $object info vars]] {
    if {[DO $object array exists $v]} {
      append vars "$object array set $v [list [DO $object array get $v]]\n"
    } else {
      append vars "$object set $v [list [DO $object set $v]]\n"
    }
  }
  if {[string compare "" $vars]} {
    append output "<h3>Variables</h3>\n" \
	[::xotcl::api source_to_html $vars] \n
  }
}

if {$isclass} {
  set instances ""
  foreach o [lsort [DO $object info instances]] {
    append instances [::xotcl::api object_link $scope $o] ", "
  }
  set instances [string trimright $instances ", "]
  if {[string compare "" $instances]} {
    append output "<h3>Instances</h3>\n" \
	<blockquote>\n \
	$instances \
	</blockquote>\n
  }
}


DO $s destroy
