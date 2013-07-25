ad_page_contract {
    Displays last requests of a user

    @author Gustaf Neumann (adapted for interaction with controlling thread)
    @cvs-id $Id: last-requests.tcl,v 1.2 2005/12/30 00:07:23 gustafn Exp $
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

TableWidget t1 \
    -actions [subst {
      Action new -label "$label($all)" -url $url -tooltip "$tooltip($all)"
    }] \
    -columns {
      Field time -label "Time"
      Field timediff -label "Seconds ago" -html { align right }
      Field url -label "Url"
      Field pa -label "Peer Address"
    } \
    -no_data "no requests for this user recorded" 

set all [expr {!$all}]
set requests [throttle users last_requests $request_key]
set last_timestamp [lindex [lindex $requests end] 0]

set hidden 0
foreach element [lsort -index 0 -decreasing $requests] {
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
  set url [string_truncate_middle -len 70 $url]
  t1 add       -time [clock format $timestamp] \
	       -timediff $diff \
	       -url $url \
	       -pa $pa
}

set user_string "$hidden requests hidden."
if {$hidden>0} {
  append user_string " (Patterns: $hide_patterns)"
}
set t1 [t1 asHTML]
