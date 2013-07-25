<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_readable_calendars">      
      <querytext>
      

    select   unique(calendar_id) as calendar_id,
             calendar_name,
             ' ' as checked_p
    from     calendars
    where    acs_permission.permission_p(calendar_id, :user_id, 'calendar_read') = 't'
    and      acs_permission.permission_p(calendar_id, :user_id, 'calendar_show') = 't'
    and      private_p = 'f'

    union 
    
    select  unique(on_which_calendar) as calendar_id,
            calendar.name(on_which_calendar) as calendar_name,
            ' ' as checked_p
    from    cal_items
    where   acs_permission.permission_p(cal_item_id, :user_id, 'cal_item_read') = 't'
    and     calendar.private_p(on_which_calendar) = 'f'

      

      </querytext>
</fullquery>

 
</queryset>
