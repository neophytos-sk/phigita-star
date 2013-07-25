<!--	
	The template for user preferences
	

	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Dec 14, 2000
     	@cvs-id $Id: calendar-preferences.adp,v 1.5 2002/11/07 12:45:12 peterm Exp $
-->
<master>
<property name="title">#calendar.lt_Calendar_Administrati#: @party_name@ </property>
<property name="context"> #calendar.Calendar_Preferences# </property>


<table>

  <tr>
    <td width=400 colspan=2 align=center> 
      <b> #calendar.Select_Calendars# </b>
    </td>
  </tr>

  <tr>
    <td width=400 colspan=3 align=left> 
      <b> #calendar.Note# </b> #calendar.lt_The_following_is_a__l#
    </td>
  </tr>

  <if @calendars:rowcount@ eq 0>
    <tr>
      <td colspan=3> 
         #calendar.No_Calendars# 
      </td>
    </tr>
  </if>

  <else>


    <form method=post action="calendar-preferences">
      <input type=hidden name=action value=edit>
     	  
      <multiple name=calendars>
           
        <tr>
           <td align=center> 
	     <if @calendars.show_p@ eq f>
               <input type=checkbox name=calendar_hide_list value="@calendars.calendar_id@" checked>
               <input type=hidden name=calendar_old_list value="@calendars.calendar_id@">	
	     </if>
           
             <else>
		 <input type=checkbox name=calendar_hide_list value="@calendars.calendar_id@">
             </else>
          </td>

          <td align=left>             
	    @calendars.calendar_name@ 
          </td>      
        </tr>
      </multiple>

      <tr>
      <td colspan=2>
        <input type=submit value="#calendar.lt_Hide_Checked_Calendar#">
      </td>	
    </tr>
   </form>

 </else>

</table>
































