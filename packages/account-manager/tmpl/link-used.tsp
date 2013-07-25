ad_page_contract {
    @author Neophytos Demetriou
} {
    token:trim,notnull
}

set inv_id ""
set payload ""
lassign [split ${token} -] inv_id payload

if {![db_0or1row get_invitation_info "select * from xo__friend_invite_tokens t join users u on (t.friend_id=u.user_id) where invite_id=:inv_id and token=:payload"]} {
    ad_returnredirect link-broken
    return
}

tmpl::simple -title "Link Already Used" {

  blockquote {
    b {
	t "Link Already Used"
    }
    p
    t -disableOutputEscaping [format { 
	The link you followed to create a phigita.net account has already been
	used to create an account for <b><i>%s</i></b>. Now, its account creating powers are all gone. To create another phigita.net account, 
    	you'll need a shiny new account creation link. We apologize for the 
    	inconvenience. If you've already created a phigita.net account,  go to the <a class="fl" href="/accounts/?email=%s">login</a> page.} ${screen_name} ${screen_name}]
  }


}
