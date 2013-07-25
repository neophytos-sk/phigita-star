namespace eval ::labeling {;}

DB_Class ::labeling::Label -lmap mk_like {
    ::content::Object
    ::content::Name
    ::content::Name_CRC32
}



DB_Class ::labeling::Label_no_crc32 -lmap mk_like {
    ::content::Object
    ::content::Name
}


