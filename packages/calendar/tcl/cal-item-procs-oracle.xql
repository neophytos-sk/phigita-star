<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="cal_item_create.insert_activity">      
      <querytext>
      
	begin
	:1 := acs_activity.new (
	  name          => :name,
	  description   => :description,
	  creation_user => :creation_user,
	  creation_ip   => :creation_ip
	);
	end;
    
      </querytext>
</fullquery>

 
<fullquery name="cal_item_create.insert_timespan">      
      <querytext>
      
	begin
	:1 := timespan.new(
	  start_date => to_date(:start_date,:date_format),
	  end_date   => to_date(:end_date,:date_format)
	);
	end;
    
      </querytext>
</fullquery>

 
<fullquery name="cal_item_create.cal_item_add">      
      <querytext>
      
	begin
	:1 := cal_item.new(
	  on_which_calendar  => :on_which_calendar,
	  activity_id        => :activity_id,
          timespan_id        => :timespan_id,
          item_type_id       => :item_type_id,
	  creation_user      => :creation_user,
	  creation_ip        => :creation_ip,
          context_id         => :on_which_calendar
	);
	end;
    
      </querytext>
</fullquery>

 
<fullquery name="cal_item_update.update_interval">      
      <querytext>
      
	begin
	  time_interval.edit (
	    interval_id  => :interval_id,
	    start_date   => to_date(:start_date,:date_format),
	    end_date     => to_date(:end_date,:date_format)
	  );
	end;
    
      </querytext>
</fullquery>

 
<fullquery name="cal_item_delete.delete_cal_item">      
      <querytext>
      
	begin
	  cal_item.delete (
	    cal_item_id  => :cal_item_id
	  );
	end;
    
      </querytext>
</fullquery>

<fullquery name="cal_item_delete_recurrence.delete_cal_item_recurrence">      
      <querytext>
      
	begin
	  cal_item.delete_all (
	    recurrence_id  => :recurrence_id
	  );
	end;
    
      </querytext>
</fullquery>

<fullquery name="cal_item_edit_recurrence.recurrence_timespan_update">
<querytext>
begin
  acs_event.recurrence_timespan_edit (
    event_id => :event_id,
    start_date => to_date(:start_date,'YYYY-MM-DD HH24:MI'),
    end_date => to_date(:end_date,'YYYY-MM-DD HH24:MI')
  );
end;
</querytext>
</fullquery>
 
</queryset>
