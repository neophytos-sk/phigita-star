<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_calendar_audiences">      
      <querytext>
      
	select    distinct(grantee_id) as party_id,
	          acs_object__name(grantee_id) as name
	from      acs_permissions
	where     object_id = :calendar_id	
    
      </querytext>
</fullquery>

 
</queryset>
