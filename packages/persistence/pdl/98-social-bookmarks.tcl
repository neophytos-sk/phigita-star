namespace eval ::bm {;}


DB_Class ::bm::Bookmark_Comment -lmap mk_attribute {
    {String ancestor -isNullable no}
    {String screen_name -isNullable no}
} -lmap mk_like {
    ::content::Object
    ::content::Content
    ::auditing::Auditing
} -lmap mk_index {
    {Index ancestor}
}

