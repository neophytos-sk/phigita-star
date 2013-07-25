<?xml version="1.0"?>
<queryset>

<fullquery name="calendar::adjust_calendar_list.select_calendar_list">
<querytext>
select calendar_id from calendars
where package_id= :package_id
and (private_p='f' or (private_p='t' and owner_id= :user_id))
$sql_clause
</querytext>
</fullquery>

<fullquery name="calendar::get_item_types.select_item_types">
<querytext>
select type, item_type_id from cal_item_types
where calendar_id= :calendar_id
</querytext>
</fullquery>

<fullquery name="calendar::item_type_new.insert_item_type">
<querytext>
insert into cal_item_types
(item_type_id, calendar_id, type)
values
(:item_type_id, :calendar_id, :type)
</querytext>
</fullquery>

<fullquery name="calendar::item_type_delete.reset_item_types">
<querytext>
update cal_items
set item_type_id= NULL
where item_type_id = :item_type_id
and on_which_calendar= :calendar_id
</querytext>
</fullquery>
 
<fullquery name="calendar::item_type_delete.delete_item_type">
<querytext>
delete from cal_item_types where item_type_id= :item_type_id
and calendar_id= :calendar_id
</querytext>
</fullquery>

    <fullquery name="calendar::rename.rename_calendar">
        <querytext>
            update calendars
            set calendar_name = :name
            where calendar_id = :calendar_id
        </querytext>
    </fullquery>

</queryset>
