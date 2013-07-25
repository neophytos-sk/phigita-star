ad_page_contract {
  realtime user list for a chat room

  @author Peter Alberer (peter.alberer@wu-wien.ac.at)
  @creation-date Mar 10, 2006
} {
  id
  s
}

::app::Chat c1 -volatile -chat_id $id -session_id $s
set output [c1 html_active_user_list]

ns_return 200 text/html "
<HTML>
<style type='text/css'>
#users { font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#users .user {text-align: left; vertical-align: top; }
</style>
<body>
<table id='users'><tbody>$output</tbody></table>
</body>
</HTML>"
