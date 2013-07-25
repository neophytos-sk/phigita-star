DB_Class ::Content_Folder -lmap mk_attribute {
    {String title -isNullable no}
    {String description -isNullable yes}
    {Boolean leaf_p -isNullable no -default 't'}
} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing
} -set id 32


