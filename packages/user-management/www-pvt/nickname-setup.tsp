ad_page_contract {

    @author Neophytos Demetriou

} {
    {return_url ""}
}

set user_id [ad_conn user_id]

db_1row get_user_info "select email,screen_name,password,url,second_to_last_visit from cc_users where user_id=:user_id"


tmpl::master -title "Set up your screen name" -context_bar [ad_context_bar "Set up your screen name"] {


    if {![string equal ${screen_name} ""]} {
        t -disableOutputEscaping [format "You are currently logged in as <b>%s</b>. You are already known as <b>%s</b>." ${email} ${screen_name}]

    } else {

	table -width 500 {
	    tr {
		td {
		    t -disableOutputEscaping "Please choose a nickname. The nickname is required for you to be able to use services like the instant messenger (or webmail in the future)."
		    p
		    center {
			form -method POST -action nickname-setup-2 {
			    input -type hidden -name return_url -value ${return_url}
			    input -type text -name nickname
			    input -type submit -value Setup
			    p
			    font -color "\#666666" {
				t "min.: 5 chars, max.: 20 chars"
				br
				t "allowed chars: a-z 0-9 _"
			    }
			}
		    }
		}
	    }
	}
    }

}
