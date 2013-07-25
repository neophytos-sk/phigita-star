<!--	
	Displays the basic UI for the calendar
	
	@author Gary Jin (gjin@arsidigta.com)
     	@creation-date Dec 14, 2000
     	@cvs-id $Id: cal-item-delete-confirm.adp,v 1.8 2002/11/07 12:45:07 peterm Exp $
-->


<master>
<property name="title">#calendar.Calendar_Item_Delete#: @cal_item.name@</property>
<property name="context">#calendar.Delete#</property>

<table>

  <tr>
    <td valign=top>
      <p>
      @cal_nav@
    </td>	

    <td valign=top> 
    <table>
    <tr><td colspan=2><blockquote>@cal_item.description@</blockquote></td></tr>
    <tr><th align=right>#calendar.Date_1#<if @cal_item.no_time_p@ eq 0> #calendar.and_Time#</if>:</th><td><a href="./view?view=day&date=@cal_item.start_date@">@cal_item.pretty_short_start_date@</a><if @cal_item.no_time_p@ eq 0>, #calendar.from# @cal_item.start_time@ #calendar.to# @cal_item.end_time@</if></td></tr>
    <tr><th align=right>#calendar.Title#</th><td>@cal_item.name@</td></tr>
    <if @cal_item.item_type@ not nil><tr><th align=right>#calendar.Type#</th><td>@cal_item.item_type@</td></tr></if>
    </table>
    <p>
<if @cal_item.recurrence_id@ not nil>
<b>#calendar.lt_This_is_a_repeating_e#</b>#calendar._You_may_choose_to#
<ul>
<li> <a href="cal-item-delete?cal_item_id=@cal_item_id@&confirm_p=1">#calendar.lt_delete_only_this_inst#</a>
<li> <a href="cal-item-delete-all-occurrences?recurrence_id=@cal_item.recurrence_id@">#calendar.lt_delete_all_occurrence#</a>
</ul>
</if>
<else>
#calendar.lt_Are_you_sure_you_want_1#
<ul>
<li> <a href="cal-item-delete?cal_item_id=@cal_item_id@&confirm_p=1">#calendar.yes_delete_it#</a>
<li> <a href="cal-item-view?show_cal_nav=@show_cal_nav@&cal_item_id=@cal_item_id@">#calendar.no_keep_it#</a>
</ul>
</else>
    </td>
  </tr>
</table>


