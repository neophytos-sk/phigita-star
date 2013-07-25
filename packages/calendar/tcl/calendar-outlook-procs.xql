<?xml version="1.0"?>
<queryset>

<fullquery name="calendar::outlook::adjust_timezone.adjust_timezone">
<querytext>
select to_char(timezone.utc_to_local(tz_id, utc_time), :format)
from timezones,
(select timezone.local_to_utc(tz_id, to_date(:timestamp,:format)) as utc_time
from timezones where tz= :server_tz)
where tz= :user_tz
</querytext>
</fullquery>

<fullquery name="calendar::outlook::format_item.select_recurrence">      
<querytext>
select 
recurrence_id, recurrences.interval_type, interval_name,
every_nth_interval, days_of_week, recur_until
from recurrences, recurrence_interval_types
where recurrence_id= :recurrence_id
and recurrences.interval_type = recurrence_interval_types.interval_type
</querytext>
</fullquery>

 
</queryset>
