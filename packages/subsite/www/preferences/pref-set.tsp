ad_page_contract {
    @author Neophytos Demetriou
} {
    {hl "en"}
    {return_url ""}
}

ad_set_cookie -max_age inf PREF "LD=${hl}"

#ad_set_cookie -max_age inf PREF [join "LD=${hl} NR=[ad_conn PREF_NR] TZ=[ad_conn PREF_TZ]" ":"]

throw REDIRECT ${return_url}
