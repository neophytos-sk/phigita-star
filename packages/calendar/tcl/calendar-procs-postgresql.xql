<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="calendar_create.create_new_calendar">      
      <querytext>
	select calendar__new(
		null,
		:calendar_name,
		'calendar',
		:owner_id,
		:private_p,
		:package_id,
		null,
		now(),
		:creation_user,
		:creation_ip
	);
      </querytext>
</fullquery>

 
<fullquery name="calendar_assign_permissions.get_magic_id">      
      <querytext>
      
	    select  acs__magic_object_id('the_public')
	            as party_id
	    from    dual
	
      </querytext>
</fullquery>

 
 
<fullquery name="calendar_create_private.get_user_name">      
      <querytext>
      
	select   acs_object__name(:private_id) 
	from     dual
    
      </querytext>
</fullquery>

 
<fullquery name="calendar_get_name.get_calendar_name">      
      <querytext>
      
	       select  calendar__name(:calendar_id)
	       from    dual
    
      </querytext>
</fullquery>

 
<fullquery name="calendar_public_p.check_calendar_permission">      
      <querytext>
      
              select   acs_permission__permission_p(
                         :calendar_id, 
                         acs__magic_object_id('the_public'),
                         'calendar_read'
                       ) 
              from     dual

            
      </querytext>
</fullquery>

 
</queryset>
