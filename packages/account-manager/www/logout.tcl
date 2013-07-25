# /www/register/logout.tcl

ad_page_contract {
    Logs a user out

    @cvs-id $Id: logout.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

} {
    
}

ad_user_logout 
db_release_unused_handles

ad_returnredirect "http://www.phigita.net/"

