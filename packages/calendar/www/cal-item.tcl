# /packages/calendar/www/cal-item.tcl

ad_page_contract {
    
    Single calendar item view
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-item.tcl,v 1.13 2002/09/13 10:43:59 jeffd Exp $
} {
    {action add}
    {date ""}
    {julian_date ""}
    {cal_item_id 0}
    {start_time "now"}
    {end_time "now"}
    {return_url ""}
    {force_calendar_id ""}
    {show_cal_nav 1}
} -properties {
    cal_item_id:onevalue

    name:onevalue
    description:onevalue

    start_date:onevalue
    start_time:onevalue
    end_time:onevalue

    edit_p:onevalue
    delete_p:onevalue
    admin_p:onevalue

    calendars:multirow

}

if {[empty_string_p $date]} {
    if {[empty_string_p $julian_date]} {
        set date now
    } else {
        set date [db_string select_from_julian "select to_date(:julian_date ,'J') from dual"]
    }
}
 

# find out the user_id 
set user_id [ad_verify_and_get_user_id]


# find out the calendar_id
# for this case, we are assuming that its
# a private calendar
set calendar_id [calendar_have_private_p -return_id 1 $user_id]

# set up all the default values
set name ""
set description ""

if {$date == "now"} {
    set start_date "now"
} else {
    set start_date $date 
}

#------------------------------------------------
# check the permission on the party to the object
# then set up the variable to the template

# write permission
set edit_p [ad_permission_p $cal_item_id cal_item_write]

# delete permission
set delete_p [ad_permission_p $cal_item_id cal_item_delete] 

# admin permission
set admin_p [ad_permission_p $cal_item_id calendar_admin]

set item_type_id ""

#------------------------------------------------
# only worry about the query when it is an edit
if { $action == "edit" } {
    
    # check so that cal_item_id does exist
    if { [empty_string_p $cal_item_id] } {
	# barf error
	ad_return_complaint 1 "you need to supply a cal_item_id"
    }


    # get data time
    db_1row get_item_data { 
	select   to_char(start_date,'HH24:MI')as start_time,
		 to_char(start_date, 'MM/DD/YYYY') as start_date,
	         to_char(end_date, 'HH24:MI') as end_time,
	         nvl(a. name, e.name) as name,
	         nvl(e.description, a.description) as description,
                 recurrence_id,
                 item_type_id,
                 on_which_calendar as calendar_id
	from     acs_activities a,
	         acs_events e,
	         timespans s,
	         time_intervals t,
                 cal_items
	where    e.timespan_id = s.timespan_id
	and      s.interval_id = t.interval_id
	and      e.activity_id = a.activity_id
	and      e.event_id = :cal_item_id
        and      cal_items.cal_item_id= :cal_item_id
    }

    set force_calendar_id $calendar_id
    
    set cal_item_types [calendar::get_item_types -calendar_id $force_calendar_id]    
    # forced error checking
    set name [ad_quotehtml $name]
    set description [ad_quotehtml $description]

} elseif { [string equal $action "add"] } {
    # get calendar names that user has calendar
    # write permission to


    # write permission for the calendar
    set edit_p [ad_permission_p $calendar_id calendar_write]
    
    # user has no private calendar
    if { [string equal $calendar_id 0] } {
	set edit_p 1
    }

    db_multirow calendars list_calendars {}

    if {![empty_string_p $force_calendar_id]} {
        set force_calendar_name [calendar_get_name $force_calendar_id]

        set cal_item_types [calendar::get_item_types -calendar_id $force_calendar_id]
    }

}

set no_time_p [dt_no_time_p -start_time $start_time -end_time $end_time]

ad_return_template










