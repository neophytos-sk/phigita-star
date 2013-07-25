<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="cc_group_to_name.group_name_select">      
      <querytext>
      
             select acs_group__name(:group_id)
             from   dual
    
      </querytext>
</fullquery>

 
<fullquery name="cc_is_party_group_p.get_group_result">      
      <querytext>
      
	select    acs_object_util__get_object_type(:party_id)
	as        result
	from      dual
    
      </querytext>
</fullquery>

 
<fullquery name="cc_is_party_user_p.get_group_result">      
      <querytext>
      
	select    acs_object_util__get_object_type(:party_id)
	as        result
	from      dual
    
      </querytext>
</fullquery>

 
</queryset>
