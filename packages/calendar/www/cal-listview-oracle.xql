<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_day_items">      
      <querytext>
      
select   to_char(start_date, 'j') as start_date,
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
        to_date(:current_date,:date_format) and
         to_date(:current_date,:date_format) + (24 - 1/3600)/24
and      e.event_id
in       (
           select    cal_item_id
           from      cal_items  
           where     on_which_calendar = :calendar_id
         )

      </querytext>
</fullquery>

 
<fullquery name="get_day_items">      
      <querytext>
      
select   to_char(start_date, 'j') as start_date,
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
        to_date(:current_date,:date_format) and
         to_date(:current_date,:date_format) + (24 - 1/3600)/24
and      e.event_id
in       (
           select    cal_item_id
           from      cal_items  
           where     on_which_calendar = :calendar_id
         )

      </querytext>
</fullquery>

 
</queryset>
