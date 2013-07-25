<?xml version="1.0"?>
<queryset>

<fullquery name="calendar_update.update_calendar">      
      <querytext>
      
	update   calendars
	set      calendar_name = :calendar_name
	where    calendar_id = :calendar_id	
    
      </querytext>
</fullquery>

<fullquery name="calendar_have_group_cal_p.get_calendar_info">
    <querytext>
    select    calendar_id,
    from      calendars
    where     owner_id = :party_id
    </querytext>
</fullquery>

<fullquery name="calendar_have_private_p.get_calendar_info">
    <querytext>
    select    calendar_id
    from      calendars
    where     owner_id = :party_id
    and       private_p = 't'
    </querytext>
</fullquery>
 
</queryset>
