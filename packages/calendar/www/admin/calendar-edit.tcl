# /packages/calendar/www/admin/calendar-edit.tcl

ad_page_contract {
    
    edit the basic info
    of an existing calendar

    @author Gary Jin (gjin@arsdigita.com)
    
    @party_id  key to owner id
    @calendar_name  the name of the calendar
    @calendar_permission the permissions of the calendar

    @creation-date Dec 14, 2000
    @cvs-id $Id: calendar-edit.tcl,v 1.2 2002/03/13 22:50:53 donb Exp $
} {
    {action edit}
    {party_id:integer,notnull}
    {calendar_id:integer,notnull}
    {calendar_name:notnull}
    {calendar_permission "private"}
}

if { [string equal $action "edit"] } {
    calendar_update $calendar_id $party_id $calendar_name $calendar_permission
}

ad_returnredirect "."



