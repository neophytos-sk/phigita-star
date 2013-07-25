<!--	
	Template for calendar edit
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Jan 09, 2000
     	@cvs-id $Id: calendar-edit.adp,v 1.3 2002/11/30 17:28:30 jeffd Exp $
-->


<if @action@ eq delete>

  <form action="calendar-edit" method=post>
    <input type=hidden name=calendar_id value=@calendar_id@>
    <input type=hidden name=confirm value=yes>
    <p>	
      #calendar.lt_Are_you_sure_you_want# 
    </p>	

    <input type=submit value="#calendar.Yes_I_am_sure#">	

  </form>
</if>

