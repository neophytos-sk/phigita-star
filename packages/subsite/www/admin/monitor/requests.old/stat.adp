<master>
<property name="title">@title@</property>

<table style="border: 1px solid blue; padding: 10px;">
  <tr><td><b>@active_user_label;noquote@</b></td><td>@active_users_10@</td></tr>
  <tr><td><b>Current System Activity:</b></td><td>@current_system_activity@</td></tr>
  <tr><td><b>Current System Load:</b></td><td>@current_load@</td></tr>
  <tr><td><b>Current Avg Response Time/sec:</b></td><td>@current_response@</td></tr>
  <tr><td colspan="2"><a href='stat-details'>Details</a></td></tr>
</table>

<br>

<h3 style='text-align: center;'>Page View Statistics</h3>
<div style="padding: 00px;">@views_trend;noquote@</div><p>

<h3 style='text-align: center;'>Active Users</h3>
<div style="padding: 00px;">@users_trend;noquote@</div><p>

<h3 style='text-align: center;'>Avg. Response Time in milliseconds</h3>
<div style="padding: 00px;">@response_trend;noquote@</div>

<div style="padding: 00px;">@throttle_stats;noquote@</div>
