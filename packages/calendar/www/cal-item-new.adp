<master>
<property name="title">#calendar.Calendar_Add_Item#</property>
<property name="context">#calendar.Add#</property>
<property name="focus">cal_item.title</property>

<table width="95%">

  <tr>
    <td valign=top width=150>
      <p>
      @cal_nav@
      <p>
	<include src="cal-options">	
    </td>	

    <td valign=top> 
    
    <formtemplate id="cal_item"></formtemplate>

    </td>
  </tr>
</table>
</if>

