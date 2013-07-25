
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ${user_id} == 0 } {
    set admin_p f
} else {
    set admin_p [permission::permission_p -object_id ${package_id} -party_id ${user_id} -privilege admin]
}

set bbdata [::db::Set new -type ::bboard::Message -order "creation_date desc" -limit 100]
$bbdata load

::tmpl::master -docStyleId doc2 -docStyleClass z-t2 -title "BBoard" -context_bar [ad_context_bar Administration] {

    div -id bd {
	div -id z-main {
	    div -class z-b {
		div -class z-gc {
		    div -class "z-u first" {

			if { $admin_p } {
			    b {
				t "\[ "
				a -class fl -href "message-one" {
				    t "Post a message"
				}
				t " | "
				a -class fl -href "types/" {
				    t "Message Types"
				}
				t " \]"
			    }
			}

			p
			
			h3 { t "Recently posted messages" }
			ul {
			    if { [$bbdata emptyset_p] } {
				li { t "None Yet" }
			    } else {
				foreach o [$bbdata set result] {
				    li {
					a -href ../message/[$o set id] {
					    t [$o set title]
					}
					if { $admin_p } {
					    t " -  \[ "
					    a -class fl -href message-status-toggle?id=[$o set id] {
						if { [$o set live_p] } {
						    t "hide"
						} else {
						    t "show"
						}
					    }
					    t " | "
					    a -class fl -href message-delete?id=[$o set id] {
						t "delete"
					    }
					    t " | "
					    t "edit"
					    t " \]"
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}