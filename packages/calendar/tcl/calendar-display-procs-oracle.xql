<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="calendar::one_month_display.select_monthly_items">      
      <querytext>
      
	select   to_char(start_date, 'j') as start_date,
                 to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
                 to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
	         nvl(e.name, a.name) as name,
	         nvl(e.description, a.description) as description,
                 nvl(e.status_summary, a.status_summary) as status_summary,
	         e.event_id as item_id,
		 (select on_which_calendar from cal_items where cal_item_id = e.event_id) as calendar_id,
		 (select calendar_name from calendars 
		 where calendar_id = (select on_which_calendar from cal_items where cal_item_id= e.event_id))
		 as calendar_name
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
	         where   on_which_calendar in ([join $calendar_id_list ","])
         )
         order by start_date,end_date
	
      </querytext>
</fullquery>


<fullquery name="calendar::one_week_display.select_week_items">
<querytext>
select   to_char(start_date, 'J') as start_date_julian,
         to_char(start_date,'HH24:MI') as start_date,
         to_char(end_date,'HH24:MI') as end_date,
         to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         nvl(e.name, a.name) as name,
         nvl(e.status_summary, a.status_summary) as status_summary,
         e.event_id as item_id,
         (select type from cal_item_types where item_type_id= cal_items.item_type_id) as item_type,
	 on_which_calendar as calendar_id,
	 (select calendar_name from calendars 
	 where calendar_id = on_which_calendar)
	 as calendar_name
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t,
         cal_items
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      e.event_id = cal_items.cal_item_id       
and      start_date >= to_date(:first_day_of_week_julian, 'J') 
and      start_date <= to_date(:first_day_of_week_julian + 7, 'J')
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar in ([join $calendar_id_list ","])
         )
order by start_date
</querytext>
</fullquery>

<fullquery name="calendar::one_day_display.select_day_items">
<querytext>
	select to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         nvl(e.name, a.name) as name,
         nvl(e.status_summary, a.status_summary) as status_summary,
         e.event_id as item_id,
         (select type from cal_item_types where item_type_id= cal_items.item_type_id) as item_type,
	 on_which_calendar as calendar_id,
	 (select calendar_name from calendars 
	 where calendar_id = on_which_calendar)
	 as calendar_name,
         to_char(timezone.local_to_utc(timezone.get_id(:timezone),to_date(:current_date,:date_format)),'YYYY-MM-DD HH24:MI:SS') as start_interval,
         to_char(timezone.local_to_utc(timezone.get_id(:timezone),to_date(:current_date,:date_format) + (24 - 1/3600)/24),'YYYY-MM-DD HH24:MI:SS')  as end_interval
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t,
         cal_items
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      start_date between
         timezone.local_to_utc(timezone.get_id(:timezone),to_date(:current_date,:date_format)) and
         timezone.local_to_utc(timezone.get_id(:timezone),to_date(:current_date,:date_format) + (24 - 1/3600)/24)
and     cal_items.cal_item_id= e.event_id
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar in ([join $calendar_id_list ","])
         )
	
</querytext>
</fullquery>

<fullquery name="calendar::list_display.select_list_items">
<querytext>
	select   to_char(start_date, 'HH24') as start_hour,
         to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         nvl(e.name, a.name) as name,
         nvl(e.status_summary, a.status_summary) as status_summary,
         e.event_id as item_id,
         recurrence_id,
         (select type from cal_item_types where item_type_id= cal_items.item_type_id) as item_type
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t,
         cal_items
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      cal_items.cal_item_id= e.event_id
and      (start_date > to_date(:start_date,:date_format) or :start_date is null) and
         (start_date < to_date(:end_date,:date_format) or :end_date is null)
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar = :calendar_id
         )
order by $sort_by	
</querytext>
</fullquery>
 
</queryset>
