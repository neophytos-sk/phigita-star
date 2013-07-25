ad_page_contract {
  present usage statistics, active users, etc

  @author Gustaf Neumann
  @cvs-id $id:$
} -properties {
  title:onevalue
  context:onevalue
  active_user_label
  active_users_10
  current_system_activity
  current_load
  current_response
  views_trend
  users_trend
  response_trend
  throttle_stats
}

set title "Performance statistics"

# draw a graph in form of an html table of with 500 pixels
proc graph values {
  set pixel_file ./resources/backcolor.gif
  #set pixel_file /media/img/backcolor.gif

  set max 1
  foreach v $values {if {$v>$max} {set max $v}}
  set graph "<table cellpadding=0 cellspacing=1 style='background: #EAF2FF'>\n"
  foreach v $values {
    append graph "<tr><td width=500><img title='$v' src='$pixel_file' width=[expr {int(450.0*$v/$max)}] height=2></td></tr>\n"
  }
  append graph "</table>\n"
  return $graph
}

# compute the average of the last n values (or less, if
# not enough values are given)
proc avg_last_n {list n var} {
  upvar $var cnt
  set total 0.0
  set list [lrange $list end-[incr n -1] end]
  foreach d $list { set total [expr {$total+$d}] }
  set cnt [llength $list]
  return [expr {$cnt > 0 ? $total*0.001/$cnt : 0}]
}


# collect current system statistics
proc currentSystemLoad {} {
  return [lindex [split [exec "/usr/bin/w"] \n] 0]
}

# collect current response time (per minute and hour)
proc currentResponseTime {} {
  set tm [throttleThread do "response_time_minutes set trend"]
  set hours [throttleThread do "response_time_hours set trend"]
  if { $tm == "" } { return "NO DATA" }
  set avg_half_hour [avg_last_n $tm 30 cnt]
  if {$cnt > 0} {
    set minstat "[format %4.2f $avg_half_hour] (last $cnt minutes),"
  } else {
    set minstat ""
  }
  if {[llength $tm]>0} {
    set lminstat "[format %4.2f [expr {[lindex $tm end]/1000.0}]] (last minute),"
  } else {
    set lminstat ""
  }
  if {[llength $hours]>0} {
    set avg_last_day [avg_last_n $hours 24 cnt]
    set hourstat "[format %4.2f [expr {[lindex $hours end]/1000.0}]] (last hour),"
    append hourstat " [format %4.2f $avg_last_day] (last $cnt hours)"
  } else {
    set hourstat ""
  }
  return "$lminstat $minstat $hourstat"
}

# collect figures for views per second (when statistics are applied
# only on views)
proc currentViews {} {
  set vm [throttleThread do "minutes set trend"]
  set um [throttleThread do "user_count_minutes set trend"]
  if { $vm == "" } { return "NO DATA" }
  set views_per_sec [expr {[lindex $vm end]/60.0}]
  set views_per_min_per_user [expr {60.0*$views_per_sec/[lindex $um end]}]
  set view_time [expr {$views_per_min_per_user>0 ? 
	" avg. view time: [format %4.1f [expr {60.0/$views_per_min_per_user}]]" : ""}]
  return "[format %4.1f $views_per_sec] views/sec, [format %4.2f $views_per_min_per_user] views/min/user,  $view_time"
}


# build an HTML table from statistics of monitor thread

proc counterTable {label objlist} {
  append text "<table>" \
      "<tr><td width=100></td><td width=500>Trend</td><td width=300>Max</td></tr>"
  foreach {t l} $objlist {
    set trend [throttleThread do $t set trend]
    append text \
        "<tr><td style='text-align: center; border: 1px solid blue;'>$label per <br>$l</td>" \
        "<td style='padding: 5px; border: 1px solid blue;'>[graph $trend]<font size=-2>$trend</font></td>" \
        "<td style='padding: 5px; border: 1px solid blue;' valign='top'>" \
        "<table width='100%'>\n"
    set c 1
    foreach v [throttleThread do $t set stats] {
      incr c
      switch $t {
        minutes {set rps "([format %5.2f [expr {[lindex $v 1]/60.0}]] rps)"}
        hours   {set rps "([format %5.2f [expr {[lindex $v 1]/(60*60.0)}]] rps)"}
        default {set rps ""}
      }
      set bg [expr {$c%2==0?"white":"#EAF2FF"}]
      append text "<tr style='background: $bg'><td><font size=-2>[lindex $v 0]</font></td>
                       <td align='right'><font size=-2>[lindex $v 1] $rps</font></td></tr>"
    }
    append text "</td></td></table></tr>"
  }
  append text "</table><p>"
}

# set variables for template
set views_trend [counterTable Views [list seconds Second minutes Minute hours Hour]]
set users_trend [counterTable Users [list user_count_minutes Minute user_count_hours Hour]]
set response_trend [counterTable "Avg. Response <br>Time" \
			[list response_time_minutes Minute response_time_hours Hour]]
set current_response [currentResponseTime]
set current_load [currentSystemLoad]

if {[string compare "" [info command ::tlf::system_activity]]} {
  array set server_stats [::tlf::system_activity]
  set current_exercise_activity $server_stats(activity)
  set current_system_activity "$server_stats(activity) exercises last 15 mins, "
} else {
  set current_system_activity ""
}
append current_system_activity \n[currentViews]

set active_users_10 [throttleThread do Users total]
set throttle_stats [throttle statistics]
set active24 [throttleThread do Users perDay]
set activeUsers24 [lindex $active24 1]
set activeIP24 [lindex $active24 0]
set activeTotal24 [expr {$activeUsers24+$activeIP24}]
set active_string "$active_users_10 active users in last 10 minutes, $activeUsers24 in last 24 hours ($activeTotal24 total)"
set current_url [ns_conn url]
regexp {^(.*/)[^/]*$} $current_url match current_path
set active_user_label "<A href='$current_path/whos-online'>Active Users:</A>"

# use template in OACS or HTML table with plain AS
if {[string compare "" [info command ad_return_template]]} {
  ad_return_template
} else {
  ns_return 200 text/html [subst -nobackslash {
 <HTML><TITLE>System Statistics</TITLE><BODY>
 <table style="border: 1px solid blue; padding: 10px;"
    onload="setTimeout('self.location.href=\'$current_url'',6)">
    <tr><td><b>$active_user_label</b></td><td>$active_users_10</td></tr>
    <tr><td><b>Current System Activity:</b></td><td>$current_system_activity</td></tr>
    <tr><td><b>Current System Load:</b></td><td>$current_load</td></tr>
    <tr><td><b>Current Avg Response Time/sec:</b></td><td>$current_response</td></tr>
    <tr><td colspan="2"><a href='stat-details.tcl'>Details</a></td></tr>
 </table>
 <br>
 <h3 style='text-align: center;'>Page View Statistics</h3>
 <div style="padding: 00px;">$views_trend</div><p>
 <h3 style='text-align: center;'>Active Users</h3>
 <div style="padding: 00px;">$users_trend</div><p>
 <h3 style='text-align: center;'>Avg. Response Time in milliseconds</h3>
 <div style="padding: 00px;">$response_trend</div>
  $throttle_stats
 </BODY>
  }]
}
