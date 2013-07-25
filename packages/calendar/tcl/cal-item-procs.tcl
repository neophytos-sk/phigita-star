# /packages/calendar/tcl/cal-item-procs.tcl

ad_library {

    Utility functions for Calendar Applications

    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Jan 11, 2001
    @cvs-id $Id: cal-item-procs.tcl,v 1.11 2002/11/30 17:27:51 jeffd Exp $

}


#------------------------------------------------
# update the permissions of the calendar
ad_proc cal_assign_item_permission { cal_item_id 
                                     party_id
                                     permission 
                                     {revoke ""}
} {
    update the permission of the specific cal_item
    if revoke is set to revoke, then we revoke all permissions
} {
    
    # adding permission

    if { ![string equal $revoke "revoke"] } {

	# we make the assumation that permission cal_read is 
	# by default granted to all users who needs write, delete
	# and invite permission

	if { ![string equal $permission "cal_item_read"] } {

	    # grant read permission first
            permission::grant -object_id $cal_item_id -party_id $party_id -privilege cal_item_read
	    
	}
	
	# grant other permission

        permission::grant -object_id $cal_item_id -party_id $party_id -privilege $permission

	
    } elseif { [string equal $revoke "revoke"] } {
	
	# revoke the permissions

        permission::revoke -object_id $cal_item_id -party_id $party_id -privilege $permission

    }
}

#------------------------------------------------
# adding a new calendar item
ad_proc cal_item_create { start_date
                          end_date
                          name
                          description
                          on_which_calendar
                          creation_ip
                          creation_user
{item_type_id ""}
} {

  create a new cal_item
  for this version, i am omitting recurrence

} {


    # find out the activity_id
    set activity_id [db_exec_plsql insert_activity {
	begin
	:1 := acs_activity.new (
	  name          => :name,
	  description   => :description,
	  creation_user => :creation_user,
	  creation_ip   => :creation_ip
	);
	end;
    }
    ]

    # set the date_format
    set date_format "YYYY-MM-DD HH24:MI"

    # find out the timespan_id
    set timespan_id [db_exec_plsql insert_timespan {
	begin
	:1 := timespan.new(
	  start_date => to_date(:start_date,:date_format),
	  end_date   => to_date(:end_date,:date_format)
	);
	end;
    }
    ]

    # create the cal_item
    # we are leaving the name and description fields in acs_event
    # blank to abide by the definition that an acs_event is an acs_activity
    # with added on temperoal information

    # by default, the cal_item permissions 
    # are going to be inherited from the calendar permissions

    set cal_item_id [db_exec_plsql cal_item_add {
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
    }
    ]

    return $cal_item_id

}


#------------------------------------------------
# update an existing calendar item
ad_proc cal_item_update { cal_item_id
                          start_date
                          end_date
                          name
                          description
{item_type_id ""}
{edit_all_p 0}
} {

    updating  a new cal_item
    for this version, i am omitting recurrence

} {
    
    if {$edit_all_p} {
        set recurrence_id [db_string select_recurrence_id {}]

        # If the recurrence id is NULL, then we stop here and just do the normal update
        if {![empty_string_p $recurrence_id]} {
            cal_item_edit_recurrence -event_id $cal_item_id \
                    -start_date $start_date \
                    -end_date $end_date \
                    -name $name \
                    -description $description \
                    -item_type_id $item_type_id

            return
        }
    }

    # set the date_format
    set date_format "YYYY-MM-DD HH24:MI"

    # update the events
    db_dml update_event ""

    # update the time interval based on the timespan id

    db_1row get_interval_id ""

    db_transaction {
        # call edit procedure
        db_exec_plsql update_interval "
	begin
        time_interval.edit (
        interval_id  => :interval_id,
        start_date   => to_date(:start_date,:date_format),
        end_date     => to_date(:end_date,:date_format)
        );
	end;
        "
    
        # Update the item_type_id
        db_dml update_item_type_id "update cal_items
        set item_type_id= :item_type_id
        where cal_item_id= :cal_item_id"
    }
}


#------------------------------------------------
# delete an exiting cal_item
ad_proc cal_item_delete { cal_item_id } {

    delete an existing cal_item given a cal_item_id

} {

    # call delete procedure
    db_exec_plsql delete_cal_item "
	begin
	  cal_item.delete (
	    cal_item_id  => :cal_item_id
	  );
	end;
    "    
}


# Recurrences
ad_proc -public cal_item_delete_recurrence {
    {-recurrence_id:required}
} {

    # call delete procedure
    db_exec_plsql delete_cal_item_recurrence "
	begin
	  cal_item.delete_all (
	    recurrence_id  => :recurrence_id
	  );
	end;
    "    
}


ad_proc -public cal_item_edit_recurrence {
    {-event_id:required}
    {-start_date:required}
    {-end_date:required}
    {-name:required}
    {-description:required}
    {-item_type_id ""}
} {
    edit a recurrence
} {
    set recurrence_id [db_string select_recurrence_id {}]
    
    db_transaction {
        # Update the recurrence start and end dates
        db_exec_plsql recurrence_timespan_update {}

        # Update the activities table
        # We shouldn't update activities, I don't think
        # db_dml recurrence_activities_update {}

        # Update the events table
        db_dml recurrence_events_update {}
        
        # Update the cal_items table
        db_dml recurrence_items_update {}
    }
}

ad_proc -public calendar_item_add_recurrence {
    {-cal_item_id:required}
    {-interval_type:required}
    {-every_n:required}
    {-days_of_week ""}
    {-recur_until ""}
} {
    Adds a recurrence for a calendar item
} {
    # We do things in a transaction
    db_transaction {
        # Create the recurrence
        set recurrence_id [db_exec_plsql create_recurrence "
            begin
            :1 := recurrence.new(interval_type => :interval_type,
            every_nth_interval => :every_n,
            days_of_week => :days_of_week,
            recur_until => :recur_until);
            end;
        "]
        
        # Update the events table
        db_dml update_event "update acs_events set recurrence_id= :recurrence_id where event_id= :cal_item_id"

        # Insert instances
        db_exec_plsql insert_instances "
        begin
        acs_event.insert_instances(event_id => :cal_item_id);
        end;
        "
        
        # Make sure they're all in the calendar!
        db_dml insert_cal_items "
        insert into cal_items (cal_item_id, on_which_calendar)
        select event_id, (select on_which_calendar as calendar_id from cal_items where cal_item_id = :cal_item_id) from acs_events where recurrence_id= :recurrence_id and event_id <> :cal_item_id"
    }
}
        
