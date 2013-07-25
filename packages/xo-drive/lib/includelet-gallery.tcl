set user_id [ad_conn user_id]
set pathexp [list "User $user_id"]
set items [db::Set new -pathexp ${pathexp} -type ::Content_Item]