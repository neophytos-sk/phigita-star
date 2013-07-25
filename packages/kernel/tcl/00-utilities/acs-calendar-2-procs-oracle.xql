<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dt_widget_week.select_week_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as day_of_the_week,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday')) 
as sunday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday'),'J') 
as sunday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 1) 
as monday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 1,'J') 
as monday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 2) 
as tuesday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 2,'J') 
as tuesday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 3) 
as wednesday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 3,'J') 
as wednesday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 4) 
as thursday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 4,'J') 
as thursday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 5) 
as friday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 5,'J') 
as friday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 6) 
as saturday_date,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday') + 6,'J') 
as saturday_julian,
to_date(:current_date,'yyyy-mm-dd') - 7 as last_week,
to_char(to_date(:current_date, 'yyyy-mm-dd') - 7,'Month DD, YYYY') as last_week_pretty,
to_date(:current_date,'yyyy-mm-dd') + 7 as next_week,
to_char(to_date(:current_date, 'yyyy-mm-dd') + 7,'Month DD, YYYY') as next_week_pretty
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
