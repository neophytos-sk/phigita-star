 # /packages/calendar/www/cal-weekview.tcl

ad_page_contract {
    
    Source files for the week view generation
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-weekview.tcl,v 1.6 2002/04/10 00:54:09 ben Exp $
} {
    {date now}
    {view week}
    {calendar_id:integer "-1"}
    {calendar_list:multiple,optional {}}
} -properties {
    row_html:onevalue
    date:onevalue
}

if { $date ==  "now"} {
    set date [dt_systime]
}


#-------------------------------------------------
# find out the user_id 
set user_id [ad_verify_and_get_user_id]

set current_date $date
set date_format "YYYY-MM-DD HH24:MI"

# get the week info from oracle
# this should be part of the proc
# dt_get_info_from_db

db_1row get_weekday_info "
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as       day_of_the_week,
         to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'SUNDAY')) 
as       sunday_of_the_week,
         to_char(next_day(to_date(:current_date, 'yyyy-mm-dd'), 'Saturday')) 
as       saturday_of_the_week
from     dual
"

#-----------------------------------------------
# get cal-item


set mlist ""
set set_id [ns_set new week_items]



#-------------------------------------------------
# verifiy if the calendar_list has elements or not

if {[llength $calendar_list] == 0} {
    
    # in the case when there are no elements, we check the
    # default, the calendar is set to -1

    if { [string equal $calendar_id "-1"] } {
	# find out the calendar_id of the private calendar
	
	set calendar_id [calendar_have_private_p -return_id 1 $user_id]
	set calendar_name "Private"
	
    } else {
	# otherwise, get the calendar_name for the give_id
	set calendar_name [calendar_get_name $calendar_id]
    }


    db_foreach get_day_items {
select   to_char(start_date, 'J') as start_date,
         to_char(start_date, 'HH24:MI') as pretty_start_date,
         to_char(end_date, 'HH24:MI') as pretty_end_date,
         nvl(e.name, a.name) as name,
         e.event_id as item_id
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      start_date between
         to_date(:sunday_of_the_week,'YYYY-MM-DD') and
         to_date(:saturday_of_the_week,'YYYY-MM-DD')
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar = :calendar_id
         )
} {
	ns_set put $set_id  $start_date "<li> <a href=cal-item-view?action=edit&cal_item_id=$item_id>
	$pretty_start_date - $pretty_end_date $name ($calendar_name)
	</a>"
	append items "<li> <a href=?action=edit&cal_item_id=$item_id>
	$pretty_start_date - $pretty_end_date $name ($calendar_name)
	</a><br>"
    } 

} else {
    # when there are elements, we construct the query to extract all
    # the cal_items associated with the calendar in which the given
    # party has read permissions to.
        
    foreach item $calendar_list {
	set calendar_id [lindex $item 0]
	
	if { [string equal $calendar_id "-1"] } {
	    # find out the calendar_id of the private calendar
	    set calendar_id [calendar_have_private_p -return_id 1 $user_id]
	    set calendar_name "Private"
	} else {
	    set calendar_name [calendar_get_name $calendar_id]
	}


	db_foreach get_day_items {
select   to_char(start_date, 'J') as start_date,
         to_char(start_date, 'HH24:MI') as pretty_start_date,
         to_char(end_date, 'HH24:MI') as pretty_end_date,
         nvl(e.name, a.name) as name,
         e.event_id as item_id
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      start_date between
         to_date(:sunday_of_the_week,'YYYY-MM-DD') and
         to_date(:saturday_of_the_week,'YYYY-MM-DD')
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar = :calendar_id
         )
} {
	    ns_set put $set_id  $start_date "<li> <a href=?action=edit&cal_item_id=$item_id>
	    $pretty_start_date - $pretty_end_date $name ($calendar_name)
                                     </a>"
    append items "<li> <a href=?action=edit&cal_item_id=$item_id>
	    $pretty_start_date - $pretty_end_date $name ($calendar_name)
	    </a><br>"
	} 

	
    }
}


#-------------------------------------------------
#
set num_hour_rows 7
set i 0

set bgcolor_html "bgcolor=DCDCDC"

set row_html "
<table  cellpadding=2 cellspacing=0 border=1 width=350>

"




while {$i < $num_hour_rows} {
    
    set sql "
    select  to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'SUNDAY')+$i, 'DAY') 
    as      weekday,
            to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'SUNDAY')+$i, 'YYYY-MM-DD') 
            as pretty_date,
            to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'SUNDAY')+$i, 'J') 
            as start_date
    from    dual
    "

    db_1row week_data $sql
    append row_html "
    <tr >
      <td $bgcolor_html> <b>$weekday </b> 
           <a href=\"?date=[ns_urlencode $pretty_date]&view=$view&action=add\">$pretty_date</a> 
      </td>
    </tr>
    
    <tr>
      <td>"


    set cal_item_index [ns_set find $set_id $start_date]     

    if {$cal_item_index == -1} {
	append row_html "&nbsp;"
    }

    while {$cal_item_index > -1} {

	append row_html [ns_set value $set_id $cal_item_index]

	ns_set delete $set_id $cal_item_index
	set cal_item_index [ns_set find $set_id $start_date]     
    }

    
    append row_html "  
        </td>
      </tr>
    "

    incr i
}
append row_html "</table>"

ad_return_template













