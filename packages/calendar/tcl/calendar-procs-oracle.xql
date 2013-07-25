<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="calendar_create.create_new_calendar">      
      <querytext>
      
	begin
	:1 := calendar.new(
	  owner_id      => :owner_id,
	  private_p     => :private_p,
	  calendar_name => :calendar_name,
	  package_id    => :package_id,
	  creation_user => :creation_user,
	  creation_ip   => :creation_ip
	);	
	end;
    
      </querytext>
</fullquery>

 
<fullquery name="calendar_assign_permissions.get_magic_id">      
      <querytext>
      
	    select  acs.magic_object_id('the_public')
	            as party_id
	    from    dual
	
      </querytext>
</fullquery>

 
 
<fullquery name="calendar_create_private.get_user_name">      
      <querytext>
      
	select   acs_object.name(:private_id) 
	from     dual
    
      </querytext>
</fullquery>

 
<fullquery name="calendar_get_name.get_calendar_name">      
      <querytext>
      
	       select  calendar.name(:calendar_id)
	       from    dual
    
      </querytext>
</fullquery>

 
<fullquery name="calendar_public_p.check_calendar_permission">      
      <querytext>
      
              select   acs_permission.permission_p(
                         :calendar_id, 
                         acs.magic_object_id('the_public'),
                         'calendar_read'
                       ) 
              from     dual

            
      </querytext>
</fullquery>

 
</queryset>
