namespace eval ::echo {;}

DB_Class ::echo::Message -is_final_if_no_scope "1" -lmap mk_attribute {
    {String device -isNullable no -default 'sms'}
    {Integer cnt_comment -isNullable no -default '0'}
    {String last_comment -isNullable yes}
    {Boolean public_p -isNullable no -default 'f'}
    {String attachment -isNullable yes}
} -lmap mk_like {
    ::content::Object
    ::content::Content
    ::auditing::Auditing
} -lmap mk_index {
    {Index public_p}
}


DB_Class ::echo::Device -lmap mk_attribute {
    {String device_guid -maxlen 100 -isNullable no}
    {Integer device_user -isNullable no}
    {String device_token -isNullable no}
    {Boolean is_verified_p -isNullable no -default 'f'}
} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing
} -lmap mk_index {
    {Index device_guid_token -subject "device_guid device_token" -isUnique yes}
    {Index device_guid_user -subject "device_guid device_user" -isUnique yes}
    {Index device_verified_p -subject "device_guid is_verified_p"}
}

DB_Class ::echo::Message_Comment -lmap mk_attribute {
    {RelKey parent_id -ref "::echo::Message" -refkey "id" -isNullable no}
    {String screen_name -isNullable no}
} -lmap mk_like {
    ::content::Object
    ::content::Content
    ::auditing::Auditing
} -lmap mk_index {
    {Index parent_id}
}

