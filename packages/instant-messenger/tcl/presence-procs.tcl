proc getStatusImg {user_id status} {
    if {[ad_conn user_id]} {
	if { ${status} eq {available} } {
	    return "<a href=http://my.phigita.net/im/ border=0 title=\"$status\"><img src=/graphics/im/${status}.gif width=13 height=13 border=0></a>"
	}
    }
    return
}

  proc allUsersDisconnect {} {
      ns_log notice "Messenger: Disconnecting all users..."
      set conn [DB_Connection new]
      $conn do "update users set status='disconnected'"
      $conn destroy
  }


if { [ns_config ns/server/[ns_info server] is_chat_p 0] } {
    ns_atshutdown allUsersDisconnect
}