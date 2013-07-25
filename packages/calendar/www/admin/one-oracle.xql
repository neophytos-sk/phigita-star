<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_calendar_audiences">      
      <querytext>
      
	select    unique(grantee_id) as party_id,
	          acs_object.name(grantee_id) as name
	from      acs_permissions
	where     object_id = :calendar_id	
    
      </querytext>
</fullquery>

 
</queryset>
