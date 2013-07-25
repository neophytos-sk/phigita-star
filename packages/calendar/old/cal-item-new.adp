<master>
<if @ad_form_mode@ eq display>
  <property name="title">#calendar.Calendar_Edit_Item#</property>
  <property name="context">#calendar.Edit#</property>
  <property name="focus">cal_item.title</property>
</if>
<else>
  <property name="title">#calendar.Calendar_Add_Item#</property>
  <property name="context">#calendar.Add#</property>
  <property name="focus">cal_item.title</property>
</else>
<property name="onload">TimePChanged()</property>
<property name="header_stuff">
  <link href="/resources/calendar/calendar.css" rel="stylesheet" type="text/css">
</property>


<script language="JavaScript">
    function disableTime(form_name) {
          <multiple name="time_format_elms">
            document.forms[form_name].elements["start_time.@time_format_elms.name@"].disabled = true;
            document.forms[form_name].elements["end_time.@time_format_elms.name@"].disabled = true;
          </multiple>
    }
    function enableTime(form_name) {
          <multiple name="time_format_elms">
            document.forms[form_name].elements["start_time.@time_format_elms.name@"].disabled = false;
            document.forms[form_name].elements["end_time.@time_format_elms.name@"].disabled = false;
          </multiple>
    }
    function TimePChanged(elm) {
      var form_name = "cal_item";

      if (elm == null) return;
      if (document.forms == null) return;
      if (document.forms[form_name] == null) return;
      if (elm.value == 0) {
         disableTime(form_name);
      } else {
         enableTime(form_name);
      }
  }
</script>

  <div id="viewadp-mini-calendar">
    <include src="mini-calendar" base_url="view" view="@view@" date="@ansi_date@">
  </div>
        
  <div id="events">   
    <formtemplate id="cal_item"></formtemplate>
  </div>


<script language="JavaScript">
  // TimePChanged();
  @js;noquote@
</script>

