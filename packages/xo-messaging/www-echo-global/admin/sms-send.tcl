ad_page_contract {
    @author Neophytos Demetriou
} {
    msisdn:notnull
    content:notnull
}

set group_name outgoing
set src_msisdn +35799643810
#set msisdn    +35799408270
#set message "this is a test"

set msgId [smsq_submit_ascii -src $src_msisdn $group_name $msisdn $content]

ns_return 200 text/plain [subst {
    Msg ID: $msgId
    queue_info: [smsq_get_queue_info]
    Retrieve Ascii: [smsq_retrieve_ascii $group_name $msgId]
}]
