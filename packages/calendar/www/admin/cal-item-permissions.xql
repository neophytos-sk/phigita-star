<?xml version="1.0"?>
<queryset>

<fullquery name="get_existing_permissions">      
      <querytext>
      
    select   distinct(child_privilege) as privilege 
    from     acs_privilege_hierarchy 
    where    child_privilege like 'cal_item%'

      </querytext>
</fullquery>

 
<fullquery name="get_party_privileges">      
      <querytext>
      
	select    distinct privilege
	from      all_object_party_privilege_map 
	where     party_id = :party_id
	and       object_id = :cal_item_id
	and       privilege like '%cal_item%'
    
      </querytext>
</fullquery>

 
</queryset>
