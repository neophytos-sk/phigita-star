<?xml version="1.0"?>
<queryset>

<fullquery name="cal_item_create.get_permissions_to_items">      
      <querytext>
      
	select          grantee_id,
                  	privilege
	from            acs_permissions
	where           object_id = :on_which_calendar
    
      </querytext>
</fullquery>

<fullquery name="cal_item_update.select_recurrence_id">
<querytext>
select recurrence_id from acs_events where event_id= :cal_item_id
</querytext>
</fullquery>

<fullquery name="cal_item_update.update_activity">
    <querytext>
    update acs_activities 
    set    name = :name,
           description = :description
    where  activity_id
    in     (
           select activity_id
           from   acs_events
           where  event_id = :cal_item_id
           )
    </querytext>
</fullquery>

<fullquery name="cal_item_update.update_event">
    <querytext>
    update acs_events
    set    name = :name,
           description = :description
    where  event_id= :cal_item_id
    </querytext>
</fullquery>

<fullquery name="cal_item_update.get_interval_id">
    <querytext>
    select interval_id 
    from   timespans
    where  timespan_id
    in     (
           select timespan_id
           from   acs_events
           where  event_id = :cal_item_id
           )
    </querytext>
</fullquery>

<fullquery name="cal_item_edit_recurrence.select_recurrence_id">
<querytext>
select recurrence_id from acs_events where event_id= :event_id
</querytext>
</fullquery>

<fullquery name="cal_item_edit_recurrence.recurrence_activities_update">
    <querytext>
    update acs_activities 
    set    name = :name,
           description = :description
    where  activity_id
    in     (
           select activity_id
           from   acs_events
           where  recurrence_id = :recurrence_id
           )
    </querytext>
</fullquery>

<fullquery name="cal_item_edit_recurrence.recurrence_events_update">
    <querytext>
    update acs_events set
    name= :name, description= :description
    where recurrence_id= :recurrence_id
    </querytext>
</fullquery>


<fullquery name="cal_item_edit_recurrence.recurrence_items_update">
    <querytext>
    update cal_items set
    item_type_id= :item_type_id
    where cal_item_id in (select event_id from acs_events where recurrence_id= :recurrence_id)
    </querytext>
</fullquery>
 
</queryset>
