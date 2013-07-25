# /packages/calendar/www/cal-monthview.tcl

ad_page_contract {
    
    Source files for the month view generation
    Requires acs_datetime to be installed and enabled
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-monthview.tcl,v 1.6 2002/04/10 00:54:09 ben Exp $
} {
    {date now}
    {view month}
    {calendar_id:integer "-1"}
    {calendar_list:multiple,optional {}}
} -properties {
    row_html:onevalue
    mlist:onevalue
    month_items
}

# find out the user_id 
set user_id [ad_verify_and_get_user_id]

set mlist ""
set set_id [ns_set new month_items]


#-------------------------------------------------
# verifiy if the calendar_list has elements or not

if {[llength $calendar_list] == 0} {
    
    # in the case when there are no elements, we check the
    # default, the calendar is set to -1

    if { [string equal $calendar_id "-1"] } {
	# find out the calendar_id of the private calendar
	
	set calendar_id [calendar_have_private_p -return_id 1 $user_id]
	set calendar_name "Private"
	
    } else {
	# otherwise, get the calendar_name for the give_id
	set calendar_name [calendar_get_name $calendar_id]
    }


    db_foreach get_monthly_items "" {
	ns_set put $set_id  $start_date "<a href=cal-item-view?action=edit&cal_item_id=$item_id>
	  $name ($calendar_name)
	</a><br>"
    }


    


} else {
    # when there are elements, we construct the query to extract all
    # the cal_items associated with the calendar in which the given
    # party has read permissions to.
    

    
    foreach item $calendar_list {
	set calendar_id [lindex $item 0]
	
	if { [string equal $calendar_id "-1"] } {
	    # find out the calendar_id of the private calendar
	    set calendar_id [calendar_have_private_p -return_id 1 $user_id]
	    set calendar_name "Private"
	} else {
	    set calendar_name [calendar_get_name $calendar_id]
	}


	db_foreach get_monthly_items "" {
	    ns_set put $set_id  $start_date "<a href=?action=edit&cal_item_id=$item_id>
	      $name ($calendar_name)
	    </a><br>"
	}

    }
	    
}





set row_html [dt_widget_month  -calendar_details $set_id -date $date]

ad_return_template



