ad_page_contract {
    Displays last requests of a user

    @author Gustaf Neumann 

    @cvs-id $id: whos-online.tcl,v 1.1.1.1 2004/03/16 16:11:51 nsadmin exp $
} -query {
    {all:optional 0}
    {orderby:optional "totaltime,desc"}
} -properties {
    title:onevalue
    context:onevalue
    user_string:onevalue
}

set title "Url Statistics"
set context [list "Url Statistics"]
set hide_patterns [parameter::get -parameter hide-requests -default {*.css}]

set stat [throttle report_url_stats]
set total 0.0
set cnt 0
set full_stat [list]

foreach l $stat {
  set total [expr {$total+[lindex $l 1]}]
  set cnt   [expr {$cnt  +[lindex $l 2]}]
  lappend full_stat [lappend l [expr {[lindex $l 1]/[lindex $l 2]}]]
}
set total_avg [expr {$cnt>0 ? $total/($cnt*1000.0) : "0" }]

set label(0) "Show filtered"
set tooltip(0) "Show filtered values"
set label(1) "Show all"
set tooltip(1) "Show all values"
set all [expr {!$all}]
set url [export_vars -base [ad_conn url] {all}]

switch -glob $orderby {
  *,desc {set order -decreasing}
  *,asc  {set order -increasing}
} 
switch -glob $orderby {
  url,*       {set index 0; set type -dictionary}
  totaltime,* {set index 1; set type -integer}
  cnt,*       {set index 2; set type -integer}
  avg,*       {set index 3; set type -integer}
}


TableWidget t1 \
    -actions [subst {
      Action new -label "$label($all)" -url $url -tooltip "$tooltip($all)"
      Action new -label "Delete Statistics" -url flush-url-statistics \
	  -tooltip "Delete URL Statistics"
    }] \
    -columns {
      Field url   -label "Request" -orderby url
      Field totaltime -label "Total Time" -html { align right } -orderby totaltime
      Field cnt   -label "Count"          -html { align right } -orderby cnt
      Field avg   -label "Ms"             -html { align right } -orderby avg
      Field total -label "Total"          -html { align right }
    }

  set nr 0
  set hidden 0
  set all [expr {!$all}]
  foreach l [lsort $type $order -index $index $full_stat] {
    set avg [expr {[lindex $l 1]/[lindex $l 2]}]
    set rel [expr {($avg/1000.0)/$total_avg}]
    set url [lindex $l 0]
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
    t1 add 	-url [string_truncate_middle -len 80 $url] \
		-totaltime [lindex $l 1] \
		-cnt [lindex $l 2] \
		-avg $avg \
		-total [format %.2f%% [expr {[lindex $l 1]*100.0/$total}]] 
  }

set t1 [t1 asHTML]

append user_string "<b>Grand Total Avg Response time: </b>" \
	[format %6.2f $total_avg] " seconds/call " \
	"(base: $cnt requests)<br>"

append user_string "$hidden requests hidden."
if {$hidden>0} {
  append user_string " (Patterns: $hide_patterns)"
}

