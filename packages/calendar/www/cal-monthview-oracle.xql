<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_monthly_items">      
      <querytext>
      
	select   to_char(start_date, 'j') as start_date,
        	 nvl(e.name, a.name) as name,
         	 nvl(e.description, a.description) as description,
         	 e.event_id as item_id
	from     acs_activities a,
	         acs_events e,
        	 timespans s,
	         time_intervals t
	where    e.timespan_id = s.timespan_id
	and      s.interval_id = t.interval_id
	and      e.activity_id = a.activity_id
	and      e.event_id
	in       (
        	 select  cal_item_id
	         from    cal_items
	         where   on_which_calendar = :calendar_id
        	 )
	
      </querytext>
</fullquery>

 
<fullquery name="get_monthly_items">      
      <querytext>
      
	select   to_char(start_date, 'j') as start_date,
	         nvl(e.name, a.name) as name,
	         nvl(e.description, a.description) as description,
	         e.event_id as item_id
	from     acs_activities a,
	         acs_events e,
	         timespans s,
	         time_intervals t
	where    e.timespan_id = s.timespan_id
	and      s.interval_id = t.interval_id
	and      e.activity_id = a.activity_id
	and      e.event_id
	in       (
	         select  cal_item_id
	         from    cal_items
	         where   on_which_calendar = :calendar_id
         )
	
      </querytext>
</fullquery>

 
</queryset>
