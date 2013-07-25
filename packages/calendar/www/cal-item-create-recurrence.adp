<!--	
	Displays the basic UI for the calendar
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Dec 14, 2000
     	@cvs-id $Id: cal-item-create-recurrence.adp,v 1.11 2002/11/07 12:45:07 peterm Exp $
-->


<master>
<property name="title">#calendar.lt_Calendars_Repeating_E#</property>
<property name="context">#calendar.Repeat#</property>

#calendar.lt_You_are_choosing_to_m#
<p>
<b>#calendar.Date#</b> @cal_item.start_date@<br>
<b>#calendar.Time#</b> @cal_item.start_time@ - @cal_item.end_time@<br>
<b>#calendar.Details#</b> @cal_item.description@
<p>

<FORM method=post action=cal-item-create-recurrence-2>
<INPUT TYPE=hidden name=cal_item_id value=@cal_item.cal_item_id@>
<INPUT TYPE=hidden name=return_url value="@return_url@">

#calendar.Repeat_every# <INPUT TYPE=text name=every_n value=1 size=3>:<br>
<INPUT TYPE=radio name=interval_type value=day> #calendar.day_s#<br>
<INPUT TYPE=radio name=interval_type value=week> 
<%
foreach dow [list [list "#calendar.Sunday#" 0] [list "#calendar.Monday#" 1] [list "#calendar.Tuesday#" 2] [list "#calendar.Wednesday#" 3] [list "#calendar.Thursday#" 4] [list "#calendar.Friday#" 5] [list "#calendar.Saturday#" 6]] {
        if {[lindex $dow 1] == [expr "$cal_item(day_of_week) -1"]} {
                set checked_html "CHECKED"
        } else {
                set checked_html ""
        }

        template::adp_puts "<INPUT TYPE=checkbox name=days_of_week value=[lindex $dow 1] $checked_html>[lindex $dow 0] &nbsp;"
}
%>
#calendar.of_the_week# <br>
<INPUT TYPE=radio name=interval_type value=month_by_date> #calendar.day#
@cal_item.day_of_month@ #calendar.of_the_month# <br>
<INPUT TYPE=radio name=interval_type value=month_by_day> #calendar.same# @cal_item.pretty_day_of_week@ #calendar.of_the_month# <br>
<INPUT TYPE=radio name=interval_type value=year> #calendar.year#<br>
#calendar.lt_Repeat_this_event_unt# <%= [dt_widget_datetime -default [dt_systime] recur_until] %>
<p>
<INPUT TYPE=submit value="#calendar.Add_Recurrence#">

</FORM>

