<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1.2</version></rdbms>

<fullquery name="calendar::outlook::adjust_timezone.adjust_timezone">
<querytext>
select to_char(timezone__utc_to_local(tz_id, utc_time), :format)
from timezones,
(select timezone__convert_to_utc(tz_id, :timestamp) as utc_time
from timezones where tz= :server_tz) foo
where tz= :user_tz
</querytext>
</fullquery>
 
</queryset>
