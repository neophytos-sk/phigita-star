# /packages/calendar/www/cal-listview.tcl

ad_page_contract {
    
    Source files for the day view generation
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-listview.tcl,v 1.5 2001/09/23 14:40:55 charlesm Exp $
} {
    {date now}
    {view list}
    {calendar_id:integer "-1"}
    {calendar_list:multiple,optional {}}
} -properties {
    items:onevalue
}

if { $date ==  "now"} {
    set date [dt_systime]
}

set current_date $date
set date_format "YYYY-MM-DD HH24:MI"


set items ""
set mlist ""
set set_id [ns_set new day_items]




#-------------------------------------------------
# find out the user_id 
set user_id [ad_verify_and_get_user_id]

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

    db_foreach get_day_items "" {
	ns_set put $set_id  $start_date "<a href=?action=edit&cal_item_id=$item_id>
	$pretty_start_date - $pretty_end_date $name ($calendar_name)
	</a><br>"
	append items "<li> <a href=?action=edit&cal_item_id=$item_id>
	$pretty_start_date - $pretty_end_date $name ($calendar_name)
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

	db_foreach get_day_items "" {
	    ns_set put $set_id  $start_date "<a href=?action=edit&cal_item_id=$item_id>
	    $pretty_start_date - $pretty_end_date $name ($calendar_name)
	    </a><br>"
	    append items "<li> <a href=?action=edit&cal_item_id=$item_id>
	    $pretty_start_date - $pretty_end_date $name ($calendar_name)
	    </a><br>"
	} 

    }
	    
}





#-------------------------------------------------
# date info
#dt_get_info_from_db $date
dt_get_info $date

set day_of_week $first_day_of_month
set julian_date $first_julian_date

set calendar_day_index [ns_set find $set_id $julian_date]

#-------------------------------------------------
#

ad_return_template




