<!--	
	The template for creating the calendar
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Jan 09, 2000
     	@cvs-id $Id: one.adp,v 1.6 2002/11/07 12:45:12 peterm Exp $
-->


<master>
<property name="title">#calendar.lt_Calendar_Administrati#: @title@ </property>
<property name="context">@context@</property>

<if @action@ eq view>
	#calendar.lt_Calendar_detail_listi#
</if>


<if @action@ eq delete>
<table>
<tr>
  <td>
    <include src="calendar_edit">

  </td>
</tr>
</table>
</if>



<if @action@ eq permission>
<table>
<tr>
  <td>
    <p>
      <b> #calendar.lt_Audiences_for_calenda#: @calendar_name@ </b>
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
              <a href="calendar-permissions?calendar_id=@calendar_id@&party_id=@audiences.party_id@">
            @audiences.name@            
	      </a>
          </multiple>
        </ul>
      </p>
    </else>

    <a href="calendar-permissions?calendar_id=@calendar_id@&action=add">
      #calendar.Add_a_new_Audience#
    </a>	
    
  </td>
</tr>
</table>
</if>



<else>
  <if @action@ eq add>
    <p>

    <b>#calendar.DEVELOPER_NOTE#</b>

    #calendar.lt_the_calendar_creation#

    <ol>
      <li> #calendar.lt_create_the_calendar_o#
      <li> #calendar.lt_select_groups_andor_u#
      <li> #calendar.lt_apply_group_user_spec#
    </ol>

    </p>

    <form action="calendar-create" method=post>
      <input type=hidden name=party_id value=@party_id@>

  </if>

  <if @action@ eq edit>
    <form action="calendar-edit" method=post>
      <input type=hidden name=calendar_id value=@calendar_id@>
      <input type=hidden name=party_id value=@party_id@>
  </if>

  <table>
		
    <tr>
      <td valign=top align=right>
	<b> #calendar.Calendar_Name# </b>
      </td>

      <td valign=top align=left>
	<if @action@ eq edit>
	  <input type=text size=60 name=calendar_name maxlength=200 value="@calendar_name@">     
	</if>
	<else>
	  <if @action@ eq add>
   	    <input type=text size=60 name=calendar_name maxlength=200>     
	  </if>
	</else>
      </td>
    </tr>

    <tr>
      <td valign=top align=right>
	<b> #calendar.Calendar_Permissions_1# </b>
      </td>

      <td valign=top align=left>
	<select name=calendar_permission>
	  <if @action@ eq edit>
	    <option value="@calendar_permission@" selected> @calendar_permission@
	  </if>
	  <option value="private"> #calendar.private#
	  <option value="public"> #calendar.public#
	</select>	
      </td>
    </tr>

    <tr>
      <td colspan=2 valign=top align=left>

	<ul>
	  <li><b>#calendar.Public#</b> #calendar.lt_everyone_have_read_pe#
	  <li><b>#calendar.Private#</b> #calendar.lt_only_those_you_choose#
	</ul>
      </td>	
    </tr>

    <tr>
      <td colspan=2 valign=top align=left>
	<input type=submit value="#calendar.Submit_query#">
      </td>		
    </tr>
		
  </table>

  <p>
    <a href="one?calendar_id=@calendar_id@&action=permission"> 
      #calendar.lt_Manage_Calendar_Audie#
    </a>
  </p>

</form>
</else>

