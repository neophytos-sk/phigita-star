
ad_page_contract {
    Delete a calendar item
    
    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-06-02
} {
    cal_item_id:integer,notnull
    {return_url "view"}
    {confirm_p 0}
}

if {!$confirm_p} {
    ad_returnredirect "cal-item-delete-confirm?cal_item_id=$cal_item_id"
    ad_script_abort
}

calendar::item::delete -cal_item_id $cal_item_id

ad_returnredirect $return_url
