ad_page_contract {
    Displays last 100 requests in the system

    @author Gustaf Neumann 

    @cvs-id $id
} -query {
    {orderby:optional "time,desc"}
} -properties {
    title:onevalue
    context:onevalue
}

set title "Last 100 Requests"
set context [list "Last 100 Requests"]
set stat [list]
foreach {key value} [throttle last100] {lappend stat $value}

Class CustomField -volatile \
    -instproc render-data {row} {
      html::div -style {
	border: 1px solid #a1a5a9; padding: 0px 5px 0px 5px; background: #e2e2e2} {
	  html::t  [$row set [my name]] 
	}
    }

TableWidget t1 -volatile \
    -columns {
      Field time       -label "Time" -orderby time -mixin ::template::CustomField
      AnchorField user -label "Userid" -orderby user
      Field ms         -label "Ms" -orderby ms
      Field url        -label "URL" -orderby url
    }

foreach {att order} [split $orderby ,] break
t1 orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att

foreach l $stat {
  foreach {timestamp c url ms requestor} $l break
  if {[string first . $requestor] > 0} {
    set user_string $requestor
  } else {
    acs_user::get -user_id $requestor -array user
    set user_string "$user(first_names) $user(last_name)"
  }
  t1 add -time [clock format $timestamp -format "%H:%M:%S"] \
      -user $user_string \
      -user.href [export_vars -base last-requests {{request_key $requestor}}] \
      -ms $ms \
      -url $url
}
set t1 [t1 asHTML]

