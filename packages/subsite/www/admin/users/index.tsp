set base "http://www.phigita.net"
set interval "14 days"

set userdata [::db::Set new -type CC_Users -where [list "last_visit is not null" "current_timestamp-last_visit< '${interval}'::interval"] -order "last_visit desc"]
$userdata load

tmpl::simple -title "Users (in last $interval)" {
    t "Num Users (in last $interval): [llength [$userdata set result]]"
    ul {
	foreach o [$userdata set result] {
	    li {
		a -href "${base}/~[$o set screen_name]/" { 
		    t "[$o set first_names] [$o set last_name]"
		}
		t " ([$o set screen_name])"
		ul {
		    li { t "User ID: [$o set user_id]" } 
		    li { t "Last visit: [$o set last_visit]" }
		    li { t "Number of sessions: [$o set n_sessions]" }
		}
	    }
	}
    }
}