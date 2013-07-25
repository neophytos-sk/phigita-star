<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="calendar::outlook::adjust_timezone.adjust_timezone">
<querytext>
select to_char(timezone.utc_to_local(tz_id, utc_time), :format)
from timezones,
(select timezone.local_to_utc(tz_id, to_date(:timestamp,:format)) as utc_time
from timezones where tz= :server_tz)
where tz= :user_tz
</querytext>
</fullquery>
 
</queryset>
