ad_page_contract {
    @author Neophytos Demetriou (k2pts@phigita.net)
} {
    user_id:integer
    {return_url "[ad_pvt_home]"}
}

tmpl::simple -title "Λάθος Κωδικός" {

    b {
	t "Problem with Your Input"
    }

    blockquote {
	t "Ο κωδικός που εισήγαγες δεν ταιριάζει με αυτό που έχουμε στη βάση δεδομένων."
    t "Αν νομίζεις ότι δεν τον έγραψες σωστά, παρακαλώ πήγαινε πίσω με τον browser και δοκίμασε ξανά. Αν ξέχασες  τον κωδικό σου, μπορείς να ζητήσεις από το σύστημα να τον επαναρυθμίσει: "
	a -href "forgotten-password" {
	    t "Forgotten Password Self-Service"
	}
    }
    
}


