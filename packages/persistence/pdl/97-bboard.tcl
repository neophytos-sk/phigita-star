namespace eval ::bboard {;}


DB_Class ::bboard::Message_Type -is_final_if_no_scope 1 -lmap mk_attribute {
    {Boolean live_p -isNullable no -default 'f'}
} -lmap mk_like {
    ::content::Object
    ::content::Name
    ::content::Description
    ::content::HStore
}

DB_Class ::bboard::Message -is_final_if_no_scope 1 -lmap mk_attribute {
    {Boolean live_p -isNullable no -default 'f'}
    {Boolean allow_comments_p -isNullable no -default 'f'}
    {FKey type_id -isNullable yes -ref ::bboard::Message_Type -onDeleteAction "cascade"}
} -lmap mk_like {
    ::content::Object
    ::content::Title
    ::content::Type
    ::content::Content
    ::content::Tags
    ::content::HStore
    ::auditing::Auditing
} -lmap mk_index {
    {Index live_p}
}

