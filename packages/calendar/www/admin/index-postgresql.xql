<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="calendar_list">      
      <querytext>
      
    select     calendar_id, 
               calendar_name
    from       calendars
    where      owner_id = :user_id
    and        acs_permission__permission_p(
                  calendar_id, 
                  :user_id,
                  'calendar_admin'
               ) = 't'
    order by   calendar_name

      </querytext>
</fullquery>

 
</queryset>
