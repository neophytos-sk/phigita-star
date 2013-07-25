tmpl::master {

    p

    t "The login page has expired. Please "
    a -href "/accounts/" { t "login" }
    t " again."

    p

    font -size -1 {
	table -cellpadding 5 -cellspacing 1 -border 1 {
	    tr {
		td -bgcolor "#ffffcc" {
		    b { t "Note:" }
		    t "For security reasons, the login page expires after a certain interval to prevent malicious attackers from logging in as you using cached browser passwords."
		}
	    }
	}
    }
}
