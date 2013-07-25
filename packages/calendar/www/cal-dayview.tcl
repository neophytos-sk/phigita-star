# /packages/calendar/www/cal-dayview.tcl

ad_page_contract {
    
    Source files for the day view generation
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-dayview.tcl,v 1.10 2002/04/10 00:54:09 ben Exp $
} {
    {date now}
    {view day}
    {calendar_id:integer "-1"}
    {calendar_list:multiple,optional {}}
} -properties {
    row_html:onevalue
    date:onevalue
}

if { $date ==  "now"} {
    set date [dt_sysdate]
}


#-------------------------------------------------
# find out the user_id 
set user_id [ad_verify_and_get_user_id]

set current_date $date
set date_format "YYYY-MM-DD HH24:MI"

set mlist ""
set set_id [ns_set new day_items]


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
	ns_set put $set_id  $start_hour "<a href=cal-item-view?date=$date&action=edit&cal_item_id=$item_id>
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
	    
            set calendar_name [calendar_get_name $calendar_id]
            
            if {[empty_string_p $calendar_name]} {
                set calendar_name "Private"
            }

	} else {
	    set calendar_name [calendar_get_name $calendar_id]
	}

	db_foreach get_day_items "" {
	    ns_set put $set_id  $start_hour "<a href=?action=edit&cal_item_id=$item_id>
	    $pretty_start_date - $pretty_end_date $name ($calendar_name)
	    </a><br>" 
	} 

    }
}


#-------------------------------------------------
#
set num_hour_rows 24
set i 0

set bgcolor_html "border=1 color=blue"

set row_html "
<table cellpadding=2 cellspacing=0 border=1 width=500>
<tr>
  <td width=90>
    <b>Time</b>
  </td>
  <td>
    <b>Title</b>
  </td>
</tr>

"
 

while {$i < $num_hour_rows} {
    set filled_cell_count 0


    # making hours before 10 looks prettier
    if {$i < 10} {
	set cal_hour "0$i"
    } else {
	set cal_hour "$i"
    }
    

    # am or pm determination logic
    if {$i < 12} {
	if {$i == 0} {
	    set time "12:00 am"
	} else {
	    set time "$cal_hour:00 am"
	}
    } else {
	if {$i == 12} {
	    set time "12:00 pm"
	} else {
	    set fm_hour [expr $i - 12]
	    if {$fm_hour < 10} {
		set fm_hour "0$fm_hour"
	    } 
	    set time "$fm_hour:00 pm"
	}    
    }
    
    set cal_item_index [ns_set find $set_id $cal_hour]    

    append row_html "
    <tr>
      <td valign=top nowrap $bgcolor_html width=10%>
        <a href=?date=$date&view=$view&action=add&start_time=$i:00&end_time=[expr $i+1]:00> $time </a>
      </td>
    
      <td valign=top nowrap border=1>
    "

    if {$cal_item_index == -1} {
	append row_html "&nbsp;"
    }

    while {$cal_item_index > -1} {

	append row_html "[ns_set value $set_id $cal_item_index]"
	ns_set delete $set_id $cal_item_index
	set cal_item_index [ns_set find $set_id $cal_hour]     
    }


    append row_html "
    </td>
      
    </tr>
    "

    incr i
}

append row_html "</table> "

ad_return_template














