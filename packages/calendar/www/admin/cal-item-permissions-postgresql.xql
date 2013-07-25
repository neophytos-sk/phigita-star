<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_party_name">      
      <querytext>
      
                  select   acs_object__name(:party_id)
                  from     dual
               
      </querytext>
</fullquery>


<fullquery name="get_cal_item_name">      
      <querytext>
      
                     select    cal_item__name(:cal_item_id)
                     from      dual
                  
      </querytext>
</fullquery>

 
<fullquery name="list_users">      
      <querytext>
      
	select   acs_object__name(party_id) 
	         as pretty_name,
	         party_id
        from     parties
    
      </querytext>
</fullquery>

 
<fullquery name="get_calendar_audiences">      
      <querytext>
      
	select    distinct(grantee_id) as party_id,
	          acs_object__name(grantee_id) as name
	from      acs_permissions
	where     object_id = :cal_item_id	
    
      </querytext>
</fullquery>

 
</queryset>
