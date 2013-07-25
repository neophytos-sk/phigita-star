ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id: chat.tcl,v 1.4 2006/04/09 00:07:10 gustafn Exp $
} -query {
  m
  id
  s
  msg:optional,allhtml
  {mode ""}
}

if {0} {
    set user_agent [string tolower [ns_set get [ns_conn headers] User-Agent]]
    ns_log notice "user_agent=$user_agent peeraddr=[ns_conn peeraddr]"
}

ns_set put [ns_conn outputheaders] Cache-Control no-cache
ns_set put [ns_conn outputheaders] Pragma no-cache
ns_set put [ns_conn outputheaders] Expires -1
#ns_set put [ns_conn outputheaders] Transfer-Encoding chunked
#ns_set put [ns_conn outputheaders] Content-Length 1000000

#ns_log notice "--c m=$m session_id=$s [clock format [lindex [split $s .] 1] -format %H:%M:%S] mode=$mode" 
::app::Chat c1 -volatile -chat_id $id -session_id $s -mode $mode
switch -- $m {
    add_msg {
	set msg [ad_quotehtml $msg]
	if { 0 && [string index [string trim ${msg}] 0] eq "/" } {
	    set q [string trim [lrange ${msg} 1 end]]
	    switch -- [string trim [lindex ${msg} 0]] {
		{/to} {
		    set to_user_id [lindex ${msg} 1]
		    messenger do -async Subscriber send_to_user $to_user_id [lrange $msg 2 end]
		}
		{/searchasdflksadflaksdflaksjdflsakjdf} {
		    if { ![namespace exists ::GoogleSearchService] } {
			namespace eval ::GoogleSearchService {
			    set endpoint http://api.google.com/search/beta2
			    set schema http://www.w3.org/2001/XMLSchema
			    SOAP::create doGetCachedPage \
				-proxy $endpoint -params {key string url string} \
				-action urn:GoogleSearchAction \
				-encoding http://schemas.xmlsoap.org/soap/encoding/ \
				-schema [list xsd $schema] \
				-uri urn:GoogleSearch
			    SOAP::create doSpellingSuggestion \
				-proxy $endpoint -params {key string phrase string} \
				-action urn:GoogleSearchAction \
				-encoding http://schemas.xmlsoap.org/soap/encoding/ \
				-schema [list xsd $schema] \
				-uri urn:GoogleSearch
			    SOAP::create doGoogleSearch -proxy $endpoint \
				-params {key string q string start int maxResults int \
					     filter boolean restrict string safeSearch boolean \
					     lr string ie string oe string} \
				-action urn:GoogleSearchAction \
				-encoding http://schemas.xmlsoap.org/soap/encoding/ \
				-schema [list xsd $schema] \
				-uri urn:GoogleSearch
			}; # end of GoogleSearchService
		    }

		    set key "vw5XblRQFHLguLNkCTsCbzzLZEpHG1qd"
		    set args $q
		    array set opts {start 0 max 10 filter false restrict "" safe false lang "" utf-8 utf-8}
		    array set google_search_result [GoogleSearchService::doGoogleSearch $key $args \
							$opts(start) $opts(max) $opts(filter) \
							$opts(restrict) $opts(safe) $opts(lang) utf-8 utf-8]
		    
		    if { [info exists google_search_result(resultElements)] } {
			if { $google_search_result(resultElements) ne {} } {
			    append msg " = [lindex $google_search_result(resultElements) 0]"
			} else {
			    append msg " = Not Found"
			}
		    } else {
			append msg " = Not Found"
		    }
		    
		}
		{/trn} -
		{/translate} {
		    if { ![namespace exists ::BabelFishService] } {
			namespace eval ::BabelFishService {
			    set endpoint http://services.xmethods.net:80/perl/soaplite.cgi
			    SOAP::create BabelFish -proxy $endpoint \
				-params {translationmode string sourcedata string} \
				-action urn:xmethodsBabelFish\#BabelFish \
				-encoding http://schemas.xmlsoap.org/soap/encoding/ \
				-uri urn:xmethodsBabelFish
			}; # end of BabelFishService
		    }
		    set mode [string tolower [lindex $q 0]]
		    set valid_translation_modes {
			"en_zh"
			"en_fr"
			"en_de"
			"en_it"
			"en_ja"
			"en_ko"
			"en_pt"
			"en_es"
			"zh_en"
			"fr_en"
			"fr_de"
			"de_en"
			"de_fr"
			"it_en"
			"ja_en"
			"ko_en" 
			"pt_en"
			"ru_en"
			"es_en"
		    }
		    if { [lsearch -exact $valid_translation_modes $mode] != -1 } {
			append msg " = [::BabelFishService::BabelFish $mode [lrange $q 1 end]]"
		    } else {
			append msg " = Invalid Translation Mode"
		    }
		    
		}
		{/whois} {
		    set o [::db::Set new -volatile -from cc_users -where [list "screen_name=[ns_dbquotevalue ${q}]"] -load]
		    if { ![$o emptyset_p] } {
			append msg " = [[$o head] set first_names] [[$o head] set last_name] ([[$o head] set email])"
		    } else {
			append msg " = Not Found"
		    }
		}
		{/isbn} {
		    set ean13_code [::isbn::convert_to_ean13 ${q}]
		    set o [::db::Set new -volatile -from biblionet -where [list "ean13=[ns_dbquotevalue ${ean13_code}]"] -limit 1 -load]
		    if { ![$o emptyset_p] } {
			append msg " = [join [[$o head] set authorlist] ", "]. \"[string trim [[$o head] set title]]\" [[$o head] set publisher], [[$o head] set year] -- [string range [[$o head] set summary] 0 [expr { [string wordstart [[$o head] set summary] 150] - 1 }]]..."
		    } else {
			
			#source [acs_root_dir]/packages/bookshelf/www-pvt/test.tcl
			::amazon::get_book_info -array book [string map {- {}} $q]
			if { $book(book_title) eq {} || $book(book_author) eq {} } {
			    append msg " = Not Found"
			} else {
			    set title $book(book_title)
			    set authorlist $book(book_author)
			    db_dml update_isbndb "insert into biblionet (title,authorlist,ean13,source) values (:title,:authorlist,:ean13_code,'amazon.com')"
			    append msg " = [join $book(book_author) ", "]. \"$book(book_title)\""
			}
		    }
		    $o destroy
		}
		{/spell} {
		    
		    if { [regexp -- {[a-zA-Z0-9\s]+} ${q}] } {
			set dictionary en
		    } else {
			set dictionary el
		    }
		    
		    
		    set encoding utf-8
		    set mode sgml
		    set o [::SpellChecker new -volatile  \
			       -dictionary ${dictionary} \
			       -encoding ${encoding}     \
			       -mode ${mode}]
		    
		    set correct_p [${o} checkWord ${q}]
		    set wordlist [${o} suggestWord ${q}]
		    append msg " = $wordlist"
		    ${o} destroy
		}
	    }
	}
	
	#ns_log notice "--c call c1 $m '$msg'"
	set _ [c1 $m $msg]
	#ns_log notice "--c add_msg returns '$_'"
    }
    status {
	set _ [c1 $m $msg]
    }
    login -
    subscribe -
    adjust_buffer_size -
    get_new -
    get_all {set _ [c1 $m]}
    default {ns_log error "--c unknown method $m called."} 
}

ns_return 200 text/html $_