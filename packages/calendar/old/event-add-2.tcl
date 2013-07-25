ad_page_contract {
    @author Neophytos Demetriou
} {
    title:trim,notnull
    venue:trim,notnull
    date:trim,notnull
    time_p:boolean,notnull
    {start_time.hours:integer,trim,notnull "00"}
    {start_time.minutes:integer,trim,notnull "00"}
    {end_time.hours:integer,trim,notnull "23"}
    {end_time.minutes:integer,trim,notnull "59"}
    description:trim,notnull
    event_type_id:integer,notnull
}

set start_date "$date [util::pad ${start_time.hours} 2]:[util::pad ${start_time.minutes} 2]"
set end_date "$date [util::pad ${end_time.hours} 2]:[util::pad ${end_time.minutes} 2]"

set pathexp [list Subsite [ad_conn subsite_id]]
set o [::sw::agg::Event new \
	   -mixin ::db::Object \
	   -pathexp $pathexp]

$o set title $title
$o set venue $venue
$o set start_date $start_date
$o set end_date $end_date
$o set description $description
$o set event_type_id $event_type_id

doc_return 200 text/html [$o info vars]
#ad_returnredirect .