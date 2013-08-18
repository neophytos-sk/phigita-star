#/packages/lang/www/test.tcl
ad_page_contract {

    Tests procedures in the lang package

    @author John Lowry (lowry@ardigita.com)
    @creation-date 29 September 2000
    @cvs-id $Id: catalog-test.tcl,v 1.1 2002/10/07 14:32:49 lars Exp $
} { }

set title "Test acs-lang package message catalog and locale API"
set header [ad_header $title]
set context_bar [ad_context_bar "Message Catalog Test"]
set footer [ad_footer]

# Test 1 verifies that the message catalog has loaded successfully
set english [_ en test.English]
set french  [_ fr test.French]
set spanish [_ es test.Spanish]
set german  [_ de test.German]


set locale [ad_locale user locale]
#set locale "ja_JP"

set language [ad_locale user language]
#set language ja

set language_name [ad_locale_language_name $language]



ad_return_template