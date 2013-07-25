<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_item_data">      
      <querytext>
       
	select   to_char(start_date, 'MM/DD/YYYY') as start_date,
	         to_char(start_date, 'HH24:MI') as start_time,
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
        and      cal_items.cal_item_id = :cal_item_id
      </querytext>
</fullquery>

 
<fullquery name="list_calendars">      
      <querytext>


        select    calendar_id, calendar_name
        from      calendars
        where     acs_permission.permission_p(calendar_id, :user_id, 'calendar_write') = 't'
        and       private_p = 'f'        



      </querytext>
</fullquery>

 
</queryset>
