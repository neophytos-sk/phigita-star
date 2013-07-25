if { ![ns_config ns/server/[ns_info server] is_chat_p 0] } { return }

ad_library {
    XoWiki - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @cvs-id $Id: chat-procs.tcl,v 1.7 2006/04/09 00:07:10 gustafn Exp $
}
namespace eval ::app {
  ::xo::ChatClass Chat -superclass ::xo::Chat

  Chat instproc render {} {
    my orderby time
    set result ""
    foreach child [my children] { 
      set msg       [$child msg]
      set user_id   [$child user_id]
      set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]

      #[clock scan {2008-03-13 17:10:11} -format {%Y-%m-%d %H:%M:%S} -timezone :UTC]
      #clock format $s -format {%H:%M:%S} -timezone :Europe/Athens

      if {$user_id > 0} {
	acs_user::get -user_id $user_id -array user
	set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]
	set url "http://www.phigita.net/~$user(screen_name)/"
	set creator "<a target='_blank' href='$url'>$name</a>"
      } else {
	set creator "Nobody"
      }
      append result "<TR><TD class='timestamp'>$timeshort</TD>\
	<TD class='user'>[my encode $creator]</TD>\
	<TD class='message'>[my encode $msg]</TD></TR>\n"
    }
    return $result
  }

  Chat proc initialize_nsvs {} {;}      ;# noop



    Chat instproc html_active_user_list {} {
      set output ""
	foreach {user_id timestamp} [nsv_array get [my set array]-last-activity] {
	    if {$user_id > 0} {
              acs_user::get -user_id $user_id -array user
		set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]
              append output "<TR><TD>$name</TD></TR>\n"
	    }
	}
      return $output
    }

    Chat instproc active_users {} {
	return [expr { [llength [nsv_array get [my set array]-last-activity]] / 2 }]
    }


  Chat proc login {-chat_id -package_id -mode} {
      #my log "--"
    #auth::require_login
    if {![info exists package_id]} {set package_id [ad_conn package_id] }
    if {![info exists chat_id]}    {set chat_id $package_id }
    set context id=$chat_id&s=[ad_conn session_id].[clock seconds]
    #set path    [site_node::get_url_from_object_id -object_id $package_id]
    set path .
      set user_id [ad_conn user_id]

    if {![info exists mode]} {
      set mode polling
	if {[info command ::thread::mutex] ne {}} {
	    # we seem to have libthread installed, we can use the background delivery thread
	    # scripted streaming should work everywhere
	    set mode scripted-streaming
	    set user_agent [string tolower [ns_set get [ns_conn headers] User-Agent]]
	    #ns_log notice "chat user_agent= $user_agent"
	    if {[string match *gecko* ${user_agent}]} {
		# for firefox, we could use the nice mode without the spinning load indicator
		set mode streaming
	    }
	}
	#my log "--mode $mode"
    }


      switch $mode {
	  polling {
	      set jspath packages/instant-messenger/lib/chat.js
	      set login_url ${path}/ajax/chat?m=login&$context
	      set users_url $path/ajax/users?$context
	      set get_update  "chatSendCmd(\"$path/ajax/chat?m=get_new&$context\",chatReceiver)"
	      set get_all     "chatSendCmd(\"$path/ajax/chat?m=get_all&$context\",chatReceiver)"
	  }
	  streaming {
	      set jspath packages/instant-messenger/lib/streaming-chat.js
	  }
	  scripted-streaming {
	      append context &mode=scripted-streaming
	      set jspath packages/instant-messenger/lib/scripted-streaming-chat.js
	  }
      }
      set subscribe_url ${path}/ajax/chat?m=subscribe&$context
      set adjust_url ${path}/ajax/chat?m=adjust_buffer_size&$context
      set send_url  ${path}/ajax/chat?m=add_msg&$context&msg=
      set logout_url ${path}/ajax/chat?m=logout&$context
      set status_url ${path}/ajax/chat?m=status&$context&msg=

    if { ![file exists [acs_root_dir]/$jspath] } {
      return -code error "File [acs_root_dir]/$jspath does not exist"
    }
    set file [open [acs_root_dir]/$jspath]; set js [read $file]; close $file

    switch $mode {
      polling {return "\
      <script type='text/javascript' language='javascript'>
      $js
      setInterval('$get_update',5000)
      var sendconn = new DataConnection;
      sendconn.handler=messagesReceiver;

function ichatPostLoad () {
    var div = frames\['ichat'\].document.getElementById('messages');
    frames\['ichat'\].window.scrollTo(0,div.offsetHeight);
}
function pausecomp(millis)
{
    date = new Date();
    var curDate = null;

    do { var curDate = new Date(); }
    while(curDate-date < millis);
}
function keypressHandler(kc){
    if (kc==13) {
        sendconn.chatSendMsg(\"$send_url\");
    }
    return kc!=13;
}


      </script>
      <form action='#' onsubmit='sendconn.chatSendMsg(\"$send_url\"); return false;'>
      <iframe name='ichat' id='ichat' frameborder='0' src='$login_url'
style='width:70%; border:1px solid black; padding:2px; margin-right:10px;' height='250' onload='ichatPostLoad();'>
      </iframe>
      <iframe name='ichat-users' id='ichat-users' frameborder='0' src='$users_url'
style='width:25%; border:1px solid black; padding:2px;' height='250'>
      </iframe>
      <input type='text' size='80' name='msg' id='chatMsg' autocomplete='off'  onkeypress=\"return keypressHandler(event.keyCode);\">
      </form>
      <script type='text/javascript' language='javascript'>document.getElementById('chatMsg').focus();</script>"
      }
      streaming {return "\
      <script type='text/javascript' language='javascript'>$js

function keypressHandler(kc){
    if (kc==13) {
        chatSendMsg();
    }
    return kc!=13;
}
      var send_url = \"$send_url\";
var status_url = \"$status_url\";
var user_id = \"$user_id\";
var adjust_url= \"$adjust_url\";

      chatSubscribe(\"$subscribe_url\");
      </script>
<table width='100%' cellpadding=3 cellspacing=0>
<tr><td width='70%' valign=top>
<div id='messages' style='margin:1.5em 0 1.5em 0;
padding:1em 0 1em 1em;
background-color: #f9f9f9;
border:1px solid #dedede;
height:150px;
height:250px;
font-size:.95em;
line-height:1.5em;
color:#333;
overflow:auto;
'></div>
   <form action='#' onsubmit='chatSendMsg(); return false;'>
   <input type='text' size='80' name='msg' id='chatMsg' autocomplete='off' onkeypress=\"return keypressHandler(event.keyCode);\">
   </form>
</td><td width='25%' valign=top>
<div id='users' style='margin:1.5em 0 1.5em 0;
padding:1em 0 1em 1em;
background-color: #f9f9f9;
border:1px solid #dedede;
height:150px;
height:250px;
font-size:.95em;
line-height:1.5em;
color:#333;
overflow:auto;
'></div>
Change Status <select id=\"statusNode\"><option value=available onclick=\"chatChangeStatus('available');return false;\">Available</option><option value=busy onclick=\"chatChangeStatus('busy');return false;\">Busy</option><option value=away onclick=\"chatChangeStatus('away');return false;\">Away</option></select>
</td></tr></table>
      <script type='text/javascript' language='javascript'>document.getElementById('chatMsg').focus();</script>"
      }
      scripted-streaming {return "\
      <script type='text/javascript' language='javascript'>
var adjust_url= \"$adjust_url\";
      $js
function keypressHandler(kc){
    if (kc==13) {
        chatSendMsg();
    }
    return kc!=13;
}
function chatSubscribe(){
    var ichat=document.createElement('iframe');
//    ichat.setAttribute(name,'ichat');
//    ichat.setAttribute(id,'ichat');
//    ichat.setAttribute(frameborder,'0');
    document.body.appendChild(ichat);
    ichat.style.cssText='visibility:hidden;width:0px; height:0px; border: 0px;'
    document.getElementById('chatMsg').disabled=false;
    document.getElementById('chatMsg').focus();
    ichat.onreadystatechange=function(){
	if (this.readyState==4 || this.readyState=='complete') {
	    document.getElementById('errdiv').innerHTML='You have been disconnected.';
	}
    }
    ichat.src='$subscribe_url';


}

      var send_url = \"$send_url\";
      var status_url=\"$status_url\";
var user_id = \"$user_id\";

      </script>
<table width='100%' cellpadding=3 cellspacing=0>
<tr><td width='70%' valign=top>
<div id='messages' style='margin:1.5em 0 1.5em 0;
padding:1em 0 1em 1em;
background-color: #f9f9f9;
border:1px solid #dedede;
height:150px;
height:250px;
font-size:.95em;
line-height:1.5em;
color:#333;
overflow:auto;
'></div>
      <form action='#' onsubmit='chatSendMsg(); return false;'>
      <input type='text' size='80' name='msg' id='chatMsg' autocomplete='off' disabled=\"true\" onkeypress=\"return keypressHandler(event.keyCode);\">
      </form>
</td><td width='25%' valign=top>
<div id='users' style='margin:1.5em 0 1.5em 0;
padding:1em 0 1em 1em;
background-color: #f9f9f9;
border:1px solid #dedede;
height:150px;
height:250px;
font-size:.95em;
line-height:1.5em;
color:#333;
overflow:auto;
'></div>
Change Status <select id=\"statusNode\" onchange=\"chatChangeStatus(this.childNodes\[this.selectedIndex\].value);return false;\"><option value=available>Available</option><option value=busy>Busy</option><option value=away onclick=\"chatChangeStatus('away');return false;\">Away</option></select>
</td></tr></table>
<script type='text/javascript' language='javascript'>window.onload=function(){chatSubscribe();}</script>
"
      }
    }
  }
}

