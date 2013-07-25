ad_page_contract {
    Displays last requests of a user

    @author Gustaf Neumann (adapted for interaction with controlling thread)
    @cvs-id $Id:$
} -query {
  request_key
  {all:optional 1}
  {orderby:optional}
} -properties {
    title:onevalue
    context:onevalue
    user_string:onevalue
}

set title "Last Requests of "
set context [list "Last Requests"]
set hide_patterns [parameter::get -parameter hide-requests -default {*.css}]

if {[string first . $request_key] > 0} {
   set user_string $request_key 
} else {
   acs_user::get -user_id $request_key -array user
   set user_string "$user(first_names) $user(last_name)"
   set tmp_url [acs_community_member_url -user_id $request_key]
   append user_string " (<a href='$tmp_url'>$request_key</a>)" 
}

append title $user_string
set admin_p [acs_user::site_wide_admin_p]
if {!$admin_p} {
  ad_return_warning "Insufficient Permissions" \
      "Only side wide admins are allowed to view this page!"
  ad_script_abort
}

set label(0) show_filtered
set tooltip(0) "Show filtered values"
set label(1) show_all
set tooltip(1) "Show all values"
set all [expr {!$all}]
set url [export_vars -base [ad_conn url] {request_key all}]

template::list::create \
    -actions [list $label($all) $url $tooltip($all)] \
    -name last_requests \
    -no_data "no requests for this user recorded" \
    -elements {
      time {
        label "Time"
      }
      timediff {
        label "Seconds ago"
	html { align right }
      }
      url {
        label "Url"
      }
      pa {
        label "Peer Address"
      }
    }
set all [expr {!$all}]
multirow create last_requests time timediff url pa

set requests [throttleThread do Users last_requests $request_key]
set last_timestamp [lindex [lindex $requests end] 0]

set hidden 0
foreach element $requests {
  foreach {timestamp url pa} $element break
  if {!$all} {
    set exclude 0
    foreach pattern $hide_patterns {
      if {[string match $pattern $url]} {
	set exclude 1
	incr hidden
	break
      }
    }
    if {$exclude} continue
  }
  set diff [expr {$last_timestamp-$timestamp}]
  if {[string length $url]>70} {
    set url [string range $url 0 35]...[string range $url end-35 end]
  }

  multirow append last_requests [clock format $timestamp] $diff $url $pa
}

set user_string "$hidden requests hidden."
if {$hidden>0} {
  append user_string " (Patterns: $hide_patterns)"
}

