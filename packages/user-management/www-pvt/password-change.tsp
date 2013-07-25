::xo::kit::require_secure_conn

ad_page_contract {

    Let's the user change his/her password.  Asks
    for old password, new password, and confirmation.

}

set user_id [ad_conn user_id]

db_1row user_information "select first_names, last_name, email, url from cc_users where user_id=:user_id"


tmpl::master -title "${first_names} ${last_name} > Change your password" -context_bar [ad_context_bar "Change your password"] {

    small {

	t "You are currently logged in as "
	b {
	    t ${email}
	}

	t "."

	p

	form -method "POST" -action "password-change-2" {
	    input -type hidden -value "${user_id}"
	
	    table -bgcolor efefef {
		tr {
		    th { t "Current password:" }
		    td {
			input -type password -name password_old -size "15"
		    }
		}

		tr {
		    th { t "New password:" }
		    td {
			input -type "password" -name "password_1" -size "15"
		    }
		}
		tr {
		    th { t "Confirm:" }
		    td { 
			input -type password -name password_2 -size 15
		    }
		}
		tr {
		    td -colspan 2 -align center {
			br
			input -type submit -value "Change"
		    }
		}
	    }
	}
    }
}
