ad_page_contract {
    Toggle translator mode on/off.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date October 24, 2002
    @cvs-id $Id: translator-mode-toggle.tcl,v 1.1 2002/10/25 15:12:15 peterm Exp $
} {
    {return_url "."}
}

lang::util::translator_mode_set [expr ![lang::util::translator_mode_p]]

ad_returnredirect $return_url

