::xo::html::cssList {actions}

### Echo

if {[ad_conn ctx_uid] > 0} {

    ::xo::html::add_style {
	.permalink {font-size:9px;font-style:italic;color:#888;}
	a.permalink {text-decoration:none;border:none;}
	a.permalink:hover {text-decoration:underline;}
	.msg {
	    background:#ffa;
	    margin-top:5px;
	    padding:5px;
	}
    }
    set user_id [ad_conn ctx_uid]

    set echo_msgs [::db::Set new \
		       -cache "Echo:User_Latest_Message:[ad_conn ctx_uid]-[ad_conn user_id]" \
		       -pathexp [list "User ${user_id}"] \
		       -type ::echo::Message \
		       -order "creation_date desc" \
		       -limit 1 \
		       -noinit]


    set counter [::db::Set new \
		     -cache "Echo:User-${ctx_uid}:COUNT_RECENT_MSGS-[::xo::kit::is_registered_p]" \
		     -pathexp [list "User $ctx_uid"] \
		     -select {{count(1) as count} {max(creation_date) as max_date}} \
		     -type ::echo::Message \
		     -where [list "creation_date > current_timestamp-'48 hours'::interval"] \
		     -noinit]

    if { 0 == [ad_conn user_id] } {
	$echo_msgs lappend where "public_p"
	$counter lappend where "public_p"
    }


    $echo_msgs load
    $counter load


    set count_recent 0
    set max_date ""
    if { ![$counter emptyset_p] } {
	set count_recent [[$counter head] set count]
	set max_date [[$counter head] set max_date]
    }


    if { ![$echo_msgs emptyset_p] } {
	h3 { nt "Latest Echo" }
	set m [$echo_msgs head]
	div {
	    div -class "msg" {
		nt [::xo::structured_text::minitext_to_html [$m set content]]
		br
		a -class permalink -href "echo/[$m set id]" {
		    t "[::util::age_pretty -timestamp_ansi [$m set creation_date] -sysdate_ansi [clock_to_ansi [clock seconds]]]"
		    t " from [$m set device] "
		}
		if { [$m set creation_user] eq [ad_conn user_id] } {
		    span -class actions {
			a -href "http://echo.phigita.net/message-remove?id=[$m set id]&return_url=[util_current_location]" -style "font-size:x-small;" -class fl -onclick "return confirm('Sure you want to delete this update? There is NO undo!');" {
			    t "\[remove\]"
			}
		    }
		}
	    }
	}

	a -class "fl s i" -href "echo/" {
	    t "more echo..."
	}
    }

    if { $count_recent > 0 } {
	tmpl::tag=new -n_items "&nbsp;${count_recent}&nbsp;" -title "${count_recent} echo [ad_decode ${count_recent} 1 update updates] in last 48 hours"
    }

}