
##########################
### ::bookshelf   ##
##########################

namespace eval ::bookshelf {;}

DB_Class ::bookshelf::Book -lmap mk_attribute {

    {String code -maxlen 255}
    {Boolean wishlist_p}

} -lmap mk_like {

    ::content::Object
    ::content::Description
    ::content::Content
    ::content::Favorite
    ::content::Reading
    ::content::Rating
    ::auditing::Auditing
    ::sharing::Flag_with_Start_Date

}