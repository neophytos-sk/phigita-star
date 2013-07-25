ad_page_contract {
    Displays last requests of a user

    @author Gustaf Neumann (adapted for interaction with controlling thread)
    @cvs-id $Id:$
} -query {
  {orderby:optional}
} -properties {
    title:onevalue
    context:onevalue
    user_string:onevalue
}

set admin_p true ;#[acs_user::site_wide_admin_p]
if {!$admin_p} {
  ad_return_warning "Insufficient Permissions" \
      "Only side wide admins are allowed to view this page!"
  ad_script_abort
}

set title "Currently Running Requests"
set context [list "Running Requests"]

template::list::create \
    -actions [list refresh [ad_conn url] "Reload current page"] \
    -name running \
    -no_data "Currently no running requests" \
    -elements {
      user_string {
        label "User"
	link_url_col user_url
      }
      url {
        label "Url"
      }
      elapsed {
        label "Elapsed Time"
	html { align right }
      }
    }

multirow create running user_string user_url url elapsed

set sortable_requests [list]
foreach {key elapsed} [throttle do running] {
  foreach {requestor url} [split $key ,] break
  set s [expr {([clock clicks -milliseconds]-$elapsed)/1000.0}]
  set ms [format %.2f $s]
  if {[string first . $requestor] > 0} {
    set user_string $requestor 
  } else {
    acs_user::get -user_id $requestor -array user
    set user_string "$user(first_names) $user(last_name)"
  }
  set user_url "last-requests?request_key=$requestor"
  lappend sortable_requests [list $user_string $user_url $url $ms]
}

foreach r [lsort -decreasing -real -index 3 $sortable_requests] {
  foreach {user_string user_url url ms} $r break
  multirow append running $user_string $user_url $url $ms
}

