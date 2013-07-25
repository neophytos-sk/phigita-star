<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="cc_group_to_name.group_name_select">      
      <querytext>
      
             select acs_group.name(:group_id)
             from   dual
    
      </querytext>
</fullquery>

 
<fullquery name="cc_is_party_group_p.get_group_result">      
      <querytext>
      
	select    acs_object_util.get_object_type(:party_id)
	as        result
	from      dual
    
      </querytext>
</fullquery>

 
<fullquery name="cc_is_party_group_p.get_group_result">      
      <querytext>
      
	select    acs_object_util.get_object_type(:party_id)
	as        result
	from      dual
    
      </querytext>
</fullquery>

 
</queryset>
