<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_readable_calendars">      
      <querytext>
      

    select  distinct(calendar_id) as calendar_id,
             calendar_name,
             ' '::varchar as checked_p
    from     calendars
    where    acs_permission__permission_p(calendar_id, :user_id, 'calendar_read') = 't'
    and      acs_permission__permission_p(calendar_id, :user_id, 'calendar_show') = 't'
    and      private_p = 'f'

    union 
    
    select  distinct(on_which_calendar) as calendar_id,
            calendar__name(on_which_calendar) as calendar_name,
            ' '::varchar as checked_p
    from    cal_items
    where   acs_permission__permission_p(cal_item_id, :user_id, 'cal_item_read') = 't'
    and     calendar__private_p(on_which_calendar) = 'f'

      

      </querytext>
</fullquery>

 
</queryset>
