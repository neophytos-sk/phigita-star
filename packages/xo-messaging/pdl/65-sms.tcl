namespace eval ::sms {;}

DB_Class ::sms::Message -lmap mk_attribute {

    {String originating_msisdn -isNullable no -maxlen 40}
    {String terminating_msisdn -isNullable no -maxlen 40}
    {Boolean incoming_p -isNullable no -default 't'}
    {Timestamptz creation_date -isNullable no}
    {Timestamptz last_update -isNullable no}
    {Integer message_ref -isNullable no}
    {Integer message_max_parts -isNullable no -default 1}
    {Integer message_cnt_parts -isNullable no -default 1}
    {Boolean complete_p -isNullable no -default 't'}

} -lmap mk_like {

    ::content::Object
    ::content::Content

} -lmap mk_index {

    {Index     last_update -on_copy_include_p yes}
    {Index     message_key -subject "originating_msisdn message_ref" -on_copy_include_p yes}

} -instproc save_message {} {
    my instvar message_max_parts message_part_number content complete_p originating_msisdn message_ref smsc_timestamp
#    if { $message_max_parts > 0 } {
    set content [list $message_part_number $smsc_timestamp $content]
#    }
    if { $message_part_number <= 1 } {
	set complete_p [expr { $message_max_parts == 1 }]
	my do self-insert
    } else {
	[my getConn] do [subst {
	    update [my info.db.table] set 
	        content = content || ' ' || [ns_dbquotevalue $content]
	       ,message_cnt_parts=message_cnt_parts+1
	       ,last_update = CURRENT_TIMESTAMP
	       ,complete_p=case when message_max_parts=message_cnt_parts+1 then true else false end
	    where originating_msisdn=[ns_dbquotevalue $originating_msisdn] 
	      and message_ref=[ns_dbquotevalue $message_ref]
	}]
    }

} -instproc get_content {} {
    my instvar content
    set result ""
    foreach {message_part_number smsc_timestamp message_part_content} $content {
        append result $message_part_content
    }
    return $result
}
