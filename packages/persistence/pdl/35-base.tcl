namespace eval ::base {;}

DB_Class ::base::Item -lmap mk_attribute {

    {HStore extra}

} -lmap mk_like {

    ::content::Object
    ::content::Title
    ::content::Content
    ::sharing::Flag_with_Start_Date

} -lmap mk_index {

    {Index extra}

}