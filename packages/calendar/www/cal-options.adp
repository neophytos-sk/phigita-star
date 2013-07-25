<!--	
	The template for display a list of calendars that
        the user wants to see.
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Dec 14, 2000
     	@cvs-id $Id: cal-options.adp,v 1.3 2002/06/03 04:08:17 ben Exp $
-->

<if @calendars:rowcount@ gt 1>
<ul>
<multiple name="calendars">
<li> @calendars.calendar_name@
</multiple>
</ul>
</if>
