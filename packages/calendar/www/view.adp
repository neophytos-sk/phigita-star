<% 

	set context_bar [ad_context_bar] 
	set title [_ Calendar Calendar]

%>

<master>
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

 
@navbar@  
<table width="600">

  <tr>	

    <td valign=top>@cal_stuff@
    </td>
    <td valign=top width=150>
      <p>
      @cal_nav@
      <p>
	<include src="cal-options">	
    </td>
  </tr>
</table>
</if>

