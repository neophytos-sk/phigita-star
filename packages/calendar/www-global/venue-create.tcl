ad_page_contract {
    @author Neophytos Demetriou 
} {
    venue_name:trim,notnull
    venue_address:trim,notnull
    venue_city:trim,notnull
    venue_country:trim,notnull
    venue_description:trim
    venue_homepage_url:trim
    venue_phone:trim
    venue_postal_code:trim
    {venue_private_p:boolean "f"}
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
set place [::agenda::Place new -mixin ::db::Object -pool agendadb]
set placedata [::db::Set new -pool agendadb -type ::agenda::Place -where [list "extra->'city'=[ns_dbquotevalue $venue_city]" "extra->'country'=[ns_dbquotevalue $venue_country]"] -limit 1]
$placedata load

$o beginTransaction
$o rdb.self-id


if { [$placedata emptyset_p] } {
    $place rdb.self-id
    $place set extra.city       $venue_city
    $place set extra.country    $venue_country
    $place rdb.self-insert
    set place_id [$place set id]
} else {
    set place_id [[$placedata head] set id]
}

$o set place_id             $place_id
$o set venue_name           $venue_name
$o set venue_address        $venue_address
$o set venue_city           $venue_city
$o set venue_country        $venue_country
$o set venue_homepage_url   $venue_homepage_url
$o set venue_phone          $venue_phone
$o set venue_postal_code    $venue_postal_code
$o set venue_description    $venue_description
$o set venue_private_p      $venue_private_p
$o set ts_vector            $ts_vector

$o set creation_user        $user_id
$o set creation_ip          $peeraddr
$o set modifying_user       $user_id
$o set modifying_ip         $peeraddr

$o rdb.self-insert
$o endTransaction

set id [$o set id]

ns_return 200 text/html [::util::map2json b:success true M:data "s:venue_id ${id} s:venue_name ${venue_name} s:venue_address ${venue_address} s:venue_city ${venue_city} s:venue_country ${venue_country}"]