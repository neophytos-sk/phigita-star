<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_weekday_info">      
      <querytext>
      
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as       day_of_the_week,
         to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'SUNDAY')) 
as       sunday_of_the_week,
         to_char(next_day(to_date(:current_date, 'yyyy-mm-dd'), 'Saturday')) 
as       saturday_of_the_week
from     dual

      </querytext>
</fullquery>

 
<fullquery name="get_day_items">      
      <querytext>
      
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
and      trunc(start_date) between to_date(:sunday_of_the_week,'YYYY-MM-DD') and
         to_date(:saturday_of_the_week,'YYYY-MM-DD')
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar = :calendar_id
         )

      </querytext>
</fullquery>

 
</queryset>
