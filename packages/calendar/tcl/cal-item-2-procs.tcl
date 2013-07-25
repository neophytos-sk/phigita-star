
ad_library {
    A beginning of an attempt to rewrite calendar by making
    procs cleaner, etc... (ben)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-06-02
}

namespace eval calendar::item {

    ad_proc -private dates_valid_p {
        {-start_date:required}
        {-end_date:required}
    } {
        A sanity check that the start time is before the end time. 
    } {
        # set the date_format for oracle - from cal_item_create
        set date_format "YYYY-MM-DD HH24:MI"

        set dates_valid_p [db_string dates_valid_p_select {}]

        if {[string equal $dates_valid_p 1]} {
            return 1
        } else {
            return 0
        }
    }

    ad_proc -public new {
        {-start_date:required}
        {-end_date:required}
        {-name:required}
        {-description:required}
        {-calendar_id:required}
        {-item_type_id ""}
    } {
        # if the dates are invalid, don't create the item
        if {[dates_valid_p -start_date $start_date -end_date $end_date]} {
            # For now we call the old nasty version
            return [cal_item_create $start_date $end_date $name $description $calendar_id [ad_conn peeraddr] [ad_conn user_id] $item_type_id]
        } else {
            # FIXME: do this better
            ad_return_complaint 1 "Start Time must be before End Time"
            ad_script_abort
        }

    }

    ad_proc -public get {
        {-cal_item_id:required}
        {-array:required}
    } {
        Get the data for a calendar item
    } {
        upvar $array row

        if {[calendar::attachments_enabled_p]} {
            set query_name select_item_data_with_attachment
        } else {
            set query_name select_item_data
        }
        
        db_1row $query_name {} -column_array row

        # Localize
        set row(start_time) [lc_time_fmt $row(ansi_start_date) "%X"]
        # Unfortunately, SQL has weekday starting at 1 = Sunday
        set row(day_of_week) [expr [lc_time_fmt $row(ansi_start_date) "%w"] + 1]
        set row(pretty_day_of_week) [lc_time_fmt $row(ansi_start_date) "%A"]
        set row(day_of_month) [lc_time_fmt $row(ansi_start_date) "%d"]
        set row(pretty_short_start_date) [lc_time_fmt $row(ansi_start_date) "%x"]

        set row(end_time) [lc_time_fmt $row(ansi_end_date) "%X"]
    }
        
    ad_proc -public add_recurrence {
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
	    set recurrence_id [db_exec_plsql create_recurrence {}]
	    
	    # Update the events table
	    db_dml update_event {}
	    
	    # Insert instances
	    db_exec_plsql insert_instances {}
	    
	    # Make sure they're all in the calendar!
	    db_dml insert_cal_items {}
	}
    }
    

    ad_proc -public edit {
        {-cal_item_id:required}
        {-start_date:required}
        {-end_date:required}
        {-name:required}
        {-description:required}
        {-item_type_id ""}
        {-edit_all_p 0}
    } {
        Edit the item
    } {
        cal_item_update $cal_item_id $start_date $end_date $name $description $item_type_id $edit_all_p
    }

    ad_proc -public delete {
        {-cal_item_id:required}
    } {
        delete the item
    } {
        cal_item_delete $cal_item_id
    }
    
}
