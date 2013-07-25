<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_item_data">      
      <querytext>
       
	select   to_char(start_date, 'HH24:MI') as start_time,
		 to_char(start_date, 'MM/DD/YYYY') as start_date,
	         to_char(end_date, 'HH24:MI') as end_time,
	         coalesce(a. name, e.name) as name,
	         coalesce(e.description, a.description) as description
	from     acs_activities a,
	         acs_events e,
	         timespans s,
	         time_intervals t
	where    e.timespan_id = s.timespan_id
	and      s.interval_id = t.interval_id
	and      e.activity_id = a.activity_id
	and      e.event_id = :cal_item_id
    
      </querytext>
</fullquery>

 
<fullquery name="list_calendars">      
      <querytext>
      
        select    calendar_id, calendar_name
        from      calendars
        where     acs_permission__permission_p(calendar_id, :user_id, 'calendar_write') = 't'
        and       private_p = 'f';          
    
      </querytext>
</fullquery>

 
</queryset>
