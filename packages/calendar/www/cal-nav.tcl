# /packages/calendar/www/cal-nav.tcl

ad_page_contract {
    
    Nav page
    
    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: cal-nav.tcl,v 1.2 2002/04/10 00:54:09 ben Exp $
} {
    {view day}
    {date now}
    {action view}
    {calendar_id:integer "-1"}
    {calendar_list:multiple,optional {}}
} -properties {
    html:onevalue
    view:onevalue
    date:onevalue
}

if {$date == "now"} {
    set date [dt_sysdate]
}

# we have to deal with the list 
# if the list is empty, we ignore the list
# if the there is content, we have to break 
# apart the list and append element per element

if {[llength $calendar_list] == 0} {

    set pass_in_vars "[export_url_vars calendar_id]"

} else {

    set pass_in_vars ""
    foreach items $calendar_list {
	
	append pass_in_vars "calendar_list=[lindex $items 0]&"
    }
}

# set the html
set html [dt_widget_calendar_navigation "./" $view $date $pass_in_vars]

ad_return_template















