ad_page_contract {
  Displays who's currently online
  
  @author Gustaf Neumann (adapted for interaction with controlling thread)
  
  @cvs-id $id: whos-online.tcl,v 1.1.1.1 2004/03/16 16:11:51 nsadmin exp $
} -query {
  {orderby:optional "name,asc"}
  {all:optional 1}
} -properties {
  title:onevalue
  context:onevalue
}

set title "Who's online?"
set context [list "Who's online"]

# get value from package parameters
set peer_groups [parameter::get -parameter peer-groups \
			 -default {*wlan* *dsl* *.com *.net *.org}]

set admin [acs_user::site_wide_admin_p]
#set admin 0

set label(0) "Authenticated only"
set tooltip(0) "Show authenticated users only"
set label(1) all
set tooltip(1) "Show all users"
set all [expr {!$all}]
set url [export_vars -base [ad_conn url] {request_key all}]

TableWidget t1 \
    -actions [subst {
      Action new -label "$label($all)" -url $url -tooltip "$tooltip($all)"
      Action new -label "Delete Statistics" -url flush-url-statistics \
	  -tooltip "Delete URL Statistics"
    }] \
    -columns [subst {
      AnchorField name  -label "User" -orderby name
      Field online_time -label "Last Activity" -html { align right } \
	  -orderby online_time
      if {$admin} {
	Field activity -label "Activity" -html { align right } -orderby activity
	AnchorField hits -label "Hits" -orderby hits
	Field switches  -label "Switches" -html { align center } -orderby switches
	Field peer_address -label "Peer" -orderby peer_address
      }
    }] \
    -no_data "no registered users online" 


foreach cat $peer_groups {set peer_cat_count($cat) 0}
set peer_cat_count(others) 0

# this proc is used only for caching purposes
proc my_hostname pa {
  if {[catch {set peer [ns_hostbyaddr $pa]}]} { return $pa } 
  return "$peer ($pa)"
  #return "$peer"
}

set users [list]
foreach element [throttle users active -full] {
  foreach {user_id pa timestamp hits smooth switches} $element break
  if {[string first . $user_id] > 0} {
    if {$all} continue
    # it was an IP address
    set user_label $user_id
    set user_url ""
  } else {
    acs_user::get -user_id $user_id -array user
    set user_label "$user(last_name), $user(first_names)" 
    set user_url [acs_community_member_url -user_id $user_id]
  }
  set timestamp [lindex $smooth 2]
  set last_request_minutes [expr {[clock seconds]/60 - $timestamp}]
  
  set peer $pa
  if {$admin} {
    catch {set peer [util_memoize [string tolower \
				       [list ::template::my_hostname $pa]]]}
    set match 0
    foreach cat $peer_groups {
      if {[string match $cat $peer]} {
	incr peer_cat_count($cat)
	set match 1
	break
      }
      }
    if {!$match} {
      incr peer_cat_count(others)
      append peer " ???"
    }
  }
  set loadparam "1m=[lindex $smooth 3], 10m=$hits"
  set detail_url "last-requests?request_key=$user_id"

  lappend users [list $user_label \
		     $user_url \
		     $last_request_minutes "$last_request_minutes minutes ago" \
		     [format %.2f [lindex $smooth 0]] \
		     $hits $loadparam $detail_url \
		     $switches \
		     $peer]
}

switch -glob $orderby {
  *,desc {set order -decreasing}
  *,asc  {set order -increasing}
} 
switch -glob $orderby {
  name,*         {set index 0; set type -dictionary}
  online_time,*  {set index 2; set type -integer}
  activity,*     {set index 4; set type -real}
  hits,*         {set index 5; set type -dictionary}
  switches,*     {set index 8; set type -integer}
  peer_address,* {set index 9; set type -dictionary}
}

if {$admin} {
  set total $peer_cat_count(others)
  foreach cat $peer_groups {incr total $peer_cat_count($cat)}
  set summarize_categories "$total users logged in from: "
    if { $total > 0 } {
	foreach cat $peer_groups {
	    append summarize_categories "$cat [format %.2f [expr {$peer_cat_count($cat)*100.0/$total}]]%, "
	}
	append summarize_categories "others [format %.2f [expr {$peer_cat_count(others)*100.0/$total}]]%. "
    } else {
	append summarize_categories "total=0"
    }
} else {
  set summarize_categories ""
}

foreach e [lsort $type $order -index $index $users] {
  if {$admin} {
    t1 add 	-name [lindex $e 0] \
		-name.href [lindex $e 1] \
		-online_time [lindex $e 4] \
		-activity [lindex $e 5] \
		-hits [lindex $e 6] \
		-hits.href [lindex $e 7] \
		-switches [lindex $e 8] \
		-peer_address [lindex $e 9]
  } else {
    t1 add 	-name [lindex $e 0] \
		-name.href [lindex $e 1] \
		-online_time [lindex $e 4]
  }
}

set t1 [t1 asHTML]
