
ad_page_contract {
    
    Choose a Calendar
    
    @author Brad Duell (bduell@ncacasi.org)
    @creation-date 2002-08-06
    @cvs-id $Id: calendar-choose.tcl,v 1.2 2002/11/07 12:45:07 peterm Exp $
} {
    {return_url ""}
    {date ""}
    {julian_date ""}
    {start_time ""}
    {end_time ""}
}

set package_id [ad_conn package_id]

set date [calendar::adjust_date -date $date -julian_date $julian_date]

set calendar_list [calendar::calendar_list]

set calendar_id [lindex $calendar_list 0]

set cals_calendar_list [list]
for { set i 0 } { $i < [llength $calendar_list] } { incr i } {
    db_1row select_name "select calendar_name from calendars where calendar_id=[lindex $calendar_list $i]"
    lappend cals_calendar_list [list $calendar_name [lindex $calendar_list $i]]
}

# Create the form
form create cals

element create cals return_url \
    -label "return_url" \
    -datatype text -widget hidden -value $return_url

element create cals calendar_id \
    -label "[_ calendar.Calendar]" -datatype text -widget select \
    -options $cals_calendar_list

# Process the form
if {[form is_valid cals]} {
    template::form get_values cals return_url calendar_id

    ad_returnredirect "$return_url&calendar_id=$calendar_id"
    
    # Stop here
    ad_script_abort
}

set cal_nav [dt_widget_calendar_navigation "view" day $date "calendar_id=$calendar_id"]

ad_return_template
