# /packages/calendar/www/cal-item.tcl

ad_page_contract {
    
    Output an item as ics for Outlook
    
    @author Ben Adida (ben@openforce.net)
    @creation-date May 28, 2002
    @cvs-id $Id: cal-item-outlook.tcl,v 1.3 2002/09/10 22:22:31 jeffd Exp $
} {
    cal_item_id:integer
}

ad_returnredirect "ics/${cal_item_id}.ics"
