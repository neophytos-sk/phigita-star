<?xml version="1.0"?>

<queryset>

<fullquery name="calendar::item::add_recurrence.update_event">
<querytext>
update acs_events 
set recurrence_id= :recurrence_id
where event_id= :cal_item_id
</querytext>
</fullquery>

<fullquery name="calendar::item::add_recurrence.insert_cal_items">
<querytext>
insert into cal_items 
(cal_item_id, on_which_calendar)
select
event_id, 
(select on_which_calendar 
as calendar_id from cal_items 
where cal_item_id = :cal_item_id)
from acs_events where recurrence_id= :recurrence_id 
and event_id <> :cal_item_id
</querytext>
</fullquery>

</queryset>
