<!--	
	template for assigning cal_item permissions
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Jan 14, 2000
     	@cvs-id $Id: cal-item-permissions.adp,v 1.6 2002/11/07 12:45:12 peterm Exp $
-->

<master>
<property name="title">#calendar.lt_Calendar_Item_Adminis# </property>
<property name="context"> #calendar.lt_Calendar_Item_Permiss# </property>

<if @action@ eq list>
  <table>
    <tr>
       <td>
        <p>
          <b> #calendar.Audiences_for_item#: @cal_item_name@ </b>
        </p>
	
        <if @audiences:rowcount@ eq 0>
          <p>
            <i>#calendar.lt_There_are_no_audience#
          </p>
        </if>

        <else>
          <p>
            <ul>
            <multiple name=audiences>
	      <li> 
              <a href="cal-item-permissions?cal_item_id=@cal_item_id@&party_id=@audiences.party_id@&action=view">
                @audiences.name@            
	      </a>
              </li>
            </multiple>
            </ul>
          </p>
        </else>

        <a href="cal-item-permissions?cal_item_id=@cal_item_id@&action=add">
          #calendar.Add_a_new_Audience#
        </a>	
    
      </td>
    </tr>
  </table>

</if>



<if @action@ eq view>
<b> #calendar.Current_Permissions# </b>

<if @privileges:rowcount@ eq 0>
  <p>		
    <li>#calendar.lt_no_privilege_has_been#
  </p>
</if>

<else>
  <p>
    <ul>
    <multiple name=privileges>	 
      <li>@privileges.privilege@  
	[<a href="cal-item-permissions?cal_item_id=@cal_item_id@&action=revoke&party_id=@party_id@&permission=@privileges.privilege@">            #calendar.revoke#
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
  <form action=cal-item-permissions method=post>
    <input type=hidden name=action value=edit>
    <input type=hidden name=cal_item_id value=@cal_item_id@>
 
    <if @action@ ne add>
      <input type=hidden name=party_id value=@party_id@>
    </if>

    <table>
      <tr>
        <td>
          <input type=submit value="#calendar.Grant#">
        </td>

        <td>
          <if @cal_item_permissions:rowcount@ eq 0>
            <li>#calendar.lt_no_privilege_exist_co#
          </if>

          <else>
            <select name=permission>
              <multiple name=cal_item_permissions>	 
                <option value=@cal_item_permissions.privilege@>@cal_item_permissions.privilege@
              </multiple>
            </select>
          </else>
	
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











