ad_page_contract {
  Displays active users in a community

    @author Gustaf Neumann 

    @cvs-id $id$
} -query {
  community_id
} -properties {
    title:onevalue
    context:onevalue
}

set community_name [dotlrn_community::get_community_name $community_id]
set title "Users in Community $community_name"
set context [list $title]
set stat [list]

TableWidget t1 \
    -columns {
      Field time -label "Last Activity" -html {align center}
      Field user -label User
    }

foreach e [lsort -decreasing -index 0 \
	       [throttle users in_community $community_id]] {
  foreach {timestamp requestor} $e break
  if {[info exists listed($requestor)]} continue
  set listed($requestor) 1
  if {[string first . $requestor] > 0} {
    set user_string $requestor
  } else {
    acs_user::get -user_id $requestor -array user
    set user_string "$user(first_names) $user(last_name)"
  }
  set time [clock format $timestamp -format "%H:%M"]
  t1 add -time $time -user $user_string
}

set t1 [t1 asHTML]
