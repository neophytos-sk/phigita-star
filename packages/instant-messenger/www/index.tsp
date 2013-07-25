#source [acs_root_dir]/packages/instant-messenger/tcl/10-chat-app-procs.tcl

ns_set put [ns_conn outputheaders] Cache-Control no-cache
ns_set put [ns_conn outputheaders] Pragma no-cache
ns_set put [ns_conn outputheaders] Expires -1

ad_page_contract {
  a tiny chat client
}


tmpl::master -title "Chat-IM" -context_bar [ad_context_bar] -onload {} {

div -id errdiv -style "color:red;margin-left:50px;font-weight:bold;" {
	t " "
}
#t "Exei provlima... To ftiaxno tora. Tha xreiastei na kaneis refresh meta."
style {
	c {
		.online {
			background-image: url(/graphics/im/online.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
		.available {
			background-image: url(/graphics/im/available.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
		.offline {
			background-image: url(/graphics/im/offline.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
		.away {
			background-image: url(/graphics/im/away.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
		.busy {
			background-image: url(/graphics/im/busy.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
		.idle {
			background-image: url(/graphics/im/idle.gif);
			background-repeat: no-repeat; 
			background-position:left;
			padding-left:15px;
		}
	}
}


if { 1 } {
	t -disableOutputEscaping [::app::Chat login -chat_id [ad_conn package_id]]
} else {
	t "Chat upgrade in progress. Come back later."
}


}
