<master>
<property name="title">#calendar.lt_Calendar_Administrati#: @party_name@ </property>
<property name="context">#calendar.Calendar_Permissions#</property>


<if @action@ eq view>
<b> #calendar.Current_Permissions# </b>

<if @privileges:rowcount@ eq 0>
  <ul>		
    <li>#calendar.lt_no_privilege_has_been#
  </ul>
</if>

<else>
  <p>
    <ul>
    <multiple name=privileges>	 
      <li>@privileges.privilege@  
	[<a href="calendar-permissions?calendar_id=@calendar_id@&action=revoke&party_id=@party_id@&permission=@privileges.privilege@">            
	  #calendar.revoke#
	 </a>]</li>
    </multiple>
    </ul>
  </p>
</else>
</if>

<if @action@ eq view or @action@ eq add>
<!-- simple UI to grand permission -->
<b> #calendar.Grant_Permissions# </b>
<p>
<form action=calendar-permissions method=post>
<input type=hidden name=action value=grant>
<input type=hidden name=calendar_id value=@calendar_id@>

<if @action@ ne add>
  <input type=hidden name=party_id value=@party_id@>
</if>

<table>
  <tr>
    <td>
      <input type=submit value="#calendar.Grant#">
    </td>

    <td> 
      <select name=permission>

      <if @calendar_permissions:rowcount@ eq 0>
        <li>#calendar.lt_no_privilege_exist_co#
      </if>
 
      <else>
        <multiple name=calendar_permissions>	 
          <option value=@calendar_permissions.privilege@>@calendar_permissions.privilege@
        </multiple>
      </else>
	
      </select>
    </td>

    <td>
      <if @action@ eq add>
	#calendar.to#
        <if @parties:rowcount@ eq 0>
          <li> #calendar.lt_no_parties_exist_cont#
        </if>
     
        <else>
          <select name=party_id>
            <multiple name=parties>
    	      <option value=@parties.party_id@> @parties.pretty_name@
	    </multiple>
          </select>
        </else>
      </if>	
    </td>	
  </tr>
</table>
</form>

</if>











