<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="calendar::item::dates_valid_p.dates_valid_p_select">
      <querytext>
        select CASE WHEN (:start_date::timestamp - :end_date::timestamp) <= 0 
                    THEN 1
                    ELSE -1
               END 
      </querytext>
    </fullquery>

    <fullquery name="calendar::item::get.select_item_data">      
      <querytext>
       select
         i.cal_item_id,
         0 as n_attachments,
         to_char(start_date, 'YYYY-MM-DD HH:MI:SS') as start_date,
         end_date as end_date,
         to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         coalesce(a.name, e.name) as name,
         coalesce(e.description, a.description) as description,
         recurrence_id,
         i.item_type_id,
         it.type as item_type,
         on_which_calendar as calendar_id
       from
         acs_events e join timespans s
           on (e.timespan_id = s.timespan_id)
         join time_intervals t
           on (s.interval_id = t.interval_id)
         join acs_activities a
           on (e.activity_id = a.activity_id)
         join cal_items i
           on (e.event_id = i.cal_item_id)
         left join cal_item_types it
           on (it.item_type_id = i.item_type_id)
       where
         e.event_id = :cal_item_id
      </querytext>
    </fullquery>

    <fullquery name="calendar::item::get.select_item_data_with_attachment">      
      <querytext>
       select
         i.cal_item_id,
         (select count(*) from attachments where object_id = cal_item_id) as n_attachments,
         to_char(start_date,'HH:MIpm') as start_time,
	 to_char(start_date,'D') as day_of_week,
         to_char(start_date,'Day') as pretty_day_of_week,
         to_char(start_date,'DD') as day_of_month,
         to_char(start_date, 'YYYY-MM-DD HH:MI:SS') as start_date,
         to_char(start_date, 'MM/DD/YYYY') as pretty_short_start_date,
         to_char(end_date, 'HH:MIpm') as end_time,
         end_date as end_date,
         to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         coalesce(a.name, e.name) as name,
         coalesce(e.description, a.description) as description,
         recurrence_id,
         i.item_type_id,
         it.type as item_type,
         on_which_calendar as calendar_id
       from
         acs_events e join timespans s
           on (e.timespan_id = s.timespan_id)
         join time_intervals t
           on (s.interval_id = t.interval_id)
         join acs_activities a
           on (e.activity_id = a.activity_id)
         join cal_items i
           on (e.event_id = i.cal_item_id)
         left join cal_item_types it
           on (it.item_type_id = i.item_type_id)
       where
         e.event_id = :cal_item_id
     </querytext>
   </fullquery>

<fullquery name="calendar::item::add_recurrence.create_recurrence">
<querytext>
select recurrence__new(:interval_type,
    	:every_n,
    	:days_of_week,
    	:recur_until,
	NULL)
</querytext>
</fullquery>

<fullquery name="calendar::item::add_recurrence.insert_instances">
<querytext>
select acs_event__insert_instances(:cal_item_id, NULL);
</querytext>
</fullquery>

</queryset>
