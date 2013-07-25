ad_page_contract {
    @author Neophytos Demetriou 
} {
    id:integer,notnull
    venue_name:trim,notnull
    venue_address:trim,notnull
    venue_city:trim,notnull
    venue_country:trim,notnull
    {venue_description:trim ""}
    {venue_homepage_url:trim ""}
    {venue_phone:trim ""}
    {venue_postal_code:trim ""}
    {venue_private_p:boolean "f"}
    {lng:trim ""}
    {lat:trim ""}
}


set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]


set tmplist ""
foreach varName {venue_name venue_address venue_city venue_country venue_postal_code venue_description} {
    lappend tmplist [::ttext::trigrams [string tolower [::ttext::unac utf-8 [::ttext::ts_clean_text [set $varName]]]]]
}
set ts_vector [join [::xo::fun::map x [join $tmplist] { string map {{'} {\'} {"} {\"} \\ \\\\ { } {\ } {,} {\,}} $x }]]

#ns_log notice "ts_vector=$ts_vector"

set o [::agenda::Venue new -mixin ::db::Object -pool agendadb]

$o beginTransaction
$o set id $id

$o set venue_name           $venue_name
$o set venue_address        $venue_address
$o set venue_city           $venue_city
$o set venue_country        $venue_country
$o set venue_homepage_url   $venue_homepage_url
$o set venue_phone          $venue_phone
$o set venue_postal_code    $venue_postal_code
#$o set venue_description    $venue_description
$o set venue_private_p      $venue_private_p
$o set ts_vector            $ts_vector

set longitude [ns_dbquotevalue $lng]
set latitude [ns_dbquotevalue $lat]

#$o set db(geom)           "st_setsrid(st_makepoint($longitude,$latitude),4326)"
$o set __update(geom)           "st_setsrid(st_makepoint($longitude,$latitude),4326)"

$o set modifying_user       $user_id
$o set modifying_ip         $peeraddr

$o rdb.self-update
$o endTransaction

set id [$o set id]

doc_return 200 text/plain \{venue_id:${id},venue_name:'${venue_name}',venue_address:'${venue_address}',venue_city:'${venue_city}',venue_country:'${venue_country}'\}