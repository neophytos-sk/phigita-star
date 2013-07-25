# /packages/calendar/tcl/calendar-procs.tcl

ad_library {

    Utility functions for Calendar Applications

    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: calendar-procs.tcl,v 1.11 2002/11/30 17:27:51 jeffd Exp $

}


#------------------------------------------------
# datetime info extraction

ad_proc calendar_make_datetime {
    event_date
    {event_time ""}
} {
    given a date, and a time, construct the proper date string
    to be imported into oracle. (yyyy-mm-dd hh24:mi format)s
} {
    
    # MUST CONVERT TO ARRAYS! (ben)
    array set event_date_arr $event_date
    if {![empty_string_p $event_time]} {
        array set event_time_arr $event_time
    }
    
    # extract from even-date 
    set year   $event_date_arr(year)
    set day    $event_date_arr(day)
    set month  $event_date_arr(month)
    
    if {![empty_string_p $event_time]} {
        # extract from event_time
        set hours $event_time_arr(hours)
        set minutes $event_time_arr(minutes)
        
        # AM/PM? (ben - openacs fix)
        if {[info exists event_time_arr(ampm)]} {
            if {$event_time_arr(ampm)} {
                if {$hours < 12} {
                    incr hours 12
                }
            } else {
                # This is the case where we're dealing with AM/PM
                # The one issue we have to worry about is 12am
                if {!$event_time_arr(ampm) && $hours == 12} {
                    set hours 0
                }
            }
        }
        
        if {$hours < 10} {
            set hours "0$hours"
        }
        
    }
    
    
    if {$month < 10} {
	set month "0$month"
    }
    
    if {$day < 10} {
	set day "0$day"
    }
    
    if {[empty_string_p $event_time]} {
        return "$year-$month-$day"
    } else {
        return "$year-$month-$day $hours:$minutes"
    }
    
}


#------------------------------------------------
# datetime info extraction

ad_proc calendar_make_date { event_date } {
    given a date, construct the proper date string
    to be imported into oracle (yyyy-mm-dd format)
} {

    # extract from even-date 
    set year   [lindex $event_date 5]
    set day    [lindex $event_date 7]
    set month  [lindex $event_date 9]
    
    if {$month < 10} {
	set month "0$month"
    }

    if {$day < 10} {
	set day "0$day"
    }
    return "$year-$month-$day"

}


#------------------------------------------------
# should probably roll this one into the pl/sql since 
# note: not sure how useful this is going to be

ad_proc calendar_have_group_cal_p { party_id } {
    
    figures out if the given party_id have an existing calendar. 
 
   
} {

    return [db_0or1row get_calendar_info ""]
    
}


#------------------------------------------------
# figure out if user have a private calendar or not
# again, best suited to be rolled into the pl/sql

ad_proc calendar_have_private_p { {-return_id 0} party_id } {
    
    check to see if ther user have a prviate calendar
    if -return_id is 1, then proc will return the calendar_id

} {

    set result [db_string get_calendar_info "" -default 0]
    
    if { ![string equal $result "0"] } {

	if { [string equal $return_id "1"] } {
	    return $result
	} else {
	    return 1
	}
 
    } else {
	
	return 0
    }
}


#------------------------------------------------
# creating a new calendar

ad_proc calendar_create { owner_id
                          private_p          
                          {calendar_name ""}       
} {

    create a new calendar
    private_p is default to true since the default
    calendar is a private calendar 
} {

    # find out configuration info
    set package_id [ad_conn package_id]
    set creation_ip [ad_conn "peeraddr"]
    set creation_user [ad_conn "user_id"]
    
    # BMA:FIXME: this needs to be fixed a LOT more, but for now we patch the obvious
    if {$creation_user == 0} {
        set creation_user $owner_id
    }

    set calendar_id [db_exec_plsql create_new_calendar {
	begin
	:1 := calendar.new(
	  owner_id      => :owner_id,
	  private_p     => :private_p,
	  calendar_name => :calendar_name,
	  package_id    => :package_id,
	  creation_user => :creation_user,
	  creation_ip   => :creation_ip
	);	
	end;
    }
    ]
    
    return $calendar_id
    
}


#------------------------------------------------
# assign the permission of the calendar to a party

ad_proc calendar_assign_permissions { calendar_id
                                      party_id
                                      cal_privilege
                                      {revoke ""}                        
} {
    given a calendar_id, party_id and a permission
    this proc will assign the permission to the party
    the legal permissions are

    public, private, calendar_read, calendar_write, calendar_delete

    if the revoke is set, then the given permission will 
    be removed for the party

} {
    # default privilege is being able to read 

    # if the permission is public, oassign the magic object
    # and set permission to read

    if { [string equal $cal_privilege "public"] } {
	
	db_1row get_magic_id {
	    select  acs.magic_object_id('the_public')
	            as party_id
	    from    dual
	}

	set cal_privilege "calendar_read"
    } elseif { [string equal $cal_privilege "private"] } {
	set cal_privilege "calendar_read"
    } 


    if { [empty_string_p $revoke] } {
	# grant the permissions

        permission::grant -object_id $calendar_id -party_id $party_id -privilege $cal_privilege

    } elseif { [string equal $revoke "revoke"] } {
	# revoke the permissions

        permission::revoke -object_id $calendar_id -party_id $party_id -privilege $cal_privilege

    }    

}


#------------------------------------------------
# add a new private calendar to a user

ad_proc calendar_create_private { private_id } {
    
    create a private calendar

} {
    # check to make sure the user_id given is indeed a user
    # this shouldn always happen

    if {![cc_is_party_user_p $private_id]} {
	return "ERROR: ID NOT USER"
    }

    # set the private calendar name
    set calendar_name "private calendar for [db_string get_user_name {
	select   acs_object.name(:private_id) 
	from     dual
    } -default ""]"

    set calendar_id [calendar_create $private_id "t" $calendar_name]

    return $calendar_id
}


#------------------------------------------------
# find out if the name of a calendar has already 
# been taken 

#ad_proc calendar_name_exist_p { calendar_name } {
    
    #since calendar_name is unique, this proc determines
    #if a given name is already used
#} {
    
#}

#------------------------------------------------
# update a calendar

ad_proc calendar_update { calendar_id
                          party_id
                          calendar_name
                          cal_privilege
} {
    update the basic info of a  calendar
    does not pretain to the audience of 
    the calendar
} {
    
    #update the calendar table
    db_dml update_calendar {
	update   calendars
	set      calendar_name = :calendar_name
	where    calendar_id = :calendar_id	
    }

    #reassign the permission
    calendar_assign_permissions $calendar_id $party_id $cal_privilege
}

#------------------------------------------------
# find out the name of a calendar < roll into pl/sql >
# NOTE: calendar.name()

ad_proc calendar_get_name { calendar_id } {
    
    find out the name of a calendar
} {
    
    return [db_string get_calendar_name {
	       select  calendar.name(:calendar_id)
	       from    dual
    } -default ""]

}

                          

#------------------------------------------------
# figures out if a given calendar is public or not

ad_proc calendar_public_p { calendar_id } {

    returns 't' if a given calendar is public 
    and 'f' if it is not 

} {
  
#    return [db_string check_calendar_permission {
#              select   acs_permission.permission_p(
#                         :calendar_id, 
#                         acs.magic_object_id('the_public'),
#                         'calendar_read'
#                       ) 
#              from     dual
#
#            }]
#

    set private_p [db_string check_calendar_p "select private_p from calendars where calendar_id = :calendar_id"]

    if { $private_p == "t" } {
        return "f"
    } else {
        return "t"
    }

}

