# party_id 
# person_id 
# user_id 
# password 
# salt 
# screen_name 
# priv_name 
# email_verified_p 
# email_bouncing_p 
# no_alerts_until 
# last_visit 
# second_to_last_visit 
# n_sessions 
# password_question 
# password_answer 
# status 
# roles 
# extra 
# allow_ads_p 
# member_state
# member_since (added by alter table add column on 2010-11-14)
DB_Class User -shorthand "u" -attribute {

    {OID       id}
    {Integer   user_id -isNullable yes}

    {String    first_names -maxlen 100}    
    {String    last_name -maxlen 100}
    {String    screen_name          -maxlen 100 -isNullable "yes" -isUnique "yes"}
    {String    status}
    {String    member_state}
    {String    email}
    {String    url}
    {Timestamp member_since}
    {Timestamptz creation_date}

    {Timestamptz last_visit}
    {Timestamptz second_to_last_visit}
    {Integer   n_sessions           -isNullable "no" -default "1"}
    {Integer priv_contact_info}

    {Boolean allow_ads_p}

} -set id 10

DB_Class CC_User -prefix "public"

DB_Class ::Parties
DB_Class ::Persons
DB_Class ::Users


::my::Object set __defaults(volatile_p) no


::db::View ::CC_Users  \
    -type [db::Inner_Join def \
               -lhs [db::View def   \
			 -alias pp \
			 -type [::db::Inner_Join def   \
				    -lhs [db::View def  -from Parties -alias pa] \
				    -rhs [db::View def  -from Persons -alias pe] \
				    -join_condition {pa.party_id=pe.person_id}]] \
               -rhs [::db::View def -from Users -alias u] \
               -join_condition {u.user_id = pp.person_id}]


::CC_Users proc new {args} {
    return [::User new {*}$args]
}

::CC_Users proc getDBSlots {} {
    return [::User getDBSlots]
}

::my::Object unset __defaults(volatile_p)
