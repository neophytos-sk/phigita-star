namespace eval ::content {;}
DB_Class ::content::Object -lmap mk_attribute {
    {OID id}
} -lmap mk_index {
    {Index id -isUnique yes -on_copy_include_p yes}
}

DB_Class ::content::Name -lmap mk_attribute {
    {String name -maxlen 1000 -isNullable no}
} -lmap mk_index {
    {Index name -isUnique yes -on_copy_include_p yes}
}
DB_Class ::content::Name_CRC32 -lmap mk_attribute {
    {Integer name_crc32 -isNullable no}
} -lmap mk_index {
    {Index name_crc32 -on_copy_include_p yes}
}
DB_Class ::content::Title -lmap mk_attribute {
    {String title -maxlen 1000 -isNullable yes}
}
DB_Class ::content::Description -lmap mk_attribute {
    {String description -maxlen 1000 -isNullable yes}
}
DB_Class ::content::Content -lmap mk_attribute {
    {String content -isNullable yes}
}
DB_Class ::content::Snippet -lmap mk_attribute {
    {String snippet -maxlen 1000 -isNullable yes}
}
DB_Class ::content::Rating -lmap mk_attribute {
    {Smallint rating -isNullable yes}
} -lmap mk_index {
    {Index rating -on_copy_include_p yes}
}
DB_Class ::content::Reading -lmap mk_attribute {
    {Boolean unread_p -isNullable no}
} -lmap mk_index {
    {Index unread_p -on_copy_include_p yes}
}
DB_Class ::content::Subscription -lmap mk_attribute {
    {Boolean subscribe_p -isNullable no}
} -lmap mk_index {
    {Index subscribe_p -on_copy_include_p yes}
}
DB_Class ::content::Cache -lmap mk_attribute {
    {Boolean cache_p -isNullable no}
} -lmap mk_index {
    {Index cache_p -on_copy_include_p yes}
}
DB_Class ::content::Adult -lmap mk_attribute {
    {Boolean adult_p -isNullable no}
} -lmap mk_index {
    {Index adult_p -on_copy_include_p yes}
}
DB_Class ::content::Interesting -lmap mk_attribute {
    {Boolean interesting_p -isNullable no}
} -lmap mk_index {
    {Index interesting_p -on_copy_include_p yes}
}
DB_Class ::content::Sticky -lmap mk_attribute {
    {Boolean sticky_p -isNullable no}
} -lmap mk_index {
    {Index sticky_p -on_copy_include_p yes}
}
DB_Class ::content::Fixed -lmap mk_attribute {
    {Boolean fixed_p -isNullable yes -default 'f'}
} -lmap mk_index {
    {Index fixed_p -on_copy_include_p yes}
}
DB_Class ::content::Favorite -lmap mk_attribute {
    {Boolean favorite_p -isNullable yes -default 'f'}
} -lmap mk_index {
    {Index favorite_p -on_copy_include_p yes}
}


DB_Class ::content::Starred -lmap mk_attribute {
    {Boolean starred_p -isNullable no -default 'f'}
} -lmap mk_index {
    {Index starred_p -on_copy_include_p yes}
}
DB_Class ::content::Hidden -lmap mk_attribute {
    {Boolean hidden_p -isNullable no -default 'f'}
} -lmap mk_index {
    {Index hidden_p -on_copy_include_p yes}
}
DB_Class ::content::Deleted -lmap mk_attribute {
    {Boolean deleted_p -isNullable no -default 'f'}
} -lmap mk_index {
    {Index deleted_p -on_copy_include_p yes}
}
DB_Class ::content::Shared -lmap mk_attribute {
    {Boolean shared_p -isNullable no -default 'f'}
} -lmap mk_index {
    {Index shared_p -on_copy_include_p yes}
}


DB_Class ::content::Tags -lmap mk_attribute {
    {String tags -isNullable yes}
    {Intarray tags_ia -isNullable yes}
} -lmap mk_index {
    {Index tags_ia -on_copy_include_p yes}
}



DB_Class ::content::SearchableContent -lmap mk_attribute {
    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}
} -lmap mk_like {
    ::content::Content
} -lmap mk_index {
    {Index ts_vector -on_copy_include_p yes}
}


DB_Class ::content::Type -lmap mk_attribute {
    {String content_type}
} -lmap mk_index {
    {Index content_type -on_copy_include_p yes}
}

DB_Class ::content::HStore -lmap mk_attribute {
    {HStore hstore -isNullable yes}
} -lmap mk_index {
    {Index hstore -on_copy_include_p yes}
}
