<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dt_widget_week.select_week_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as day_of_the_week,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday')
as sunday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday'),'J') 
as sunday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 1
as monday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 1,'J')
as monday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 2
as tuesday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 2,'J') 
as tuesday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 3
as wednesday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 3,'J') 
as wednesday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 4
as thursday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 4,'J') 
as thursday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 5
as friday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 5,'J') 
as friday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 6
as saturday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 6,'J') 
as saturday_julian,
:current_date::timestamp - '7 days'::timespan as last_week,
to_char(:current_date::timestamp - '7 days'::timespan, 'Month DD, YYYY') as last_week_pretty,
:current_date::timestamp + '7 days'::timespan as next_week,
to_char(:current_date::timestamp + '7 days'::timespan, 'Month DD, YYYY') as next_week_pretty
from     dual
</querytext>
</fullquery>

<fullquery name="dt_widget_day.select_day_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'Day, DD Month YYYY') 
as day_of_the_week,
to_char(to_date(:current_date, 'yyyy-mm-dd')-1, 'yyyy-mm-dd')
as yesterday,
to_char(to_date(:current_date, 'yyyy-mm-dd')+1, 'yyyy-mm-dd')
as tomorrow
from     dual
</querytext>
</fullquery>

 
</queryset>
