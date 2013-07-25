
<if @browsing_history_exists_p@ eq 1>
<list name="browsing_history">
<li><a href="<%=[lindex @browsing_history:item@ 0]%>"><%=[lindex @browsing_history:item@ 1]%></a>
</list>
</if>