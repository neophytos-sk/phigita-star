ad_page_contract {

    Administration of the localized messages

    @author Bruno Mattarollo <bruno.mattarollo@ams.greenpeace.org>
    @creation-date 19 October 2001
    @cvs-id $Id: localized-messages.tcl,v 1.2 2002/10/21 11:39:14 peterm Exp $
}

db_multirow -extend { escaped_locale } locales select_locale_list {
    select locale as locale,
           label as locale_name
    from   ad_locales
} {
    set escaped_locale [ns_urlencode $locale]
}
