<?xml version="1.0"?>
<queryset>

<fullquery name="private_calendar_count_qry">
<querytext>
select count(*) from calendars
where package_id= :package_id
and  owner_id= :user_id
and  private_p = 't'
</querytext>
</fullquery>

</queryset>
