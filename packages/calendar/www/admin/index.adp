<!--	
	Displays the basic UI for the calendar
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Dec 14, 2000
     	@cvs-id $Id: index.adp,v 1.6 2002/11/07 12:45:12 peterm Exp $
-->


<master>
<property name="title">#calendar.lt_Calendar_Administrati_1# # @user_id@</property>
<property name="context">@context_bar@</property>


<p>
#calendar.lt_Your_are_in_the_follo# <br>
@data@
</p>

<if @calendars:rowcount@ eq 0>
  <p>
    <i>#calendar.lt_You_have_no_party_wid#</i>
  </p>
</if>

<else>
  <p>
  #calendar.lt_You_can_manage_the_fo#
  <table>
   <multiple name=calendars>
     <tr>
	<td valign=top>
	  <li>[<a href="one?calendar_id=@calendars.calendar_id@&action=edit"> 
             @calendars.calendar_name@ 
           </a>]          	
	</td>
     </tr>	
   </multiple>
  </table>
  </p>
</else>

<p>
<a href="one?party_id=@user_id@&action=add">
#calendar.lt_Create_a_new_calendar#
</a>
</p>


<p>
<a href="calendar-preferences">
#calendar.lt_Edit_your_Calendar_Pr#
</a>
</p>





