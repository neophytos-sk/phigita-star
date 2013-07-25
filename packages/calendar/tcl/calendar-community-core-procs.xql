<?xml version="1.0"?>
<queryset>

<fullquery name="cc_member_of_groups.get_all_party_ids">      
    <querytext>
    select   group_id 
    from     group_member_index
    where    member_id = :member_id
    </querytext>
</fullquery>
 
</queryset>
