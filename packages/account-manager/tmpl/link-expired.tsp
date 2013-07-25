tmpl::simple -title "You're too late... this link has expired" {

  blockquote {
    b {
      t "Link Expired"
    }

    p

    t "The link you followed to this page seems to be stale. Since the link has passed its expiration date, it's no longer valid for a phigita.net account. If you'd still like to sign up for phigita.net, you'll need to get a fresh account creation link. We apologize for the inconvenience."
    p
    t "If you've already created a phigita.net account, go to the "
    a -href "/accounts/" {
       t "login"
    }
    t " page."
  }

}