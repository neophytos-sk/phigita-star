ad_page_contract {
    @author Neophytos Demetriou
} {
    screen_name:trim
    email:trim,notnull
}

tmpl::simple -title "Email Already Used" {

  blockquote {
  b {
    t "Email Already Used"
  }

  p
  t -disableOutputEscaping [format "The link you followed to create a phigita.net account is OK but it seems that <i>%s</i> has already been used to create a phigita.net account." ${email}]

  ul {
    li {
      t "If you forgot your password, try the "
      a -href "/accounts/forgotten-password" {
	t "Forgotten Password Self-Service"
      }	
      t "."
    }
    br
    if {[string equal ${screen_name} ""]} {
      li {
        t "If you want to set up your login name, then click "
	a -href "/my/nickname-setup" {
          t "here"
        }
	t "."
      }
    }
  }
}

}