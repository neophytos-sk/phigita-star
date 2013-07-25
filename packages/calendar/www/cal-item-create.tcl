# /packages/calendar/www/cal-item-create.tcl

ad_page_contract {
    
    Creation of new calendar item
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-item-create.tcl,v 1.15 2002/09/18 12:12:03 jeffd Exp $
} {
    {view day}
    {action view}
    {no_time_p ""}
    {event_date:array}
    {start_time:array}
    {end_time:array}
    {name:notnull}
    {description ""}
    {date now}
    {calendar_id "-1"}
    {return_url ""}
    {recurrence_p 0}
    {item_type_id ""}
    {show_cal_nav 1}
} 

if { $date == "now" } {
    set date [dt_sysdate] 
}


#----------------------------------------------------------------
# extract the time info 
#

if {$no_time_p == 1} {
    set no_time(hours) 0
    set no_time(minutes) 0
    set start_datetime [calendar_make_datetime [array get event_date] [array get no_time]]
    set end_datetime [calendar_make_datetime [array get event_date] [array get no_time]]
} else {
    set start_datetime [calendar_make_datetime [array get event_date] [array get start_time]]
    set end_datetime [calendar_make_datetime [array get event_date] [array get end_time]]
}


#-----------------------------------------------------------------
# validate time interval ( start_time <= end_time )

if { [dt_interval_check $start_datetime $end_datetime] < 0 } {
    ad_return_complaint 1 "your end time <i>$end_datetime </i> can't happen before start time <i> $start_datetime </i>"
}

#------------------------------------------------------------------
# insert the information 
#
# probably not the best way to do it, well fix
# after this release


# find out the user_id 
set user_id [ad_verify_and_get_user_id]

# find out configuration info
set package_id [ad_conn package_id]
set creation_ip [ad_conn "peeraddr"]

# Owner_id refers to a party, user or group
# the default creation_user is just the person 
# who happen to made the calendar
set creation_user [ad_conn "user_id"]


#-------------------------------------------------------------------
# if calendar_id is not provided, 
# we assume that its a private calendar

if { [string equal $calendar_id "-1"] } {
    #private calendar

    # check to see if the user have a private calendar of not.
    # if he doesn't have a private calendar, then we will should
    # seamlessly create a private calendar before creating the 
    # cal-item

    if { ![calendar_have_private_p $user_id] } {
	# no private calendar detected. 
	# we need to create the private calendar

	set calendar_id [calendar_create_private $user_id ]

    } 
    set calendar_id [calendar_have_private_p -return_id 1 $user_id]

    
} else {
    # its not a private calendar
    # we expect there to be a calendar_id
    # we perform error check if the calendar_id 
    # is not given
	
    if { [empty_string_p $calendar_id] } {
	ad_return_complaint 1 "You need to supply a calendar"
        ad_script_abort
    }

    # now we make sure that the user has the permission 
    # to create the event on the calendar

    ad_require_permission $calendar_id cal_item_create
}


db_transaction {
    # create new cal_item
    set cal_item_id [cal_item_create $start_datetime \
	                         $end_datetime \
                                 $name \
				 $description \
                                 $calendar_id \
				 $creation_ip \
                                 $creation_user \
                                 $item_type_id]
}

# Fix up the return URL
if {[empty_string_p $return_url]} {
    set return_url "cal-item-view?[export_url_vars date action view cal_item_id show_cal_nav return_url]"
}

if {$recurrence_p} {
    # We must ask for recurrence information
    ad_returnredirect "cal-item-create-recurrence?cal_item_id=$cal_item_id&return_url=[ns_urlencode $return_url]"
    ad_script_abort
}

# set the date to be the date of the event
ad_returnredirect "${return_url}"
ad_script_abort
set date [calendar_make_date [array get event_date]]
