<master>
<property name="title">#calendar.Calendar_Item_Types#</property>
<property name="context">@context@</property>

<ul>
<%
foreach item_type $item_types {
        set item_type_id [lindex $item_type 1]
        set type [lindex $item_type 0]

        if {[empty_string_p $item_type_id]} {
            continue
        }

      template::adp_puts "<li> \[ <a href=\"item-type-delete?calendar_id=$calendar_id&item_type_id=$item_type_id\">delete</a> \]  &nbsp; $type</li>\n"
}
%>
</ul>
<form method="post" action="item-type-new">
<input type="hidden" name="calendar_id" value="@calendar_id@" />
#calendar.New_Type# <input type="text" name="type" size="40" />
<input type="submit" value="#calendar.add#" />
</form>


